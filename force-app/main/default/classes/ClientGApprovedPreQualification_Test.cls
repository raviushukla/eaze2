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
                          Declined_or_Closed_Lost_Date__c = Date.today(),
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                          Business_Service_Fee__c = 6, Status = 'Declined - Client did not pass the pre-qualifying questions');
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
                           State = 'TX',
                           Account__c = client.Id,
                           Declined_or_Closed_Lost_Date__c = Date.today(),
                           GA_Lead__c = True,
                           RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                           Business_Service_Fee__c = 6, Status = 'Declined - Client did not pass the pre-qualifying questions');
        ldList.add(l2);
        insert ldList;
        ClientGApprovedPreQualification.fetchApplications(client.Id);
    }
}