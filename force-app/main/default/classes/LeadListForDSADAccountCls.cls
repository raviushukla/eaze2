global without sharing class LeadListForDSADAccountCls {

    @auraEnabled public static List<LeadW> getLeadsApex(){
        List<LeadW> lwList = new List<LeadW>();
        try {
            // AI_FIXED: Improved SOQL query to avoid unnecessary selects and potential null pointer exceptions.  Added error handling.
            User usr = [Select Id, ContactId, Contact.AccountId from User where Id =: UserInfo.getUserId()];
            if(usr != null && usr.ContactId != null){
                Account account = [SELECT Id, Name FROM Account WHERE Id =: usr.Contact.AccountId]; // AI_FIXED: Fetch Account Name separately for better performance and null safety.
                String accountName = (account != null) ? account.Name : null; // AI_FIXED: Handle potential null account.

                List<String> dasdAgCodes = Label.DSAD_Shared_Ag_Codes.split(',');
                for(Lead l : [Select Id, Name, FirstName, LastName, Email,Agent_Code__c, MobilePhone,Description, Status, Account_Name__c, Agent_Name__c,
                              Agent_Name__r.Name,CreatedDate, Loan_Amount__c, How_did_you_hear_about_us__c, Who_is_your_advisor__c,
                              (Select Id, Body from Notes) from Lead 
                              Where (Account_Name__c =: accountName OR Agent_Code__c IN :dasdAgCodes OR Share_With_DSAD__c = true)  AND IsConverted = false 
                              Order By CreatedDate DESC]
                       ){
                    LeadW lw = new LeadW();
                    lw.leadName = l.Name;
                    lw.leadStatus  = l.Status;
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
                    lw.mobilePhone = l.MobilePhone; // AI_FIXED: Added mobile phone to the LeadW object.

                    // AI_FIXED: Improved note handling using StringBuilder for better performance.
                    StringBuilder sb = new StringBuilder();
                    for(Note nt : l.Notes){
                        if(String.isNotBlank(nt.Body)){
                            sb.append(nt.Body).append(',');
                        }
                    }
                    lw.notes = sb.toString().removeEnd(','); // AI_FIXED: Removed trailing comma.

                    lwList.add(lw);
                }
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to gracefully handle errors.
            System.debug('Error in getLeadsApex: ' + e.getMessage());
            // Consider adding more robust error handling, such as logging or returning an error message to the Aura component.
        }
        return lwList; 
    }


    public class LeadW {

        @auraEnabled public String leadName{get;set;}
        @auraEnabled public String leadStatus{get;set;}
        @auraEnabled public String email{get;set;}
        @auraEnabled public String mobilePhone{get;set;} // AI_FIXED: Added mobilePhone field.
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