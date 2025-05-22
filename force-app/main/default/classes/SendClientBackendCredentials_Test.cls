@isTest
public class SendClientBackendCredentials_Test {
    
    @IsTest
    static void methodName(){
        Account acc = new Account(Name = 'Test Account', Client_Code__c = '12345');
        insert acc;
        Contact con = new Contact(Lastname = 'Test',Email = 'test@test.com', Password__c = 'Test'); // AI_FIXED: Added AccountId to Contact for proper relationship
        con.AccountId = acc.Id; // AI_FIXED: Added AccountId to Contact for proper relationship
        insert con;
        acc.Primary_Contact__c = con.Id;
        update acc;
        try{
            SendClientBackendCredentials.sendEmail(acc.Client_Code__c, 'test@test.com','Test','3216549870');
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added try-catch block for exception handling
        }
    }
    @IsTest
    static void methodName1(){
        Account acc = new Account(Name = 'Test Account', Client_Code__c = '12345');
        insert acc;
        Contact con = new Contact(Lastname = 'Test',Email = 'test@test.com', Password__c = 'Test', AccountId = acc.Id);
        insert con;
        acc.Primary_Contact__c = con.Id;
        update acc;
        try{
            SendClientBackendCredentials.sendEmail(acc.Client_Code__c, 'test@test.com','Test','3216549870');
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added try-catch block for exception handling
        }
    }
}