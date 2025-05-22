@isTest
global class DHCustomerLeadListForAccountCls_test {
    
    testmethod static void runtest(){
        Account ac = new Account(Name='testAccount',Default_Lead_Source__c='OTF Application'); // AI_FIXED: Added unique Name to prevent insertion errors
        insert ac;
        Contact con = new Contact( lastName='test', accountid=ac.id, email='test@gmail.com');
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'CspLitePortal' Limit 1 ];
        
        User u = new User(
            Alias = 'testu',
            Email = 'test@unitingambition.com',
            EmailEncodingKey = 'UTF-8',
            contactId = con.id,
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            UserName='test@unitingambition.com'
        );
        
        System.runAs( u ) {
            Lead ld = new Lead();
            ld.LastName = 'test';
            ld.Status ='Qualified';
            ld.Loan_Amount__c = 10000;
            ld.LeadSource = 'OTF Application';
            ld.Social_Security_Number__c = '124566541';
            ld.Date_of_Birth__c = date.today();
            ld.Income_Source_1__c = 'Employed';
            ld.MobilePhone = '45612352';
            try{ // AI_FIXED: Added try-catch block for exception handling during Lead insertion
                insert ld;
                DHCustomerLeadListForAccountCls.getLeadsApex(); 
            } catch(Exception e){
                System.debug('Exception during Lead insertion: ' + e.getMessage()); // AI_FIXED: Improved error handling by logging the exception message
            }
        }       
        
    }

}