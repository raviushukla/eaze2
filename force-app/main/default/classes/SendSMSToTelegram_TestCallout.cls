@isTest
public class SendSMSToTelegram_TestCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        return res;
    }
}