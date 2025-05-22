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
        Account acc = new Account();
        if( clientId != null || clientId != '' ){
            acc = [SELECT Id, Logo_URL__c FROM Account WHERE Client_Code__c=:clientId];
        }
        return acc;
    }
    
    @AuraEnabled(cacheable=TRUE)
    public static Double conversionRate(){
       return [SELECT Id, ConversionRate FROM CurrencyType WHERE IsoCode = 'CAD'].ConversionRate;
    }

    @AuraEnabled
    public static boolean newCanadaLead(leadWpObj obj){
        System.debug('wapper obj' + obj );
        Lead newCanadaLeadObj = new Lead();

        obj.amount = obj.amount.remove('$');
        obj.amount = obj.amount.remove(',');

        obj.expence = obj.expence.remove('$');        
        obj.expence = obj.expence.remove(',');

        obj.monthlyRent = obj.monthlyRent.remove('$');
        obj.monthlyRent = obj.monthlyRent.remove(',');

        obj.taxIncome = obj.taxIncome.remove('$');
        obj.taxIncome = obj.taxIncome.remove(',');

        //newCanadaLeadObj.Loan_Type__c = 'MAJOR_PURCHASE';
        newCanadaLeadObj.Loan_Amount__c = Integer.valueOf(obj.amount);
        newCanadaLeadObj.Citizenship_Status__c = obj.citizenship;
        newCanadaLeadObj.City = obj.city;
        newCanadaLeadObj.Country = 'Canada';
        newCanadaLeadObj.Credit_Score_Text__c = obj.creditScore;
        newCanadaLeadObj.Date_of_Birth__c = date.parse(obj.dateBirth);
        newCanadaLeadObj.Email = obj.email;
        newCanadaLeadObj.Income_Source_1__c = obj.employment;
        newCanadaLeadObj.FirstName = obj.firstName;
        newCanadaLeadObj.LastName = obj.lastName;
        newCanadaLeadObj.Monthly_Expenses__c = Integer.valueOf(obj.expence);
        newCanadaLeadObj.PostalCode = obj.zipCode;
        newCanadaLeadObj.MobilePhone = obj.phone;
        newCanadaLeadObj.State = obj.state;
        newCanadaLeadObj.Monthly_Rent_Mortgage_Amount__c = Integer.valueOf(obj.monthlyRent);
        newCanadaLeadObj.Salutation = obj.salutation;
        newCanadaLeadObj.Street = obj.street;
        newCanadaLeadObj.Current_Residence_Status__c = obj.residence;
        newCanadaLeadObj.Annual_Pre_Tax_Income__c = Integer.valueOf(obj.taxIncome);
        newCanadaLeadObj.Client_Code__c = obj.clientCode;
        newCanadaLeadObj.Agent_Code__c = obj.agentCode;
        newCanadaLeadObj.Status = '	New Lead';
        newCanadaLeadObj.Newsletter_Consent__c = obj.newLetter;
        newCanadaLeadObj.Past_Bankruptcy_or_Consumer_Proposal__c = Integer.valueOf(obj.pastBankurpty) == 1 ? true : false;
        newCanadaLeadObj.RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        newCanadaLeadObj.Source_URL__c = obj.sourceUrl;
        newCanadaLeadObj.CurrencyIsoCode = 'CAD';
        newCanadaLeadObj.Purpose__c = 'Purchase an Item';
        newCanadaLeadObj.Social_Security_Number__c = String.valueOf(obj.socialNum);
        newCanadaLeadObj.Credit_Proposal__c = Integer.valueOf(obj.creditProposal) == 1 ? true : false;
        newCanadaLeadObj.Past_Bankruptcy_Last_7_Years__c = Integer.valueOf(obj.pastBankurptyLastSeven) == 1 ? true : false;
        Boolean recordStatus = true;
        try {
            insert newCanadaLeadObj;
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