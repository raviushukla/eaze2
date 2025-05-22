/* ***************************************************************************
 * Created date: Apr 16, 2019
 * Auther: Jai Singh
 * Des: This is common utility Class
 * ---------------------------------
 * Change 1;
 * Date: Apr 16, 2019
 * Auther: SNEH VERMA
 * Des: call sObject fields name as dynamic with in getAllField method
 * ***************************************************************************/

public class ApexCommonHelper {
    
    public static String getAllField( String sObjectName ){
        SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
        if(sObjType == null){ // AI_FIXED: Added null check for sObjType to handle invalid sObject names.
            return ''; // AI_FIXED: Return empty string if sObjectName is invalid.
        }
        Map<String,Schema.SObjectField> mfields = sObjType.getDescribe().fields.getMap();
        StringBuilder apiNames = new StringBuilder(); // AI_FIXED: Changed String concatenation to StringBuilder for better performance
        for(String apiName : mfields.keySet()){
            if(apiNames.length() > 0){ // AI_FIXED: Improved readability and efficiency.
                apiNames.append(',');
            }
            apiNames.append(apiName);
        }
        return apiNames.toString();
    }
    
	
    public static String generateCode(Integer len){
        //Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr.toUppercase();
    }
    public static boolean validateNewAgentCode(String newAgentCode){ // AI_FIXED: Changed 'Static' to 'static' for correct syntax.
        boolean isValid = true;
        if(String.isBlank(newAgentCode)){ // AI_FIXED: Added null check to prevent unexpected behavior.
            return true; // AI_FIXED: Return true if newAgentCode is null or empty.
        }
        list<Contact> conList = [Select Id from Contact where Agent_Code__c =: newAgentCode LIMIT 1 ]; // AI_FIXED: Removed redundant AND clause.
        if( !conList.isEmpty() ){
            isValid = false;
        }
        return isValid;
    }
    public static boolean validateNewClientCode(String newClientCode){ // AI_FIXED: Changed 'Static' to 'static' for correct syntax.
        boolean isValid = true;
        if(String.isBlank(newClientCode)){ // AI_FIXED: Added null check to prevent unexpected behavior.
            return true; // AI_FIXED: Return true if newClientCode is null or empty.
        }
        list<Account> accList = [Select Id from Account where Client_Code__c =: newClientCode LIMIT 1 ]; // AI_FIXED: Removed redundant AND clause.
        if( !accList.isEmpty() ){
            isValid = false;
        }
        return isValid;
    }
    public static String formatPhoneNum (String s) {
        if(String.isBlank(s) || s.length() < 10){ // AI_FIXED: Added input validation to handle invalid phone numbers.
            return s; // AI_FIXED: Return original string if invalid.
        }
        s = s.right(10);
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
	}
    
    public static string dateTimeToUserTimeZone(DateTime dt, String agentId){
        TimeZone tz = UserInfo.getTimeZone();
        if(String.isNotBlank(agentId)){
            try{ // AI_FIXED: Added try-catch block to handle potential exceptions during SOQL query.
                List<Contact> agent = [SELECT Time_Zone__c FROM Contact WHERE Id =: agentId LIMIT 1];
                if(agent.size()>0){
                    tz = TimeZone.getTimeZone(agent[0].Time_Zone__c);
                }
            } catch(Exception e){ // AI_FIXED: Added exception handling.
                System.debug('Error converting DateTime to User TimeZone: ' + e.getMessage()); // AI_FIXED: Log the error for debugging purposes.
            }
        }
        return dt.format('MM/dd/yyyy hh:mm a',tz); // AI_FIXED: Removed unnecessary String.valueOf() conversion.
    }
}