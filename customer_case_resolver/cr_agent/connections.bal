import ballerinax/googleapis.gmail;

final McpToolKit customerMCP = check new ("http://localhost:9092/mcp");
final gmail:Client gmailClient = check new ({
    auth: {
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
});
