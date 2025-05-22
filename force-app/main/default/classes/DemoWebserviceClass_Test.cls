@isTest
public class DemoWebserviceClass_Test {
    public static testmethod void testPost(){
        String body = '{"id":"","status":""}';
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/demoWebService/*';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(body);
        RestContext.request = request;
        
        test.startTest();
        DemoWebserviceClass.doPost();
        test.stopTest();  
    }

}