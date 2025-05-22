public class LeadTrackerApprovedDSAD {
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

        String approvedHeader = Label.Lead_Tracker_Header_Approved_DSAD;
        String fundedHeader = Label.Lead_Tracker_Header_Funded_DSAD;

        List<String> approvedStatus = Label.Lead_Tracker_Status_Approved_DSAD.split(',');
        List<String> fundedStatus = Label.Lead_Tracker_Status_Funded_DSAD.split(',');

        leadStatus.addAll(approvedStatus);
        leadStatus.addAll(fundedStatus);

        Integer currentYear = System.Today().year();
        String stringDate = Label.Lead_Tracker_Beginning_Date;
        Datetime begOfYear = datetime.valueOf(stringDate);
        //DateTime begOfYear  = Datetime.newInstance(currentYear, 1, 1, 00, 00, 00);
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone,MobilePhone, Status, Total_Amount_pre_approved__c, Is_Contacted__c, Share_With_DSAD__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Payout_Amount__c, Lender__c, Pre_Approval_Date__c,Invoice_Paid_Date__c,
                               (SELECT CreatedDate, Body, Title FROM Notes Order By CreatedDate DESC Limit 1) 
                               FROM Lead 
                               WHERE Status IN: leadStatus 
                               AND CreatedDate >=: begOfYear
                               AND Share_With_DSAD__c = true
                               Order By CreatedDate DESC
                               ];
        system.debug('leadList : '+leadList);
        if(leadList.size()>0){
            List<Lead> tempApprovedLeads = new List<Lead>();
            List<Lead> tempFundedLeads = new List<Lead>();
            for(Lead ld: leadList){
                if(approvedStatus.contains(ld.Status)){
                    tempApprovedLeads.add(ld);
                }
                if(fundedStatus.contains(ld.Status)){
                    tempFundedLeads.add(ld);
                }
            }
            finalLeadsWrapper.add(new leadRecordWrapper(approvedHeader, approvedStatus, tempApprovedLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(fundedHeader, fundedStatus, tempFundedLeads));
            system.debug(finalLeadsWrapper);
        }
        return finalLeadsWrapper;
    }

    @AuraEnabled
    public static string updateLender(String lender, String recordId){
        try{
            system.debug('lender : '+lender);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(
                Id = recordId, 
                Lender__c = lender
            );
            update ld;
            return 'success';
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateStatus(String leadStatus, String recordId){
        try{
            system.debug('leadStatus : '+leadStatus);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(
                Id = recordId, 
                Status = leadStatus
            );
            update ld;
            return 'success';
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateContacted(String value, String recordId){
        try{
            system.debug('value : '+value);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(
                Id = recordId, 
                Is_Contacted__c = Boolean.valueOf(value)
            );
            update ld;
            return 'success';
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string saveNote(String title, string body, String recordId){
        try{
            system.debug('title : '+title);
            system.debug('body : '+body);
            system.debug('recordId : '+recordId);
            Note nt = new Note(
                ParentId = recordId, 
                Body = body,
                Title = title
            );
            insert nt;
            return 'success';
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateApprovalAmount(Integer amount, String recordId){
        try{
            system.debug('amount : '+amount);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(
                Id = recordId, 
                Loan_Amount__c = amount
            );
            update ld;
            return 'success';
        }
        catch(exception ex){
            return 'error : '+ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static string updateInvcPaidDate(String dt, String recordId){
        try{
            system.debug('dt : '+dt);
            system.debug('recordId : '+recordId);
            Lead ld = new Lead(Id = recordId);
            if(String.isNotBlank(dt)){
                ld.Invoice_Paid_Date__c = Date.valueOf(dt);
            }
            else{
                ld.Invoice_Paid_Date__c = null;
            }
            update ld;
            return 'success';
        }
        catch(exception ex){
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