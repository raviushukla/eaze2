global class BulkTextMessageBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,FirstName, MobilePhone FROM Contact Where MobilePhone != null AND Is_Primary__c = true AND GA_Ad_Text_Sent__c = false LIMIT '+ Label.Text_Message_Limit;
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {	
     	String messageid = '';
        SMS_Template__c smsObj = [Select Id, SMS_Text__c, Subject__c From SMS_Template__c Where Name =: Label.Text_Message_Template_Name];
        List<Twilio_SMS__c> textObjList = new List<Twilio_SMS__c>();
        List<Twilio_SMS__c> textObjCreateList = new List<Twilio_SMS__c>();
        for(Contact con : scope)
        {
            Twilio_SMS__c textObj = new Twilio_SMS__c();
			textObj.Agent__c = con.Id;
            textObj.From_Number__c = '3103040250';
            textObj.SMS_Body__c = con.FirstName + smsObj.SMS_Text__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
            String recipient = (con.MobilePhone).remove('(');
            recipient = recipient.remove(')');
            recipient = recipient.remove('-');
            recipient = recipient.remove('+');
            recipient = recipient.remove(' ');
            textObj.SMS_Recipient__c = con.MobilePhone;
            textObj.SMS_Status__c = 'Sent';
            textObj.SMS_Subject__c = smsObj.Subject__c;
            textObj.Type__c = 'Outgoing';
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
                textObj.Message_Id__c = SimpleTextingApi.sendSmsSync(textObj.SMS_Body__c, recipient, '',textObj.From_Number__c);
                textObjCreateList.add(textObj);
            }
        }
       
     	insert textObjCreateList;
    }
    global void finish(Database.BatchableContext BC) {
    }
}