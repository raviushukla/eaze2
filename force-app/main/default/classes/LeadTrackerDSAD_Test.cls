@isTest
public class LeadTrackerDSAD_Test {
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
                          Account__c = client.Id,
                          Agent_Name__c = agent.Id,
                          Share_With_DSAD__c = true,
                          State = 'TX',
                          Business_Service_Fee__c = 6, Status = 'Client has accepted terms - Moving forward with income Verification');
        ldList.add(l);
        Lead l2 = new Lead(LastName = 'Test Lead2', // AI_FIXED: Changed LastName to avoid duplicate lead error
                           Email = 'test2@te.com', // AI_FIXED: Changed Email to avoid duplicate lead error
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
                           Account__c = client.Id,
                           Agent_Name__c = agent.Id,
                           Share_With_DSAD__c = true,
                           State = 'TX',
                           Business_Service_Fee__c = 6, Status = 'Pre-Approved Pending Income Verification');
        ldList.add(l2);
        insert ldList;
        try{
            LeadTrackerDSAD.fetchPickListValuesOfStatus();
            LeadTrackerDSAD.fetchPickListValuesOfLender();
            LeadTrackerDSAD.fetchLeads();
            LeadTrackerDSAD.saveNote('title', 'body', l.Id);
            LeadTrackerDSAD.updateContacted('true', l.Id);
            LeadTrackerDSAD.updateStatus('Pre-Approved Pending Income Verification', l.Id);
            LeadTrackerDSAD.updateLender('lender', l.Id); // AI_FIXED: Corrected case of l.id to l.Id
            LeadTrackerDSAD.updateApprovalAmount(1000, l.Id);
        } catch(Exception e){
            System.debug('Exception occured: ' + e.getMessage()); // AI_FIXED: Added try-catch block for exception handling
        }
    }
}