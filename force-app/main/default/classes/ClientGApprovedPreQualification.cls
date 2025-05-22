public without sharing class ClientGApprovedPreQualification {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c,
                               GA_Declined_Reason__c
                               FROM Lead 
                               WHERE (CreatedDate >=: begOfYear OR Declined_or_Closed_Lost_Date__c >=: bgn)
                               AND Account__c =: accId
                               AND RecordType.Name = 'USA Lead'
                               AND GA_Lead__c = True
                               AND GA_Declined_Reason__c != null
                               Order By Declined_or_Closed_Lost_Date__c DESC
                              ];
        system.debug('leadList : '+leadList);
        
        return leadList;
    }
}