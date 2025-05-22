@isTest
public class ContentDocumentLinkTrigger_Test {
    @istest static void ContentDocumentLinkTrigger_TestMethod(){
        Account a = new Account(Name = 'DSAD');
        Insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        Training_Document__c td2 = new Training_Document__c(Name='Attorney', Type__c = 'Attorney');
        insert td2;
        ContentVersion cv = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv;
        ContentVersion cv1 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv1;
        
        ContentVersion cv2 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv2;
        ContentVersion cv3 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv3;
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;
        
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = td1.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers');
        ContentDocumentLink contentlink1=new ContentDocumentLink(LinkedEntityId = td2.Id,ContentDocumentId = conDocument1,Visibility = 'AllUsers');
        
        test.startTest();
        insert contentlink;
        insert contentlink1;
        test.stopTest();
    }
}