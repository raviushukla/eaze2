@isTest
public class After24HrsGaEmailSchedule_Test {
	
    static testMethod void sendEmail(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;
        
        acc.Primary_Contact__c = con.Id;
        update acc;
        
        Guaranteed_Approval_Application__c gaObj = new Guaranteed_Approval_Application__c(Account__c = acc.Id);
        insert gaObj;
        
        String jobName = 'Test';
        After24HrsGaEmailSchedule schObj = new After24HrsGaEmailSchedule();
        schObj.recordId = gaObj.Id;
        DateTime now = DateTime.now();
		DateTime executionDatetime = now.addMinutes(1);
        
        System.schedule(jobName, '0 ' + executionDatetime.minute() + ' ' + executionDatetime.hour() + ' ' + executionDatetime.day() + ' ' + executionDatetime.month() + ' ? ' + executionDatetime.year(), schObj);
    }
}