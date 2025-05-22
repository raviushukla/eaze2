public without sharing class ClientApplicationsPreQualifying {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c,
                               Employment_Type__c, W_2_Unqualified_Reason__c, Self_employed_1099_Unqualified_Reason__c
                               FROM Lead 
                               WHERE (CreatedDate >=: begOfYear OR Declined_or_Closed_Lost_Date__c >=: bgn)
                               AND Account__c =: accId
                               AND RecordType.Name = 'USA Lead'
                               AND GA_Lead__c = false
                               Order By Declined_or_Closed_Lost_Date__c DESC
                              ];
        system.debug('leadList : '+leadList);
        
        return leadList;
    }
    
    @AuraEnabled
    public static String generateCSV(List<Lead> leadList, Integer month, Integer year){        
        
        String URlDownload;
        
        if(leadList.size()>0){
            string header = 'Name , Phone, Email, Reason for the decline \n';
            string finalstr = header ;
            String reason;
            DateTime finaldate;
            for(Lead a: leadList){
                finaldate = a.Declined_or_Closed_Lost_Date__c!=null ? a.Declined_or_Closed_Lost_Date__c : a.CreatedDate;
                reason = a.Employment_Type__c=='W-2' ? a.W_2_Unqualified_Reason__c : a.Self_employed_1099_Unqualified_Reason__c;
                
                if(finaldate.month() == month && finaldate.year() == year){
                    string recordString = '"'+a.Name+'","'+a.MobilePhone+'","'+a.Email+'","'+reason+'"\n';
                    finalstr = finalstr +recordString;
                }
            }
            finalstr = finalstr.replaceAll('null', '');
            
            Document o = new Document(
                FolderId = UserInfo.getUserId(),
                Name = 'Declined - Pre-Qualifier.csv',
                Body = Blob.valueOf(finalstr )
            );
            insert o;
            String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
            URlDownload = fullFileURL+'/servlet/servlet.FileDownload?file='+o.Id;
        }
        system.debug('Download URL:' +URlDownload);
        return URlDownload;
    }
    
    @AuraEnabled
    public static void deleteCSVRecord(){        
        List<Document> csvfiles= [SELECT Id From Document WHERE Name = 'Declined - Pre-Qualifier.csv'];
        if(csvfiles.size()>0){
            System.debug('deleted : '+csvfiles);
            delete csvfiles;
        }
        
    }
}