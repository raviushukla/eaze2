public class LeadTrackerDeclined {
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
        
        List<String> leadStatus = new List<String>();
        
        String leadDeclinedHeader = Label.Lead_Tracker_Header_Declined;
        
        List<String> leadDeclinedStatus = Label.Lead_Tracker_Status_Declined.split(',');
        
        leadStatus.addAll(leadDeclinedStatus);
        
        Integer currentYear = System.Today().year();
        // AI_FIXED: Using Datetime.newInstance for better date handling and avoiding potential issues with Label parsing.
        Datetime begOfYear  = Datetime.newInstance(currentYear, 1, 1, 00, 00, 00);
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, Is_Contacted__c,Credit_Score__c,Credit_Score_Text__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Payout_Amount__c, Lender__c,Share_With_DSAD__c,
                               (SELECT CreatedDate, Body, Title FROM Notes Order By CreatedDate DESC Limit 1) 
                               FROM Lead 
                               WHERE Status IN: leadStatus 
                               AND CreatedDate >=: begOfYear
                               Order By CreatedDate DESC
                              ];
        system.debug('leadList : '+leadList);
        if(leadList.size()>0){
            // AI_FIXED: Removed unnecessary loop; the SOQL query already filters by status.
            finalLeadsWrapper.add(new leadRecordWrapper(leadDeclinedHeader, leadDeclinedStatus, leadList));
            system.debug(finalLeadsWrapper);
        }
        return finalLeadsWrapper;
    }
    
    @AuraEnabled
    public static string updateLender(String lender, String recordId){
        try{
            system.debug('lender : '+lender);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(Id = recordId, Lender__c = lender); // AI_FIXED: Simplified Lead constructor
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
            system.debug('leadStatus : '+leadStatus);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(Id = recordId, Status = leadStatus); // AI_FIXED: Simplified Lead constructor
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
            system.debug('value : '+value);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(Id = recordId, Is_Contacted__c = Boolean.valueOf(value)); // AI_FIXED: Simplified Lead constructor
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
            system.debug('title : '+title);
            system.debug('body : '+body);
            system.debug('recordId : '+recordId);
            Note nt = new Note(ParentId = recordId, Body = body, Title = title); // AI_FIXED: Simplified Note constructor
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
            system.debug('amount : '+amount);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(Id = recordId, Loan_Amount__c = amount); // AI_FIXED: Simplified Lead constructor
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