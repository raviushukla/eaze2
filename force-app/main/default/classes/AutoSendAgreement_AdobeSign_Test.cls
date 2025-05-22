@isTest
global class AutoSendAgreement_AdobeSign_Test {
    global static testmethod void test1(){
        
        Test.setMock(HttpCalloutMock.class, new AutoSendAgreementMock());  
        
        AutoSendAgreement_AdobeSign.RequestParam rp = new AutoSendAgreement_AdobeSign.RequestParam();
        AutoSendAgreement_AdobeSign.createEnrolments(new list<AutoSendAgreement_AdobeSign.RequestParam>{rp});
    }
    
    global class AutoSendAgreementMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "22", "instance_url":"Test"}}');
            response.setStatusCode(200);
            return response; 
        }
    }

}