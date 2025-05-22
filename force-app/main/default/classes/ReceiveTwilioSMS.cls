@RestResource(urlMapping='/receiveTwilioSMS/*')
global without sharing class ReceiveTwilioSMS {
    
    @HttpGet
    global static void createTwilioSmsRecord(){
        RestRequest req = RestContext.request;
        Map<String, String> response = req.params; // AI_FIXED: Corrected the Map value type to String
        
        String fromMobile = '';
        String body = '';
        String leadId = '';
        String leadName = '';
        String leadEmail = '';
        
        if(response.containsKey('From')){
            fromMobile = response.get('From');
        }
        if(response.containsKey('Body')){
            body = response.get('Body');
        }
        if( String.isNotBlank(fromMobile) && String.isNotBlank(body)){
            try{
                // AI_FIXED: Added try-catch block for exception handling
                List<Lead> ld = [Select Id, Name, Email From Lead where Mobile_Custom__c =: fromMobile ORDER BY LastModifiedDate DESC LIMIT 1]; // AI_FIXED: Added LIMIT 1 to optimize query and prevent unnecessary SOQL queries
                if( ld.size()>0 ){
                    leadId = ld[0].Id;
                    leadName = ld[0].Name;
                    leadEmail = ld[0].Email;
                }
                Twilio_SMS__c rcd = new Twilio_SMS__c(SMS_Body__c = body, SMS_Recipient__c = fromMobile, Type__c = 'Incoming');
                if( String.isNotBlank(leadId) ){
                    rcd.Leads__c = leadId;
                }
                Database.insert(rcd);
                if(String.isNotBlank(leadName)){ // AI_FIXED: Moved email sending logic inside the if condition to prevent unnecessary email sending
                    // AI_FIXED: Using StringBuilder for better performance in email body construction
                    StringBuilder mailBody = new StringBuilder();
                    mailBody.append('<html><body style="color: black;"><br/>');
                    mailBody.append('Hey SBS Team,<br/><br/>');
                    mailBody.append('We have received a reply from ');
                    mailBody.append(leadName);
                    mailBody.append(', Cell # ');
                    mailBody.append(fromMobile);
                    mailBody.append(' the message is as below:<br/>');
                    mailBody.append(body);
                    mailBody.append('<br/><br/>');
                    mailBody.append('Regards,<br/>');
                    mailBody.append('SBS Salesforce Admin');
                    mailBody.append('</body></html>');

                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    list<string> toaddress = new list<string>();
                    toaddress.add('info@sbsfinancing.com');
                    email.setToAddresses(toaddress);
                    email.setSubject('Reply Received From Customer '+leadName);
                    email.setHtmlBody(mailBody.toString()); // AI_FIXED: Using StringBuilder's toString() method
                    Messaging.sendEmail( new Messaging.SingleEmailMessage[] { email } );
                }
            } catch(Exception ex){
                // AI_FIXED: Added exception handling to log errors
                System.debug('Error processing Twilio SMS: ' + ex.getMessage());
            }
        }
    }
}