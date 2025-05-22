public without sharing class GuaranteeApprovalApplication {

    @AuraEnabled
    public static String findAccount(String Email){
        String accId = '';
        List<Account> accList = [Select Id from Account Where Primary_Contact_Email_Formula__c =: Email LIMIT 1]; // AI_FIXED: Removed unnecessary space in SOQL query
        if(accList.size() > 0){
            return accList[0].Id;
        }
        return accId;
    }
    
    @AuraEnabled
    public static void uploadFiles(String recordId,Map<String, String> fileNameBase64Map){ // AI_FIXED: Changed Map key type to String for better clarity and handling
        List<ContentVersion> cvList = new List<ContentVersion>();
        try{
            for(String fileName : fileNameBase64Map.keySet()){ // AI_FIXED: Changed loop variable type to String
                ContentVersion cvObj = new ContentVersion();
                cvObj.Title = fileName; // AI_FIXED: Removed unnecessary String.valueOf() conversion
                cvObj.PathOnClient = fileName; // AI_FIXED: Removed unnecessary String.valueOf() conversion
                cvObj.VersionData = EncodingUtil.base64Decode(fileNameBase64Map.get(fileName)); // AI_FIXED: Removed unnecessary String.valueOf() conversion
                cvObj.IsMajorVersion = true;
                cvList.add(cvObj);
            }
            insert cvList;

            //Get Content Documents.  This query is inefficient and unnecessary.  The ContentDocumentId is available immediately after insert.
            //List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList]; // AI_FIXED: Removed inefficient query

            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv : cvList){ // AI_FIXED: Use the original cvList instead of querying again.
                ContentDocumentLink cdl = new ContentDocumentLink(); // AI_FIXED: Corrected capitalization
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = cv.ContentDocumentId; // AI_FIXED: Access ContentDocumentId directly from the ContentVersion object.
                cdlList.add(cdl);   
            }
            insert cdlList;
        } catch(Exception e){ // AI_FIXED: Added try-catch block for exception handling
            System.debug('Error uploading files: ' + e.getMessage()); // AI_FIXED: Added error logging
            throw new AuraHandledException('An error occurred while uploading files.'); // AI_FIXED: Throw a user-friendly exception
        }
    }
}