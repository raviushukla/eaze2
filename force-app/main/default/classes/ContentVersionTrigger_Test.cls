@isTest
public class ContentVersionTrigger_Test {
    @isTest static void ContentVersionTestMethod(){
        Account a = new Account(Name = 'DSAD',Client_Type__c = 'Attorney',DSAD_Account__c = true);
        insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        Training_Document__c td2 = new Training_Document__c(Name='Attorney', Type__c = 'Attorney');
        insert td2;
        ContentVersion cv = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv;
        ContentVersion cv1 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv1;
        
        ContentVersion cv2 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv2;
        
        ContentVersion cv3 = new ContentVersion(Title = 'clientlogo',PathOnClient = 'clientlogo.jpg',
                                                VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv3;
       
        // AI_FIXED: Using a single SOQL query to fetch all ContentDocumentIds for better performance
        List<ContentVersion> cvs = new List<ContentVersion>{cv,cv1,cv3};
        Map<Id, Id> contentDocumentIds = new Map<Id, Id>();
        for(ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvs.Id]){
            contentDocumentIds.put(conVer.Id, conVer.ContentDocumentId);
        }
        Id conDocument = contentDocumentIds.get(cv.Id);
        Id conDocument1 = contentDocumentIds.get(cv1.Id);
        Id conDocument3 = contentDocumentIds.get(cv3.Id);
        
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = td1.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers');
        insert contentlink;
        
        ContentDocumentLink contentlink1=new ContentDocumentLink(LinkedEntityId = td2.Id,ContentDocumentId = conDocument1,Visibility = 'AllUsers');
        insert contentlink1;
        
        ContentDocumentLink contentlink3=new ContentDocumentLink(LinkedEntityId = a.Id,ContentDocumentId = conDocument3,Visibility = 'AllUsers');
        insert contentlink3;
        
        ContentVersionTriggerHelper.handleNewDocUpload(new set<Id>{td1.Id,td2.Id});
    }
    @isTest static void saveAsAttachment(){
        Account a = new Account(Name = 'DSAD',Client_Type__c = 'Attorney',DSAD_Account__c = true);
        insert a;
        
        ContentVersion cv = new ContentVersion(Title = 'clientlogo',PathOnClient = 'clientlogo.JPG',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv;
        
        // AI_FIXED: Using a single SOQL query to fetch ContentDocumentId for better performance
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = a.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers');
        insert contentlink;
    }
}