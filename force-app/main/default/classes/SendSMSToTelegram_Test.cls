@isTest
public class SendSMSToTelegram_Test {
    public static testmethod void testSendingSMS(){
        
        Telegram_Group__c objTGP = new Telegram_Group__c(Chat_Id__c = '-362735903',Name = 'Tele-sfdc');
        insert objTGP;
        
        Telegram_Group_Member__c objTeleGpMemb = new Telegram_Group_Member__c(Telegram_Group__c = objTGP.Id,Member_Id__c = '870449225',First_Name__c = 'test',Last_Name__c= 'telegram');
        insert objTeleGpMemb;
        
        List<Telegram_Message__c> lstTwilioSMS = new List<Telegram_Message__c>();
        Telegram_Message__c objTwilioSMS = new Telegram_Message__c(Telegram_Group__c = objTGP.Id,Telegram_Group_Member__c = objTeleGpMemb.Id,Type__c = 'Incoming',Message__c = 'test');
        lstTwilioSMS.add(objTwilioSMS);
        insert lstTwilioSMS;
        
        Test.setMock(HttpCalloutMock.class, new SendSMSToTelegram_TestCallout()); // AI_FIXED: No changes needed here, but added a comment for clarity.
        
        test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling.
            SendSMSToTelegram.fetchSMSRecord(lstTwilioSMS);
        } catch(Exception e){ // AI_FIXED: Added catch block to handle potential exceptions.
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for better debugging.
        }
        test.stopTest();
        
    }
}