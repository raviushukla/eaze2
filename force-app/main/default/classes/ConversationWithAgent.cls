public class ConversationWithAgent {
    // fetching agent/contacts.
    @AuraEnabled
    public static object fetchGroups(){
        
        //Integer fromDate = Integer.valueOf(Label.From_Months);
        //Date dt = Date.today().addMonths(-fromDate);
        
        List<Telegram_Group__c> groups = [SELECT Name FROM Telegram_Group__c WHERE Chat_Id__c != null ORDER by Latest_Message_Timestamp__c DESC NULLS LAST];
        return groups;
    }
    
    // fetching records form twilio sms.
    @AuraEnabled
    public static object fetchConversation(String groupId){
        List<Telegram_Message__c> convr = [SELECT Message__c, 
                                           Type__c,
                                           Telegram_Group_Member__r.Member_Name__c,
                                           CreatedDate, 
                                           Status__c 
                                           FROM Telegram_Message__c 
                                           WHERE Telegram_Group__c =: groupId
                                           //AND Medium__c = 'Telegram'
                                           Order By CreatedDate ASC];
        return convr;
    }
    
    @AuraEnabled
    public static object sendMessage(String groupId,String smsBody){
        List<Telegram_Group__c> gp = [Select Client__c From Telegram_Group__c Where Id =: groupId Limit 1];
        Telegram_Message__c msg = new Telegram_Message__c(
            Telegram_Group__c = groupId,
            Message__c=smsBody,
            Type__c = 'Outgoing',
            //Telegram_Group_Member__c = '',
            Status__c = 'Sent'
        );
        if( gp[0].Client__c != null ){
            msg.Client__c = gp[0].Client__c;
        }
        try{
        	insert msg;
            system.debug('sms Id : '+msg.Id);
            return 'success';
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
    
    // fetching unread messages
    @AuraEnabled
    public static object fetchNotification(){
        List<Telegram_Message__c> convr = [SELECT Message__c,
                                     Telegram_Group__c,
                                     Telegram_Group__r.Name,
                                     Telegram_Group_Member__r.Member_Name__c,
                                     CreatedDate
                                     FROM Telegram_Message__c 
                                     WHERE Type__c = 'Incoming' 
                                     AND Unseen__c = true
                                     Order By CreatedDate DESC];
        
        return convr;
    }
    
    // mark messages as read for selected client
    @AuraEnabled
    public static string markSMSasRead(List<String> twilioSmsIds){
        try{
            system.debug('twilioSmsIds : '+twilioSmsIds);
            List<Telegram_Message__c> twList = new List<Telegram_Message__c>();
            for(String twId: twilioSmsIds){
                Telegram_Message__c tw = new Telegram_Message__c(
                	Id = twId,
                    Unseen__c = false
                );
                twList.add(tw);
            }
            update twList;
            return 'success';
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
}