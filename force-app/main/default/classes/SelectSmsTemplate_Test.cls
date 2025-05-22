@isTest
public class SelectSmsTemplate_Test {
    public static testmethod void getSms(){
        //lead ld = new lead(LastName='Class',FirstName='forTestSms',Company='TestC');
        //insert ld;
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
        sms.SMS_Text__c = 'Hello {{Lead.owner.name}} {{lead.name}} ';
        sms.Subject__c = 'Test';
        sms.Parent__c = 'Lead';
        insert sms;
        String tempId = sms.Id;
        system.assert(tempId != null);
        Test.startTest();
        list <Sms_Template__c> templist = SelectSmsTemplate.getSMSTemplates(ld.Id);
        Sms_Template__c st = SelectSmsTemplate.getSmsDetails(tempId, leadId);
        string smstemp = SelectSmsTemplate.saveRecordDetails('testClass', 'test', 'test3');
        Test.stopTest();     
        
    }
    
}