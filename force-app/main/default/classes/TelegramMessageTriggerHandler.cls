public class TelegramMessageTriggerHandler {
    public Static void insertTelegramGroup(List<Telegram_Message__c> triggerNew) {

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
            for(Contact con: [Select AccountId From Contact Where Id IN: conIds]){
                accIds.add(con.AccountId);
                conAccIdMap.put(con.Id, con.AccountId);
            }
        }
        if(conIdsToGetMemeber.size()>0){
            for(Telegram_Group_Member__c tgm: [Select Agent__c, Agent__r.Name, User_Name__c From Telegram_Group_Member__c Where Agent__c IN: conIdsToGetMemeber AND User_Name__c != null]){
                tgmUserMap.put(tgm.Agent__c, tgm);
            }
        }
        System.debug('tgmUserMap : '+tgmUserMap);
        if(accIds.size()>0){
            List<Telegram_Group__c> telegramGp = [Select Client__c From Telegram_Group__c Where Client__c IN: accIds];
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
        }
    }
    
    // this method delete telegram message form Telegram.
    public static void deleteTeleMssFromTelegram(List<Telegram_Message__c> triggerOld){
        List<String> chatAndMessageIds = new List<String>();
        for(Telegram_Message__c teleMsg: triggerOld){
            if(String.IsNotBlank(teleMsg.Chat_Id__c) && String.IsNotBlank(teleMsg.Message_Id__c)){
                chatAndMessageIds.add(teleMsg.Chat_Id__c+'@'+teleMsg.Message_Id__c);
            }
        }
        if(chatAndMessageIds.size()>0){
            deleteTeleMessage(chatAndMessageIds);
        }
    }
    @future(callout=true)
    public static void deleteTeleMessage(List<String> chatAndMessageIds){
        for(String ids: chatAndMessageIds){
            String chatId = ids.split('@')[0];
            String MessageId = ids.split('@')[1];
            TelegramApiClass.deleteMessage(chatId, MessageId);
        }
    }
}