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
        
        Test.setMock(HttpCalloutMock.class, new SendSMSToTelegram_TestCallout());
        
        test.startTest();
        SendSMSToTelegram.fetchSMSRecord(lstTwilioSMS);
        test.stopTest();
        
    }
}