public  class SendMessage {
    
    // get the only record which have parent object field as same as the object
    @AuraEnabled
    public static list <SMS_Template__c> getSMSTemplates(String recordId){
        
        Id record = (Id)recordId;
        Schema.SObjectType Objname = record.getSobjectType();
        DescribeSObjectResult objResult = Objname.getDescribe();
        String objAPIName = objResult.getName();
        return [SELECT Id, Name FROM SMS_Template__c WHERE Parent__c = :objAPIName];
    }
    
    
    // get the value of subject field and merge field from smsTemplate
    @AuraEnabled
    public static SMS_Template__c getSmsDetails(String templateId, String recordId){
        Id record = (Id)recordId;
        Schema.SObjectType Objname = record.getSobjectType();
        DescribeSObjectResult objResult = Objname.getDescribe();
        String objAPIName = objResult.getName();
        
        SMS_Template__c allDetails = [SELECT Id, Name ,Subject__c, SMS_Text__c FROM SMS_Template__c WHERE Id = :templateId];
        List<string> getfieldList = new List<string>();
        map<String,String> mergFieldToSobjectFieldMap = new map<String,String>();
        String smsBody = allDetails.SMS_Text__c;
        
        String key1 = '{{'+objAPIName+'.';
        String key2 = '}}';
        Integer index = 0;
        try{
            while( smsBody.indexOf(key1, index ) != -1 ){
                Integer key1StartIndex = smsBody.indexOf(key1, index );
                integer key2StartIndex = smsBody.indexOf(key2, index );
                Integer fieldStartIndex = key1StartIndex + 2 + objAPIName.length() + 1;
                
                String fieldName = smsBody.substring(fieldStartIndex, key2StartIndex);
                String mergField = key1+fieldName+key2;
                mergFieldToSobjectFieldMap.put(mergField,fieldName);
                index = key2StartIndex+2;
                system.debug('fieldName='+fieldName+' index='+index);  
                getfieldList.add(fieldName);
                
            }
            String query = ' SELECT ' +String.join(getfieldList, ',') + ' FROM ' +objAPIName+  ' WHERE Id =: recordId ' ;        
            sObject obj = Database.query( query);
            
            for(String mergField : mergFieldToSobjectFieldMap.keySet() ){
                String fieldName = mergFieldToSobjectFieldMap.get(mergField);
                system.debug(mergField+'='+fieldName);
                String fieldValue = '';
                String relName = '';
                if( fieldName.contains( '.' ) ){
                    String fieldNameTemp = fieldName.replace('.', ',');
                    list<String> relNameList = fieldNameTemp.split(',');
                    system.debug('relNameList='+relNameList);
                    relName = relNameList[0];
                    fieldName = relNameList[1];
                    system.debug('relname'+relName+  '   fieldName' +fieldName+ '      obj'+ obj);
                    system.debug('value of rel name'+obj.getSobject(relName));
                    Object temp1 = (Object) obj.getSobject(relName).get(fieldName);
                    fieldValue = String.valueOf(temp1);
                    system.debug(fieldValue);
                }
                else{
                    Object temp = (Object)obj.get(fieldName);
                    fieldValue = String.valueOf(temp);
                    // fieldValue = (String) obj.get(fieldName);  
                    system.debug(fieldValue);                 
                }
                smsBody = smsBody.replace(mergField, fieldValue);
            }
        }
        catch (Exception e) {
            system.debug('exception='+e);
        }       
        allDetails.SMS_Text__c = smsBody;
        return allDetails;
    }
    
    //Save the fields value into the sms object
    @AuraEnabled    
    public static string saveRecordDetails(String to, String leadId, String body, String subject, boolean doNotUpdate){
        Twilio_SMS__c sms = new Twilio_SMS__c();
        sms.SMS_Recipient__c = to ;
        sms.Leads__c = leadId;
        sms.SMS_Body__c = body;
        sms.SMS_Subject__c = subject;
        sms.Type__c ='Outgoing';
        sms.Do_Not_Update__c = doNotUpdate;
        insert sms;
        return 'Method called';
    }
    
}