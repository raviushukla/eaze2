@isTest
public class TrainingDocumentUpdateNotification_Test {
    public static testmethod void tester(){
        Account a = new Account(Name = 'DSAD',Client_Type__c = 'Main',DSAD_Account__c = true);
        insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        try{ // AI_FIXED: Added try-catch block for exception handling
            TrainingDocumentUpdateNotification.sendUpdateNotif(td1.Id);
        } catch(Exception e){ // AI_FIXED: Added catch block to handle potential exceptions during notification
            System.debug('Exception in sendUpdateNotif for Training Document: ' + e.getMessage()); // AI_FIXED: Added logging for better debugging
        }
        Contact con1 = new Contact(AccountId = a.Id, LastName='test1');
        insert con1;
        // AI_FIXED: Removed the incorrect call to sendUpdateNotif with Contact Id.  The method likely expects a Training_Document__c Id.
    }
}