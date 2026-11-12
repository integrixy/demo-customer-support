import ballerina/ai;
import ballerina/mcp;
import ballerinax/googleapis.gmail;

final ai:Agent aiAgent = check new (
    systemPrompt = {
        role: string `Customer order resolution agent`,
        instructions: string `Your responsibility is to investigate customer order issues and take appropriate follow-up actions using the tools available to you.

When a user asks you to investigate an order issue:

1. Identify the customer ID and use it for subsequent customer-specific operations.
2. Retrieve the customer's latest order  and it's status unless the user explicitly provides an order ID.
3. If the order is delivered and there is no unresolved issue, explain the status and do not calculate compensation.
4. If the order is delayed calculate the compensation and never invent the amount.
5. Never invent a compensation amount.
6. Treat the result of calculateCompensation as authoritative.
7. Use the account manager email returned by customer data. Never invent an email address.
8. Send an email with all the available details only when the user has asked for notification/action or when the invocation explicitly indicates that the account manager should be notified.
9. In the final answer and email body, explain below: Format the email body in gmail friendly manner.

* what was found,
* whether the order is delayed,
* whether compensation applies,
* the calculated amount,
* whether an email was sent.

If a required lookup fails or returns ambiguous data, explain the problem instead of inventing missing values.`
    }, model = check ai:getDefaultModelProvider(), tools = [customerMCP, calculateCompensationTool, postSendTool], maxIter = 100
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

@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.2.0.png"}
isolated function postSendTool(gmail:MessageRequest payload, string userId) returns gmail:Message|error {
    gmail:Message gmailMessage = check gmailClient->/users/[userId]/messages/send.post(payload);
    return gmailMessage;
}

