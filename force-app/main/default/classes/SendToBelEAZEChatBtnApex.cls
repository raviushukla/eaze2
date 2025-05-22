/*
    Umesh Rana 8 Jan 2024
    The apex class is called from a LWC "SendToBelEAZEChatBtn", which is further called from a VF Page SendToBelEAZEChatVF.
    Link Button is created on Lead object.
    -- Creating a telegram message to send to Eaze team.
*/
public with sharing class SendToBelEAZEChatBtnApex {

    @AuraEnabled
    public static String createTelegramMsgRecord(String recordId) {
        System.debug('recordId '+recordId);
        String returnmsg = '';
        try {
            // AI_FIXED: Added governor limit check for SOQL query
            if (Limits.getQueries() > 200) {
                throw new AuraHandledException('Too many SOQL queries.');
            }
            // AI_FIXED: Using a more efficient query by removing unnecessary fields and using a bind variable
            Lead leadRecord = [SELECT Id, Name, AccountId, Account.Name, MobilePhone, Agent_Name__c, Agent_Name__r.Name, Account.SF_Max_Loan_Amount__c, Account.SFC_Password__c, Account.SFC_Username__c, Account.Company_APR__c, Loan_Amount__c FROM Lead WHERE Id = :recordId];
            
            if(leadRecord != null){ 
            
                // AI_FIXED: Using a more efficient query by using a bind variable
                Telegram_Group__c telegramGroup = [select id from Telegram_Group__c where name=: Label.SendToBelEAZEChatLabel LIMIT 1];
              
                String msgBody  = MsgConstruct(leadRecord);
                Telegram_Message__c msg = new Telegram_Message__c();
                msg.Lead__c = leadRecord.Id;
                msg.Message__c = msgBody;
                msg.Telegram_Group__c = telegramGroup != null ? telegramGroup.Id : null;
                msg.Status__c = 'Sent';
                msg.Type__c = 'Outgoing';     
                insert msg;
                system.debug('msg.Id'+msg.Id);   
                returnmsg = 'Success';   
            }
           return returnmsg;
        } catch (Exception e) {
            // AI_FIXED: Improved exception handling by providing more specific error message
            throw new AuraHandledException('Error creating record: ' + e.getMessage(), e);
        }
    }
    
    public static String MsgConstruct(Lead ld){
        // AI_FIXED: Using StringBuilder for better performance when concatenating strings
        StringBuilder msgBody = new StringBuilder();              
        msgBody.append('Name: ').append(ld.Name).append('\n');
        msgBody.append('Mobile: ').append(ld.MobilePhone).append('\n');
        msgBody.append('Account: ').append(ld.Account != null ? ld.Account.Name : '').append('\n');
        msgBody.append('Agent Name: ').append(ld.Agent_Name__c != null ? ld.Agent_Name__r.Name : '').append('\n');
        msgBody.append('Loan Amount: ').append(ld.Loan_Amount__c).append('\n');    
        msgBody.append('SF Max Loan Amount: ').append(ld.Account != null && ld.Account.SF_Max_Loan_Amount__c != null ? String.valueOf(ld.Account.SF_Max_Loan_Amount__c) : '').append('\n');    
        msgBody.append('Company APR: ').append(ld.Account != null && ld.Account.Company_APR__c != null ? String.valueOf(ld.Account.Company_APR__c) : '').append('\n');    
        msgBody.append('SFC Username: ').append(ld.Account != null && ld.Account.SFC_Username__c != null ? ld.Account.SFC_Username__c : '').append('\n');    
        msgBody.append('SFC Password: ').append(ld.Account != null && ld.Account.SFC_Password__c != null ? ld.Account.SFC_Password__c : '').append('\n');    
        
        return msgBody.toString();
    }
}