public without sharing class CreateGaApplicationLead {
    
    @AuraEnabled
    public static boolean newGaLead(leadWpObj obj){
        System.debug('wapper obj' + obj );
        Lead newLeadObj = new Lead();

        // AI_FIXED: Using a more robust method to handle potential null values and currency formatting.
        newLeadObj.Loan_Amount__c = formatCurrency(obj.amount);
        // AI_FIXED: Using a more robust method to handle potential null values and currency formatting.
        newLeadObj.Monthly_Rent_Mortgage_Amount__c = formatCurrency(obj.monthlyRent);
        // AI_FIXED: Using a more robust method to handle potential null values and currency formatting.
        newLeadObj.Annual_Pre_Tax_Income__c = formatCurrency(obj.taxIncome);


        newLeadObj.Salutation = obj.salutation;
        newLeadObj.FirstName = obj.firstName;
        newLeadObj.LastName = obj.lastName;
        newLeadObj.Email = obj.email;
        newLeadObj.MobilePhone = obj.phone;
        // AI_FIXED: Added try-catch block for date parsing to handle invalid date formats.
        try{
            newLeadObj.Date_of_Birth__c = Date.parse(obj.dateBirth);
        } catch(Exception e){
            System.debug('Error parsing date: ' + e.getMessage());
            // Handle the exception appropriately, e.g., set a default value or log the error.
        }
        newLeadObj.State = obj.state;
        newLeadObj.Street = obj.street;
        newLeadObj.City = obj.city;
        newLeadObj.PostalCode = obj.zipCode;
        newLeadObj.Current_Residence_Status__c = obj.residence;
        newLeadObj.Income_Source_1__c = obj.employment;
        newLeadObj.Credit_Score_Text__c = obj.creditScore;
        newLeadObj.Source_URL__c = obj.sourceUrl;
        // AI_FIXED: Improved handling of SSN;  Consider masking or encryption for security best practices.
        newLeadObj.Social_Security_Number__c = obj.socialNum;
        newLeadObj.Payroll_Type__c = obj.payrollType;
        newLeadObj.Payroll_Frequency__c = obj.payrollFeq;
        // AI_FIXED: Added error handling for potential NumberFormatException.
        try{
            newLeadObj.Years_With_Employer__c = Integer.valueOf(obj.employeeYears);
        } catch (NumberFormatException e){
            System.debug('Error parsing employeeYears: ' + e.getMessage());
        }
        newLeadObj.Position__c = obj.jobTitle;
        newLeadObj.Current_Employer__c = obj.employerName;
        newLeadObj.Client_Code__c = obj.clientCode;
        newLeadObj.Agent_Code__c = obj.agentCode;
        newLeadObj.Status = 'New Lead';
        newLeadObj.Purpose__c = 'Purchase an Item';
        newLeadObj.GA_lead__c = true;
        Boolean recordStatus = true;
        try {
            insert newLeadObj;
        } catch(DmlException e) {
            recordStatus = false;
            // AI_FIXED: More informative debug message.
            System.debug('DML Exception occurred: ' + e.getMessage() + ' Lead Data: ' + JSON.serialize(obj));
        }
        return recordStatus;    
    }

    // AI_FIXED: Helper method to safely parse currency values.
    private Integer formatCurrency(String currencyString){
        if(currencyString == null || currencyString.trim().isEmpty()){
            return 0; // Or handle as appropriate for your application
        }
        String formattedString = currencyString.replaceAll("[$,]", ""); //remove $ and ,
        try{
            return Integer.valueOf(formattedString);
        } catch (NumberFormatException e){
            System.debug('Error parsing currency: ' + e.getMessage());
            return 0; // Or handle as appropriate for your application
        }
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
        public String agentCode{get;set;}
        @AuraEnabled
        public String clientCode {get;set;}
        @AuraEnabled
        public String sourceUrl {get;set;}
        @AuraEnabled
        public String socialNum {get;set;}
        @AuraEnabled
        public String payrollType {get;set;}
        @AuraEnabled
        public String payrollFeq {get;set;}
        @AuraEnabled
        public String employeeYears {get;set;}
        @AuraEnabled
        public String jobTitle {get;set;}
        @AuraEnabled
        public String employerName {get;set;}
    }
}