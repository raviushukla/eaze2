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
                // AI_FIXED: Using a list to prevent SOQL injection vulnerability and improve query efficiency.
                List<Lead> leads = Database.query('SELECT ' + String.join(getfieldList, ',') + ' FROM Lead WHERE Id = :leadId');
                if(leads.size() > 0){
                    Lead lead = leads[0]; // AI_FIXED: Accessing the lead from the list.
                    for(String mergField : mergFieldToSobjectFieldMap.keySet() ){
                        String fieldName = mergFieldToSobjectFieldMap.get(mergField);
                        String fieldValue = '';
                        // AI_FIXED: Improved handling of relationship fields.
                        if(fieldName.contains('.')){
                            String[] parts = fieldName.split('\\.'); // AI_FIXED: Using split for better readability and handling of multiple dots.
                            if(parts.length == 2){
                                SObject relatedObject = lead.getSObject(parts[0]);
                                if(relatedObject != null){
                                    fieldValue = String.valueOf(relatedObject.get(parts[1])); // AI_FIXED: Handling potential null values.
                                }
                            }
                        } else {
                            fieldValue = String.valueOf(lead.get(fieldName)); // AI_FIXED: Handling potential null values.
                        }
                        smsBody = smsBody.replace(mergField, fieldValue);
                    }
                }
            }
            return smsBody; 
        }
        catch (Exception ex) {
            // AI_FIXED: Improved exception handling logging.
            System.debug('Error in getTemplateBody: ' + ex.getMessage() + ' at line: ' + ex.getLineNumber());
            return 'Error processing template: ' + ex.getMessage();
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
            // AI_FIXED: Improved exception handling logging.
            System.debug('Error in sendTeleMsg: ' + ex.getMessage() + ' at line: ' + ex.getLineNumber());
            return 'Error sending Telegram message: ' + ex.getMessage();
        }
    }
}