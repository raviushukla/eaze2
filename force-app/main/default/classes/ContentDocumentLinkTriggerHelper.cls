public class ContentDocumentLinkTriggerHelper {
    public static void oneFilePerRecord(List<ContentDocumentLink> TriggerNew){
        
        Set<String> linkEntityIds = new Set<String>();
        Set<String> conDocIds = new Set<String>();
        List<String> trainingDocIds = new List<String>();
        
        for(ContentDocumentLink cdl : TriggerNew){
            linkEntityIds.add(cdl.LinkedEntityId);
        }
        system.debug('linkEntityIds : '+linkEntityIds);
        
        List<Training_Document__c> trainingDocList = [SELECT Id FROM Training_Document__c where Id IN: linkEntityIds];
        system.debug('trainingDocList : '+trainingDocList);
        for(Training_Document__c td: [SELECT Id FROM Training_Document__c where Id IN: linkEntityIds]){
            trainingDocIds.add(td.Id);
        }
        system.debug('trainingDocIds : '+trainingDocIds);
        if(trainingDocIds.size()>0){
            linkEntityIds.clear();
            
            for(ContentDocumentLink cdl: [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: trainingDocIds]){
                linkEntityIds.add(cdl.LinkedEntityId);
            }
            system.debug('linkEntityIds : '+linkEntityIds);
            for(ContentDocumentLink cdl : TriggerNew){
                if(linkEntityIds.contains(cdl.LinkedEntityId)){
                    conDocIds.add(cdl.ContentDocumentId);
                    cdl.addError(Label.Training_Document_One_File_Error_Msg);
                }
            }
            
            system.debug('conDocIds : '+conDocIds);
            if(conDocIds.size()>0){
                delete [Select Id From ContentDocument Where Id IN: conDocIds];
            }
        }
    }
    
    public static void updateTrainDocAndCon(List<ContentDocumentLink> TriggerNew){
        Set<Id> fileParentIds = new Set<Id>();
        Set<String> docTypes = new Set<String>();
        for(ContentDocumentLink cdl: TriggerNew){
            fileParentIds.add(cdl.LinkedEntityId);
        }
        system.debug('fileParentIds : '+fileParentIds);
        List<Training_Document__c> trainingDocList = [SELECT Name, Type__c FROM Training_Document__c where Id In: fileParentIds];
        system.debug('trainingDocList : '+trainingDocList);
        for(Training_Document__c td: trainingDocList){
            docTypes.add(td.Type__c);
            td.Uploaded_On__c = date.today();
        }
        system.debug('docTypes : '+docTypes);
        update trainingDocList;
        if(docTypes.contains('Main')){
            updateContacts('Main');
        }
        else if(docTypes.contains('Attorney')){
            updateContacts('Attorney');
        }
    }
    
    // update document link on contact
    public static void updateContacts(String clientType){
        List<Contact> conList = [Select Send_Training_Document__c From Contact Where Account.Client_Type__c =: clientType AND Account.DSAD_Account__c = true];
        for(Contact con: conList){
            con.Send_Training_Document__c = true;
        }
        update conList;
    }
    
    /*public static void CreateContentVersion(List<ContentDocumentLink> TriggerNew){
        
        List<String> ContentDocumentIds = new List<String>();
        
        Map<String, String> conDocNameToConDocIdMap = new Map<String, String>();
        List<ContentVersion> contVersionToInsertLst = new List<ContentVersion>();
        List<Id> contDocIdsToDelete = new List<Id>();
        
        List<Account> acc = [Select Id From Account Where Name =: Label.Account_Name_to_Store_Master_Training_Document Limit 1];
        if(acc.size()>0){
            for(ContentDocumentLink cdl : TriggerNew){
                system.debug('cdl : '+cdl);
                if(cdl.LinkedEntityId == acc[0].Id ){
                    ContentDocumentIds.add(cdl.ContentDocumentId);
                    break;
                }
            }
        }
        
        String masterAttorneysDocName = Label.Master_Training_Doc_Attorneys;
        String masterMainDocName = Label.Master_Training_Doc_Main;
        
        List<ContentVersion> ContVesrionList = [SELECT VersionData, PathOnClient, Origin, Title, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId IN: ContentDocumentIds 
                                                AND IsLatest = true 
                                                AND (Title LIKE : masterAttorneysDocName 
                                                     OR Title LIKE : masterMainDocName)];
               
        if(ContVesrionList.size()>0){
            ContentVersion cv = ContVesrionList[0];
            String fileName = masterMainDocName;
            String docType = 'Main';
            if(cv.Title.contains('Attorney')){
                fileName = masterAttorneysDocName;
            }
            
            //  fetching old contentdocumentId with same name.
            for(contentdocumentLink cd: [SELECT ContentDocumentId, ContentDocument.Title 
                                         FROM contentdocumentLink 
                                         WHERE LinkedEntityId =: acc[0].Id 
                                         AND ContentDocumentId NOT IN: ContentDocumentIds 
                                         AND ContentDocument.Title LIKE :fileName LIMIT 1]){
                                             
                                             ContentVersion cVersion = new ContentVersion();
                                             cVersion.ContentDocumentId =  cd.ContentDocumentId;
                                             cVersion.PathOnClient = cv.PathOnClient;
                                             cVersion.Origin = cv.Origin;
                                             cVersion.Title = cv.Title;
                                             cVersion.VersionData = cv.VersionData;
                                             contVersionToInsertLst.add(cVersion);
                                             
                                             contDocIdsToDelete.add(cv.ContentDocumentId);
                                             
            }
            if(contVersionToInsertLst.size()>0){
                Insert contVersionToInsertLst;
            }
            if(contDocIdsToDelete.size()>0){
                ContentDocumentLinkTriggerHelper.deleteContDocs(contDocIdsToDelete);
            }
        }
    }
    @future
    public static void deleteContDocs(List<Id> contDocIds){
        List<ContentDocument> contDocToDeleteList = new List<ContentDocument>();
        for(String contDocId: contDocIds){
        	contDocToDeleteList.add(new ContentDocument(Id = contDocId));
        }
        Delete contDocToDeleteList;
    }*/
}