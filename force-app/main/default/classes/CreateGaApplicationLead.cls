public without sharing class CreateGaApplicationLead {
    
    @AuraEnabled
    public static boolean newGaLead(leadWpObj obj){
        System.debug('wapper obj' + obj );
        Lead newLeadObj = new Lead();

        obj.amount = obj.amount.remove('$');
        obj.amount = obj.amount.remove(',');

        obj.monthlyRent = obj.monthlyRent.remove('$');
        obj.monthlyRent = obj.monthlyRent.remove(',');

        obj.taxIncome = obj.taxIncome.remove('$');
        obj.taxIncome = obj.taxIncome.remove(',');

        newLeadObj.Salutation = obj.salutation;
        newLeadObj.FirstName = obj.firstName;
        newLeadObj.LastName = obj.lastName;
        newLeadObj.Email = obj.email;
        newLeadObj.MobilePhone = obj.phone;
        newLeadObj.Date_of_Birth__c = date.parse(obj.dateBirth);
        newLeadObj.State = obj.state;
        newLeadObj.Street = obj.street;
        newLeadObj.City = obj.city;
        newLeadObj.PostalCode = obj.zipCode;
        newLeadObj.Current_Residence_Status__c = obj.residence;
        newLeadObj.Income_Source_1__c = obj.employment;
        newLeadObj.Credit_Score_Text__c = obj.creditScore;
        newLeadObj.Source_URL__c = obj.sourceUrl;
        newLeadObj.Social_Security_Number__c = String.valueOf(obj.socialNum);
        newLeadObj.Payroll_Type__c = obj.payrollType;
        newLeadObj.Payroll_Frequency__c = obj.payrollFeq;
        newLeadObj.Years_With_Employer__c = obj.employeeYears;
        newLeadObj.Position__c = obj.jobTitle;
        newLeadObj.Current_Employer__c = obj.employerName;
        newLeadObj.Loan_Amount__c = Integer.valueOf(obj.amount);
        newLeadObj.Monthly_Rent_Mortgage_Amount__c = Integer.valueOf(obj.monthlyRent);
        newLeadObj.Annual_Pre_Tax_Income__c = Integer.valueOf(obj.taxIncome);
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
            System.debug('The following exception has occurred: ' + e.getMessage());
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