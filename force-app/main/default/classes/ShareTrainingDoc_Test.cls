@isTest
public class ShareTrainingDoc_Test {
    static testMethod void ShareTrainingDoc_TestMethod(){
        Account a = new Account(name='test acc');
        insert a;
        ContentVersion cv = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv;
        ContentVersion cv1 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert cv1;
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId; // AI_FIXED: Removed unnecessary SOQL query for conDocument1, using the same method as conDocument
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = a.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers');
        insert contentlink;
        ContentDocumentLink contentlink1=new ContentDocumentLink(LinkedEntityId = a.Id,ContentDocumentId = conDocument1,Visibility = 'AllUsers');
        insert contentlink1;
        ShareTrainingDoc.getMasterDoc1Link();
        ShareTrainingDoc.getMasterDoc2Link();
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = cv.Id;
        //insert cd;  
        
        test.startTest();
        ShareTrainingDoc.currentSitePathPrefix();
        ShareTrainingDoc.currentSitePrefix();
        ShareTrainingDoc.fetchMasterAccountInfo();
        ShareTrainingDoc.fetchTainingDocValueMapping(); // AI_FIXED: Corrected typo in method name
        ShareTrainingDoc.getMasterDoc1Link();
        ShareTrainingDoc.fetchMasterFile1();
        ShareTrainingDoc.getMasterDoc2Link();
        ShareTrainingDoc.fetchMasterFile2();
        ShareTrainingDoc.fetchAgents();
        test.stopTest();
    }
}