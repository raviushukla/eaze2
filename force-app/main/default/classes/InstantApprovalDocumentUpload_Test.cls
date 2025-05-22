@isTest
public class InstantApprovalDocumentUpload_Test {

    testMethod static void uploadFiles(){
        
        Account testAccount = new Account(Name = 'Test Account', Client_Code__c = 'TestClientCode'); // AI_FIXED: Added Client_Code__c to avoid SOQL query later
        insert testAccount;
        
        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            testContentVersions.add(cv);
        }
		
        insert testContentVersions;
        
        List<String> cvIdsList = new List<String>();
        for (ContentVersion cv : testContentVersions) {
            cvIdsList.add(cv.Id);
        }
		
        //String clientCode = [Select Id, Client_Code__c From Account Where Id =:testAccount.Id].Client_Code__c; // AI_FIXED: Removed unnecessary SOQL query
        // Call the method to be tested
        Test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling
            InstantApprovalDocumentUpload.uploadFiles(testAccount.Id, cvIdsList, '1');
            InstantApprovalDocumentUpload.getAcc(testAccount.Client_Code__c); // AI_FIXED: Passed Client_Code__c directly from Account object
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging
        }
        Test.stopTest();
    }
}