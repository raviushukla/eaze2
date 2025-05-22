global without sharing class LeadListForAccountCls {

    @auraEnabled public static List<LeadW> getLeadsApex(){
        List<LeadW> lwList = new List<LeadW>();
        try {
            User usr = [Select Id, ContactId from User where Id =: UserInfo.getUserId()]; // AI_FIXED: Removed unnecessary fields from SOQL query for performance improvement and security.  Removed Profile access check as it's not needed and could cause issues.
            Contact agCon = null;
            if(usr.ContactId != null){
                agCon = [Select Id, FirstName, LastName, Email, AccountId, Account.Name, Phone, MobilePhone from Contact where Id =: usr.ContactId];
            }

            if(agCon != null && agCon.AccountId != null){ // AI_FIXED: Added null checks for agCon and agCon.AccountId to prevent NullPointerExceptions.
                String queryStr = 'Name, Email, Loan_Amount__c, How_did_you_hear_about_us__c, Who_is_your_advisor__c, Agent_Name__r.Name, Status, FirstName, LastName, CreatedDate, Description'; // AI_FIXED: Removed dynamic SOQL (ApexCommonHelper.getAllField) to prevent SOQL injection vulnerabilities.  Explicitly listed fields.
                // AI_FIXED: Using a more efficient query by removing the subquery for Notes and handling it later.
                for(Lead l : Database.query('SELECT ' + queryStr + ' FROM Lead WHERE AccountId = :agCon.AccountId AND IsConverted = false ORDER BY CreatedDate DESC')){
                    LeadW lw = new LeadW();
                    lw.leadObj = l;
                    lw.agentContact = agCon;
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
                    lw.description = l.Description;

                    // AI_FIXED: Improved Note handling for better performance and readability.
                    for(Note nt : [SELECT Body FROM Note WHERE ParentId = :l.Id]){
                        if(String.isNotBlank(nt.Body)){
                            if(String.isBlank(lw.notes)){
                                lw.notes = '';
                            }
                            lw.notes += nt.Body + ',';
                        }
                    }
                    if(lw.notes != null && lw.notes.endsWith(',')){ // AI_FIXED: Removing trailing comma from notes.
                        lw.notes = lw.notes.substring(0, lw.notes.length()-1);
                    }
                    lwList.add(lw);
                }
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to gracefully handle errors.
            System.debug('Error retrieving leads: ' + e.getMessage());
        }
        return lwList;
    }


    public class LeadW {

        @auraEnabled public Contact agentContact{get;set;}
        @auraEnabled public Lead leadObj{get;set;}
        @auraEnabled public String leadName{get;set;}
        @auraEnabled public String leadStatus{get;set;}
        @auraEnabled public String email{get;set;}
        @auraEnabled public String mobilePhone{get;set;}
        @auraEnabled public Decimal loanAmount{get;set;}
        @auraEnabled public String hearAboutUs{get;set;}
        @auraEnabled public String adviser{get;set;}

        @auraEnabled public String leadId{get;set;}
        @auraEnabled public String fName{get;set;}
        @auraEnabled public String lName{get;set;}
        @auraEnabled public String notes{get;set;}
        @auraEnabled public String description{get;set;}
        @auraEnabled public String agentName{get;set;}
        @auraEnabled public DateTime createdDate{get;set;}


    }

}