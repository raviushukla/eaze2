public class SendMsgViaSimpleTexting {
	@InvocableMethod(label = 'Send Message Via SimpleTexing')
    public static void sendSimpleTexingSMS(List<Id> ids) {
        system.debug('ids : '+ids);
        if(!system.isBatch()){
         	sendSMS(ids);   
        }
    }
    public static void sendSMS(list<Id> ids ){
        list<Twilio_SMS__c> simpleTexingSMSes = [SELECT id, SMS_Body__c, SMS_Recipient__c, From_Number__c from Twilio_SMS__c 
                                           WHERE Id IN:ids 
                                           AND SMS_Recipient__c != null ];
        system.debug('simpleTexingSMSes'+ simpleTexingSMSes);
        if( simpleTexingSMSes.size() > 0 ){
            for( Twilio_SMS__c simpleTexingSMS : simpleTexingSMSes ){
                String smsBody = simpleTexingSMS.SMS_Body__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
                if( String.isNotBlank(smsBody ) ){
                    String recipient = (simpleTexingSMS.SMS_Recipient__c).remove('(');
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
                        SimpleTextingApi.sendSmsAsync(smsBody, recipient, simpleTexingSMS.Id,simpleTexingSMS.From_Number__c);
                    }
                }
            }
        }
    }
}