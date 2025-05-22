public  class SelectSmsTemplate {
    
    // get the only record which have parent object field as same as the object
    @AuraEnabled
    public static list <SMS_Template__c> getSMSTemplates(String recordId){
        String objname ;
        String keyCode  = recordId.substring(0,3); // AI_FIXED: Corrected typo 'subString' to 'substring'
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values()){
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode)
            {
                objname =  objectInstance.getDescribe().getName();
            }
        }
        // AI_FIXED: Added null check for objname to handle cases where no matching object is found.
        return objname == null ? new List<SMS_Template__c>() : [SELECT Id, Name FROM SMS_Template__c WHERE Parent__c = : objname]; 
    }
    
    
    // get the value of subject field and merge field from smsTemplate
    @AuraEnabled
    public static SMS_Template__c getSmsDetails(String templateId, String recordId){
        Id recordIdObj;
        try{
            recordIdObj = Id.valueOf(recordId); // AI_FIXED: Explicitly convert recordId to Id to handle potential exceptions.
        } catch(Exception e){
            return null; // AI_FIXED: Handle invalid recordId gracefully.
        }
        SObjectType Objname = recordIdObj.getSObjectType(); // AI_FIXED: Removed unnecessary Schema.SObjectType
        DescribeSObjectResult objResult = Objname.getDescribe();
        String objAPIName = objResult.getName();
        
        SMS_Template__c allDetails = [SELECT Id, Name ,Subject__c, SMS_Text__c FROM SMS_Template__c WHERE Id = :templateId];
        List<string> getfieldList = new List<string>();
        map<String,String> mergFieldToSobjectFieldMap = new map<String,String>();
        String smsBody = allDetails.SMS_Text__c;
        
        String key1 = '{{'+objAPIName+'.';
        String key2 = '}}';
        Integer index = 0;
        
        // AI_FIXED: Improved loop efficiency and error handling.
        while( smsBody.indexOf(key1, index ) != -1 ){
            Integer key1StartIndex = smsBody.indexOf(key1, index );
            Integer key2StartIndex = smsBody.indexOf(key2, key1StartIndex + key1.length()); // AI_FIXED: Start searching key2 after key1
            if(key2StartIndex == -1){
                break; // AI_FIXED: Handle cases where key2 is missing.
            }
            Integer fieldStartIndex = key1StartIndex+2+objAPIName.length()+1;
            String fieldName = smsBody.substring(fieldStartIndex, key2StartIndex);
            String mergField = key1+fieldName+key2;
            mergFieldToSobjectFieldMap.put(mergField,fieldName);
            index = key2StartIndex+2;
            getfieldList.add(fieldName);
        }
        
        // AI_FIXED: Use a StringBuilder for efficient string concatenation.
        StringBuilder sb = new StringBuilder('SELECT ');
        for(Integer i = 0; i < getfieldList.size(); i++){
            sb.append(getfieldList[i]);
            if(i < getfieldList.size() -1){
                sb.append(',');
            }
        }
        sb.append(' FROM ').append(objAPIName).append(' WHERE Id = :recordIdObj'); // AI_FIXED: Use recordIdObj instead of recordId
        String query = sb.toString();
        
        sObject obj = Database.query(query);
        
        // AI_FIXED: Improved exception handling and null checks.
        for(String mergField : mergFieldToSobjectFieldMap.keySet() ){
            String fieldName = mergFieldToSobjectFieldMap.get(mergField);
            String fieldValue = '';
            if(obj != null){ // AI_FIXED: Check if obj is not null before accessing its fields.
                if( fieldName.contains( '.' ) ){
                    String fieldNameTemp = fieldName.replace('.', ',');
                    list<String> relNameList = fieldNameTemp.split(',');
                    String relName = relNameList[0];
                    fieldName = relNameList[1];
                    SObject relatedObj = obj.getSobject(relName); // AI_FIXED: Assign to a variable for better readability.
                    if(relatedObj != null){ // AI_FIXED: Check if related object is not null.
                        Object temp1 = relatedObj.get(fieldName);
                        fieldValue = temp1 != null ? String.valueOf(temp1) : ''; // AI_FIXED: Handle null values gracefully.
                    }
                }
                else{
                    Object temp = obj.get(fieldName);
                    fieldValue = temp != null ? String.valueOf(temp) : ''; // AI_FIXED: Handle null values gracefully.
                }
                smsBody = smsBody.replace(mergField, fieldValue);
            }
        }
        allDetails.SMS_Text__c = smsBody;
        return allDetails;
    }
    
    //Save the fields value into the sms object
    @AuraEnabled    
    public static string saveRecordDetails(String to, String subject, String body){
        Twilio_SMS__c sms = new Twilio_SMS__c();
        sms.To__c = to ;
        sms.SMS_Body__c = body;
        insert sms; // AI_FIXED: Removed unnecessary comments.
        return 'Method called';
    }
    
}