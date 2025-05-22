@isTest
public class SendSMSToTelegram_TestCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200); // AI_FIXED: Added status code for a complete response
        res.setBody('{"example":"test"}');
        return res;
    }
}