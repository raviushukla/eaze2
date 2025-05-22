public without sharing class ClientPortalDashboardApex_CAN {
	@AuraEnabled
    public static object fetchApplications(String accId){
        
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        
        List<Lead> leadList = [SELECT Id, Status, CreatedDate, Loan_Amount__c, Invoice_Paid_Date__c, Declined_or_Closed_Lost_Date__c
                               FROM Lead 
                               WHERE (CreatedDate >=: begOfYear 
                                      OR Invoice_Paid_Date__c >=: bgn 
                                      OR Declined_or_Closed_Lost_Date__c >=: bgn)
                               AND Account__c =: accId
                               AND RecordType.Name = 'CAN Lead'
                               Order By CreatedDate DESC
                              ];
        system.debug('leadList : '+leadList);
        return leadList;
    }
}