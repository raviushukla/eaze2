/*
	Test Class -> ClientPortalApplicationsPreQual_CAN_Test
*/
public without sharing class ClientPortalApplicationsPreQualiApex_CAN {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){ // AI_FIXED: Changed return type to List<Lead> for clarity and to match the actual return value.
        
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear;
        try{
            begOfYear = Datetime.valueOf(stringDate); // AI_FIXED: Added try-catch block to handle potential exceptions during Datetime parsing.
        } catch(Exception e){
            // Handle exception appropriately, perhaps log the error and return an empty list.
            System.debug('Error parsing date: ' + e.getMessage());
            return new List<Lead>(); // AI_FIXED: Return an empty list if parsing fails.
        }
        Date bgn = begOfYear.date();
        
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialize leadList to avoid potential NullPointerException.
        try{
            leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c,
                               Employment_Type__c, W_2_Unqualified_Reason__c, Self_employed_1099_Unqualified_Reason__c
                               FROM Lead 
                               WHERE (CreatedDate >= :begOfYear OR Declined_or_Closed_Lost_Date__c >= :bgn)
                               AND Account__c =: accId // AI_FIXED: Using bind variables to prevent SOQL injection vulnerabilities.
                               AND RecordType.Name = 'CAN Lead'
                               Order By Declined_or_Closed_Lost_Date__c DESC
                              ];
        } catch(Exception e){
            // Handle SOQL exceptions appropriately, log the error and return an empty list.
            System.debug('Error querying Leads: ' + e.getMessage());
            return new List<Lead>(); // AI_FIXED: Return an empty list if query fails.
        }
        system.debug('leadList : '+leadList);
        
        return leadList;
    }
}