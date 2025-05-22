@isTest
public class ReceiveTwilioSMS_Test {
    public static testMethod void test() 
    { 
        Test.startTest();
        Lead ld = new Lead( LastName='Test', Status = 'New Lead', Loan_Amount__c = 100, 
                           Social_Security_Number__c	= '12', Income_Source_1__c = 'Employed', 
                           Date_of_Birth__c = Date.today()-1000, 
                           MobilePhone = '8507834123'
                          );
        insert ld;
        RestRequest req = new RestRequest();        
        req.requestURI = '/services/apexrest/receiveTwilioSMS/';
        req.httpMethod = 'GET';
        req.addParameter('From', '8507834123');
        req.addParameter('Body', 'this is a test sms');
        RestContext.request = req;
        receiveTwilioSMS.createTwilioSmsRecord();
        Test.stopTest();
    }
}