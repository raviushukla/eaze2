public class CommonUtil {
    
    
    public static API_Log__c createAPILog( API_Log__c apiLog ){
        insert apiLog;
        return apiLog;
    }

}