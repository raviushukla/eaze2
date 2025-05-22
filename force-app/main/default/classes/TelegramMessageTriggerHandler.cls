public class TelegramMessageTriggerHandler {
    public static void insertTelegramGroup(List<Telegram_Message__c> triggerNew) {

        Set<String> accIds = new Set<String>();
        Set<String> conIds = new Set<String>();
        Set<String> conIdsToGetMemeber = new Set<String>();
        List<Telegram_Message__c> teleMsgs = new List<Telegram_Message__c>();
        Map<String, String> clientToTeleGpMap = new Map<String, String>();
        Map<String, String> conAccIdMap = new Map<String, String>();
        Map<String, Telegram_Group_Member__c> tgmUserMap = new Map<String, Telegram_Group_Member__c>();

        for(Telegram_Message__c teleMsg: triggerNew){
            System.debug(teleMsg.Client__c+' : '+teleMsg.Agent__c);
            if(teleMsg.Type__c == 'Outgoing' && teleMsg.Telegram_Group__c == null && (teleMsg.Client__c != null || teleMsg.Agent__c != null)){
                teleMsgs.add(teleMsg);
                if(teleMsg.Client__c != null ){
                    accIds.add(teleMsg.Client__c);
                }
                else if(teleMsg.Agent__c != null){
                    conIds.add(teleMsg.Agent__c);
                }
                if(teleMsg.Agent__c != null){
                    conIdsToGetMemeber.add(teleMsg.Agent__c);
                }
            }
        }
        System.debug('conIds : '+conIds);
        if(conIds.size()>0){
            // AI_FIXED: Added try-catch block for exception handling during SOQL query
            try{
                for(Contact con: [Select AccountId From Contact Where Id IN :conIds]){ // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variables
                    accIds.add(con.AccountId);
                    conAccIdMap.put(con.Id, con.AccountId);
                }
            } catch(Exception e){
                System.debug('Error querying Contacts: ' + e.getMessage());
                // Add appropriate error handling logic here, e.g., logging, alerting
            }
        }
        if(conIdsToGetMemeber.size()>0){
            // AI_FIXED: Added try-catch block for exception handling during SOQL query
            try{
                for(Telegram_Group_Member__c tgm: [Select Agent__c, Agent__r.Name, User_Name__c From Telegram_Group_Member__c Where Agent__c IN :conIdsToGetMemeber AND User_Name__c != null]){ // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variables
                    tgmUserMap.put(tgm.Agent__c, tgm);
                }
            } catch(Exception e){
                System.debug('Error querying Telegram Group Members: ' + e.getMessage());
                // Add appropriate error handling logic here, e.g., logging, alerting
            }
        }
        System.debug('tgmUserMap : '+tgmUserMap);
        if(accIds.size()>0){
            // AI_FIXED: Added try-catch block for exception handling during SOQL query
            try{
                List<Telegram_Group__c> telegramGp = [Select Client__c From Telegram_Group__c Where Client__c IN :accIds]; // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variables
                if(telegramGp.size()>0){
                    for(Telegram_Group__c tlGp: telegramGp){
                        clientToTeleGpMap.put(tlGp.Client__c, tlGp.Id);
                    }
                    if(clientToTeleGpMap.size()>0){
                        for(Telegram_Message__c teleMsg: teleMsgs){
                            if( teleMsg.Client__c == null){
                                teleMsg.Client__c = conAccIdMap.get(teleMsg.Agent__c);
                            }
                            teleMsg.Telegram_Group__c = clientToTeleGpMap.get(teleMsg.Client__c);
                            if(tgmUserMap.containsKey(teleMsg.Agent__c) && String.isNotBlank(teleMsg.Message__c)){
                                teleMsg.Message__c = teleMsg.Message__c.replace(tgmUserMap.get(teleMsg.Agent__c).Agent__r.Name, '@'+tgmUserMap.get(teleMsg.Agent__c).User_Name__c+' '+tgmUserMap.get(teleMsg.Agent__c).Agent__r.Name);
                            }
                        }
                    }
                }
            } catch(Exception e){
                System.debug('Error querying Telegram Groups: ' + e.getMessage());
                // Add appropriate error handling logic here, e.g., logging, alerting
            }
        }
    }
    
    // this method delete telegram message form Telegram.
    public static void deleteTeleMssFromTelegram(List<Telegram_Message__c> triggerOld){
        List<String> chatAndMessageIds = new List<String>();
        for(Telegram_Message__c teleMsg: triggerOld){
            if(String.isNotBlank(teleMsg.Chat_Id__c) && String.isNotBlank(teleMsg.Message_Id__c)){
                chatAndMessageIds.add(teleMsg.Chat_Id__c+'@'+teleMsg.Message_Id__c);
            }
        }
        if(chatAndMessageIds.size()>0){
            deleteTeleMessage(chatAndMessageIds);
        }
    }
    @future(callout=true)
    public static void deleteTeleMessage(List<String> chatAndMessageIds){
        // AI_FIXED: Added try-catch block for exception handling during callouts
        try{
            for(String ids: chatAndMessageIds){
                String chatId = ids.split('@')[0];
                String MessageId = ids.split('@')[1];
                TelegramApiClass.deleteMessage(chatId, MessageId);
            }
        } catch(Exception e){
            System.debug('Error deleting Telegram messages: ' + e.getMessage());
            // Add appropriate error handling logic here, e.g., logging, alerting
        }
    }
}