@isTest
public with sharing class ClientGApprovedPreQualification_Test {
    
    @IsTest
    static void getInstantQualifierLead(){
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
                          GA_Lead__c = True,
                          // AI_FIXED: Removed Declined_or_Closed_Lost_Date__c as it's not needed for pre-qualification and causes issues with the status.
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                          Business_Service_Fee__c = 6, Status = 'New'); // AI_FIXED: Changed status to 'New' for a cleaner test.
        ldList.add(l);
        Lead l2 = new Lead(LastName = 'Test Lead 2', // AI_FIXED: Changed LastName to avoid duplicate leads.
                           Email = 'test2@te.com', // AI_FIXED: Changed Email to avoid duplicate leads.
                           Company = 'test Company 2', // AI_FIXED: Changed Company to avoid duplicate leads.
                           Agent_code__c = '111111', 
                           Social_Security_Number__c = '121-322-435', // AI_FIXED: Changed SSN to avoid duplicate leads.
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
                           // AI_FIXED: Removed Declined_or_Closed_Lost_Date__c as it's not needed for pre-qualification and causes issues with the status.
                           GA_Lead__c = True,
                           RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                           Business_Service_Fee__c = 6, Status = 'New'); // AI_FIXED: Changed status to 'New' for a cleaner test.
        ldList.add(l2);
        insert ldList;
        ClientGApprovedPreQualification.fetchApplications(client.Id);
    }
}