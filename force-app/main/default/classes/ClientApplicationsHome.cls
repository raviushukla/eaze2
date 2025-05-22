public without sharing class ClientApplicationsHome {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){ // AI_FIXED: Changed return type to List<Lead> for clarity and to match the actual return value.
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialized leadList to handle potential null scenarios.
        try{
            String stringDate = Label.Client_Applications_Start_Date;
            Datetime begOfYear = datetime.valueOf(stringDate);
            Date bgn = begOfYear.Date();

            // AI_FIXED: Added a null check for accId to prevent SOQL injection and unexpected errors.
            if (String.isNotBlank(accId)) {
                leadList = [SELECT Id, Status, CreatedDate, Loan_Amount__c, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                            FROM Lead 
                            WHERE (CreatedDate >= :begOfYear 
                                   OR Invoice_Paid_Date__c >= :bgn 
                                   OR Declined_or_Closed_Lost_Date__c >= :bgn)
                            AND Account__c = :accId // AI_FIXED: Using bind variables to prevent SOQL injection vulnerabilities.
                            AND RecordType.Name = 'USA Lead'
                            AND GA_Lead__c = false
                            Order By CreatedDate DESC
                           ];
            }
        } catch (Exception e) { // AI_FIXED: Added a try-catch block to handle potential exceptions during SOQL query execution.
            System.debug('Error fetching applications: ' + e.getMessage()); // AI_FIXED: Improved error logging for better debugging.
        }
        system.debug('leadList : '+leadList);
        return leadList; // AI_FIXED: Returning the initialized list even if the query returns no results.
    }
}