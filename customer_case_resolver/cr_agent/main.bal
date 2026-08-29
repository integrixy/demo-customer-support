import ballerina/ai;
import ballerina/http;

listener ai:Listener agentChatListener = new (listenOn = check http:getDefaultListener());

service /ai\-agent on agentChatListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request)
            returns ai:ChatRespMessage|error {
        string stringResult = check aiAgent.run(request.message, sessionId = request.sessionId);
        return {message: stringResult};
    }
}

listener http:Listener httpDefaultListener = http:getDefaultListener();

@http:ServiceConfig {
    cors: {
        allowMethods: ["POST"],
        allowOrigins: [
            "*"
        ]
    }
}
service /api/customer on httpDefaultListener {
    resource function post resolve(@http:Payload CustomerIssueRequest payload) returns CustomerIssueResponse|error {
        do {
            CustomerIssueResponse result = check aiAgent.run(string `Answer the request.

Request payload:
${payload.toJsonString()}`);
            return result;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

