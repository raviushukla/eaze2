@isTest
public class TrainingDocumentUpdateNotification_Test {
    public static testmethod void tester(){
        Account a = new Account(Name = 'DSAD',Client_Type__c = 'Main',DSAD_Account__c = true);
        Insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        TrainingDocumentUpdateNotification.sendUpdateNotif(td1.Id);
        Contact con1 = new Contact(AccountId = a.Id, LastName='test1');
        insert con1;
        TrainingDocumentUpdateNotification.sendUpdateNotif(con1.Id);
    }
}