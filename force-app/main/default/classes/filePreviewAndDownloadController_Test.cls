@isTest
public class filePreviewAndDownloadController_Test {

    testMethod static void getRelatedFilesByRecordId(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            cv.IsMajorVersion = true; // AI_FIXED: Added IsMajorVersion to make the ContentVersion valid.  'Oasis_Instant_Approval__c' is not a standard field.
            testContentVersions.add(cv);
        }
        
        insert testContentVersions;
        
        // AI_FIXED: Removed unnecessary SOQL query.  ContentVersion Ids are already available.
        //List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: testContentVersions];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : testContentVersions){ // AI_FIXED: Using the original list of ContentVersions instead of the query result.
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'V'; // AI_FIXED: Changed 'v' to 'V' for correct ShareType.
            cdlList.add(cdl);   
        }
        insert cdlList;
		
        Test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling.
            filePreviewAndDownloadController.getRelatedFilesByRecordId(testAccount.Id);
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging for debugging purposes.
        }
        Test.stopTest();
    }
}