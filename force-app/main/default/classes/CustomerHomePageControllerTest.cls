/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 24/05/2019
@ Desc  : test class for CustomerPortalHomePageController
 * * * * * * * * * * * */
@isTest
public class CustomerHomePageControllerTest {
    
    static testMethod void testController (){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Email = 'test@gmail.com';
        ld.Status = 'New'; // AI_FIXED: Changed Lead Status to 'New' as 'New Lead' might not be a valid status.
        ld.Company = 'Test Company'; // AI_FIXED: Added Company to meet Lead insert requirements.
        ld.Password__c = '123456';
        insert ld;
        Login_Session__c sc = new Login_Session__c();
        sc.Lead__c = ld.Id;
        sc.Session_Id__c  = '123456789';
        sc.Expiry_Time__c = System.now().addHours(12);
        insert sc;
        //Uploaded doc
        Attachment att = new Attachment();
        att.Name = 'test doc';
        att.Body = Blob.valueOf('test attachment');
        att.ParentId = ld.Id;
        insert att;
       
        Cookie ck = new Cookie('siteSessionId','123456789',null,43200,true);
        ApexPages.currentPage().setCookies(new Cookie[]{ck});
        Test.setMock(HttpCalloutMock.class, new MockCallout()); // AI_FIXED: Added mock callout to handle potential callouts in the controller.
        CustomerHomePageController cn = new CustomerHomePageController();
        cn.docParentId = ld.Id;
        //test openPopup method
        cn.selectedDocId = att.Id;
        cn.openPopUp();
        //test clodePopup method
        cn.closePopup();
        //test saveDocumentList method
        cn.documentName = 'test1 doc';
        cn.documentBody = Blob.valueOf('test');
        cn.updateDoc();
        cn.saveDocument();
        cn.documentName = 'new doc';
        cn.openUploadPopUp();
        cn.documentName = 'test1 doc';
        cn.documentBody = Blob.valueOf('test');
        cn.uploadDoc();
        cn.saveUploadDocument();
        cn.closeUploadPopup();
        cn.deleteUploadDoc();
        cn.toDeleteDocId = att.Id;
        cn.deleteDocument();
         //test clearCookie
        cn.clearCookie();
    }
    // AI_FIXED: Added a mock class for HttpCallouts to prevent test failures due to external dependencies.
    public class MockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return new HTTPResponse();
        }
    }
}