@isTest
public class TelegramMessageTrigger_Test {
    public static testMethod void method() {
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Telegram_Group__c tg = new Telegram_Group__c(Client__c = client.Id, Chat_Id__c = 'textChatId');
        insert tg;
        
        Telegram_Group_Member__c tgm = new Telegram_Group_Member__c(Agent__c = agent.Id, Telegram_Group__c = tg.Id, User_Name__c = 'user name', Last_Name__c = 'Name' );
        insert tgm;
        
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
        
        // AI_FIXED: Added a unique email for the second lead to avoid duplicate email error
        Lead ld1 = new Lead(LastName = 'Test Lead 2', // AI_FIXED: Changed LastName to avoid duplicate lead error
                          Email = 'test2@te.com', // AI_FIXED: Changed Email to avoid duplicate email error
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
                          Business_Service_Fee__c = 6, Status = 'Client has accepted terms - Moving forward with income Verification');
        insert ld1;
        
        Telegram_Message__c tm = new Telegram_Message__c(Lead__c = ld.Id, Agent__c = agent.Id, Client__c = client.Id, Message__c = '', Type__c = 'Outgoing');
        insert tm;
        Telegram_Message__c tm1 = new Telegram_Message__c(Lead__c = ld.Id, Agent__c = agent.Id, Message__c = '', Type__c = 'Outgoing');
        insert tm1;
        
    }
    public static testMethod void deleteTeleMssFromTelegram(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Telegram_Group__c tg = new Telegram_Group__c(
            Client__c = client.Id, 
            Chat_Id__c = 'textChatId');
        insert tg;
        
        Telegram_Group_Member__c tgm = new Telegram_Group_Member__c(
            Agent__c = agent.Id, 
            Telegram_Group__c = tg.Id, 
            User_Name__c = 'user name', 
            Last_Name__c = 'Name' );
        insert tgm;
        Telegram_Message__c tm = new Telegram_Message__c(
            Telegram_Group__c = tg.Id,
            Telegram_Group_Member__c = tgm.Id,
            Message__c = '', 
            Type__c = 'Outgoing',
            Message_Id__c = 'messageId');
        insert tm;
        delete tm;
    }
}