@isTest
public class CreateDTCAEmailService_Test {
    static testMethod void TestinBoundEmail()
    {

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for new application email
        email.fromAddress = 'someaddress@email.com';
        email.subject = 'Your Eaze Consulting Merchant Application';
        email.plainTextBody = 'Hello Umesh, your application is submitted. Thank you for applying for a Eaze Consulting account. Please allow us 2-3 business days to review your application.'; 
        email.toAddresses = new List<String>{'test@test.com','createdirecttocustomerapplication@test.com'};
        
            
        // call the email service class and test it with the data in the testMethod
        CreateDTCAEmailService  testInbound = new CreateDTCAEmailService ();
        testInbound.handleInboundEmail(email, env);
        
        Direct_To_Client_Application__c client = New Direct_To_Client_Application__c();
        client.Name = 'Test';
        client.Email__c = 'test@test.com';
        client.Status__c = 'New';
        insert client;
        
        email.plainTextBody = 'Hello Umesh, your application is submitted. Upon review of your application, we regret to inform you that we are unable to open an account for you at this time.';
        testInbound.handleInboundEmail(email, env); 
        
        email.plainTextBody = 'Hello Hero Singh, Welcome to EAZE Consulting\'s Direct-to-Client Funding Program.'; 
        email.subject = 'Welcome to Eaze Consulting!';
        testInbound.handleInboundEmail(email, env);  
        
    }
}