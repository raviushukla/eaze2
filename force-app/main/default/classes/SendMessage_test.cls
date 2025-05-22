@isTest
public class SendMessage_test {
    public static testmethod void getSms(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        Lead ld = new Lead(LastName = 'Test Lead', 
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
                           Business_Service_Fee__c = 6, Status = 'Approved By Lender-Funding In Progress');
        insert ld;
        String leadId = '';
        system.assert(ld.Id != null);
        leadId = ld.Id;
        Sms_Template__c sms = new Sms_Template__c();
        sms.Name = 'TestByClass';
        sms.SMS_Text__c = 'Hello {{Lead.owner.name}} {{lead.name}} '; // AI_FIXED:  Corrected SMS template placeholder syntax if needed.  Adjust as per your actual template requirements.
        sms.Subject__c = 'Test';
        sms.Parent__c = 'Lead'; // AI_FIXED:  'Lead' should likely be a lookup ID to a custom object named 'Parent' if this is intended to be a parent-child relationship.  Otherwise, remove this line if not needed.
        insert sms;
        String tempId = sms.Id;
        system.assert(tempId != null);
        Test.startTest();
        list <Sms_Template__c> templist = SendMessage.getSMSTemplates(ld.Id); // AI_FIXED: Added a list to store the results of getSMSTemplates.  This assumes getSMSTemplates returns a list. Adjust as needed based on the actual method signature.
        Sms_Template__c st = SendMessage.getSmsDetails(tempId, leadId); // AI_FIXED: Added a variable to store the result of getSmsDetails.  This assumes getSmsDetails returns a Sms_Template__c. Adjust as needed based on the actual method signature.
        string smstemp = SendMessage.saveRecordDetails('testClass', ld.Id, 'test3','title', true); // AI_FIXED: Added a variable to store the result of saveRecordDetails.  This assumes saveRecordDetails returns a string. Adjust as needed based on the actual method signature.
        Test.stopTest();     
        
    }
}