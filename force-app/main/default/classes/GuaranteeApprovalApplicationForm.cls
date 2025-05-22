public without Sharing class GuaranteeApprovalApplicationForm {
	
    @AuraEnabled
    public static String findAccount(String businessEmail, String businessName, String phone, String principalPhone1, String principalPhone2, String principalName1, String principalName2, String clientDBA){
        // AI_FIXED: Added null checks and trimmed inputs to prevent errors and improve query efficiency.
        businessEmail = String.isBlank(businessEmail) ? null : businessEmail.trim();
        businessName = String.isBlank(businessName) ? null : businessName.trim();
        phone = String.isBlank(phone) ? null : phone.trim();
        principalPhone1 = String.isBlank(principalPhone1) ? null : principalPhone1.trim();
        principalPhone2 = String.isBlank(principalPhone2) ? null : principalPhone2.trim();
        principalName1 = String.isBlank(principalName1) ? null : principalName1.trim();
        principalName2 = String.isBlank(principalName2) ? null : principalName2.trim();
        clientDBA = String.isBlank(clientDBA) ? null : clientDBA.trim();

        String accId = '';
        List<Account> accList = new List<Account>();
        try{
            // AI_FIXED: Improved SOQL query for better performance and readability.  Used binding instead of string concatenation.
            accList = [SELECT Id FROM Account WHERE 
                       (Primary_Contact_Email_Formula__c = :businessEmail) 
                       OR (Primary_Contact_Phone__c = :principalPhone1 OR Primary_Contact_Phone__c = :principalPhone2 OR Primary_Contact_Phone__c = :phone) 
                       OR Name = :businessName OR Name = :clientDBA
                       OR (Primary_Contact__r.Name = :principalName1 OR Primary_Contact__r.Name = :principalName2)
                       ORDER BY CreatedDate DESC
                       LIMIT 1];
        } catch(Exception ex){
            // AI_FIXED: Added exception handling to gracefully handle potential errors during SOQL query.
            System.debug('Error in findAccount: ' + ex.getMessage());
        }
        if(accList.size() > 0){
            accId = accList[0].Id;
        }
        return accId;
    }
    
    
    @AuraEnabled
    public static void uploadFiles(String recordId, List<String> cvIdsList){
        
        if(recordId == null || recordId.isEmpty() || cvIdsList == null || cvIdsList.isEmpty()){
            // AI_FIXED: Added null checks for recordId and cvIdsList to prevent errors.
            return;
        }

        // AI_FIXED: Added try-catch block for exception handling during DML operations.
        try{
            //Get Content Documents
            List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvIdsList];
            
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv : contentVersionList){
             	ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdlList.add(cdl);   
            }
            insert cdlList;
        } catch(DmlException e){
            // AI_FIXED: Improved error handling by logging the exception details.
            System.debug('DML Exception during file upload: ' + e.getMessage() + ' - ' + e.getLineNumber());
            // AI_FIXED: Added more specific exception handling for better error reporting.
            throw new AuraHandledException('Error uploading files. Please contact support.');
        } catch(Exception e){
            // AI_FIXED: Added generic exception handling to catch unexpected errors.
            System.debug('Unexpected Exception during file upload: ' + e.getMessage() + ' - ' + e.getLineNumber());
            throw new AuraHandledException('An unexpected error occurred. Please contact support.');
        }
        
    }
    
}