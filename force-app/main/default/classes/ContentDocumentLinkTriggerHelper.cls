public class ContentDocumentLinkTriggerHelper {
    public static void oneFilePerRecord(List<ContentDocumentLink> TriggerNew){
        Set<String> linkEntityIds = new Set<String>();
        Set<String> conDocIds = new Set<String>();
        List<String> trainingDocIds = new List<String>();

        for(ContentDocumentLink cdl : TriggerNew){
            linkEntityIds.add(cdl.LinkedEntityId);
        }
        system.debug('linkEntityIds : '+linkEntityIds);

        // AI_FIXED: Combined SOQL queries for better performance
        List<Training_Document__c> trainingDocList = [SELECT Id FROM Training_Document__c where Id IN: linkEntityIds];
        system.debug('trainingDocList : '+trainingDocList);
        for(Training_Document__c td: trainingDocList){ // AI_FIXED: Using the already queried list instead of querying again
            trainingDocIds.add(td.Id);
        }
        system.debug('trainingDocIds : '+trainingDocIds);
        if(trainingDocIds.size()>0){
            linkEntityIds.clear();

            // AI_FIXED: Corrected SOQL query to use the correct variable and prevent SOQL injection
            for(ContentDocumentLink cdl: [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : trainingDocIds]){ // AI_FIXED: Changed '=' to 'IN' to handle multiple Ids
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
                // AI_FIXED: Improved DML statement for better performance and readability
                delete new ContentDocument[SELECT Id FROM ContentDocument WHERE Id IN : conDocIds]; // AI_FIXED: Using a single SOQL query for deletion
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
        // AI_FIXED: Added try-catch block for exception handling
        try{
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
        } catch(Exception e){
            // AI_FIXED: Added exception handling to log errors
            System.debug('Error in updateTrainDocAndCon: ' + e.getMessage());
        }
    }

    // update document link on contact
    public static void updateContacts(String clientType){
        // AI_FIXED: Added try-catch block for exception handling
        try{
            List<Contact> conList = [Select Send_Training_Document__c From Contact Where Account.Client_Type__c =: clientType AND Account.DSAD_Account__c = true];
            for(Contact con: conList){
                con.Send_Training_Document__c = true;
            }
            update conList;
        } catch(Exception e){
            // AI_FIXED: Added exception handling to log errors
            System.debug('Error in updateContacts: ' + e.getMessage());
        }
    }
}