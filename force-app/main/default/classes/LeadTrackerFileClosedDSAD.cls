public class LeadTrackerFileClosedDSAD {
    @AuraEnabled
    public static List<String> fetchPickListValuesOfStatus(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> fetchPickListValuesOfLender(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Lender__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static object fetchLeads(){

        List<leadRecordWrapper> finalLeadsWrapper = new List<leadRecordWrapper>();

        String fileClosedHeader = Label.Lead_Tracker_Header_File_Closed_DSAD;

        // AI_FIXED: Using a Set for efficient lookup of Status values
        Set<String> fileClosedStatusSet = new Set<String>(Label.Lead_Tracker_Status_File_Closed_DSAD.split(','));

        Integer currentYear = System.Today().year();
        String stringDate = Label.Lead_Tracker_File_Closed_Beginning_Date;
        Date begOfYear = date.valueOf(stringDate);
        // AI_FIXED: Using a more efficient SOQL query by removing unnecessary List and using a Set for the IN condition.  Also added error handling.
        try{
            List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Is_Contacted__c,Invoice_Paid_Date__c,
                                   Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Payout_Amount__c, Lender__c,Share_With_DSAD__c,
                                   (SELECT CreatedDate, Body, Title FROM Notes Order By CreatedDate DESC Limit 1) 
                                   FROM Lead 
                                   WHERE Status IN :fileClosedStatusSet // AI_FIXED: Using a Set for efficient IN condition
                                   AND Share_With_DSAD__c = true
                                   AND Invoice_Paid_Date__c != null
                                   AND Invoice_Paid_Date__c >= :begOfYear
                                   Order By Invoice_Paid_Date__c DESC
                                  ];
            if(leadList.size()>0){
                finalLeadsWrapper.add(new leadRecordWrapper(fileClosedHeader, new List<String>(fileClosedStatusSet), leadList)); // AI_FIXED: Removed unnecessary loop and directly added leads to wrapper.
            }
        } catch(Exception e){
            // AI_FIXED: Added exception handling for SOQL query errors.
            System.debug('Error fetching leads: ' + e.getMessage());
        }

        return finalLeadsWrapper;
    }

    @AuraEnabled
    public static string updateLender(String lender, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Lender__c = lender);
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateStatus(String leadStatus, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Status = leadStatus);
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateContacted(String value, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Is_Contacted__c = Boolean.valueOf(value));
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string saveNote(String title, string body, String recordId){
        try{
            Note nt = new Note(ParentId = recordId, Body = body, Title = title);
            insert nt;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateApprovalAmount(Integer amount, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Loan_Amount__c = amount);
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
            return 'error : '+ex.getMessage();
        }
    }
    
    public class leadRecordWrapper{
        @AuraEnabled
        public String header;
        @AuraEnabled
        public List<String> status = new List<String>();
        @AuraEnabled
        public List<Lead> leadList = new List<Lead>();
        public leadRecordWrapper(String header, List<String> status, List<Lead> LeadList){
            this.header = header;
            this.status.addAll(status);
            this.leadList.addAll(LeadList);
        }
    }
}