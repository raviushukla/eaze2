public without sharing class ClientApplicationsApproved {
    @AuraEnabled
    public static object fetchApplications(String accId){        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name,Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Share_With_DSAD__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Invoice_Paid_Date__c
                               FROM Lead 
                               WHERE (CreatedDate >=: begOfYear 
                                      OR Invoice_Paid_Date__c >=: bgn)
                               AND Account__c =: accId
                               AND RecordType.Name = 'USA Lead'
                               AND GA_Lead__c = false
                               Order By Invoice_Paid_Date__c DESC
                              ];
        system.debug('leadList : '+leadList);
        return leadList;
    }
}