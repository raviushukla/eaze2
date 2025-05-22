@isTest
public class ShareLeadsAndAccountsWithDSAD_Test {
	public static testMethod void method() {
        Account client = new Account( name = 'Test Client', DSAD_Account__c = false );
        insert client;
        Contact agent = new Contact( LastName = 'Name', Email='Test@test.com', AccountId = client.Id);
        insert agent;
        Lead ld = new Lead(LastName = 'Test Lead', 
                           Email = 'test@te.com', 
                           Company = 'test Company', 
                           Agent_code__c = agent.Agent_Code__c, 
                           Client_Code__c = client.Client_code__c,
                           Social_Security_Number__c = '121-322-434',
                           Payroll_Frequency__c = 'bi-weekly',
                           Payroll_Type__c = 'Direct_Deposit',
                           Current_Residence_Status__c = 'Rent',
                           Year_at_Address__c = '2',
                           Total_Amount_pre_approved__c = 1000, 
                           Is_Contacted__c = false, 
                           Loan_Amount__c = 10000,
                           Business_Service_Fee__c = 6,
                           Share_With_DSAD__c = false,
                           Status = 'Client has accepted terms - Moving forward with income Verification');
        insert ld;
        String clientCode = [Select Client_Code__c from Account Where Id =: client.Id].Client_Code__c;
        Test.startTest();
        ShareLeadsAndAccountsWithDSAD.execute(clientCode);
        Test.stopTest();
    }
}