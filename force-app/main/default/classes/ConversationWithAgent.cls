public class ConversationWithAgent {
    // fetching agent/contacts.
    @AuraEnabled(cacheable=true) // AI_FIXED: Added cacheable=true for performance improvement
    public static List<Telegram_Group__c> fetchGroups(){ // AI_FIXED: Changed return type to List<Telegram_Group__c> for better type safety
        
        //Integer fromDate = Integer.valueOf(Label.From_Months);
        //Date dt = Date.today().addMonths(-fromDate);
        
        List<Telegram_Group__c> groups = [SELECT Name, Chat_Id__c, Latest_Message_Timestamp__c FROM Telegram_Group__c WHERE Chat_Id__c != null ORDER by Latest_Message_Timestamp__c DESC NULLS LAST]; // AI_FIXED: Added Chat_Id__c and Latest_Message_Timestamp__c to the SELECT clause to avoid unnecessary SOQL queries later.
        return groups;
    }
    
    // fetching records form twilio sms.
    @AuraEnabled(cacheable=true) // AI_FIXED: Added cacheable=true for performance improvement
    public static List<Telegram_Message__c> fetchConversation(String groupId){ // AI_FIXED: Changed return type to List<Telegram_Message__c> for better type safety
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
    public static String sendMessage(String groupId,String smsBody){ // AI_FIXED: Changed return type to String for better type safety
        List<Telegram_Group__c> gp = [Select Client__c From Telegram_Group__c Where Id =: groupId Limit 1];
        Telegram_Message__c msg = new Telegram_Message__c(
            Telegram_Group__c = groupId,
            Message__c=smsBody,
            Type__c = 'Outgoing',
            //Telegram_Group_Member__c = '',
            Status__c = 'Sent'
        );
        if(gp != null && !gp.isEmpty() && gp[0].Client__c != null ){ // AI_FIXED: Added null and empty checks to prevent NullPointerException
            msg.Client__c = gp[0].Client__c;
        }
        try{
        	insert msg;
            system.debug('sms Id : '+msg.Id);
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'Error sending message: ' + ex.getMessage(); // AI_FIXED: Improved error message
        }
    }
    
    // fetching unread messages
    @AuraEnabled(cacheable=true) // AI_FIXED: Added cacheable=true for performance improvement
    public static List<Telegram_Message__c> fetchNotification(){ // AI_FIXED: Changed return type to List<Telegram_Message__c> for better type safety
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
    public static String markSMSasRead(List<String> twilioSmsIds){ // AI_FIXED: Changed return type to String for better type safety
        try{
            system.debug('twilioSmsIds : '+twilioSmsIds);
            List<Telegram_Message__c> twList = new List<Telegram_Message__c>();
            for(String twId: twilioSmsIds){
                twList.add(new Telegram_Message__c(Id = twId, Unseen__c = false)); // AI_FIXED: Simplified object creation
            }
            update twList;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'Error marking messages as read: ' + ex.getMessage(); // AI_FIXED: Improved error message
        }
    }
}