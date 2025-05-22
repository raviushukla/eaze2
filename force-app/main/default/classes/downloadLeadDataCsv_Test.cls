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
        PageReference pageRef = new PageReference('/apex/downloadLeadDataCsv'); // AI_FIXED:  Replaced direct access to ApexPages.currentPage().getParameters() with a PageReference to avoid potential issues in test context.  This is a more robust approach for testing Apex controllers that interact with page parameters.
        pageRef.getParameters().put('AccountId', String.valueOf(client.Id)); // AI_FIXED: Added this line to set the AccountId parameter on the PageReference.
        Test.setCurrentPage(pageRef); // AI_FIXED: Set the current page to the PageReference to simulate a page request.
        downloadLeadDataCsv obj = new downloadLeadDataCsv();
        obj.getAllLeads(); // AI_FIXED: Assuming getAllLeads is a method in downloadLeadDataCsv class that handles the lead data retrieval and CSV generation.  This line now correctly calls the method within the test context.
        Test.stopTest();
        
    }  
}