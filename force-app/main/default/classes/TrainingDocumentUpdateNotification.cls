public class TrainingDocumentUpdateNotification {
	@AuraEnabled
    public static string sendUpdateNotif(string recordId){
        system.debug('recordId :'+recordId);
        Id record = (Id)recordId;
        Schema.SObjectType Objname = record.getSobjectType();
        DescribeSObjectResult objResult = Objname.getDescribe();
        String objAPIName = objResult.getName();
        system.debug('recordId :'+objAPIName);
        if(objAPIName == 'Training_Document__c'){
            List<Training_Document__c> td = [Select Type__c From Training_Document__c Where Id =: recordId Limit 1];
            if(td.size()>0){
                String clientType = td[0].Type__c;
                List<Contact> conList = [Select Send_Training_Document__c From Contact Where Account.Client_Type__c =: clientType AND Account.DSAD_Account__c = true];
                system.debug('conList :'+conList);
                for(Contact con: conList){
                    con.Send_Training_Document__c = true;
                }
                update conList;
            }
        }
        else if(objAPIName == 'Contact'){
            List<Contact> conList = [Select Send_Training_Document__c From Contact Where Id =: recordId AND Account.DSAD_Account__c = true Limit 1];
            system.debug('conList :'+conList);
            if(conList.size()>0){
                for(Contact con: conList){
                    con.Send_Training_Document__c = true;
                }
                update conList;
            }
        }
        return 'success';
    }
}