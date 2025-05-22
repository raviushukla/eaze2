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
        Id id = apexpages.currentpage().getparameters().get('AccountId');
        leadList = [Select Id, Name, CreatedDate, MobilePhone, Email, Loan_Amount__c, Agent_Name_Text__c, Status,
                    Meeting_Scheduled_Text__c, Time_Zone__c 
                    From Lead Where Account__c =: Id  AND CreatedDate >=: begOfYear ORDER BY Status ASC, CreatedDate DESC];
    }
}