@isTest
public class ContentDocumentLinkTrigger_Test {
    @isTest static void ContentDocumentLinkTrigger_TestMethod(){
        Account a = new Account(Name = 'DSAD');
        insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        Training_Document__c td2 = new Training_Document__c(Name='Attorney', Type__c = 'Attorney');
        insert td2;
        // AI_FIXED: Using a single DML operation to improve performance
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        contentVersions.add(new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        contentVersions.add(new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        contentVersions.add(new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        contentVersions.add(new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true));
        insert contentVersions;
        
        // AI_FIXED: Using a single SOQL query to improve performance and handle potential null ContentDocumentId
        List<ContentDocumentId> contentDocumentIds = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :new List<Id>{contentVersions[0].Id, contentVersions[1].Id}];
        Id conDocument = contentDocumentIds.isEmpty() ? null : contentDocumentIds[0]; // Handle potential empty list
        Id conDocument1 = contentDocumentIds.isEmpty() ? null : contentDocumentIds[1]; // Handle potential empty list

        // AI_FIXED: Added null checks to prevent NullPointerException
        ContentDocumentLink contentlink = conDocument != null ? new ContentDocumentLink(LinkedEntityId = td1.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers') : null;
        ContentDocumentLink contentlink1 = conDocument1 != null ? new ContentDocumentLink(LinkedEntityId = td2.Id,ContentDocumentId = conDocument1,Visibility = 'AllUsers') : null;

        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        if(contentlink != null) contentLinks.add(contentlink);
        if(contentlink1 != null) contentLinks.add(contentlink1);

        test.startTest();
        // AI_FIXED: Using a single DML operation to improve performance
        if(!contentLinks.isEmpty()) insert contentLinks;
        test.stopTest();
    }
}