public class ContentVersionTriggerHelper {
    public static void saveAsAttachment(List<ContentVersion> triggerNew){
        Set<String> cvIds = new Set<String>();
        List<Attachment> attachList = new List<Attachment>();
        Map<String, ContentVersion> cdIdtoCvMap = new Map<String, ContentVersion>();
        Map<String, blob> cdIdtoCvDataMap = new Map<String, blob>();
        Map<String, String> cdIdtoCvIdMap = new Map<String, String>();
        Map<String, String> cdIdtoParentIdMap = new Map<String, String>();
        for(ContentVersion cv:triggerNew){
            String fileName = cv.PathOnClient.toLowerCase();
            if(cv.ContentDocumentId != null && (fileName.contains('clientlogo') || fileName.contains('client logo'))){
                cdIdtoCvMap.put(cv.ContentDocumentId, cv);
                cdIdtoCvIdMap.put(cv.ContentDocumentId, cv.Id);
            }
        }
        system.debug('cdIdtoCvMap : '+cdIdtoCvMap);
        if(cdIdtoCvMap.size()>0){
            for(ContentDocumentLink cdl: [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN: cdIdtoCvMap.keySet()]){
                Id record = (Id)cdl.LinkedEntityId;
                Schema.SObjectType Objname = record.getSobjectType();
                DescribeSObjectResult objResult = Objname.getDescribe();
                String objAPIName = objResult.getName();
                system.debug('objAPIName : '+objAPIName);
                // if parent is Account
                if(objAPIName == 'Account'){
                    cdIdtoParentIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    cvIds.add(cdIdtoCvIdMap.get(cdl.ContentDocumentId));
                }
            }
        }
        if(cdIdtoParentIdMap.size()>0){
            for(ContentVersion cv: [Select VersionData From ContentVersion Where Id IN: cvIds]){
                cdIdtoCvDataMap.put(cv.Id, cv.VersionData);
            }
            for(String cdId: cdIdtoParentIdMap.keySet()){
                ContentVersion cv = cdIdtoCvMap.get(cdId);
                Attachment attach = new Attachment(Body = cdIdtoCvDataMap.get(cv.Id), Name = cv.PathOnClient,ParentId = cdIdtoParentIdMap.get(cdId) );
                attachList.add(attach);
            }
        }
        if(attachList.size()>0){
            insert attachList;
        }
    }
    public static void newDocUploaded(List<ContentVersion> triggerNew){
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentVersion cv:triggerNew)
        {
            if(cv.ContentDocumentId != null)
            {
                contentDocumentIds.add(cv.ContentDocumentId);
            }
        }
        system.debug('contentDocumentIds : '+contentDocumentIds);
        
        Set<Id> fileParentIds = new Set<Id>();
        for(ContentDocumentLink cdl: [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIds]){
            fileParentIds.add(cdl.LinkedEntityId);
        }
        List<Training_Document__c> trainingDocList = [SELECT Name, Type__c FROM Training_Document__c where Id In: fileParentIds];
        if( trainingDocList.size() > 0 ){
        	handleNewDocUpload(fileParentIds);
        }
    }
    
    @future
    public static void handleNewDocUpload(Set<Id> fileParentIds){
        
        Set<String> docTypes = new Set<String>();
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
}