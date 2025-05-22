public without Sharing class InstantApprovalDocumentUpload {

    @AuraEnabled
    public static void uploadFiles(String recordId, List<String> cvIds, String fileCode){
        
        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvIds];
        List<ContentVersion> contentVersionUpdateList = new List<ContentVersion>();

        for(ContentVersion cvObj : contentVersionList){
            //contentVersionList[0].Title = fileTitle;
            cvObj.Oasis_Instant_Approval__c = True;
            cvObj.Oasis_Instant_Approval_Doc_Code__c = fileCode;
            contentVersionUpdateList.add(cvObj);
        }

        if(contentVersionList.size() > 0){
            update contentVersionList;
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv : contentVersionList){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'v';
                cdlList.add(cdl);   
            }
            insert cdlList;
        }
        
    }

    @AuraEnabled
    public static InstantApprovalDocWrapper getAcc(String clientCode){
        String accId = [Select Id From Account Where Client_Code__c =: clientCode].Id;
        List<ContentDistribution> contentDisObjList = new List<ContentDistribution>();
        List<Id> contentDocIds = new List<Id>();
        List<ContentDocumentLink> contentDocLinkList = [SELECT  ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:accId];
        for(ContentDocumentLink obj : contentDocLinkList){
            contentDocIds.add(obj.ContentDocumentId);
        }
        List<ContentVersion> contentVerList = [Select Id, Title, Oasis_Instant_Approval_Doc_Code__c, FileExtension, CreatedDate From ContentVersion Where ContentDocumentId IN:contentDocIds AND Oasis_Instant_Approval__c = True];
        
        InstantApprovalDocWrapper wrapperObj = new InstantApprovalDocWrapper(accId, contentVerList);
        return wrapperObj;
        
    }

    public class InstantApprovalDocWrapper {
        @AuraEnabled
        public String accId {get; set;}
        @AuraEnabled
        public List<ContentVersion> contentVerList {get; set;}      
        public InstantApprovalDocWrapper(String accId, List<ContentVersion> contentVerList){
            this.accId = accId;
            this.contentVerList = contentVerList;
        }                  
    }
}