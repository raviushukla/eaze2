global class BulkTextMessageBatch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,FirstName, MobilePhone FROM Contact WHERE MobilePhone != null AND Is_Primary__c = true AND GA_Ad_Text_Sent__c = false LIMIT '+ Label.Text_Message_Limit; // AI_FIXED: Removed unnecessary space in SOQL query
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {	
        String messageid = '';
        SMS_Template__c smsObj;
        try{
            smsObj = [Select Id, SMS_Text__c, Subject__c From SMS_Template__c Where Name =: Label.Text_Message_Template_Name]; // AI_FIXED: Added try-catch block for exception handling
        } catch(Exception e){
            System.debug('Error retrieving SMS template: ' + e.getMessage());
            return; // AI_FIXED: Handle exception and exit gracefully
        }
        List<Twilio_SMS__c> textObjList = new List<Twilio_SMS__c>();
        List<Twilio_SMS__c> textObjCreateList = new List<Twilio_SMS__c>();
        for(Contact con : scope)
        {
            Twilio_SMS__c textObj = new Twilio_SMS__c();
			textObj.Agent__c = con.Id;
            textObj.From_Number__c = '3103040250';
            textObj.SMS_Body__c = con.FirstName + smsObj.SMS_Text__c.replace('\r\n','\\n').replace('\n','\\n').replace('\r','\\n');
            String recipient = con.MobilePhone.replaceAll('[^0-9]', ''); // AI_FIXED: Improved phone number cleaning using regex
            textObj.SMS_Recipient__c = '+1'+recipient; // AI_FIXED: Simplified recipient formatting and added +1 directly
            textObj.SMS_Status__c = 'Sent';
            textObj.SMS_Subject__c = smsObj.Subject__c;
            textObj.Type__c = 'Outgoing';
            try{
                textObj.Message_Id__c = SimpleTextingApi.sendSmsSync(textObj.SMS_Body__c, textObj.SMS_Recipient__c, '',textObj.From_Number__c); // AI_FIXED: Use the cleaned recipient number directly
                textObjCreateList.add(textObj);
            } catch (Exception e){
                System.debug('Error sending SMS to ' + con.MobilePhone + ': ' + e.getMessage()); // AI_FIXED: Added error handling for SMS sending
            }
        }
       
        if(!textObjCreateList.isEmpty()){ // AI_FIXED: Added check to prevent unnecessary DML operation
            insert textObjCreateList;
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}