@isTest
public class downloadLeadDataCsv_Test {
	static testMethod void testLeadInsert(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          State = 'TX',
                          Year_at_Address__c = '2',
                          Account__c = client.Id);
        insert l;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('AccountId', String.valueOf(client.Id));
        downloadLeadDataCsv obj = new downloadLeadDataCsv();
        obj.getAllLeads();
        Test.stopTest();
        
    }  
}