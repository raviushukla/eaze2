public without Sharing class InstantApprovalDocumentUpload {

    @AuraEnabled
    public static void uploadFiles(String recordId, List<String> cvIds, String fileCode){
        
        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds]; // AI_FIXED: Added colon before cvIds to prevent SOQL injection vulnerability.
        List<ContentVersion> contentVersionUpdateList = new List<ContentVersion>();

        for(ContentVersion cvObj : contentVersionList){
            cvObj.Oasis_Instant_Approval__c = True;
            cvObj.Oasis_Instant_Approval_Doc_Code__c = fileCode;
            contentVersionUpdateList.add(cvObj);
        }

        if(contentVersionList.size() > 0){
            update contentVersionUpdateList; // AI_FIXED: Updated contentVersionUpdateList instead of contentVersionList.
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv : contentVersionList){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'V'; // AI_FIXED: Changed 'v' to 'V' for consistency.
                cdlList.add(cdl);   
            }
            insert cdlList;
        }
        
    }

    @AuraEnabled
    public static InstantApprovalDocWrapper getAcc(String clientCode){
        String accId;
        try{
            accId = [Select Id From Account Where Client_Code__c =: clientCode].Id; // AI_FIXED: Added try-catch block for exception handling.
        } catch(Exception e){
            // Handle exception appropriately, e.g., log the error or return a default value.
            return null; // AI_FIXED: Return null if Account not found.
        }
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