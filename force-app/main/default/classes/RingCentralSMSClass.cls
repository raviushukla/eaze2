public class RingCentralSMSClass {
	@InvocableMethod(label = 'Send RingCentral Message')
    public static void sendRingCentralSMS(List<Id> ids) {
        system.debug('ids : '+ids);
        sendSMS(ids);
    }
    @future(callout=true)
    public static void sendSMS(list<Id> ids ){
        list<Twilio_SMS__c> ringCentralSMSes = [SELECT id, SMS_Body__c, SMS_Recipient__c from Twilio_SMS__c 
                                           WHERE Id IN:ids 
                                           AND SMS_Recipient__c != null ];
        system.debug('ringCentralSMSes'+ ringCentralSMSes);
        if( ringCentralSMSes.size() > 0 ){
            for( Twilio_SMS__c ringCentralSms : ringCentralSMSes ){
                String smsBody = ringCentralSms.SMS_Body__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
                if( String.isNotBlank(smsBody ) ){
                    String recipient = (ringCentralSms.SMS_Recipient__c).remove('(');
                    recipient = recipient.remove(')');
                    recipient = recipient.remove('-');
                    recipient = recipient.remove('+');
                    recipient = recipient.remove(' ');
                    System.debug('recipient='+recipient);
                    
                    Boolean correctRecipient = FALSE  ;
                    if( recipient.length() == 10  ){
                        recipient = '+1'+recipient;
                        correctRecipient = TRUE ;
                    }
                    else if ( recipient.length() > 10 ){
                        recipient = '+'+recipient;
                        correctRecipient = TRUE ;
                    }
                    if( correctRecipient ){
                        RingCentralApiClass.sendSMS(smsBody, recipient);
                    }
                }
            }
        }
    }
}