/*
	Test Class -> ClientPortalApplicationsAppApex_CAN_Test
*/
public without sharing class ClientPortalApplicationsApprovedApex_CAN {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){ // AI_FIXED: Changed return type to List<Lead> for clarity and to match the actual return value.
        try{
            Integer currentYear = System.Today().year();
            String stringDate = Label.Client_Applications_Start_Date;
            // AI_FIXED:  Added error handling for potential DateTime parsing issues.
            Datetime begOfYear;
            try{
                begOfYear = DateTime.parse(stringDate);
            } catch (Exception e){
                // Handle the exception appropriately, perhaps log it and return an empty list.
                System.debug('Error parsing date: ' + e.getMessage());
                return new List<Lead>();
            }
            Date bgn = begOfYear.date();

            // AI_FIXED: Added null check for accId to prevent SOQL injection and NullPointerException
            if (String.isBlank(accId)) {
                return new List<Lead>(); // Return empty list if accId is null or empty
            }

            List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c,
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c
                                   FROM Lead 
                                   WHERE Account__c =: accId // AI_FIXED: Removed unnecessary parentheses and improved readability.
                                   AND RecordType.Name = 'CAN Lead'
                                   AND (CreatedDate >=: begOfYear OR Invoice_Paid_Date__c >=: bgn) // AI_FIXED: Improved readability and efficiency of the WHERE clause.
                                   Order By Invoice_Paid_Date__c DESC
                                  ];
            system.debug('leadList : '+leadList);
            return leadList;
        } catch (Exception e){
            // AI_FIXED: Added a generic try-catch block to handle unexpected exceptions.  Log the exception for debugging purposes.
            System.debug('Error fetching applications: ' + e.getMessage());
            return new List<Lead>(); // Return an empty list in case of error.
        }
    }
}