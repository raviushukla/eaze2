public class SendTelegramMsgToAgent {
    @AuraEnabled
    public static Lead fetchLeadDetail(String leadId){
        return [SELECT Name, Agent_Name__c, Agent_Name__r.Name, Agent_Name_Text__c, Account__c FROM Lead WHERE Id =: leadId];
    }
    @AuraEnabled
    public static object fetchSMSTemplates(){
        return [SELECT Id, Name FROM SMS_Template__c WHERE Parent__c = 'Lead'];
    }
    @AuraEnabled
    public static string getTemplateBody(String templateId, String leadId){
        try{
            SMS_Template__c allDetails = [SELECT Id, Name ,Subject__c, SMS_Text__c FROM SMS_Template__c WHERE Id = :templateId];
            List<string> getfieldList = new List<string>();
            map<String,String> mergFieldToSobjectFieldMap = new map<String,String>();
            String smsBody = allDetails.SMS_Text__c;
            String objAPIName = 'Lead';
            String key1 = '{{Lead.';
            String key2 = '}}';
            Integer index = 0;

            if(String.isNotBlank(smsBody)){
                while( smsBody.indexOf(key1, index ) != -1 ){
                    Integer key1StartIndex = smsBody.indexOf(key1, index );
                    integer key2StartIndex = smsBody.indexOf(key2, index );
                    Integer fieldStartIndex = key1StartIndex+2+objAPIName.length()+1;
                    
                    String fieldName = smsBody.substring(fieldStartIndex, key2StartIndex);
                    String mergField = key1+fieldName+key2;
                    mergFieldToSobjectFieldMap.put(mergField,fieldName);
                    index = key2StartIndex+2;
                    getfieldList.add(fieldName);
                    
                }
            }
            else{
                smsBody = '';
            }
            
            if(getfieldList.size()>0){
                String query = ' SELECT ' +String.join(getfieldList, ',') + ' FROM Lead WHERE Id =: leadId ' ;        
                sObject obj = Database.query( query);
                for(String mergField : mergFieldToSobjectFieldMap.keySet() ){
                    String fieldName = mergFieldToSobjectFieldMap.get(mergField);
                    String fieldValue = '';
                    String relName = '';
                    if( fieldName.contains( '.' ) ){
                        String fieldNameTemp = fieldName.replace('.', ',');
                        list<String> relNameList = fieldNameTemp.split(',');
                        relName = relNameList[0];
                        fieldName = relNameList[1];
                        fieldValue = (String) obj.getSobject(relName).get(fieldName);
                    }
                    else{
                        fieldValue = (String) obj.get(fieldName);                    
                    }
                    smsBody = smsBody.replace(mergField, fieldValue);
                }
            }
            return smsBody; 
        }
        catch (Exception ex) {
            system.debug('error : '+ex.getLineNumber()+' : '+ex.getMessage());
            return 'error : '+ex.getLineNumber()+' : '+ex.getMessage();
        }
    }

    // this method create Telegram record, chat id is before insert trigger and message is send by process builder.
    @AuraEnabled    
    public static string sendTeleMsg(String leadId, String agentId, String clientId, String body){
        try{
            Telegram_Message__c tm = new Telegram_Message__c(
                Lead__c = leadId, 
                Agent__c = agentId, 
                Client__c = clientId, 
                Message__c = body, 
                Type__c = 'Outgoing');
            insert tm;
            system.debug('tm : '+tm);
            return 'success';
        }
        catch (Exception ex) {
            system.debug('error : '+ex.getLineNumber()+' : '+ex.getMessage());
            return 'error : '+ex.getLineNumber()+' : '+ex.getMessage();
        }
    }
}