@isTest
public class RingCentralSMSClass_Test {
    public Static Testmethod Void runTest(){
        List<id> tsmsids = new List<id>();
        Twilio_SMS__c tSMS = new Twilio_SMS__c( SMS_Body__c = 'test body',SMS_Recipient__c = '+1800856565');
        insert tSMS;
        tsmsids.add( tSMS.Id );
       
        test.startTest();
        RingCentralSMSClass.sendSMS( tsmsids );
        test.stopTest();
    }
     public Static Testmethod Void runTestNegativeScenario(){
        List<id> tsmsids = new List<id>();
        Twilio_SMS__c tSMS = new Twilio_SMS__c( SMS_Body__c = 'test body',SMS_Recipient__c = '+18008565655');
        insert tSMS;
        tsmsids.add( tSMS.Id );
       
        test.startTest();
        RingCentralSMSClass.sendSMS( tsmsids );
        test.stopTest();
    }
}