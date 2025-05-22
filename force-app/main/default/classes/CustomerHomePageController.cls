/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 14/05/2019
@ Desc  : Controller class for CustomerPortalHomePage vf page 
 * * * * * * * * * * * */
public without sharing class CustomerHomePageController {
    public Boolean isSessionValid{get;set;}
    public String sessionId{get;set;}
    public String selectedDocId{get;set;}
    public Boolean displayPopUp{get;set;}
    public Blob documentBody{get; set;}
    public String documentName{get;set;}
    public String toDeleteDocId{get;set;}
    public Boolean showDocumentListPopup {get;set;}
    public Lead uploadedDocumentList{get;set;} 
    public Id currentPageLeadId;
    private Attachment uploadAtt;
    public Attachment selectedDocument{get;set;}
    public Boolean displayUploadPopUp{get;set;}
    Public String docParentId{get;set;}
    public Boolean showUploadedDocument {get;set;}
    Public String docContentType{get;set;}
    public string docNameWithExt{get;set;}
    
    public CustomerHomePageController(){
        showDocumentListPopup = false;
        showUploadedDocument = false;
        displayUploadPopUp = false;
        uploadedDocumentList = new Lead();
        uploadAtt = new Attachment();
        selectedDocument = new Attachment();
        docParentId = '';
        docNameWithExt = '';
        Cookie ck = ApexPages.currentPage().getCookies().get('siteSessionId');
        system.debug('cookie is ' +ck);
        List<Login_Session__c> seesionList = new List<Login_Session__c>();
        if(ck != null)
            sessionId = ck.getValue();
           system.debug('sessionId is ' +sessionId);
        if(ck == null){
            isSessionValid = false;
        }
        else{
            seesionList  = [SELECT Lead__c, Session_Id__c, Expiry_Time__c FROM Login_Session__c WHERE Session_Id__c =:sessionId];
            system.debug('seesionList is ' +seesionList);
            if(seesionList.size() > 0 ){
                if(seesionList[0].Expiry_Time__c > System.now()) {
                    isSessionValid = true;
                    system.debug('not expire');
                    currentPageLeadId = seesionList[0].Lead__c;
                }
                else{
                    isSessionValid = false;
                     system.debug('expired');
                }
                    }
            else{
                isSessionValid = false; 
            }
        }
       
        if(isSessionValid) {
            uploadedDocumentList = [SELECT Name, Status, Loan_Amount__c, CreatedDate, (SELECT Id, Name,Description, ParentId FROM Attachments) 
                                    FROM Lead WHERE Id =:seesionList[0].Lead__c];
        }
    }
    
    public void openPopUp(){
        System.debug('selectedDocId is '+selectedDocId);
        selectedDocument = [SELECT Name, Description, ParentId FROM Attachment WHERE Id =:selectedDocId];
        showDocumentListPopup = true;
        displayPopUp = true;
    }
    
    public PageReference closePopup(){
        if(isSessionValid){
            displayPopUp = false;
            PageReference pageRef = new PageReference('/apex/CustomerPortalHomePage');
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            PageReference pageRef = new PageReference('/apex/CustomerPortalLoginPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    // update attachment while edit.
    public void updateDoc(){
        if(isSessionValid) {
            system.debug('docNameWithExt : '+docNameWithExt);
            system.debug('Ext : '+docNameWithExt.substringAfterLast('.'));
            uploadAtt = new Attachment(Id = selectedDocId);
            uploadAtt.Body = documentBody;
            uploadAtt.Name = documentName+'.'+docNameWithExt.substringAfterLast('.');
            uploadAtt.contentType = docContentType;
        }
    }
    
    // save edit attachement.
    public PageReference saveDocument(){
        if(isSessionValid) {
            if(uploadAtt.Id == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a file'));
                return null;
            }
            else{
                try {
                    update uploadAtt;
                    uploadAtt = new Attachment();
                    documentBody = null;
                    documentName = null;
                    PageReference pageRef = new PageReference('/apex/CustomerPortalHomePage');
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                catch(Exception e) {
                    System.debug('Exception while saving document is' +e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while uploading documents'));
                    return null;
                }
            }
        }
        else{
            PageReference pageRef = new PageReference('/apex/CustomerPortalLoginPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    public void deleteDocument(){
        if(isSessionValid) {
            System.debug('docId is '+ toDeleteDocId);
            if(String.isNotBlank(toDeleteDocId)){
                try{
                    Attachment toDeleteDoc = new Attachment(Id = toDeleteDocId);
                    delete toDeleteDoc;
                    selectedDocument = new Attachment();
                }
                catch (Exception e){
                    System.debug('exception while deleting attachment is: '+e);
                }
            }
        }
    }
    
    public void openUploadPopUp(){
        system.debug('docParentId : '+docParentId);
        system.debug('documentName : '+documentName);
        displayUploadPopUp = true;
    }
    
    public PageReference closeUploadPopup(){
        if(isSessionValid){
            displayUploadPopUp = false;
            documentBody = null;
            documentName = null;
            uploadAtt = new Attachment();
            selectedDocument = uploadAtt;
            PageReference pageRef = new PageReference('/apex/CustomerPortalHomePage');
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            PageReference pageRef = new PageReference('/apex/CustomerPortalLoginPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    // update attachment while upload.
    public void uploadDoc(){
        if(isSessionValid) {
            system.debug('docParentId : '+docParentId);
            system.debug('docNameWithExt : '+docNameWithExt);
            system.debug('Ext : '+docNameWithExt.substringAfterLast('.'));
            uploadAtt = new Attachment(ParentId = docParentId);
            uploadAtt.Name = documentName+'.'+docNameWithExt.substringAfterLast('.');
            uploadAtt.Body = documentBody;
            uploadAtt.contentType = docContentType;
            selectedDocument = uploadAtt;
            showUploadedDocument = true;
        }
    }
    
    public void deleteUploadDoc(){
        uploadAtt = new Attachment();
        selectedDocument = uploadAtt;
    }
    
    // update attachment while inserting new document.
    public PageReference saveUploadDocument(){
        if(isSessionValid) {
            if(uploadAtt.Name == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a file'));
                return null;
            }
            else
            {
                try{
                    insert uploadAtt;
                    uploadAtt = new Attachment();
                    documentBody = null;
                    documentName = null;
                    PageReference pageRef = new PageReference('/apex/CustomerPortalHomePage');
                    pageRef.setRedirect(true);
                    return pageRef;
                }
                catch(Exception e){
                    System.debug('Exception while uploading document is' +e);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while uploading documents'));
                    return null;
                }
            }
        }
        else{
            PageReference pageRef = new PageReference('/apex/CustomerPortalLoginPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    public PageReference clearCookie(){
        List<Login_Session__c	> toDelete = [SELECT Id, Session_Id__c FROM Login_Session__c WHERE Lead__c =:currentPageLeadId];
        if(toDelete.size() > 0 ){
            delete toDelete;
        }
        Cookie ck = new Cookie('siteSessionId', '',null,0,false); // Note the 0 to delete the cookie
        ApexPages.currentPage().setCookies(new Cookie[]{ck});
        PageReference pageRef = new PageReference('/apex/CustomerPortalLoginPage');
        pageRef.setRedirect(true);
        return pageRef;

    }
    
}