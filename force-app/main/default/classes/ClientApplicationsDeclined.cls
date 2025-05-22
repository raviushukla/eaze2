public without sharing class ClientApplicationsDeclined {
    @AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        
        String stringDate = Label.Client_Applications_Start_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        Date bgn = begOfYear.Date();
        
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c
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
        
        system.debug('lead : '+leadList);
        if(leadList.size()>0){
            string header = 'Name , Date, Phone, Email, Amount, Agent Name \n';
            string finalstr = header ;
            DateTime finaldate;
            for(Lead a: leadList){
                finaldate = a.Declined_or_Closed_Lost_Date__c!=null ? DateTime.newInstance(a.Declined_or_Closed_Lost_Date__c.year(),a.Declined_or_Closed_Lost_Date__c.month(),
                                                                                           a.Declined_or_Closed_Lost_Date__c.day()) : a.CreatedDate ; 
                
                if(finaldate.month() == month && finaldate.year() == year){                    
                    string recordString = '"'+a.Name+'","'+finaldate.format('MM/dd/yyyy')+'","'+a.MobilePhone+'","'+a.Email+'","'+a.Loan_Amount__c+'","'+a.Agent_Name_Text__c+'"\n';
                    finalstr = finalstr +recordString;
                }               
            }
            finalstr = finalstr.replaceAll('null', '');
            
            Document o = new Document(
                FolderId = UserInfo.getUserId(),
                Name = 'Declined Or ClosedLost.csv',
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
        List<Document> csvfiles= [SELECT Id From Document WHERE Name = 'Declined Or ClosedLost.csv'];
        if(csvfiles.size()>0){
            System.debug('deleted : '+csvfiles);
            delete csvfiles;
        }
        
    }
}