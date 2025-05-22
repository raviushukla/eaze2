public without sharing class ApplicantPortal_Home {
	
	@AuraEnabled
    public static object sessionCheck(String sessionId){
        system.debug('sessionId'+sessionId);
        List<Login_Session__c>  ls = [SELECT Id From Login_Session__c Where Session_Id__c = :sessionId AND Type__c = 'Applicant Login' AND Expired__c = false Limit 1]; // AI_FIXED: Removed unnecessary colon before 'false' in SOQL query
        system.debug('ls'+ls);
        //allowelse login
        if(ls.size()==1){
            return ls[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Lead> getLeads(String username){
        //Lead leadObj = [select Id,Social_Security_Number__c from Lead where CAN_Username__c =: username AND RecordType.Name = 'CAN Lead' LIMIT 1] ;
        try{
            return [Select Id,CreatedDate, Loan_Amount__c,Meeting_Scheduled__c,Status,Name,Purpose__c,Applicant_SR__c from Lead Where CAN_Username__c =: username AND RecordType.Name = 'CAN Lead' ORDER BY CreatedDate DESC ]; // AI_FIXED: Wrapped SOQL query in try-catch block for exception handling
        } catch(Exception e){
            // AI_FIXED: Added exception handling to catch potential errors during SOQL query execution
            System.debug('Error retrieving leads: ' + e.getMessage());
            return new List<Lead>(); // AI_FIXED: Return an empty list instead of null to avoid errors in the Aura component
        }
    }
    
}