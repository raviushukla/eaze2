// Test Class -> LwcUnsubscribePrimaryContact_Test
public without sharing class LwcUnsubscribePrimaryContactController {
    
    @AuraEnabled
    public static boolean updateContact(string email){
        boolean recordUpdated = false;
        try {
           List<Contact> conList = [Select Id from Contact Where Email=:email LIMIT 1];
           if(conList.size()>0){
                conList[0].HasOptedOutOfEmail = true;
                update conList[0];
                recordUpdated = true; 
           } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return recordUpdated;
    }
}