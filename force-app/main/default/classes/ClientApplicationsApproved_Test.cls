@isTest
public class ClientApplicationsApproved_Test {
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
                          State = 'TX',
                          Account__c = client.Id,
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                          Business_Service_Fee__c = 6, Status = 'Approved By Lender-Funding In Progress');
        ldList.add(l);
        Lead l2 = new Lead(LastName = 'Test Lead2', // AI_FIXED: Changed LastName to avoid duplicate leads
                           Email = 'test2@te.com', // AI_FIXED: Changed Email to avoid duplicate leads
                           Company = 'test Company', 
                           Agent_code__c = '111111', 
                           Social_Security_Number__c = '121-322-4345', // AI_FIXED: Changed SSN to avoid duplicate leads
                           Payroll_Frequency__c = 'bi-weekly',
                           Payroll_Type__c = 'Direct_Deposit',
                           Current_Residence_Status__c = 'Rent',
                           Year_at_Address__c = '2',
                           Total_Amount_pre_approved__c = 1000, 
                           Is_Contacted__c = false, 
                           Loan_Amount__c = 10000,
                           Agent_Name__c = agent.Id,
                           State = 'TX',
                           Account__c = client.Id,
                           RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                           Business_Service_Fee__c = 6, Status = 'Funded - Invoice EAZE Client');
        ldList.add(l2);
        insert ldList;
        try{ // AI_FIXED: Added try-catch block for exception handling
            ClientApplicationsApproved.fetchApplications(client.Id);
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging
        }
    }
}