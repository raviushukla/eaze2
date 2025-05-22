@isTest
public with sharing class LwcUnsubscribePrimaryContact_Test {

    @IsTest
    static void methodName(){
        Contact con = new Contact(LastName = 'Test', Email = 'test@test.com');
        insert con;
        Test.startTest();
        LwcUnsubscribePrimaryContactController.updateContact(con.Email);
        Test.stopTest();
        
    }
}