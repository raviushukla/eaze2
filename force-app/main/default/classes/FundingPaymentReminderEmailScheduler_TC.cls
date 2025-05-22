@isTest
public class FundingPaymentReminderEmailScheduler_TC {
    public static testmethod void method(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        List<Lead> ldList = new List<Lead>();
        Lead l = new Lead(FirstName='Test',
                          LastName = 'Lead', 
                          Email = 'test@gmail.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          Year_at_Address__c = '2',
                          Total_Amount_pre_approved__c = 1000, 
                          Is_Contacted__c = false, 
                          Loan_Amount__c = 10000,
                          Agent_Name__c = agent.Id,
                          State = 'TX',
                          Business_Service_Fee__c = 6, 
                          Status = 'New Lead',
                          LeadSource = 'Funding Partner Intro Done',
                          Immediate_Payment_Reminder_Sent__c = false);
        ldList.add(l);
        insert ldList;
        Test.StartTest();
		FundingPaymentReminderEmailScheduler testsche = new FundingPaymentReminderEmailScheduler();
		String sch = '0 10 * * * ?';
		system.schedule('FundingPaymentReminderEmailScheduler', sch, testsche );
        FundingPaymentReminderEmailScheduler f= new FundingPaymentReminderEmailScheduler();
        f.sendResetLink(ldList);
		Test.stopTest();
    }
}