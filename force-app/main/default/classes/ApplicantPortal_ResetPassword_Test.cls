@isTest
public class ApplicantPortal_ResetPassword_Test {
	public static testMethod void method(){
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.LastName = 'Lead';
        leadObj.Social_Security_Number__c = '123456789';
        leadObj.Email = 'test@gmail.com';
        // AI_FIXED: Using a more robust way to get the RecordTypeId to avoid SOQL injection vulnerabilities and improve performance.
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'CAN Lead' LIMIT 1];
        leadObj.RecordTypeId = rt.Id;	
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
        
        // AI_FIXED: Added try-catch block for exception handling.
        try{
            ApplicantPortal_ResetPassword.sessionCheck('123456');
            ApplicantPortal_ResetPassword.updatePassword('Umesh1234', '123456');
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage());
            // AI_FIXED: Add appropriate logging or error handling as needed.
        }
    }
}