@isTest
public class ApplicantPortal_Home_Test {
	
    public static testMethod void method(){
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.LastName = 'Lead';
        leadObj.Social_Security_Number__c = '123456789';
        leadObj.Email = 'test@gmail.com';
        leadObj.RecordTypeId = [select Id,Name from RecordType where sObjectType='Lead' AND Name = 'CAN Lead'].Id;	
        insert leadObj;
        
        Login_Session__c ls = new Login_Session__c();
        ls.Session_Id__c = '123456789abcd';
        ls.Type__c = 'User Login';
        ls.Expired__c = false;
        insert ls;
        
        ApplicantPortal_Home.sessionCheck('123456789abcd');
        ApplicantPortal_Home.sessionCheck('');
        system.assertEquals(ApplicantPortal_Home.getLeads('test@gmail.com')[0].Id, leadObj.Id);
        
    }
}