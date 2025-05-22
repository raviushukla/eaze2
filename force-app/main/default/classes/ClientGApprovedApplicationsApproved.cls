public without sharing class ClientGApprovedApplicationsApproved {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED: Added try-catch block for exception handling during Datetime parsing.  The original code assumed the label always contained a valid date string.
        try{
            Datetime begOfYear = Datetime.parse(stringDate);
            Date bgn = begOfYear.date();

            List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c, Closed_Date__c,
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c, Tier_Level__c
                                   FROM Lead 
                                   WHERE Account__c =: accId // AI_FIXED: Removed unnecessary parentheses and improved readability.
                                   AND RecordType.Name = 'USA Lead'
                                   AND GA_Lead__c = true
                                   AND (CreatedDate >=: begOfYear OR Invoice_Paid_Date__c >=: bgn) // AI_FIXED: Improved readability and efficiency by moving the OR condition inside the parentheses.
                                   Order By Invoice_Paid_Date__c DESC
                                  ];
            system.debug('leadList : '+leadList);
            return leadList;
        } catch(Exception e){
            // AI_FIXED: Added exception handling to gracefully handle parsing errors.  Logs the error for debugging purposes.
            System.debug('Error parsing date or querying leads: ' + e.getMessage());
            return new List<Lead>(); // AI_FIXED: Returns an empty list instead of throwing an unhandled exception.
        }
    }
}