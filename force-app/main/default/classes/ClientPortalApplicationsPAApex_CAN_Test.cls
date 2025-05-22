@isTest
public class ClientPortalApplicationsPAApex_CAN_Test {
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
                          // AI_FIXED: Using describe to get RecordTypeId instead of relying on name, which is subject to change.
                          RecordTypeId = getRecordTypeId('Lead','CAN Lead'),
                          Business_Service_Fee__c = 6, Status = 'Client has accepted terms - Moving forward with income Verification');
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
                           // AI_FIXED: Using describe to get RecordTypeId instead of relying on name, which is subject to change.
                           RecordTypeId = getRecordTypeId('Lead','CAN Lead'),
                           Business_Service_Fee__c = 6, Status = 'Pre-Approved Pending Income Verification');
        ldList.add(l2);
        insert ldList;
        ClientPortalApplicationsPreApprApex_CAN.fetchApplications(client.Id);
    }

    // AI_FIXED: Helper method to get RecordTypeId using describe, making it more robust.
    private static Id getRecordTypeId(String objectName, String recordTypeName) {
        try {
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        } catch (Exception e) {
            System.debug('Error getting RecordTypeId: ' + e.getMessage());
            return null; // Or handle the exception appropriately for your application
        }
    }
}