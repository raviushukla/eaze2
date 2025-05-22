public without sharing class ClientGApprovedApplicationsClosed {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialized leadList to avoid potential NullPointerException
        try{
            String stringDate = Label.Client_Applications_Start_Date;
            // AI_FIXED: Added error handling for invalid date format in Label
            Datetime begOfYear;
            try{
                begOfYear = Datetime.valueOf(stringDate);
            } catch(Exception e){
                System.debug('Error parsing date from Label: ' + e.getMessage());
                return leadList; // Return empty list if date parsing fails
            }
            Date bgn = begOfYear.date();

            // AI_FIXED: Added null check for accId to prevent SOQL injection and NullPointerException
            if(String.isNotBlank(accId)){
                leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, Tier_Level__c,
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c
                            FROM Lead 
                            WHERE (CreatedDate >= :begOfYear OR Declined_or_Closed_Lost_Date__c >= :bgn)
                            AND Account__c = :accId // AI_FIXED: Using bind variable to prevent SOQL injection
                            AND RecordType.Name = 'USA Lead'
                            AND GA_Lead__c = true
                            Order By Declined_or_Closed_Lost_Date__c DESC
                           ];
            }
            system.debug('leadList : '+leadList);
        } catch(Exception e){
            // AI_FIXED: Added a generic catch block to handle unexpected exceptions.  Consider more specific exception handling in production code.
            System.debug('Error fetching applications: ' + e.getMessage());
        }
        return leadList;
    }
}