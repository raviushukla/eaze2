@isTest
public class ApplicantPortal_Login_Test {
	public static testMethod void method(){
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.LastName = 'Lead';
        leadObj.Social_Security_Number__c = '123456789';
        leadObj.Email = 'Test@gmail.com';
        leadObj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        leadObj.CAN_Password__c = 'password';
        leadObj.CAN_Username__c = 'Test@gmail.com';
        insert leadObj;
        
        ApplicantPortal_Login.checkUser('Test@gmail.com', 'password');
        system.assertEquals('success', ApplicantPortal_Login.forgetPassowrd('Test@gmail.com'));
    }
}