public class TelegramGroupTriggerHelper {
    public static void updateTelegramGroupOnAccount(List<Telegram_Group__c> triggerNew , Map<Id, Telegram_Group__c> triggerOldMap){
        Map<String, Id> accIdToTeleGpIdMap = new Map<String, Id>(); // AI_FIXED: Changed String to Id for the value in the map to correctly store Ids.
        Set<Id> removeTeleGpAccIds = new Set<Id>(); // AI_FIXED: Changed Set<String> to Set<Id> for correct Id storage.

        for(Telegram_Group__c tg: triggerNew){
            // handle update
            if(triggerOldMap != null && tg.Client__c != triggerOldMap.get(tg.Id).Client__c){
                if(tg.Client__c != null ){
                    accIdToTeleGpIdMap.put(tg.Client__c, tg.Id);
                }
                if(triggerOldMap.get(tg.Id).Client__c != null) { // AI_FIXED: Added null check to prevent NullPointerException
                    removeTeleGpAccIds.add(triggerOldMap.get(tg.Id).Client__c);
                }
                system.debug('@@@@@ : Update Transaction.');
            }
            // handle insert
            else if(triggerOldMap == null && tg.Client__c != null){
                accIdToTeleGpIdMap.put(tg.Client__c, tg.Id);
                system.debug('@@@@@ : Insert Transaction.');
            }
        }
        // remove telegram group id on Accounts in case of update.
        if(removeTeleGpAccIds.size()>0){
            List<Account> accList = [SELECT Telegram_Group__c FROM Account WHERE Id IN :removeTeleGpAccIds]; // AI_FIXED: Removed unnecessary parentheses around removeTeleGpAccIds
            for(Account acc: accList){
                acc.Telegram_Group__c = null;
            }
            update accList;
        }
        // add telegram group id on Accounts in case of insert.
        if(accIdToTeleGpIdMap.size()>0){
            List<Account> accList = [SELECT Id, Telegram_Group__c FROM Account WHERE Id IN :accIdToTeleGpIdMap.keySet()]; // AI_FIXED: Added Id to SELECT clause to avoid unnecessary SOQL query in the next loop.
            for(Account acc: accList){
                acc.Telegram_Group__c = accIdToTeleGpIdMap.get(acc.Id);
            }
            update accList;
        }
    }
}