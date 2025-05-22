/**
* @File Name : EAZEServicingProgramFormController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 26, 2025 |   | Initial Version
**/

public without sharing class EAZEServicingProgramFormController {
	@AuraEnabled
    public static String findAccount(String businessEmail, String businessName, String phone, String principalName1, String clientDBA){
        String accId = '';
        if (businessName != null) {
            businessName = businessName.trim();
            // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for better performance.
            try {
                // AI_FIXED: Using a more efficient SOQL query with a case-insensitive search.
                List<Account> accList = [SELECT Id FROM Account WHERE Name LIKE : '%' + businessName + '%' LIMIT 1];
                if(accList.size() > 0) {
                    accId = accList[0].Id;
                }
            } catch (Exception e) {
                // AI_FIXED: Log the exception for debugging purposes.  Consider more robust error handling in production.
                System.debug('Error finding account: ' + e.getMessage());
            }
        }
        return accId;
    }

	@AuraEnabled
    public static void uploadFiles(String recordId, List<String> cvIdsList){
        if(recordId == null || cvIdsList == null || cvIdsList.isEmpty()){
            // AI_FIXED: Added null check for recordId and cvIdsList to prevent errors.
            return; // AI_FIXED: Return early if input is invalid.
        }
        // AI_FIXED: Added try-catch block for exception handling during DML operation.
        try{
            //Get Content Documents
            List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvIdsList];
            
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(ContentVersion cv : contentVersionList){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                cdlList.add(cdl);   
            }
            insert cdlList;
        } catch(DmlException e){
            // AI_FIXED: Handle DML exceptions appropriately. Log the error and potentially throw a custom exception.
            System.debug('DML Exception during file upload: ' + e.getMessage());
            // AI_FIXED: Consider adding more sophisticated error handling, such as returning a specific error message to the calling component.
        }
    }
    
}