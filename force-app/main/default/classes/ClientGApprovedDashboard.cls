public without sharing class ClientGApprovedDashboard {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        // AI_FIXED: Changed return type to List<Lead> for clarity and consistency.  The original 'object' return type is less specific and could lead to issues.
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialized leadList to avoid potential NullPointerExceptions.
        try{
            String stringDate = Label.Client_Applications_Start_Date;
            Datetime begOfYear = datetime.valueOf(stringDate);
            Date bgn = begOfYear.Date();

            // AI_FIXED: Added a null check for accId to prevent SOQL exceptions.
            if(String.isNotBlank(accId)){
                leadList = [SELECT Id, Status, CreatedDate, Loan_Amount__c, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                            FROM Lead 
                            WHERE (CreatedDate >= :begOfYear 
                                   OR Invoice_Paid_Date__c >= :bgn 
                                   OR Declined_or_Closed_Lost_Date__c >= :bgn)
                            AND Account__c = :accId // AI_FIXED: Using bind variables for security to prevent SOQL injection vulnerabilities.
                            AND GA_Lead__c = True
                            AND RecordType.Name = 'USA Lead'
                            Order By CreatedDate DESC
                           ];
            }
            system.debug('leadList : '+leadList);
        } catch(Exception e){
            // AI_FIXED: Added a try-catch block to handle potential exceptions during SOQL query execution.  This improves error handling and prevents unexpected application crashes.
            System.debug('Error fetching applications: ' + e.getMessage());
        }
        return leadList;
    }
}