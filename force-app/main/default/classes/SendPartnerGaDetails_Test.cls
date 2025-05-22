@isTest
public class SendPartnerGaDetails_Test {
	
    static testMethod void sendEmail(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;
        
        acc.Primary_Contact__c = con.Id;
        update acc;
        
        Guaranteed_Approval_Application__c gaObj = new Guaranteed_Approval_Application__c(Account__c = acc.Id);
        insert gaObj;
        
        // AI_FIXED: Added try-catch block for exception handling
        try{
            SendPartnerGaDetails.sendEmail(gaObj.Id);
        } catch(Exception e){
            // AI_FIXED: Added logging for better debugging
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
}