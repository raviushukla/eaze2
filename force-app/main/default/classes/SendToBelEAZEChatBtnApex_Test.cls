@isTest
public with sharing class SendToBelEAZEChatBtnApex_Test {

    @isTest
    static void testCreateTelegramMsgRecord() {
       Account client = new Account( name = 'Test Client', Client_code__c = '12345678');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434' );
        
        insert l;
        Telegram_Group__c testTelegramGroup = new Telegram_Group__c(Name = 'TestTelegramGroup');
        insert testTelegramGroup;

        Test.startTest();
        try {
            String result = SendToBelEAZEChatBtnApex.createTelegramMsgRecord(l.Id);
        } catch (Exception e) {
        }
       
        Test.stopTest();
    }
}