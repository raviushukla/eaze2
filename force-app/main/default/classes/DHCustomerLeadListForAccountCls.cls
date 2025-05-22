global without sharing class DHCustomerLeadListForAccountCls {
    
    @auraEnabled public LeadListForAccountCls.LeadW leads;
    
    @auraEnabled
    public static List<LeadW> getLeadsApex(){
        User usr = [Select Id, ContactId, Contact.Account.Name,Contact.Account.Default_Lead_Source__c from User where Id =: userInfo.getUserId() ];
        list<LeadW> lwList = new list<LeadW>();
        
        for(Lead l : [Select Id, Name, FirstName, LastName, Email, MobilePhone, Status, Account_Name__c, Agent_Name__c,
                      Agent_Name__r.Name,CreatedDate, Loan_Amount__c, How_did_you_hear_about_us__c, Who_is_your_advisor__c, 
                      (Select Id, Body from Notes ) from Lead 
                      Where (Account_Name__c =: usr.Contact.Account.Name OR (Account_Name__c =: null AND LeadSource = : usr.Contact.Account.Default_Lead_Source__c)) AND 
                      IsConverted =: false 
                      Order By CreatedDate DESC]){
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
               lw.agentName = l.Agent_Name__r.name;
               lw.createdDate = l.CreatedDate ;
               
               /*for( Note nt : l.Notes){
                   if( String.isNotBlank( nt.Body )   ){
                       if(String.isBlank(lw.notes)){
                           lw.notes = '';
                       }
                       lw.notes += nt.body +','  ;
                   }
               }*/
               lwList.add(lw);
           }
        system.debug(lwList);
        return lwList; 
    }
    
    
    public class LeadW {
        
        @auraEnabled public String leadName{get;set;}
        @auraEnabled public String leadStatus{get;set;}
        @auraEnabled public String email{get;set;}
        @auraEnabled public String mobilePhone{get;set;}
        @auraEnabled public decimal loanAmount{get;set;}
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