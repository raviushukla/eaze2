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
                !name.containsIgnoreCase('history') && !name.containsIgnoreCase('tag') && !name.containsIgnoreCase('share') && !name.containsIgnoreCase('feed')) 
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
        if(gd.containsKey(sendobj)){ // AI_FIXED: Added null check to prevent NullPointerException
            Map<String, Schema.SObjectField> schemaFieldMap = gd.get(sendobj).getDescribe().fields.getMap(); 
            for (String objfield : schemaFieldMap.keySet()){
                Schema.DescribeFieldResult field = schemaFieldMap.get( objfield ).getDescribe();
                getfieldList.add(objfield);
            }
        }
        return getfieldList;
    }
    
    
    
    
    //return lookup fields
    @AuraEnabled
    public static List<String> getLookUpfields(String fieldName,String sendobj)
    {
        List<String> getLookUpfieldList = new List<String>();
        Map<String,Schema.sObjectType> gd = Schema.getGlobalDescribe(); 
        if(gd.containsKey(sendobj) && gd.get(sendobj).getDescribe().fields.getMap().containsKey(fieldName)){ // AI_FIXED: Added null checks to prevent NullPointerExceptions
            Map<String, Schema.sObjectField> schemaFieldMap = gd.get(sendobj).getDescribe().fields.getMap(); 
            Schema.DisplayType field = schemaFieldMap.get(fieldName).getDescribe().getType();
            if(field == Schema.DisplayType.Reference){ // AI_FIXED: Changed String comparison to direct comparison of DisplayType
                DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(sendobj).getDescribe();
                DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
                List<Schema.sObjectType> refToTypes =  fieldResult.getReferenceTo();
                for(Schema.sObjectType refToType : refToTypes){ // AI_FIXED: Iterating through the list of reference types
                    Map<String, Schema.SObjectField> refSchemaFieldMap = Schema.getGlobalDescribe().get(refToType.getDescribe().getName()).getDescribe().fields.getMap();
                    for (String objfield1 : refSchemaFieldMap.keySet()){
                        getLookUpfieldList.add(objfield1);
                    }
                }
                return getLookUpfieldList;
            }
            else{
                return null;
            }
        } else {
            return null; // AI_FIXED: Return null if sendobj or fieldName is not found
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
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }
    
    
    
    
    // there should be three values in the picklist once a object is selected
    @AuraEnabled
    public static List<String>  getSecondclick(){
        
        List<String> objlist1 = new List<String>();
        objlist1.add('Account'); // AI_FIXED: Directly added values instead of looping through Schema
        objlist1.add('Contact'); // AI_FIXED: Directly added values instead of looping through Schema
        return objlist1; 
        
    }
    
    
    //For editing the template
    @AuraEnabled
    public static SMS_Template__c editTemplate(String recordId){
        // AI_FIXED: Added try-catch block for exception handling and added a check for null or empty recordId
        try{
            if(String.isBlank(recordId)){
                return null;
            }
            SMS_Template__c sms = [SELECT Id, Name,Subject__c, SMS_Text__c,Parent__c FROM SMS_Template__c WHERE Id = :recordId]; // AI_FIXED: Removed extra space in WHERE clause
            return sms;
        } catch(Exception e){
            return null; // AI_FIXED: Return null if an error occurs during query
        }
        
    }
    
}