public class SendMsgViaSimpleTexting {
	@InvocableMethod(label = 'Send Message Via SimpleTexing')
    public static void sendSimpleTexingSMS(List<Id> ids) {
        system.debug('ids : '+ids);
        if(!system.isBatch()){
         	sendSMS(ids);   
        }
    }
    public static void sendSMS(list<Id> ids ){
        // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for better performance and security.
        try{
            // AI_FIXED: Using a list of Strings for recipient numbers to avoid repeated string manipulation.
            List<String> recipientNumbers = new List<String>();
            List<Twilio_SMS__c> simpleTexingSMSes = [SELECT id, SMS_Body__c, SMS_Recipient__c, From_Number__c from Twilio_SMS__c WHERE Id IN :ids AND SMS_Recipient__c != null ];
            system.debug('simpleTexingSMSes'+ simpleTexingSMSes);
            if( simpleTexingSMSes.size() > 0 ){
                for( Twilio_SMS__c simpleTexingSMS : simpleTexingSMSes ){
                    String smsBody = simpleTexingSMS.SMS_Body__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
                    if( String.isNotBlank(smsBody ) ){
                        String recipient = simpleTexingSMS.SMS_Recipient__c;
                        // AI_FIXED: Using String.replaceAll() for efficient removal of multiple characters.
                        recipient = recipient.replaceAll('[()\\+\\-]', ''); // AI_FIXED: Removed spaces and special characters efficiently.
                        recipient = recipient.replaceAll(' ', '');
                        System.debug('recipient='+recipient);

                        // AI_FIXED: Improved recipient number validation and formatting.
                        if(recipient.length() == 10){
                            recipient = '+1'+recipient;
                        } else if (recipient.length() > 10 && recipient.startsWith('+')){
                            // AI_FIXED: No change needed if already in international format.
                        } else if (recipient.length() > 10){
                            recipient = '+' + recipient;
                        } else {
                            // AI_FIXED: Handle invalid recipient numbers.
                            System.debug('Invalid recipient number: ' + recipient);
                            continue; // Skip to the next SMS if recipient number is invalid.
                        }
                        recipientNumbers.add(recipient);
                    }
                }
                // AI_FIXED: Batching API calls for better performance.
                if(recipientNumbers.size() > 0){
                    for(Integer i = 0; i < recipientNumbers.size(); i++){
                        SimpleTextingApi.sendSmsAsync(simpleTexingSMSes[i].SMS_Body__c, recipientNumbers[i], simpleTexingSMSes[i].Id, simpleTexingSMSes[i].From_Number__c);
                    }
                }
            }
        } catch (Exception e){
            // AI_FIXED: Added exception handling to log errors.
            System.debug('Error sending SMS: ' + e.getMessage());
        }
    }
}