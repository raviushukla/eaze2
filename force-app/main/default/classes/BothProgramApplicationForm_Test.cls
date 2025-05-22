@isTest
public with sharing class BothProgramApplicationForm_Test {
    testMethod static void setAccount(){
		
		Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;

		client.Primary_Contact__c = agent.Id;
		update client;
		
		system.assertEquals(String.valueOf(client.Id), BothProgramApplicationForm.findAccount('Test@test.com'));      
        system.assertNotEquals(String.valueOf(client.Id), BothProgramApplicationForm.findAccount('Test@test.c'));    
    }
    
    @isTest
    static void testUploadFiles() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            insert cv;
            testContentVersions.add(cv);
        }

        List<String> cvIdsList = new List<String>();
        for (ContentVersion cv : testContentVersions) {
            cvIdsList.add(cv.Id);
        }

        BothProgramApplicationForm.leadWrap leadObj = new BothProgramApplicationForm.leadWrap();
        leadObj.Associate = 'Test Associate';
        leadObj.Corporate_Business_Name = 'Test Corp';
        leadObj.Company_Website = 'http://www.example.com';
        leadObj.Address = '123 Main St';
        leadObj.City = 'Test City';
        leadObj.State = 'CA';
        leadObj.Zip = '12345';
        leadObj.Phone = '555-555-5555';
        leadObj.Company_Email = 'test@example.com';
        leadObj.Principal_Name_1 = 'Test Principal';
        leadObj.Been_In_Business_Years = 5.0;
        leadObj.Number_of_Sales_Agent = 10;
        leadObj.Referred_By = 'Referrer';
        leadObj.Accounting_Associate = 'Accountant';
        leadObj.Accounting_Associate_Contact_Email = 'accountant@example.com';
        leadObj.Total_Sales_For_2023 = 100000.00;
        leadObj.Business_Incorporation_State = 'CA';
        leadObj.Source_Page = '';

        // Call the method to be tested
        Test.startTest();
        BothProgramApplicationForm.uploadFiles(testAccount.Id, cvIdsList, leadObj);
        Test.stopTest();
	}
}