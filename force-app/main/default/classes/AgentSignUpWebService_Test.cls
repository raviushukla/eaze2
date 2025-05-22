@isTest
public class AgentSignUpWebService_Test {
    
    static testMethod void testPostMethod(){
        Account client = new Account( name = 'Test Client');
        insert client;
        
        Account client1 = new Account(Id=client.id, Client_code__c = '12345678');
        update client1;
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/agentSignUp/*';
        request.httpMethod = 'POST';
        request.addParameter('fName', 'FName');
        request.addParameter('lName','lName');
        request.addParameter('email','email@eamil.com');
        request.addParameter('phone','1212121');
        request.addParameter('clientCode', client.Client_code__c); 
        RestContext.request = request;
        
        test.startTest();
        AgentSignUpWebService.createAgent();
        
        request.addParameter('clientCode', '12345678');
        AgentSignUpWebService.createAgent();
        
        request.addParameter('clientCode', client.Client_code__c); 
        request.addParameter('phone','');
        AgentSignUpWebService.createAgent();
        test.stopTest();       
        
        
    }

}