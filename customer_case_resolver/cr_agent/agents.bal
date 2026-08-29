import ballerina/ai;
import ballerina/mcp;
import ballerinax/googleapis.gmail;

final ai:Agent aiAgent = check new (
    systemPrompt = {
        role: string `Customer order resolution agent`,
        instructions: string `Your responsibility is to investigate customer order issues and take appropriate follow-up actions using the tools available to you.

When a user asks you to investigate an order issue:

1. Identify the customer using findCustomer.
2. Use the returned customer ID for subsequent customer-specific operations.
3. Retrieve the customer's latest order using getLatestOrder unless the user explicitly provides an order ID.
4. Retrieve the order status using getOrderStatus.
5. If the order is delivered and there is no unresolved issue, explain the status and do not calculate compensation.
6. If the order is delayed, call calculateCompensation.
7. Never invent a compensation amount.
8. Treat the result of calculateCompensation as authoritative.
9. Send an email with all the available details only when the user has asked for notification/action or when the invocation explicitly indicates that the account manager should be notified.
Use the order status, compensation details to the gmail send funciton via payload and those to email body in well formatted manner. 
10. Use the account manager email returned by customer data. Never invent an email address. Use that email as the to address of the gmail send - pass it as userId to the gmail send.
11. Do not send duplicate emails for the same request.
12. In the final answer, explain:

* what was found,
* whether the order is delayed,
* whether compensation applies,
* the calculated amount,
* whether an email was sent.

If a required lookup fails or returns ambiguous data, explain the problem instead of inventing missing values.`
    }, model = check ai:getDefaultModelProvider(), tools = [customerMCP, calculateCompensationTool, postSendTool]
);

isolated class McpToolKit {
    *ai:McpBaseToolKit;
    private final mcp:StreamableHttpClient mcpClient;
    private final readonly & ai:ToolConfig[] tools;

    public isolated function init(string serverUrl, mcp:Implementation info = {name: "MCP", version: "1.0.0"},
            *mcp:StreamableHttpClientTransportConfig config) returns ai:Error? {
        final map<ai:FunctionTool> permittedTools = {
            "findCustomer": self.findcustomer,
            "getOrderStatus": self.getorderstatus,
            "getLatestOrder": self.getlatestorder
        };

        do {
            self.mcpClient = check new mcp:StreamableHttpClient(serverUrl, config);
            self.tools = check ai:getPermittedMcpToolConfigs(self.mcpClient, info, permittedTools).cloneReadOnly();
        } on fail error e {
            return error ai:Error("Failed to initialize MCP toolkit", e);
        }
    }

    public isolated function getTools() returns ai:ToolConfig[] => self.tools;

    @ai:AgentTool
    public isolated function findcustomer(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        return self.mcpClient->callTool(params);
    }

    @ai:AgentTool
    public isolated function getorderstatus(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        return self.mcpClient->callTool(params);
    }

    @ai:AgentTool
    public isolated function getlatestorder(mcp:CallToolParams params) returns mcp:CallToolResult|error {
        return self.mcpClient->callTool(params);
    }
}

@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function calculateCompensationTool(decimal orderValue, int delayDays) returns CompensationResult {
    CompensationResult result = calculateCompensation(orderValue, delayDays);
    return result;
}

# Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. For example usage, see [Sending email](https://developers.google.com/gmail/api/guides/sending).
# + payload - The message to be sent.
# + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.2.0.png"}
isolated function postSendTool(gmail:MessageRequest payload, string userId) returns gmail:Message|error {
    gmail:Message gmailMessage = check gmailClient->/users/[userId]/messages/send.post(payload);
    return gmailMessage;
}
