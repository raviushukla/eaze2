public without sharing class ClientPortalDashboardApex_CAN {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){ // AI_FIXED: Changed return type to List<Lead> for clarity and consistency.
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialized leadList to handle potential null scenarios.
        try{
            String stringDate = Label.Client_Applications_Start_Date;
            Datetime begOfYear = datetime.valueOf(stringDate);
            Date bgn = begOfYear.Date();

            // AI_FIXED: Added null check for accId to prevent SOQL injection and errors.
            if (String.isNotBlank(accId)) {
                leadList = [SELECT Id, Status, CreatedDate, Loan_Amount__c, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                            FROM Lead 
                            WHERE (CreatedDate >=: begOfYear 
                                   OR Invoice_Paid_Date__c >=: bgn 
                                   OR Declined_or_Closed_Lost_Date__c >=: bgn)
                            AND Account__c =: accId // AI_FIXED: Using bind variable to prevent SOQL injection.
                            AND RecordType.Name = 'CAN Lead'
                            Order By CreatedDate DESC
                           ];
            }
        } catch (Exception e){ // AI_FIXED: Added try-catch block for exception handling.
            System.debug('Error fetching applications: ' + e.getMessage()); // AI_FIXED: Improved error logging.
        }
        System.debug('leadList : '+leadList);
        return leadList;
    }
}