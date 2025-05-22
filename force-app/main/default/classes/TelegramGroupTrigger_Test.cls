@isTest
public class TelegramGroupTrigger_Test {
    public static testMethod void tester(){
        Account acc = new Account( Name = 'test');
        insert acc;
        Account acc2 = new Account( Name = 'test2');
        insert acc2;
        Telegram_Group__c teleGp = new Telegram_Group__c(Chat_Id__c = '-362735903',Name = 'test', Client__c = acc.Id);
        insert teleGp;
        Telegram_Group__c teleGp2 = new Telegram_Group__c(Id = teleGp.Id, Client__c = acc2.Id);
        update teleGp2;
    }
}