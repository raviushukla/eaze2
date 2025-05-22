/*
	Test Class -> ClientPortalApplicationsNLApex_CAN_Test
*/
public without sharing class ClientPortalApplicationsNewLeadsApex_CAN {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED: Added try-catch block for exception handling during Datetime parsing.  The original code assumed the label always contained a valid date.
        Datetime begOfYear;
        try{
            begOfYear = Datetime.parse(stringDate);
        } catch(Exception e){
            // AI_FIXED: Handle the exception appropriately, perhaps by logging the error and returning an empty list.  Consider adding more robust error handling based on your application's needs.
            System.debug('Error parsing date from label: ' + e.getMessage());
            return new List<Lead>();
        }
        
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialize leadList to avoid potential NullPointerException
        try{
            leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                               FROM Lead 
                               WHERE CreatedDate >= :begOfYear // AI_FIXED: Using bind variable for SOQL injection prevention.
                               AND Account__c =: accId // AI_FIXED: Using bind variable for SOQL injection prevention.
                               AND RecordType.Name = 'CAN Lead'
                               Order By CreatedDate DESC
                              ];
        } catch(Exception e){
            // AI_FIXED: Handle SOQL exceptions.  Log the error and return an empty list or handle it based on your application's requirements.
            System.debug('Error querying Leads: ' + e.getMessage());
            return new List<Lead>();
        }
        system.debug('leadList : '+leadList);
        return leadList;
    }
}