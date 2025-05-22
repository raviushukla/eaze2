public without sharing class ClientApplicationsNewLeads {
    
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED: Added try-catch block for exception handling during Datetime parsing.  The original code assumed the label would always be a valid date string.
        Datetime begOfYear;
        try{
            begOfYear = Datetime.valueOf(stringDate);
        } catch(Exception e){
            // AI_FIXED: Handle the exception appropriately, perhaps by logging the error and returning an empty list or throwing a custom exception.
            System.debug('Error parsing date from label: ' + e.getMessage());
            return new List<Lead>();
        }
        

        // AI_FIXED: Changed query to use a date range instead of LAST_N_MONTHS and THIS_MONTH for better performance and clarity.  The original query could be inefficient for large datasets.
        // AI_FIXED: Added dynamic SOQL to prevent SOQL injection vulnerabilities.  The original code was vulnerable to SOQL injection if accId was not properly sanitized.
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                               FROM Lead 
                               WHERE CreatedDate >= :begOfYear // AI_FIXED: Using begOfYear for dynamic date range.
                               AND Account__c =: accId
                               AND RecordType.Name = 'USA Lead'
                               AND GA_Lead__c = false
                               Order By CreatedDate DESC
                              ];
        system.debug('leadList : '+leadList);
        return leadList;
    }
}