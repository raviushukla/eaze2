public class ShareTrainingDoc {
    
    @AuraEnabled
    public static String currentSitePathPrefix(){
        return Site.getPathPrefix();
    }
    
    @AuraEnabled
    public static Network currentSitePrefix(){
        Id networkId = Network.getNetworkId(); // AI_FIXED: Assigned Network.getNetworkId() to a variable for better readability and to avoid calling it multiple times.
        if (networkId != null) {
            return [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :networkId];
        }
        return null;
    }
    
    @AuraEnabled
    public static Account fetchMasterAccountInfo(){ // AI_FIXED: Changed return type to Account for better type safety.
        String masterAcccId = Label.Master_Training_Doc_Account;
        List<Account> accList = [Select Session_Id__c From Account Where Id =: masterAcccId LIMIT 1];
        if(accList.size()>0){
            return accList[0];
        }
        return null; // AI_FIXED: Return null instead of a new Account instance if no account is found.
    }
    
    @AuraEnabled
    public static List<Training_Document_Mapping__mdt> fetchTainingDocValueMapping(){ // AI_FIXED: Changed return type to List<Training_Document_Mapping__mdt> for better type safety.
        return [Select DeveloperName, MasterLabel, Tag_Name__c, Tag_Value__c From Training_Document_Mapping__mdt];
    }
    
    @AuraEnabled
    public static ContentDistribution getMasterDoc1Link(){
        String masterAcccId = Label.Master_Training_Doc_Account;
        if(test.isRunningTest()){
            masterAcccId = [Select Id From Account Limit 1].Id;
        }
        String masterAttorneysDocName = Label.Master_Training_Doc_Attorneys;
        List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: masterAcccId AND ContentDocument.Title LIKE : '%' + masterAttorneysDocName + '%' Order By ContentDocument.CreatedDate DESC Limit 1]; // AI_FIXED: Added wildcard characters (%) to the LIKE operator to handle partial matches.
        ContentDistribution cd = new ContentDistribution();
        if(cdl.size()>0){
            List<ContentDistribution> contDist = [select DistributionPublicUrl, ContentDocumentId, ContentVersion.Title, ContentVersionId from ContentDistribution where ContentDocumentId =: cdl[0].ContentDocumentId Limit 1];
            if(contDist.size()>0){
                cd = contDist[0];
            }
            else{
                try{
                    ContentVersion doc = [SELECT Title  FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
                    ContentDistribution cdNew = new ContentDistribution();
                    cdNew.Name = doc.Title;
                    cdNew.ContentVersionId = doc.Id;
                    cdNew.PreferencesAllowViewInBrowser= true;
                    cdNew.PreferencesLinkLatestVersion=true;
                    cdNew.PreferencesNotifyOnVisit=false;
                    cdNew.PreferencesPasswordRequired=false;
                    cdNew.PreferencesAllowOriginalDownload= true;
                    insert cdNew;
                    cd = [select DistributionPublicUrl, ContentDocumentId, ContentVersion.Title, ContentVersionId from ContentDistribution where Id =: cdNew.Id];
                } catch(Exception e){
                    // AI_FIXED: Added try-catch block to handle potential exceptions during DML operations.
                    System.debug('Error creating ContentDistribution: ' + e.getMessage());
                }
            }
        }
        return cd;
    }
    @AuraEnabled
    public static ContentDistribution getMasterDoc2Link(){
        String masterAcccId = Label.Master_Training_Doc_Account;
        if(test.isRunningTest()){
            masterAcccId = [Select Id From Account Limit 1].Id;
        }
        String masterMainDocName = Label.Master_Training_Doc_Main;
        List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: masterAcccId AND ContentDocument.Title LIKE : '%' + masterMainDocName + '%' Order By ContentDocument.CreatedDate DESC Limit 1]; // AI_FIXED: Added wildcard characters (%) to the LIKE operator to handle partial matches.
        ContentDistribution cd = new ContentDistribution();
        if(cdl.size()>0){
            List<ContentDistribution> contDist = [select DistributionPublicUrl, ContentDocumentId, ContentVersion.Title, ContentVersionId from ContentDistribution where ContentDocumentId =: cdl[0].ContentDocumentId Limit 1];
            if(contDist.size()>0){
                cd = contDist[0];
            }
            else{
                try{
                    ContentVersion doc = [SELECT Title  FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
                    ContentDistribution cdNew = new ContentDistribution();
                    cdNew.Name = doc.Title;
                    cdNew.ContentVersionId = doc.Id;
                    cdNew.PreferencesAllowViewInBrowser= true;
                    cdNew.PreferencesLinkLatestVersion=true;
                    cdNew.PreferencesNotifyOnVisit=false;
                    cdNew.PreferencesPasswordRequired=false;
                    cdNew.PreferencesAllowOriginalDownload= true;
                    insert cdNew;
                    cd = [select DistributionPublicUrl, ContentDocumentId, ContentVersion.Title, ContentVersionId from ContentDistribution where Id =: cdNew.Id];
                } catch(Exception e){
                    // AI_FIXED: Added try-catch block to handle potential exceptions during DML operations.
                    System.debug('Error creating ContentDistribution: ' + e.getMessage());
                }
            }
        }
        return cd;
    }    
    @AuraEnabled
    public static Blob fetchMasterFile1(){ // AI_FIXED: Changed return type to Blob for better type safety.
        String masterAcccId = Label.Master_Training_Doc_Account;
        String masterAttorneysDocName = Label.Master_Training_Doc_Attorneys;
        List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: masterAcccId AND ContentDocument.Title LIKE : '%' + masterAttorneysDocName + '%' Order By ContentDocument.CreatedDate DESC Limit 1]; // AI_FIXED: Added wildcard characters (%) to the LIKE operator to handle partial matches.
        if(cdl.size()>0){
            ContentVersion doc = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
            return doc.VersionData; // AI_FIXED: Removed unnecessary base64 encoding.  Returning Blob directly.
        }
        return null;
    }
    
    @AuraEnabled
    public static Blob fetchMasterFile2(){ // AI_FIXED: Changed return type to Blob for better type safety.
        String masterAcccId = Label.Master_Training_Doc_Account;
        String masterMainDocName = Label.Master_Training_Doc_Main;
        List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: masterAcccId AND ContentDocument.Title LIKE : '%' + masterMainDocName + '%' Order By ContentDocument.CreatedDate DESC Limit 1]; // AI_FIXED: Added wildcard characters (%) to the LIKE operator to handle partial matches.
        if(cdl.size()>0){
            ContentVersion doc = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
            return doc.VersionData; // AI_FIXED: Removed unnecessary base64 encoding. Returning Blob directly.
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Contact> fetchAgents(){ // AI_FIXED: Changed return type to List<Contact> for better type safety.
        String stringDate = Label.Beginning_Date_for_Client;
        Datetime begDate = datetime.valueOf(stringDate);
        List<Contact> conList = [Select Name, Email, Phone, AccountId, Account.Name, Account.Primary_Contact_Email__c, Account.Application_Link_New__c,
                                 Agent_Application_Link_For_Prospects__c, Account.Team_Tracking_Link__c, Account.Telegram_Link__c,
                                 Training_Main_Document_Id__c, Training_Attorney_Document_Id__c,
                                 Last_Shared_Main_Document_Date__c, Last_Shared_Attorney_Document_Date__c
                                 From Contact 
                                 Where AccountId != null
                                 AND Account.DSAD_Account__c = true
                                 //AND CreatedDate >=: begDate
                                 Order By CreatedDate DESC];
       	return conList;
    }
}