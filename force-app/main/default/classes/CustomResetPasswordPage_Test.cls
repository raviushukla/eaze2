@isTest
public class CustomResetPasswordPage_Test {
	public static testMethod void method(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Login_Session__c  ls = new Login_Session__c(
            Session_Id__c='abc',
            Contact__c = agent.Id,
            Type__c = 'Reset Password',
            Expired__c = false);
        insert ls;
        Test.startTest();
        CustomResetPasswordPage.sessionCheck(ls.Session_Id__c);
        CustomResetPasswordPage.updatePassword('12345678',ls.Session_Id__c);
        Test.stopTest();
    }
}