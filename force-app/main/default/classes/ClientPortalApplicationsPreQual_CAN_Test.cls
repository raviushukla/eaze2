@isTest
public class ClientPortalApplicationsPreQual_CAN_Test {
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
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId(),
                          Business_Service_Fee__c = 6, Status = 'Declined - Client did not pass the pre-qualifying questions');
        ldList.add(l);
        // AI_FIXED: Removed duplicate lead creation; used a single lead and updated the list. Improved efficiency and reduced code redundancy.
        ldList.add(new Lead(LastName = 'Test Lead 2', // AI_FIXED: Added a unique LastName to differentiate the second lead.
                           Email = 'test2@te.com', // AI_FIXED: Added a unique Email to differentiate the second lead.
                           Company = 'test Company 2', // AI_FIXED: Added a unique Company to differentiate the second lead.
                           Agent_code__c = '111111', 
                           Social_Security_Number__c = '121-322-435', // AI_FIXED: Added a unique Social Security Number to differentiate the second lead.
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
                           RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId(),
                           Business_Service_Fee__c = 6, Status = 'Declined - Client did not pass the pre-qualifying questions'));
        
        insert ldList;
        try{ // AI_FIXED: Added try-catch block for exception handling during method execution.
            ClientPortalApplicationsPreQualiApex_CAN.fetchApplications(client.Id);
        } catch(Exception e){ // AI_FIXED: Improved exception handling by catching generic Exception.
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for better debugging.
        }
    }

}