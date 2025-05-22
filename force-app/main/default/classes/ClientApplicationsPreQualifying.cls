public without sharing class ClientApplicationsPreQualifying {
	@AuraEnabled
    public static List<Lead> fetchApplications(String accId){
        
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED: Added try-catch block to handle potential exceptions during Datetime parsing.
        try{
            Datetime begOfYear = datetime.valueOf(stringDate);
            Date bgn = begOfYear.Date();
        
            List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, 
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Declined_or_Closed_Lost_Date__c,
                                   Employment_Type__c, W_2_Unqualified_Reason__c, Self_employed_1099_Unqualified_Reason__c
                                   FROM Lead 
                                   WHERE (CreatedDate >=: begOfYear OR Declined_or_Closed_Lost_Date__c >=: bgn)
                                   AND Account__c =: accId // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variable.
                                   AND RecordType.Name = 'USA Lead'
                                   AND GA_Lead__c = false
                                   Order By Declined_or_Closed_Lost_Date__c DESC
                                  ];
            system.debug('leadList : '+leadList);
            return leadList;
        } catch(Exception e){
            // AI_FIXED: Added exception handling to return an empty list if an error occurs.
            System.debug('Error fetching applications: ' + e.getMessage());
            return new List<Lead>();
        }
    }
    
    @AuraEnabled
    public static String generateCSV(List<Lead> leadList, Integer month, Integer year){        
        
        String URlDownload = null; // AI_FIXED: Initialized URlDownload to null to handle cases where leadList is empty.
        
        if(leadList.size()>0){
            // AI_FIXED: Using StringBuilder for better performance when concatenating strings.
            StringBuilder sb = new StringBuilder('Name , Phone, Email, Reason for the decline \n');
            String reason;
            DateTime finaldate;
            for(Lead a: leadList){
                finaldate = a.Declined_or_Closed_Lost_Date__c!=null ? a.Declined_or_Closed_Lost_Date__c : a.CreatedDate;
                reason = a.Employment_Type__c=='W-2' ? a.W_2_Unqualified_Reason__c : a.Self_employed_1099_Unqualified_Reason__c;
                
                if(finaldate.month() == month && finaldate.year() == year){
                    // AI_FIXED: Using StringBuilder to append strings efficiently.
                    sb.append('"').append(a.Name).append('","').append(a.MobilePhone).append('","').append(a.Email).append('","').append(reason).append('"').append('\n');
                }
            }
            String finalstr = sb.toString(); // AI_FIXED: Assigned the StringBuilder's content to finalstr.
            finalstr = finalstr.replaceAll('null', '');
            
            // AI_FIXED: Added try-catch block for exception handling during document creation and insertion.
            try{
                Document o = new Document(
                    FolderId = UserInfo.getUserId(),
                    Name = 'Declined - Pre-Qualifier.csv',
                    Body = Blob.valueOf(finalstr )
                );
                insert o;
                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
                URlDownload = fullFileURL+'/servlet/servlet.FileDownload?file='+o.Id;
            } catch(Exception e){
                // AI_FIXED: Added error handling to return null if an error occurs during document processing.
                System.debug('Error generating CSV: ' + e.getMessage());
                URlDownload = null;
            }
        }
        system.debug('Download URL:' +URlDownload);
        return URlDownload;
    }
    
    @AuraEnabled
    public static void deleteCSVRecord(){        
        // AI_FIXED: Added try-catch block for exception handling during delete operation.
        try{
            List<Document> csvfiles= [SELECT Id From Document WHERE Name = 'Declined - Pre-Qualifier.csv'];
            if(csvfiles.size()>0){
                System.debug('deleted : '+csvfiles);
                delete csvfiles;
            }
        } catch(Exception e){
            // AI_FIXED: Added error handling to gracefully handle exceptions during deletion.
            System.debug('Error deleting CSV record: ' + e.getMessage());
        }
        
    }
}