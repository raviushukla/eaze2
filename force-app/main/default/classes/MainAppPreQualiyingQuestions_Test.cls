@isTest
public class MainAppPreQualiyingQuestions_Test {
	
    @isTest static void testClassMethod1(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 3838Name', Email='Tes783t@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        MainAppPreQualiyingQuestions.leadWrap leadWrprObj = new MainAppPreQualiyingQuestions.leadWrap();
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.employmentType = 'W-2';
        
        Test.startTest();
        MainAppPreQualiyingQuestions.createLead(leadWrprObj);
       	Test.stopTest();
    }
}