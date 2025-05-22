public without Sharing class GuaranteeApprovalApplicationForm {
	
    @AuraEnabled
    public static String findAccount(String businessEmail, String businessName, String phone, String principalPhone1, String principalPhone2, String principalName1, String principalName2, String clientDBA){
        system.debug(businessEmail +' '+ businessName +' '+ phone +' '+ principalPhone1 +' '+ principalPhone2 +' '+ principalName1 +' '+ principalName2 );
        String accId = '';
        businessEmail = businessEmail.trim();
        String ClientBusinessName = businessName.trim();
        List<Account> accList = [Select Id from Account Where 
                                (Primary_Contact_Email_Formula__c =: businessEmail AND Primary_Contact_Email_Formula__c != null) 
                                OR ((Primary_Contact_Phone__c =: principalPhone1 OR Primary_Contact_Phone__c =: principalPhone2 OR Primary_Contact_Phone__c =: phone) AND Primary_Contact_Phone__c != null) 
                                OR Name =: ClientBusinessName OR Name =: clientDBA
                                OR ((Primary_Contact__r.Name =: principalName1 OR Primary_Contact__r.Name =: principalName2) AND Primary_Contact__c != null)
                                ORDER BY CreatedDate DESC
                                LIMIT 1];
        if(accList.size() > 0){
            return accList[0].Id;
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