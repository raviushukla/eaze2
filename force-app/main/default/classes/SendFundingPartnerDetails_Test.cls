@isTest
public class SendFundingPartnerDetails_Test {
	
    static testMethod void sendEmail(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;
        
        acc.Primary_Contact__c = con.Id;
        update acc;
        
        SendFundingPartnerDetails.sendEmail(acc.Id);
    }
}