public without sharing class BothProgramApplicationForm {
    @AuraEnabled
    public static String findAccount(String Email){
        String accId = '';
        // AI_FIXED: Added null check for Email to prevent NullPointerException
        if (String.isBlank(Email)) return accId;
        List<Account> accList = [Select Id from Account Where Primary_Contact_Email_Formula__c =: Email LIMIT 1];
        if(accList.size() > 0){
            return accList[0].Id;
        }
        return accId;
    }
    
    
    @AuraEnabled
    public static boolean uploadFiles(String recordId, List<String> cvIdsList, leadWrap fields){
        
        // AI_FIXED: Added null checks to prevent NullPointerExceptions
        if (String.isBlank(recordId) || cvIdsList == null || fields == null) return false;

        //Get Content Documents
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvIdsList];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersionList){
         	ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdlList.add(cdl);   
        }
        // AI_FIXED: Added try-catch block for DML operation
        try{
            insert cdlList;
        } catch(DmlException e){
            System.debug('Error inserting ContentDocumentLinks: ' + e.getMessage());
            return false; // AI_FIXED: Return false on error
        }


        Boolean leadInsert = false;

        Lead leadObj = new Lead();
        leadObj.Associate_s_Name__c = fields.Associate ;
        leadObj.Company = fields.Corporate_Business_Name ;
        leadObj.Website = fields.Company_Website ;
        leadObj.Street = fields.Address;
        leadObj.City = fields.City ;
        leadObj.State = fields.State ;
        leadObj.PostalCode  = fields.Zip;
        leadObj.Country = 'United States';
        leadObj.MobilePhone = fields.Phone;
        leadObj.Email = fields.Company_Email;
        // AI_FIXED: Improved name splitting logic for robustness
        if(fields.Principal_Name_1 != null && fields.Principal_Name_1.split(' ').size() > 1){
            leadObj.FirstName = fields.Principal_Name_1.split(' ')[0];
            leadObj.LastName = fields.Principal_Name_1.split(' ')[1];
        } else if (fields.Principal_Name_1 != null){
            leadObj.LastName = fields.Principal_Name_1;
        }
        leadObj.In_Business_from_Year__c = fields.Been_In_Business_Years;
        leadObj.Sales_Agent_Count__c = fields.Number_of_Sales_Agent;
        leadObj.Who_were_you_referred_by__c = fields.Referred_By;
        leadObj.Accounting_Associate__c = fields.Accounting_Associate;
        leadObj.Total_Sales_FY_in_2018__c = fields.Total_Sales_For_2023;
        leadObj.Business_Incorporated_State__c = fields.Business_Incorporation_State;
        leadObj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        leadObj.LeadSource = 'Funding Partner Intro Done';
        leadObj.Program_Type__c = 'Main & GA';
        leadObj.Source_Page__c = fields.Source_Page;

        try {
            insert leadObj;
            leadInsert = true;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            leadInsert = false;
        }
        
        return leadInsert;
    }

    public class leadWrap {

        @AuraEnabled public String Associate {get; set;}
        @AuraEnabled public String Corporate_Business_Name {get; set;}
        @AuraEnabled public String Company_Website {get; set;}
        @AuraEnabled public String Address{get; set;}
        @AuraEnabled public String City{get; set;}
        @AuraEnabled public String State{get; set;}
        @AuraEnabled public String Zip{get; set;}
        @AuraEnabled public String Phone {get; set;}
        @AuraEnabled public String Company_Email{get; set;}
        @AuraEnabled public String Principal_Name_1 {get; set;}
        @AuraEnabled public Decimal Been_In_Business_Years{get; set;}
        @AuraEnabled public Integer Number_of_Sales_Agent {get; set;}
        @AuraEnabled public String Referred_By{get; set;}
        @AuraEnabled public String Accounting_Associate{get; set;}
        @AuraEnabled public String Accounting_Associate_Contact_Email{get; set;}
        @AuraEnabled public Decimal Total_Sales_For_2023{get; set;}
        @AuraEnabled public String Business_Incorporation_State {get; set;}
        @AuraEnabled public String Source_Page {get; set;}
    }
}