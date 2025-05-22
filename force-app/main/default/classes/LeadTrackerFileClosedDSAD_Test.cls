@isTest
public class LeadTrackerFileClosedDSAD_Test {
	public static testMethod void method(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        List<Lead> ldList = new List<Lead>();
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
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
                          Share_With_DSAD__c = true,
                          State = 'TX',
                          Invoice_Paid_Date__c = date.today(),
                          Business_Service_Fee__c = 6, Status = 'Invoice Paid - File Closed');
        ldList.add(l);
        Lead l2 = new Lead(LastName = 'Test Lead', 
                           Email = 'test@te.com', 
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
                           Share_With_DSAD__c = true,
                           State = 'TX',
                           Invoice_Paid_Date__c = date.today(),
                           Business_Service_Fee__c = 6, Status = 'Invoice Paid - File Closed');
        ldList.add(l2);
        insert ldList;
        LeadTrackerFileClosedDSAD.fetchPickListValuesOfLender();
        LeadTrackerFileClosedDSAD.fetchLeads();
        LeadTrackerFileClosedDSAD.fetchPickListValuesOfStatus();
        LeadTrackerFileClosedDSAD.saveNote('title', 'body', l.Id);
        LeadTrackerFileClosedDSAD.updateContacted('true', l.Id);
        LeadTrackerFileClosedDSAD.updateStatus('Invoice Paid - File Closed', l.Id);
        LeadTrackerFileClosedDSAD.updateLender('lender', l.id);
        LeadTrackerFileClosedDSAD.updateApprovalAmount(1000, l.id);
    }
}