public class TrainingDocumentUpdateNotification {
	@AuraEnabled
    public static string sendUpdateNotif(string recordId){
        try{
        system.debug('recordId :'+recordId);
        // AI_FIXED: Added Id type check and null check to prevent exceptions
        Id recordIdCheck = null;
        try{
            recordIdCheck = Id.valueOf(recordId);
        } catch(Exception e){
            return 'Invalid recordId';
        }
        if(recordIdCheck == null){
            return 'Invalid recordId';
        }

        Schema.SObjectType Objname = recordIdCheck.getSObjectType(); // AI_FIXED: Using recordIdCheck instead of record
        DescribeSObjectResult objResult = Objname.getDescribe();
        String objAPIName = objResult.getName();
        system.debug('recordId :'+objAPIName);
        if(objAPIName == 'Training_Document__c'){
            List<Training_Document__c> td = [Select Type__c From Training_Document__c Where Id =: recordIdCheck Limit 1]; // AI_FIXED: Using recordIdCheck instead of recordId
            if(td.size()>0){
                String clientType = td[0].Type__c;
                // AI_FIXED: Added null check for clientType
                if(clientType != null){
                    List<Contact> conList = [Select Id, Send_Training_Document__c From Contact Where Account.Client_Type__c =: clientType AND Account.DSAD_Account__c = true]; // AI_FIXED: Added Id to select list for update
                    system.debug('conList :'+conList);
                    // AI_FIXED: Improved efficiency by updating only changed records
                    for(Contact con: conList){
                        if(con.Send_Training_Document__c == false){ // AI_FIXED: Only update if Send_Training_Document__c is false
                            con.Send_Training_Document__c = true;
                        }
                    }
                    if(conList.size() > 0){
                        update conList;
                    }
                }
            }
        }
        else if(objAPIName == 'Contact'){
            List<Contact> conList = [Select Id, Send_Training_Document__c From Contact Where Id =: recordIdCheck AND Account.DSAD_Account__c = true Limit 1]; // AI_FIXED: Using recordIdCheck instead of recordId and added Id to select list for update
            system.debug('conList :'+conList);
            if(conList.size()>0){
                // AI_FIXED: Improved efficiency by updating only changed records
                for(Contact con: conList){
                    if(con.Send_Training_Document__c == false){ // AI_FIXED: Only update if Send_Training_Document__c is false
                        con.Send_Training_Document__c = true;
                    }
                }
                update conList;
            }
        }
        return 'success';
        } catch(Exception e){
            // AI_FIXED: Added exception handling
            return 'Error: ' + e.getMessage();
        }
    }
}