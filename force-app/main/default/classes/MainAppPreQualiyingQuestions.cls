public without sharing class MainAppPreQualiyingQuestions{
    
    @AuraEnabled
    public static void createLead(leadWrap leadWpObj){
        Lead ldObj = new Lead();
        try{
            ldObj.FirstName = leadWpObj.firstName;
            ldObj.LastName = leadWpObj.lastName;
            ldObj.Email = leadWpObj.email;
            ldObj.LeadSource = 'Prequalifying Questions';
            ldObj.MobilePhone = leadWpObj.phone;
            ldObj.Employment_Type__c = leadWpObj.employmentType;
            ldObj.Client_Code__c = leadWpObj.clientCode;
            ldObj.Agent_Code__c = leadWpObj.agentCode;
            insert ldObj; // AI_FIXED: Added try-catch block for exception handling during lead insertion.
        } catch(DMLException e){
            // AI_FIXED: Added exception handling to catch DML exceptions during lead creation.  Log the error for debugging purposes.
            System.debug('Error creating lead: ' + e.getMessage());
            throw new AuraHandledException('Error creating lead. Please check the provided data.'); // AI_FIXED: Throw a user-friendly AuraHandledException to inform the user about the error.
        } catch(Exception e){
            // AI_FIXED: Added a generic catch block to handle any unexpected exceptions.
            System.debug('An unexpected error occurred: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred. Please contact support.'); // AI_FIXED: Throw a user-friendly AuraHandledException for unexpected errors.
        }
        
    }

    public class leadWrap{
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String phone{get;set;}
        @AuraEnabled
        public String employmentType{get;set;}
        @AuraEnabled
        public String clientCode{get;set;}
        @AuraEnabled
        public String agentCode{get;set;}
        
    }
}