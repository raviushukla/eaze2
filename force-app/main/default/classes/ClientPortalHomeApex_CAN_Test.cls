@isTest
public class ClientPortalHomeApex_CAN_Test {
	public static testMethod void method(){
        Account acc = new Account(Name='test');
        insert acc;
        Login_Session__c  ls = new Login_Session__c(
            Session_Id__c='abc', 
            Type__c = 'User Login',
            Expired__c = false);
        insert ls;
        Test.startTest();
        ClientPortalHomeApex_CAN.fetchUserInfo();
        ClientPortalHomeApex_CAN.sessionCheck(ls.Session_Id__c);
        ClientPortalHomeApex_CAN.fetchAccInfo(acc.Id);
        Test.stopTest();
    }
   
}