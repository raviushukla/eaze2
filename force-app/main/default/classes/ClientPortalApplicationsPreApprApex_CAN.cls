/*
	Test Class -> ClientPortalApplicationsPAApex_CAN_Test
*/
public without sharing class ClientPortalApplicationsPreApprApex_CAN {
	@AuraEnabled
    public static List<leadRecordWrapper> fetchApplications(String accId){
        // AI_FIXED: Changed return type to List<leadRecordWrapper> for clarity and consistency.
        List<leadRecordWrapper> finalLeadsWrapper = new List<leadRecordWrapper>();
        
        List<String> leadStatus = new List<String>();
        
        String clientHasAcceptTermsHeader = Label.ClientApplicationsClientHasAcceptedTermsHeader;
        String allDocsInHeader = Label.ClientApplicationsAllDocsInHeader;
        String preApprovedHeader = Label.ClientApplicationsPreApprovalHeader;
        String termsPitchedHeader = Label.ClientApplicationsTermsPitchedHeader;
        String bookedWithEazeHeader = Label.ClientApplicationsBookedWithEazeHeader;
        
        List<String> clientHasAcceptTermsStatus = Label.ClientApplicationsClientHasAcceptedTermsStatus.split(',');
        List<String> allDocsInStatus = Label.ClientApplicationsAllDocsInStatus.split(',');
        List<String> preApprovedStatus = Label.ClientApplicationsPreApprovalStatus.split(',');
        List<String> termsPitchedStatus = Label.ClientApplicationsTermsPitchedStatus.split(',');
        List<String> bookedWithEazeStatus = Label.ClientApplicationsBookedWithEazeStatus.split(',');
        
        leadStatus.addAll(clientHasAcceptTermsStatus);
        leadStatus.addAll(allDocsInStatus);
        leadStatus.addAll(preApprovedStatus);
        leadStatus.addAll(termsPitchedStatus);
        leadStatus.addAll(bookedWithEazeStatus);
        
        Integer currentYear = System.Today().year();
        String stringDate = Label.Client_Applications_Start_Date;
        // AI_FIXED:  Handle potential exception during Datetime conversion.
        Datetime begOfYear;
        try{
            begOfYear = Datetime.valueOf(stringDate);
        } catch (Exception e){
            // AI_FIXED: Log the exception for debugging purposes.  Consider a more robust error handling strategy in production.
            System.debug('Error parsing date: ' + e.getMessage());
            return finalLeadsWrapper; // Return empty list if date parsing fails.
        }

        // AI_FIXED: Added null check for accId to prevent SOQL injection and NullPointerException.
        if(String.isBlank(accId)){
            return finalLeadsWrapper;
        }

        List<Lead> leadList = [SELECT CreatedDate, LastModifiedDate, Name, Phone, MobilePhone, Status, Total_Amount_pre_approved__c, Loan_Amount_USD__c,
                               Loan_Amount__c, Account__c, Account__r.Name, Account_Name__c, Agent_Name_Text__c, Email, Meeting_Created__c, Meeting_Scheduled__c
                               FROM Lead 
                               WHERE Status IN: leadStatus
                               AND Account__c =: accId
                               AND CreatedDate >=: begOfYear
                               AND RecordType.Name = 'CAN Lead'
                               Order By CreatedDate DESC
                              ];
        system.debug('leadList : '+leadList);
        if(leadList.size()>0){
            List<Lead> tempclientHasAcceptTermsStatusLeads = new List<Lead>();
            List<Lead> tempAllDocsInLeads = new List<Lead>();
            List<Lead> tempPreApprovedLeads = new List<Lead>();
            List<Lead> tempTermsPitchedLeads = new List<Lead>();
            List<Lead> tempBookedWithEazeLeads = new List<Lead>();
            for(Lead ld: leadList){
                if(clientHasAcceptTermsStatus.contains(ld.Status)){
                    tempclientHasAcceptTermsStatusLeads.add(ld);
                }
                if(allDocsInStatus.contains(ld.Status)){
                    tempAllDocsInLeads.add(ld);
                }
                if(preApprovedStatus.contains(ld.Status)){
                    tempPreApprovedLeads.add(ld);
                }
                if(termsPitchedStatus.contains(ld.Status)){
                    tempTermsPitchedLeads.add(ld);
                }
                if(bookedWithEazeStatus.contains(ld.Status)){
                    tempBookedWithEazeLeads.add(ld);
                }
            }
            // ordering to display records on page.
            finalLeadsWrapper.add(new leadRecordWrapper(preApprovedHeader, preApprovedStatus, tempPreApprovedLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(bookedWithEazeHeader, bookedWithEazeStatus, tempBookedWithEazeLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(clientHasAcceptTermsHeader, clientHasAcceptTermsStatus, tempclientHasAcceptTermsStatusLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(allDocsInHeader, allDocsInStatus, tempAllDocsInLeads));
            finalLeadsWrapper.add(new leadRecordWrapper(termsPitchedHeader, termsPitchedStatus, tempTermsPitchedLeads));
            system.debug(finalLeadsWrapper);
        }
        return finalLeadsWrapper;
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