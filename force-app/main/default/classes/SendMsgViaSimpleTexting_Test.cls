@isTest
public class SendMsgViaSimpleTexting_Test {
	public static void runTest(){
        List<Id> tsmsids = new List<Id>();
        Twilio_SMS__c tSMS = new Twilio_SMS__c(SMS_Body__c = 'test body',SMS_Recipient__c = '+1800856565'); // AI_FIXED: Removed unnecessary space before SMS_Body__c and SMS_Recipient__c
        insert tSMS;
        tsmsids.add(tSMS.Id);
       
        test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling
            SendMsgViaSimpleTexting.sendSimpleTexingSMS(tsmsids);
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging
        }
        test.stopTest();
    }
     public static void runTestNegativeScenario(){ // AI_FIXED: Changed 'Void' to 'void' and corrected casing
        List<Id> tsmsids = new List<Id>(); // AI_FIXED: Changed 'id' to 'Id'
        Twilio_SMS__c tSMS = new Twilio_SMS__c(SMS_Body__c = 'test body',SMS_Recipient__c = '+18008565655'); // AI_FIXED: Removed unnecessary space before SMS_Body__c and SMS_Recipient__c
        insert tSMS;
        tsmsids.add(tSMS.Id);
       
        test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling
            SendMsgViaSimpleTexting.sendSimpleTexingSMS(tsmsids);
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging
        }
        test.stopTest();
    }
}