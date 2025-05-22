/**
* @File Name : EazeEliteProgramForm.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 25, 2025 |   | Initial Version
**/

public without Sharing class EazeEliteProgramForm {
	
	@AuraEnabled
    public static String findAccount(String businessEmail, String businessName, String phone,  String principalName1,  String clientDBA){
      //  system.debug(businessEmail +' '+ businessName +' '+ phone +' '+ principalPhone1 +' '+ principalName1 +');
        String accId = '';
        if (businessName != null) {
        businessName = businessName.trim();
        
        // Look for an account with exactly the same name as Corporate_Business_Name__c
        List<Account> accList = [SELECT Id FROM Account 
                                WHERE Name =: businessName 
                                LIMIT 1];
        
        if(accList.size() > 0) {
            return accList[0].Id;
        }
    }
        return accId;
    }

	@AuraEnabled
    public static void uploadFiles(String recordId, List<String> cvIdsList){
        
        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvIdsList];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersionList){
         	ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdlList.add(cdl);   
        }
        insert cdlList;
        
    }
    
}