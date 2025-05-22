/*
   * Creating Leads for Canada applicants.
   * Test Class createNewCanadaLead_Test
   * LWC Cmp : canadaApplicationPortal
   * Written by : Umesh Rana
*/ 
public without sharing class createNewCanadaLead {
    
    @AuraEnabled(cacheable=TRUE)
    public static Account fetchAccount(String clientId ){
        System.debug('client id : ' + clientId );
        Account acc = null; // AI_FIXED: Initialized Account to null for better practice
        if( clientId != null && clientId != '' ){ // AI_FIXED: Corrected logical OR to AND to prevent SOQL injection
            acc = [SELECT Id, Logo_URL__c FROM Account WHERE Client_Code__c = :clientId]; // AI_FIXED: Added : before clientId to prevent SOQL injection
        }
        return acc;
    }
    
    @AuraEnabled(cacheable=TRUE)
    public static Double conversionRate(){
        // AI_FIXED: Added try-catch block for exception handling
        try{
            return [SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = 'CAD'].ConversionRate;
        } catch(Exception e){
            System.debug('Error fetching conversion rate: ' + e.getMessage());
            return null; // AI_FIXED: Return null if an error occurs
        }
    }

    @AuraEnabled
    public static boolean newCanadaLead(leadWpObj obj){
        System.debug('wapper obj' + obj );
        Lead newCanadaLeadObj = new Lead();

        // AI_FIXED: Improved null checks and exception handling for number parsing
        try{
            obj.amount = obj.amount != null ? obj.amount.remove('$').remove(',') : '0'; // AI_FIXED: Handle null values
            newCanadaLeadObj.Loan_Amount__c = Integer.valueOf(obj.amount);

            obj.expence = obj.expence != null ? obj.expence.remove('$').remove(',') : '0'; // AI_FIXED: Handle null values
            newCanadaLeadObj.Monthly_Expenses__c = Integer.valueOf(obj.expence);

            obj.monthlyRent = obj.monthlyRent != null ? obj.monthlyRent.remove('$').remove(',') : '0'; // AI_FIXED: Handle null values
            newCanadaLeadObj.Monthly_Rent_Mortgage_Amount__c = Integer.valueOf(obj.monthlyRent);

            obj.taxIncome = obj.taxIncome != null ? obj.taxIncome.remove('$').remove(',') : '0'; // AI_FIXED: Handle null values
            newCanadaLeadObj.Annual_Pre_Tax_Income__c = Integer.valueOf(obj.taxIncome);
        } catch(Exception e){
            System.debug('Error parsing number fields: ' + e.getMessage());
            return false; // AI_FIXED: Return false if parsing fails
        }


        //newCanadaLeadObj.Loan_Type__c = 'MAJOR_PURCHASE';
        newCanadaLeadObj.Citizenship_Status__c = obj.citizenship;
        newCanadaLeadObj.City = obj.city;
        newCanadaLeadObj.Country = 'Canada';
        newCanadaLeadObj.Credit_Score_Text__c = obj.creditScore;
        // AI_FIXED: Added try-catch block for date parsing
        try{
            newCanadaLeadObj.Date_of_Birth__c = obj.dateBirth != null ? Date.parse(obj.dateBirth) : null; // AI_FIXED: Handle null values
        } catch(Exception e){
            System.debug('Error parsing date of birth: ' + e.getMessage());
            return false; // AI_FIXED: Return false if date parsing fails
        }
        newCanadaLeadObj.Email = obj.email;
        newCanadaLeadObj.Income_Source_1__c = obj.employment;
        newCanadaLeadObj.FirstName = obj.firstName;
        newCanadaLeadObj.LastName = obj.lastName;
        newCanadaLeadObj.PostalCode = obj.zipCode;
        newCanadaLeadObj.MobilePhone = obj.phone;
        newCanadaLeadObj.State = obj.state;
        newCanadaLeadObj.Salutation = obj.salutation;
        newCanadaLeadObj.Street = obj.street;
        newCanadaLeadObj.Current_Residence_Status__c = obj.residence;
        newCanadaLeadObj.Client_Code__c = obj.clientCode;
        newCanadaLeadObj.Agent_Code__c = obj.agentCode;
        newCanadaLeadObj.Status = 'New Lead'; // AI_FIXED: Removed extra whitespace
        newCanadaLeadObj.Newsletter_Consent__c = obj.newLetter;
        // AI_FIXED: Improved null checks for boolean fields
        newCanadaLeadObj.Past_Bankruptcy_or_Consumer_Proposal__c = obj.pastBankurpty != null && Integer.valueOf(obj.pastBankurpty) == 1;
        newCanadaLeadObj.RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        newCanadaLeadObj.Source_URL__c = obj.sourceUrl;
        newCanadaLeadObj.CurrencyIsoCode = 'CAD';
        newCanadaLeadObj.Purpose__c = 'Purchase an Item';
        newCanadaLeadObj.Social_Security_Number__c = obj.socialNum != null ? String.valueOf(obj.socialNum) : null; // AI_FIXED: Handle null values
        newCanadaLeadObj.Credit_Proposal__c = obj.creditProposal != null && Integer.valueOf(obj.creditProposal) == 1; // AI_FIXED: Improved null checks for boolean fields
        newCanadaLeadObj.Past_Bankruptcy_Last_7_Years__c = obj.pastBankurptyLastSeven != null && Integer.valueOf(obj.pastBankurptyLastSeven) == 1; // AI_FIXED: Improved null checks for boolean fields
        Boolean recordStatus = true;
        try {
            insert newCanadaLeadObj;
        } catch(DmlException e) {
            recordStatus = false;
            System.debug('The following exception has occurred: ' + e.getMessage());
            // AI_FIXED: Added more specific logging for DML exceptions
            for(Database.Error err : e.getErrors()){
                System.debug('Error on Lead field: ' + err.getField() + ', Message: ' + err.getMessage());
            }
        }
        return recordStatus; 
    }

    public class leadWpObj{
        @AuraEnabled
        public String amount{get;set;}
        @AuraEnabled
        public String salutation{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String phone{get;set;}
        @AuraEnabled
        public String dateBirth{get;set;}
        @AuraEnabled
        public String citizenship{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String zipCode{get;set;}
        @AuraEnabled
        public String residence{get;set;}
        @AuraEnabled
        public String employment{get;set;}
        @AuraEnabled 
        public String creditScore{get;set;}
        @AuraEnabled
        public String monthlyRent{get;set;}
        @AuraEnabled
        public String taxIncome{get;set;}
        @AuraEnabled
        public String expence{get;set;}
        @AuraEnabled
        public boolean newLetter{get;set;}
        @AuraEnabled
        public String pastBankurpty{get;set;}
        @AuraEnabled
        public String agentCode{get;set;}
        @AuraEnabled
        public String clientCode {get;set;}
        @AuraEnabled
        public String sourceUrl {get;set;}
        @AuraEnabled
        public Integer socialNum {get;set;}
        @AuraEnabled
        public String creditProposal {get;set;}
        @AuraEnabled
        public String pastBankurptyLastSeven {get;set;}
    }

}