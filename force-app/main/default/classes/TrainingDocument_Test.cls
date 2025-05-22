@isTest
public class TrainingDocument_Test {
	static testMethod void ShareTrainingDoc_TestMethod(){
        Account a = new Account(name='test acc', DSAD_Account__c = true);
        insert a;
        Contact con = new Contact(AccountId = a.Id, LastName='test');
        insert con;
        ContentVersion cv = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Attorneys',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv;
        ContentVersion cv1 = new ContentVersion(Title = '1 Page Summary Template - 3rd Party Funding - Updated - V2 - Main',PathOnClient = 'TestDocument.pdf',
                                               VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        Insert cv1;
        
        Training_Document__c td1 = new Training_Document__c(Name='Main', Type__c = 'Main');
        insert td1;
        
        Training_Document__c td2 = new Training_Document__c(Name='Attorney', Type__c = 'Attorney');
        insert td2;
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId;
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = td1.Id,ContentDocumentId = conDocument,Visibility = 'AllUsers');
        insert contentlink;
        ContentDocumentLink contentlink1=new ContentDocumentLink(LinkedEntityId = td2.Id,ContentDocumentId = conDocument1,Visibility = 'AllUsers');
        insert contentlink1;
        ShareTrainingDoc.getMasterDoc1Link();
        ShareTrainingDoc.getMasterDoc2Link();
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = cv.Id;
        //insert cd;  
        
        test.startTest();
        TrainingDocument.networkInfo();
        TrainingDocument.fetchMappingValues();
        TrainingDocument.fetchAgentInfo(con.Id);
        TrainingDocument.fetchMasterTemplate('main');
        TrainingDocument.fetchMasterTemplate('attorney');
        TrainingDocument.fetchToken();
        test.stopTest();
    }
}