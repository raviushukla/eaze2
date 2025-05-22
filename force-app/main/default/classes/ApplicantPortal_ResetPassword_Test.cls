@isTest
public class ApplicantPortal_ResetPassword_Test {
	public static testMethod void method(){
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.LastName = 'Lead';
        leadObj.Social_Security_Number__c = '123456789';
        leadObj.Email = 'test@gmail.com';
        leadObj.RecordTypeId = [select Id,Name from RecordType where sObjectType='Lead' AND Name = 'CAN Lead'].Id;	
        leadObj.CAN_Password__c = 'password';
        leadObj.CAN_Username__c = 'Test@test.com';
        insert leadObj;
        
        Login_Session__c ls = new Login_Session__c();
        ls.Session_Id__c = '123456';
        ls.Lead__c = leadObj.Id;
        ls.Expired__c = false;
        ls.Type__c = 'Applicant Reset Password';
        ls.Applicant_Email__c =  'Test@test.com';
        insert ls;
        
        ApplicantPortal_ResetPassword.sessionCheck('123456');
        ApplicantPortal_ResetPassword.updatePassword('Umesh1234', '123456');
    }
}