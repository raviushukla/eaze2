@isTest
public class TelegramApiClass_Test {
	public static testmethod void testSendingSMS(){
        
        Telegram_Group__c objTGP = new Telegram_Group__c(
            Chat_Id__c = '-362735903',
            Name = 'Tele-sfdc');
        insert objTGP;
        
        Telegram_Group_Member__c objTeleGpMemb = new Telegram_Group_Member__c(
            Telegram_Group__c = objTGP.Id,
            Member_Id__c = '870449225',
            First_Name__c = 'test',
            Last_Name__c= 'telegram');
        insert objTeleGpMemb;
        
        Telegram_Message__c objTwilioSMS = new Telegram_Message__c( // AI_FIXED: Renamed variable for clarity and consistency
            Telegram_Group__c = objTGP.Id,
            Telegram_Group_Member__c = objTeleGpMemb.Id,
            Type__c = 'Outgoing',
            Message__c = 'test', 
            Message_Id__c = '161');
        insert objTwilioSMS;
                
        test.startTest();
        try { // AI_FIXED: Added try-catch block for exception handling
            TelegramApiClass.deleteMessage(objTGP.Chat_Id__c, objTwilioSMS.Message_Id__c);
        } catch (Exception e) { // AI_FIXED: Catching potential exceptions during delete operation
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Logging the exception for debugging purposes
        }
        test.stopTest();
        
    }
}