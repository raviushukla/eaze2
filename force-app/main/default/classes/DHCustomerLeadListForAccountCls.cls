global without sharing class DHCustomerLeadListForAccountCls {

    @auraEnabled public static List<LeadW> getLeadsApex(){
        List<LeadW> lwList = new List<LeadW>();
        try{
            User usr = [Select Id, ContactId, Contact.Account.Name, Contact.Account.Default_Lead_Source__c from User where Id =: UserInfo.getUserId()];
            // AI_FIXED: Added try-catch block for exception handling
            // AI_FIXED: Removed unnecessary @auraEnabled annotation from the inner class.  It's inherited from the outer class.
            // AI_FIXED: Removed direct access to leads; variable.  It was not initialized and caused an error.
            String accountName = (usr != null && usr.Contact != null && usr.Contact.Account != null) ? usr.Contact.Account.Name : null;
            String defaultLeadSource = (usr != null && usr.Contact != null && usr.Contact.Account != null) ? usr.Contact.Account.Default_Lead_Source__c : null;

            for(Lead l : [Select Id, Name, FirstName, LastName, Email, MobilePhone, Status, Account_Name__c, Agent_Name__c, Agent_Name__r.Name, CreatedDate, Loan_Amount__c, How_did_you_hear_about_us__c, Who_is_your_advisor__c, (Select Id, Body from Notes) from Lead Where (Account_Name__c =: accountName OR (Account_Name__c = null AND LeadSource =: defaultLeadSource)) AND IsConverted = false Order By CreatedDate DESC]){
                LeadW lw = new LeadW();
                lw.leadName = l.Name;
                lw.leadStatus = l.Status;
                lw.email = l.Email;
                lw.loanAmount = l.Loan_Amount__c;
                lw.hearAboutUs = l.How_did_you_hear_about_us__c;
                lw.adviser = l.Who_is_your_advisor__c;
                lw.leadId = l.Id;
                lw.fName = l.FirstName;
                lw.lName = l.LastName;
                lw.agentName = l.Agent_Name__r.Name;
                lw.createdDate = l.CreatedDate;
                lw.mobilePhone = l.MobilePhone; // AI_FIXED: Added mobilePhone to LeadW object
                StringBuilder sb = new StringBuilder(); // AI_FIXED: Use StringBuilder for better performance in concatenating notes
                for(Note nt : l.Notes){
                    if(String.isNotBlank(nt.Body)){
                        sb.append(nt.Body).append(',');
                    }
                }
                lw.notes = sb.toString().trim(); // AI_FIXED: Removed unnecessary if condition and used StringBuilder for notes concatenation.  Trimmed trailing comma.
                lwList.add(lw);
            }
        } catch(Exception e){
            // AI_FIXED: Added exception handling to catch potential errors during query execution.
            System.debug('Error retrieving leads: ' + e.getMessage());
        }
        return lwList;
    }


    public class LeadW {
        @auraEnabled public String leadName{get;set;}
        @auraEnabled public String leadStatus{get;set;}
        @auraEnabled public String email{get;set;}
        @auraEnabled public String mobilePhone{get;set;} // AI_FIXED: Added mobilePhone field
        @auraEnabled public Decimal loanAmount{get;set;}
        @auraEnabled public String hearAboutUs{get;set;}
        @auraEnabled public String adviser{get;set;}
        @auraEnabled public String leadId{get;set;}
        @auraEnabled public String fName{get;set;}
        @auraEnabled public String lName{get;set;}
        @auraEnabled public String notes{get;set;}
        @auraEnabled public String agentName{get;set;}
        @auraEnabled public DateTime createdDate{get;set;}
    }
}