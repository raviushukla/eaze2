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
        Map<String,Schema.SObjectField> mfields = sObjType.getDescribe().fields.getMap();
        String apiNames =  '';
        for(String apiName : mfields.keySet()){
            if( string.isNotBlank(apiNames)){
                apiNames += ','+apiName;
            }else{
                apiNames = apiName;
            }
        }
        return apiNames;
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
    public Static boolean validateNewAgentCode(String newAgentCode){
        boolean isValid = true;
        list<Contact> conList = [Select Id from Contact where Agent_Code__c =: newAgentCode AND Agent_Code__c != null LIMIT 1 ];
        if( !conList.isEmpty() ){
            isValid = false;
        }
        return isValid;
    }
    public Static boolean validateNewClientCode(String newClientCode){
        boolean isValid = true;
        list<Account> accList = [Select Id from Account where Client_Code__c =: newClientCode AND Client_Code__c != null LIMIT 1 ];
        if( !accList.isEmpty() ){
            isValid = false;
        }
        return isValid;
    }
    public static String formatPhoneNum (String s) {
        s = s.right(10);
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
	}
    
    public static string dateTimeToUserTimeZone(DateTime dt, String agentId){
        TimeZone tz = UserInfo.getTimeZone();
        if(String.isNotBlank(agentId)){
            List<Contact> agent = [SELECT Time_Zone__c FROM Contact WHERE Id =: agentId LIMIT 1];
            if(agent.size()>0){
                tz = TimeZone.getTimeZone(agent[0].Time_Zone__c);
            }
        }
        return dt.format('MM/dd/yyyy hh:mm a',String.valueOf(tz));
    }
}