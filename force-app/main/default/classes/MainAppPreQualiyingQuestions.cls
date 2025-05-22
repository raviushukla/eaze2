public without sharing class MainAppPreQualiyingQuestions{
    
    @AuraEnabled
    public static void createLead(leadWrap leadWpObj){
        Lead ldObj = new Lead();
        ldObj.FirstName = leadWpObj.firstName;
        ldObj.LastName = leadWpObj.lastName;
        ldObj.Email = leadWpObj.email;
        ldObj.LeadSource = 'Prequalifying Questions';
        ldObj.MobilePhone = leadWpObj.phone;
        ldObj.Employment_Type__c = leadWpObj.employmentType;
        ldObj.Client_Code__c = leadWpObj.clientCode;
        ldObj.Agent_Code__c = leadWpObj.agentCode;
        insert ldObj;
        
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