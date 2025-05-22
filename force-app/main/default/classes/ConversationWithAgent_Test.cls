@isTest
public class ConversationWithAgent_Test {
    
    static testMethod void fetchAgents(){
        Telegram_Group__c testGroup = new Telegram_Group__c(
            Name='Test Group', 
            Chat_Id__c = '-35423475');
        insert testGroup;
        
        Telegram_Group_Member__c testMember = new Telegram_Group_Member__c(
            Telegram_Group__c = testGroup.Id, 
            First_Name__c = 'first', 
            Last_Name__c ='last');
        insert testMember;
        
        Telegram_Message__c twi = new  Telegram_Message__c (Message__c='ábc', Type__c='Outgoing', Telegram_Group__c = testGroup.Id , Telegram_Group_Member__c = testMember.Id);
        insert twi;
        Telegram_Message__c twi1 = new  Telegram_Message__c (Message__c='ábc', Type__c='Incoming', Telegram_Group__c = testGroup.Id , Telegram_Group_Member__c = testMember.Id);
        insert twi1;
        test.startTest();
        ConversationWithAgent.fetchGroups();
        ConversationWithAgent.fetchConversation(testGroup.Id);
        ConversationWithAgent.sendMessage(testGroup.Id, '');
        ConversationWithAgent.fetchNotification();
        ConversationWithAgent.markSMSasRead(new List<String>{twi1.Id});
        test.stopTest();
    }
}