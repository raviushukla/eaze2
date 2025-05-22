global without sharing class LeadListForAccountCls {
    
    @auraEnabled public LeadListForAccountCls.LeadW leads;
    
    @auraEnabled
    public static List<LeadW> getLeadsApex(){
        User usr = [Select Id, ContactId, /*Profile.PermissionsModifyAllData, */Contact.Account.Name from User where Id =: userInfo.getUserId() ];
        Contact agCon = new Contact();
        if( usr.ContactId != null ){
        	agCon = [Select Id, FirstName, LastName, Email, AccountId, Account.Name, Phone, MobilePhone from Contact where Id =: usr.ContactId];
        }
        list<LeadW> lwList = new list<LeadW>();
        String AccountName = agCon.Account.Name;
        String queryStr = ApexCommonHelper.getAllField('Lead');
        
        for(Lead l : database.query('Select '+ queryStr + ', Agent_Name__r.Name, '+'(Select Id, Body from Notes ) from Lead '+ 
                      ' Where Account_Name__c = :AccountName AND '+
                      'Account_Name__c != null AND '+
                      'IsConverted = false '+
                      'Order By CreatedDate DESC')
           ){
               LeadW lw = new LeadW();
               lw.leadObj = l;
               lw.agentContact = agCon;
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
               lw.description = l.Description;
               for( Note nt : l.Notes){
                   if( String.isNotBlank( nt.Body )   ){
                       if(String.isBlank(lw.notes)){
                           lw.notes = '';
                       }
                       lw.notes += nt.body +','  ;
                   }
               }
               lwList.add(lw);
           }
        system.debug(lwList);
        return lwList; 
    }
    
    
    public class LeadW {
        
        @auraEnabled public Contact agentContact{get;set;}
        @auraEnabled public Lead leadObj{get;set;}
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
        @auraEnabled public String description{get;set;}
        @auraEnabled public String agentName{get;set;}
        @auraEnabled public DateTime createdDate{get;set;}
        
        
    }
    
}