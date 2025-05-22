@isTest
public class SendTelegramMsgToAgent_Test {
	public static testMethod void method() {
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Telegram_Group__c tg = new Telegram_Group__c(Client__c = client.Id, Chat_Id__c = 'textChatId');
        insert tg;
                
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
                          Account__c = client.Id,
                          Agent_Name__c = agent.Id,
						  State = 'TX',
                          Business_Service_Fee__c = 6, Status = 'Client has accepted terms - Moving forward with income Verification');
        insert ld;
        Sms_Template__c sms = new Sms_Template__c(
        	Name = 'TestByClass',
            SMS_Text__c = 'Hello {{Lead.Agent_Name__r.Name}} {{Lead.Name}} ',
        	Subject__c = 'Test',
        	Parent__c = 'Lead'
        );
        insert sms;
        
        test.startTest();
        SendTelegramMsgToAgent.fetchLeadDetail(ld.Id);
        SendTelegramMsgToAgent.fetchSMSTemplates();
        SendTelegramMsgToAgent.getTemplateBody(sms.Id, ld.Id);
        SendTelegramMsgToAgent.sendTeleMsg(ld.Id, agent.Id, client.Id, '');
        test.stopTest();
    }
}