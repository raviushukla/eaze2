@RestResource(urlMapping='/receiveTwilioSMS/*')
global without sharing class ReceiveTwilioSMS {
    
    @HttpGet
    global static void createTwilioSmsRecord(){
        RestRequest req = RestContext.request;
        Map<String, string> response = req.params;
        
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
            List<Lead> ld = [Select Id, Name, Email From Lead where Mobile_Custom__c =: fromMobile ORDER BY LastModifiedDate DESC];
            if( ld.size()>0 ){
                leadId = ld[0].Id;
                leadName = ld[0].Name;
                leadEmail = ld[0].Email;
            }
            Twilio_SMS__c rcd = new Twilio_SMS__c(SMS_Body__c = body, SMS_Recipient__c = fromMobile, Type__c = 'Incoming');
            if( String.isNotBlank(leadId) ){
                rcd.Leads__c = leadId;
            }
            Database.SaveResult result = DataBase.insert(rcd);
            /*
            if(result.isSuccess() && String.isNotBlank(leadName)){
                String mailBody ='<html><body style="color: black;"><br/>'+
                    'Hey SBS Team,<br/><br/>'+
                    'We have received a reply form '+leadName+', Cell # '+fromMobile+' the message is as below:<br/>'+
                    body+'<br/><br/>'+
                    'Regards,'+
                    'SBS Salesforce Admin'+
                    '</body></html>';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                list<string> toaddress = new list<string>();
                toaddress.add('info@sbsfinancing.com');
                email.setToAddresses(toaddress);
                email.setSubject('Reply Received From Customer '+leadName);
                email.setHtmlBody(mailBody);
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { email } );
            }
			*/
        }
    }
}