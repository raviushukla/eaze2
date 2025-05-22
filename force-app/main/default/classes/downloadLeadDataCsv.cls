/*
	Getting all the leads for the account 
	and making an Excel sheet for that.
	Date - 01/01/2023
	Test Class - downloadLeadDataCsv_Test
*/
global class downloadLeadDataCsv {
	
    public List<Lead> leadList{get;set;}
    public void getAllLeads(){
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        Id accountId = apexpages.currentpage().getparameters().get('AccountId'); // AI_FIXED: Renamed variable for clarity and better readability.
        if (accountId == null) { // AI_FIXED: Added null check for AccountId to prevent errors.
            // Handle the case where AccountId is not provided.  Log an error or throw an exception as needed.
            System.debug('AccountId parameter is missing.');
            return;
        }
        try {
            leadList = [Select Id, Name, CreatedDate, MobilePhone, Email, Loan_Amount__c, Agent_Name_Text__c, Status,
                    Meeting_Scheduled_Text__c, Time_Zone__c 
                    From Lead Where Account__c =: accountId  AND CreatedDate >=: begOfYear ORDER BY Status ASC, CreatedDate DESC]; // AI_FIXED: Used the renamed accountId variable.
        } catch (Exception e) { // AI_FIXED: Added try-catch block for exception handling.
            // Handle the exception appropriately, e.g., log the error, display a user-friendly message.
            System.debug('Error retrieving leads: ' + e.getMessage());
        }
    }
}