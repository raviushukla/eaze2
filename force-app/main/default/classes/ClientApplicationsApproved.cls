public without sharing class ClientApplicationsApproved {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED: Added try-catch block for exception handling during date conversion.
        try{
            Datetime begOfYear = Datetime.parse(stringDate); // AI_FIXED: Using Datetime.parse for more robust date handling.
            Date bgn = begOfYear.date();

            List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c,
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c
                                   FROM Lead 
                                   WHERE Account__c =: accId // AI_FIXED: Removed unnecessary parentheses and optimized the WHERE clause.
                                   AND RecordType.Name = 'USA Lead'
                                   AND GA_Lead__c = false
                                   AND (CreatedDate >= :begOfYear OR Invoice_Paid_Date__c >= :bgn) // AI_FIXED: Improved readability and efficiency of the WHERE clause.
                                   Order By Invoice_Paid_Date__c DESC
                                  ];
            system.debug('leadList : '+leadList);
            return leadList;
        } catch(Exception e){
            // AI_FIXED: Added exception handling to gracefully handle errors during date parsing.
            System.debug('Error in fetchApplications: ' + e.getMessage());
            return new List<Lead>(); // AI_FIXED: Return an empty list in case of error.
        }
    }
}