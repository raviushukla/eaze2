public without Sharing class GuaranteeApprovalApplication {
	
    @AuraEnabled
    public static String findAccount(String Email){
        String accId = '';
        List<Account> accList = [Select Id from Account Where Primary_Contact_Email_Formula__c =: Email LIMIT 1];
        if(accList.size() > 0){
            return accList[0].Id;
        }
        return accId;
    }
    /*
    @AuraEnabled
    public static void uploadFiles(String incorporationFile, String financialStatement, String bankFile, String businessLicense, String incorporationFileBase64, String financialStatementBase64, String bankFileBase64, String businessLicenseBase64, String recordId){
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        ContentVersion cvObj1 = new ContentVersion();
        cvObj1.Title = 'Articles of Incorporation '+incorporationFile;
        cvObj1.PathOnClient = incorporationFile;
        cvObj1.VersionData = EncodingUtil.base64Decode(incorporationFileBase64);
        cvObj1.IsMajorVersion = true;
        cvList.add(cvObj1);
        
        ContentVersion cvObj2 = new ContentVersion();
        cvObj2.Title = 'Financial Statements(Business) '+incorporationFile;
        cvObj2.PathOnClient = financialStatement;
        cvObj2.VersionData = EncodingUtil.base64Decode(financialStatementBase64);
        cvObj2.IsMajorVersion = true;
        cvList.add(cvObj2);
        
        ContentVersion cvObj3 = new ContentVersion();
        cvObj3.Title = 'Bank statements '+incorporationFile;
        cvObj3.PathOnClient = bankFile;
        cvObj3.VersionData = EncodingUtil.base64Decode(bankFileBase64);
        cvObj3.IsMajorVersion = true;
        cvList.add(cvObj3);
        
        ContentVersion cvObj4 = new ContentVersion();
        cvObj4.Title = 'Business License '+incorporationFile;
        cvObj4.PathOnClient = businessLicense;
        cvObj4.VersionData = EncodingUtil.base64Decode(businessLicenseBase64);
        cvObj4.IsMajorVersion = true;
        cvList.add(cvObj4);
        
        insert cvList;
        
        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvList];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersionList){
         	ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdlList.add(cdl);   
        }
        insert cdlList;
    }*/
    
    @AuraEnabled
    public static void uploadFiles(String recordId,Map<Object, String> fileNameBase64Map){
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(Object fileName : fileNameBase64Map.keySet()){
            ContentVersion cvObj = new ContentVersion();
            cvObj.Title = String.valueOf(fileName);
            cvObj.PathOnClient = String.valueOf(fileName);
            cvObj.VersionData = EncodingUtil.base64Decode(fileNameBase64Map.get(String.valueOf(fileName)));
            cvObj.IsMajorVersion = true;
            cvList.add(cvObj);
        }
        insert cvList;
        
        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvList];
        
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