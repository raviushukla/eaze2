/*
	Test Class -> ClientPortalApplicationsClosed_CAN_Test
*/
public without sharing class ClientPortalApplicationsClosedApex_CAN {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){ // AI_FIXED: Changed return type to List<Lead> for clarity and to match the actual return value.
        List<Lead> leadList = new List<Lead>(); // AI_FIXED: Initialized leadList to handle potential null scenarios.
		try{
			String stringDate = Label.Client_Applications_Start_Date;
			Datetime begOfYear = datetime.valueOf(stringDate);
			Date bgn = begOfYear.Date();

			// AI_FIXED: Added null check for accId to prevent SOQL injection and errors.
			if (String.isNotBlank(accId)) {
				leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
							Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c
							FROM Lead 
							WHERE (CreatedDate >= :begOfYear OR Declined_or_Closed_Lost_Date__c >= :bgn)
							AND Account__c = :accId // AI_FIXED: Using bind variable to prevent SOQL injection.
							AND RecordType.Name = 'CAN Lead'
							Order By Declined_or_Closed_Lost_Date__c DESC
							];
			}
			system.debug('leadList : '+leadList);
		} catch(Exception e){ // AI_FIXED: Added try-catch block to handle potential exceptions during SOQL query.
			System.debug('Error fetching applications: ' + e.getMessage()); // AI_FIXED: Improved error logging for debugging purposes.
		}
        return leadList;
    }
}