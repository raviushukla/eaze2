public class LeadTracker {
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
    public static List<leadRecordWrapper> fetchLeads(){ // AI_FIXED: Changed return type to List<leadRecordWrapper> for consistency

        List<leadRecordWrapper> finalLeadsWrapper = new List<leadRecordWrapper>();

        List<String> leadStatus = new List<String>();
		
        String bookedwithEazeHeader = Label.Lead_Tracker_Header_Book_With_Eaze;
        String clientHasAcceptTermsHeader = Label.Lead_Tracker_Header_Client_has_accepted_terms;
        String allDocsInHeader = Label.Lead_Tracker_Header_All_Docs_In;
        String preApprovedHeader = Label.Lead_Tracker_Header_Pre_Approvals;
        String alertPlzHeader = Label.Lead_Tracker_Alert_Please_Check_Notes;
        
		List<String> bookedwithEazeStatus = Label.Lead_Tracker_Status_Book_With_Eaze.split(',');
        List<String> clientHasAcceptTermsStatus = Label.Lead_Tracker_Status_Client_has_accepted_terms.split(',');
        List<String> allDocsInStatus = Label.Lead_Tracker_Status_All_Docs_In.split(',');
        List<String> preApprovedStatus = Label.Lead_Tracker_Status_Pre_Approvals.split(',');
        List<String> alertPlzStatus = new List<String>{Label.Lead_Tracker_Alert_Please_Check_Notes};

        leadStatus.addAll(bookedwithEazeStatus);
        leadStatus.addAll(clientHasAcceptTermsStatus);
        leadStatus.addAll(allDocsInStatus);
        leadStatus.addAll(preApprovedStatus);
		leadStatus.addAll(alertPlzStatus);
        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Lead_Tracker_Beginning_Date;
        Datetime begOfYear = Datetime.valueOf(stringDate); // AI_FIXED: Corrected Datetime.valueOf usage
        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, Is_Contacted__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Payout_Amount__c, Lender__c,
                               (SELECT CreatedDate, Body, Title 
                                FROM Notes 
                                Order By CreatedDate DESC Limit 1),
                               (SELECT CreatedDate, SMS_Subject__c,Do_Not_Update__c
                                FROM Twilio_SMS__r WHERE Type__c = 'Outgoing' 
                                AND SMS_Recipient__c != null
                                AND SMS_Subject__c != null
                                Order By CreatedDate DESC Limit 1)
                               FROM Lead 
                               WHERE Status IN: leadStatus 
                               AND CreatedDate >=: begOfYear
                               Order By CreatedDate DESC
                               ];
        if(leadList.size()>0){
            List<Lead> tempBookedwithEazeStatusLeads = new List<Lead>();
            List<Lead> tempclientHasAcceptTermsStatusLeads = new List<Lead>();
            List<Lead> tempAllDocsInLeads = new List<Lead>();
            List<Lead> tempPreApprovedLeads = new List<Lead>();
            List<Lead> tempAlertPlzLeads = new List<Lead>();
            for(Lead ld: leadList){
                if(bookedwithEazeStatus.contains(ld.Status)){
                    tempBookedwithEazeStatusLeads.add(ld);
                }
                if(clientHasAcceptTermsStatus.contains(ld.Status)){
                    tempclientHasAcceptTermsStatusLeads.add(ld);
                }
                if(allDocsInStatus.contains(ld.Status)){
                    tempAllDocsInLeads.add(ld);
                }
                if(preApprovedStatus.contains(ld.Status)){
                    tempPreApprovedLeads.add(ld);
                }
                if(alertPlzStatus.contains(ld.Status)){
                    tempAlertPlzLeads.add(ld);
                }
            }
            finalLeadsWrapper.add(new leadRecordWrapper(bookedwithEazeHeader, bookedwithEazeStatus, tempBookedwithEazeStatusLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(clientHasAcceptTermsHeader, clientHasAcceptTermsStatus, tempclientHasAcceptTermsStatusLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(allDocsInHeader, allDocsInStatus, tempAllDocsInLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(preApprovedHeader, preApprovedStatus, tempPreApprovedLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(alertPlzHeader, alertPlzStatus, tempAlertPlzLeads));
        }
        return finalLeadsWrapper;
    }

    @AuraEnabled
    public static string updateLender(String lender, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Lender__c = lender); // AI_FIXED: Simplified Lead object creation
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateStatus(String leadStatus, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Status = leadStatus); // AI_FIXED: Simplified Lead object creation
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateContacted(String value, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Is_Contacted__c = Boolean.valueOf(value)); // AI_FIXED: Simplified Lead object creation
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string saveNote(String title, string body, String recordId){
        try{
            Note nt = new Note(ParentId = recordId, Body = body, Title = title); // AI_FIXED: Simplified Note object creation
            insert nt;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception
            return 'error : '+ex.getMessage();
        }
    }

    @AuraEnabled
    public static string updateApprovalAmount(Integer amount, String recordId){
        try{
            Lead ld = new Lead(Id = recordId, Loan_Amount__c = amount); // AI_FIXED: Simplified Lead object creation
            update ld;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception
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