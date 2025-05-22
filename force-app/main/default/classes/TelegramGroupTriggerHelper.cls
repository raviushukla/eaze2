public class TelegramGroupTriggerHelper {
    public static void updateTelegramGroupOnAccount(List<Telegram_Group__c> triggerNew , Map<Id, Telegram_Group__c> triggerOldMap){
        Map<String, String> accIdToTeleGpIdMap = new Map<String, String>();
        Set<String> removeTeleGpAccIds = new Set<String>();
        for(Telegram_Group__c tg: triggerNew){
            // handle update
            if(triggerOldMap != null && tg.Client__c != triggerOldMap.get(tg.Id).Client__c){
                if(tg.Client__c != null ){
                    accIdToTeleGpIdMap.put(tg.Client__c, tg.Id);
                }
                removeTeleGpAccIds.add(triggerOldMap.get(tg.Id).Client__c);
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
            List<Account> accList = [SELECT Telegram_Group__c FROM Account WHERE Id IN: removeTeleGpAccIds];
            for(Account acc: accList){
                acc.Telegram_Group__c = null;
            }
            update accList;
        }
        // add telegram group id on Accounts in case of insert.
        if(accIdToTeleGpIdMap.size()>0){
            List<Account> accList = [SELECT Telegram_Group__c FROM Account WHERE Id IN: accIdToTeleGpIdMap.keySet()];
            for(Account acc: accList){
                acc.Telegram_Group__c = accIdToTeleGpIdMap.get(acc.Id);
            }
            update accList;
        }
    }
}