public class CreateSmsTemplate {
    
    // return list of sObject in the org.
    @AuraEnabled
    public static List<String> fetchsObjects()
    {
        List<String> objlist = new List<String>();
        for( Schema.SObjectType obj: Schema.getGlobalDescribe().values())
        {
            String name = obj.getDescribe().getName();
            if (!obj.getDescribe().isCustomSetting() && obj.getDescribe().getRecordTypeInfos().size() > 0 && obj.getDescribe().isCreateable() &&
                !string.valueOf(obj).containsIgnoreCase('history') && !name.containsIgnoreCase('tag') && !name.containsIgnoreCase('share') && !name.containsIgnoreCase('feed')) 
            {
                objlist.add(obj.getDescribe().getName());
            }
        }
        objlist.sort();
        return objlist;
    }
    
    // return reference fields of selected object.
    @AuraEnabled
    public static List<String> getsObjectFields(String sendobj){
        List<string> getfieldList = new List<string>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> schemaFieldMap = gd.get(sendobj).getDescribe().fields.getMap(); 
        for (String objfield : schemaFieldMap.keySet()){
            Schema.DescribeFieldResult field = schemaFieldMap.get( objfield ).getDescribe();
            getfieldList.add(objfield);
        }
        return getfieldList;
    }
    
    
    
    
    //return lookup fields
    @AuraEnabled
    public static List<String> getLookUpfields(String fieldName,String sendobj)
    {
        List<String> getLookUpfieldList = new List<String>();
        Map<String,Schema.sObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.sObjectField> schemaFieldMap = gd.get(sendobj).getDescribe().fields.getMap(); 
        Schema.DisplayType field = schemaFieldMap.get(fieldName).getDescribe().getType();
        if(String.valueOf(field) == 'reference'){
            // Get the describe for the object
            DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(sendobj).getDescribe();
            // Get the field dynamically
            DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
            List<Schema.sObjectType> name =  fieldResult.getReferenceTo();
            
            Map<String,Schema.SObjectType> gd1 = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> schemaFieldMap1 = gd1.get(string.valueOf(name[0])).getDescribe().fields.getMap(); 
            for (String objfield1 : schemaFieldMap1.keySet()){
                Schema.DescribeFieldResult field1 = schemaFieldMap1.get( objfield1 ).getDescribe();
                getLookUpfieldList.add(String.valueOf(objfield1));
            }
            
            return getLookUpfieldList;
        }
        else{
            return null;
        }
        
    }
    
    
    //saving data into objects
    @AuraEnabled
    public static string saveRecordDetails(String smsName, String smsSub, String smsBody, String parentObject, String recordId){
        try{
            SMS_Template__c sms = new SMS_Template__c();
            sms.Name = smsName;
            sms.SMS_Text__c = smsBody;
            sms.Subject__c = smsSub;
            sms.Parent__c = parentObject;
            if(String.isNotBlank(recordId)){
                sms.Id = recordId;
            }
            upsert sms;
            return sms.Id;
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }
    
    
    
    
    // there should be three values in the picklist once a object is selected
    @AuraEnabled
    public static List<String>  getSecondclick(){
        
        List<String> objlist1 = new List<String>();
        for( Schema.SObjectType obj: Schema.getGlobalDescribe().values())
        {
            if(obj.getDescribe().getName()=='Account' || obj.getDescribe().getName()=='contact')
            {
                objlist1.add(obj.getDescribe().getName());
            }
        }
        return objlist1; 
        
    }
    
    
    //For editing the template
    @AuraEnabled
    public static SMS_Template__c editTemplate(String recordId){
        SMS_Template__c sms = [SELECT Id, Name,Subject__c, SMS_Text__c,Parent__c FROM SMS_Template__c WHERE Id = : recordId];
        return sms;
        
    }
    
}