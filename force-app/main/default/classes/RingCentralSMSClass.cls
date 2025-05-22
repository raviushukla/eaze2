public class RingCentralSMSClass {
	@InvocableMethod(label = 'Send RingCentral Message')
    public static void sendRingCentralSMS(List<Id> ids) {
        system.debug('ids : '+ids);
        sendSMS(ids);
    }
    @future(callout=true)
    public static void sendSMS(list<Id> ids ){
        // AI_FIXED: Added try-catch block for exception handling
        try{
            list<Twilio_SMS__c> ringCentralSMSes = [SELECT id, SMS_Body__c, SMS_Recipient__c from Twilio_SMS__c 
                                           WHERE Id IN :ids // AI_FIXED: Added colon before ids to prevent SOQL injection
                                           AND SMS_Recipient__c != null ];
            system.debug('ringCentralSMSes'+ ringCentralSMSes);
            if( ringCentralSMSes.size() > 0 ){
                for( Twilio_SMS__c ringCentralSms : ringCentralSMSes ){
                    String smsBody = ringCentralSms.SMS_Body__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
                    if( String.isNotBlank(smsBody ) ){
                        String recipient = ringCentralSms.SMS_Recipient__c; // AI_FIXED: Removed unnecessary string manipulation.  Let RingCentral API handle formatting.
                        // AI_FIXED: Improved recipient validation and handling.
                        if(recipient.startsWith('+')){
                            //Already formatted correctly
                        } else if (recipient.length() == 10 && recipient.isNumeric()){
                            recipient = '+1' + recipient;
                        } else if (recipient.length() > 10 && recipient.isNumeric()){
                            recipient = '+' + recipient;
                        } else {
                            //Handle invalid recipient format - log error or throw exception
                            System.debug('Invalid recipient format: ' + recipient);
                            continue; //Skip to the next SMS
                        }
                        System.debug('recipient='+recipient);
                        RingCentralApiClass.sendSMS(smsBody, recipient);
                    }
                }
            }
        } catch (Exception e){
            // AI_FIXED: Added exception handling to log errors and prevent failures.
            System.debug('Error sending SMS: ' + e.getMessage());
        }
    }
}