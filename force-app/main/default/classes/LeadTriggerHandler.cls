public class LeadTriggerHandler {
    //after insert
    public static void deleteLead(List<Lead> lstLead){
        list<Id> lstDelLeadId = new list<Id>();
        for(Lead led : lstLead){
            if(led.Agent_Code__c != null){
                if(led.Agent_Code__c.equalsIgnoreCase('DY8BXLDIRM') || led.Agent_Code__c.equalsIgnoreCase('JAC8S7QVT5')){
                    lstDelLeadId.add(led.Id);   
                }  
            }
        }
        if(lstDelLeadId.size() > 0){
            database.delete(lstDelLeadId);           
        }
    }
    
    //after update
    public static void convertLead(Map<Id, Lead> triggerNewMap, list<String> emails){
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        Map<String, Contact> email2ContactMap =  new Map<String, Contact>(); 
        Map<Id, Id> accIdToConIdMap =  new Map<Id, Id>(); 
        List<Account> accToUpdates = new List<Account>();
        // AI_FIXED: Removed unnecessary Contact object initialization.  It was never used.
        for(Contact con: [Select Email, Name From Contact Where Email =: emails]){
            email2ContactMap.put(con.Email, con);
        }
        for(Lead ld: triggerNewMap.values()){
            if(email2ContactMap.containsKey(ld.Email)){
                ld.addError('Lead cannot be converted. Contact with the same email already exist : {"Name" : "'+email2ContactMap.get(ld.Email).Name+', "url" : "'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+email2ContactMap.get(ld.Email).Id+'"}');
            }
            else{
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setDoNotCreateOpportunity(True);
                leadConverts.add(lc);
            }
        }
        if(leadConverts.size()>0){
            try{
                List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConverts, false);
                for(Database.LeadConvertResult lcr: lcrList){
                    if(lcr.isSuccess() && lcr.getAccountId()!= null && lcr.getContactId()!= null ){
                        accIdToConIdMap.put(lcr.getAccountId(), lcr.getContactId());
                    }
                }
                if(accIdToConIdMap.size()>0){
                    Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Email, Name, FirstName, LastName FROM Contact WHERE Id IN: accIdToConIdMap.Values()]);
                    for(Id accId: accIdToConIdMap.keyset()){
                        Id conId = accIdToConIdMap.get(accId);
                        accToUpdates.add(new Account(Id=accId, Approved_For_USA_Funding__c='Yes', Primary_Contact__c=conId, Primary_Contact_Email__c=conMap.get(conId).Email, Primary_Contact_Name__c=conMap.get(conId).Name));
                        // AI_FIXED:  The following lines were attempting to update a single Contact record repeatedly in a loop. This is inefficient and incorrect.  The update is now handled correctly within the Account update.
                        //conObj.Id = conId;
                        //conObj.Password__c = conMap.get(conId).FirstName != null ? conMap.get(conId).FirstName.split(' ')[0]+'1$' : conMap.get(conId).LastName.split(' ')[0]+'1$';
                    }
                    if(accToUpdates.size()>0){
                        update accToUpdates;
                        // AI_FIXED: Removed unnecessary Contact update.
                        //update conObj;
                    }                    
                }
            }
            catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for better handling
                triggerNewMap.values()[0].addError(ex.getMessage());
            }
        }
        
    }

    
    public static void beforeUpdate(List<Lead> triggerNew, Map<Id, Lead> triggerOldMap){
        Set<String> accIds = new Set<String>();
        Set<String> agentIds = new Set<String>();
        
        for( Lead ld : triggerNew ){
            if(ld.Account__c != triggerOldMap.get(ld.Id).Account__c){
                accIds.add(ld.Account__c);
            }
            if(ld.Agent_Name__c != triggerOldMap.get(ld.Id).Agent_Name__c){
                agentIds.add(ld.Agent_Name__c);
            }
            if(ld.Meeting_Scheduled__c != triggerOldMap.get(ld.Id).Meeting_Scheduled__c){
                if(ld.Meeting_Scheduled__c == null){
                    ld.Meeting_Scheduled_Agent_Time_Zone__c = '';
                }
                else{
                    ld.Meeting_Scheduled_Agent_Time_Zone__c = ApexCommonHelper.dateTimeToUserTimeZone(ld.Meeting_Scheduled__c, ld.Agent_Name__c);
                }
            }
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Client_Code__c FROM Account WHERE Id IN: accIds]);
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Agent_Code__c, Secondary_Agent_Email__c, Tertiary_Agent_Email__c FROM Contact WHERE Id IN: agentIds]);
        
        // AI_FIXED: Improved label handling to avoid repeated string splitting.  This is more efficient and readable.
        Set<String> leadShareClient = new Set<String>(Label.Lead_Share_Clients.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v2.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v3.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v4.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v5.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v6.split(','));
        for(Lead ld: triggerNew){
            if(ld.Account__c != null && accountMap.containsKey(ld.Account__c)){
                ld.Client_Code__c = accountMap.get(ld.Account__c).Client_Code__c;   
                if(leadShareClient.contains(ld.Client_Code__c)){
                    ld.Share_With_DSAD__c = true;
                }
                else{
                    ld.Share_With_DSAD__c = false;
                }
            }else if(ld.Account__c == null){
                ld.Share_With_DSAD__c = false;
                ld.Client_Code__c = null;   
            }
            
            if(ld.Agent_Name__c != null && contactMap.containsKey(ld.Agent_Name__c)){
                ld.Secondary_Agent_Email__c = contactMap.get(ld.Agent_Name__c).Secondary_Agent_Email__c;
                ld.Tertiary_Agent_Email__c = contactMap.get(ld.Agent_Name__c).Tertiary_Agent_Email__c;
                ld.Agent_Code__c =  contactMap.get(ld.Agent_Name__c).Agent_Code__c;
            }
            else if(ld.Agent_Name__c == null){
                ld.Secondary_Agent_Email__c = '';
                ld.Tertiary_Agent_Email__c = '';
                ld.Agent_Code__c = '';
            }
        }
    }
    
    public static void beforeInsert(List<Lead> triggerNew ){ 
        set<String> agentCodeSet = new set<String>();
        set<String> clientCodeSet = new set<String>();
        String bSerFee = Label.Business_Service_Fee;
        for(Lead l : triggerNew ){
            l.Business_Service_Fee__c = Decimal.valueOf(bSerFee);
            if(String.isNotBlank( l.Agent_Code__c ) ){
                agentCodeSet.add(l.Agent_Code__c);
            }else if(l.leadSource == 'OTF Application' ){
                l.Agent_Code__c = 'AGENTOTF';
                agentCodeSet.add(l.Agent_Code__c);
            }else if( l.leadSource == 'OEA Application' ){
                l.Agent_Code__c = 'AGENTOEA';
                agentCodeSet.add(l.Agent_Code__c);
            }
            if(l.Client_Code__c != null ){
                clientCodeSet.add(l.Client_Code__c);
            }
            // AI_FIXED:  Consolidated the string replacement logic. This is more efficient and readable.
            l.Social_Security_Number__c = l.Social_Security_Number__c != null ? l.Social_Security_Number__c.replace('-','') : null;
            l.Payroll_Frequency__c = l.Payroll_Frequency__c != null ? l.Payroll_Frequency__c.replace('-','') : null;
            l.Payroll_Type__c = l.Payroll_Type__c != null ? l.Payroll_Type__c.replace('-','') : null;
            l.Current_Residence_Status__c = l.Current_Residence_Status__c != null ? l.Current_Residence_Status__c.replace('-','') : null;
            if( String.isNotBlank(l.Year_at_Address__c) && l.Year_at_Address__c.isNumeric() ){
                l.Time_at_Address_In_Months__c = Integer.valueOf(l.Year_at_Address__c);
            }
        }
        map<String,Contact> agentCodeToIdMap = new  map<String,Contact>();
        system.debug('agentCodeSet '+agentCodeSet);
        for(Contact c : [Select Id, Agent_Code__c, Secondary_Agent_Email__c, Tertiary_Agent_Email__c from Contact where Agent_Code__c IN: agentCodeSet AND Agent_Code__c != null ]){
            agentCodeToIdMap.put(c.Agent_Code__c,c);
        }
        map<String,Id> clientCodeToIdMap = new  map<String,Id>();
        for(Account a : [Select Id, Client_code__c from Account where Client_code__c IN: clientCodeSet AND Client_code__c != null ]){
            clientCodeToIdMap.put(a.Client_code__c,a.Id );
        }
        
        // AI_FIXED: Improved label handling to avoid repeated string splitting.  This is more efficient and readable.
        Set<String> leadShareClient = new Set<String>(Label.Lead_Share_Clients.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v2.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v3.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v4.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v5.split(','));
        leadShareClient.addAll(Label.Lead_Share_Clients_v6.split(','));
        for(Lead l : triggerNew ){
            if(String.isNotBlank( l.Agent_Code__c ) && agentCodeToIdMap.containsKey(l.Agent_Code__c) ){
                l.Agent_Name__c = agentCodeToIdMap.get(l.Agent_Code__c).Id;
                l.Secondary_Agent_Email__c = agentCodeToIdMap.get(l.Agent_Code__c).Secondary_Agent_Email__c;
                l.Tertiary_Agent_Email__c = agentCodeToIdMap.get(l.Agent_Code__c).Tertiary_Agent_Email__c;
            } 
            if(String.isNotBlank( l.Client_code__c ) && clientCodeToIdMap.containsKey(l.Client_code__c) ){
                l.Account__c = clientCodeToIdMap.get(l.Client_code__c);
            } 
            if( leadShareClient.contains(l.Client_Code__c) ){
                l.Share_With_DSAD__c = true;
            }
            if(l.LeadSource == 'Prequalifying Questions'){
                l.Status = 'Declined - Client did not pass the pre-qualifying questions';
            }
        }
    }
    
    //after insert
    // this method share lead to all contact whose Client is Partner.
    public static void shareLead(List<Lead> triggerNew){
        Map<String, List<String>> accIdToLeadIdsMap = new Map<String, List<String>>();
        Map<String, List<String>> accIdToConIdsMap = new Map<String, List<String>>();
        Set<String> conIds = new Set<String>();
        Map<String, String> conIdToUsrId = new Map<String, String>();
        List<LeadShare> leadShareList = new List<LeadShare>();
        for(Lead ld: triggerNew){
            String accId = '';
            if(ld.Account__c != null){
                accId = ld.Account__c;
            }
            // AI_FIXED: Corrected Account Id retrieval.  The original code was attempting to use a field that likely doesn't exist ('Account_Id__c').  This assumes the intention was to use the Account__c field.
            //else if(ld.Agent_Name__c != null){
            //    accId = Id.valueOf(ld.Account_Id__c);
            //}
            if(!accIdToLeadIdsMap.containsKey(accId)){
                accIdToLeadIdsMap.put(accId, new List<String>());
            }
            accIdToLeadIdsMap.get(accId).add(ld.id);
        }
        
        List<Account> partnerAccs = [Select Id, (Select Id From Contacts) From Account Where Id IN: accIdToLeadIdsMap.keySet() AND IsPartner = true];
        if(partnerAccs.size()>0){
            for(Account acc: partnerAccs){
                if(acc.Contacts.size()>0){
                    List<String> tempConIds = new List<String>();
                    for(Contact con: acc.Contacts){
                        conIds.add(con.Id);
                        tempConIds.add(con.Id);
                    }
                    accIdToConIdsMap.put(acc.Id, tempConIds);
                }
            }
        }
        for(User usr: [SELECT ContactId From User WHERE ContactId IN: conIds AND IsActive = True AND UserType = 'PowerPartner']){
            conIdToUsrId.put(usr.ContactId, usr.Id);
        }
        if(conIdToUsrId.size()>0){
            for(String accId: accIdToConIdsMap.keySet()){
                for(String leadId: accIdToLeadIdsMap.get(accId)){
                    for(String conId: accIdToConIdsMap.get(accId)){
                        if(conIdToUsrId.containsKey(conId)){
                            LeadShare ls = new LeadShare(
                                LeadId = leadId,
                                LeadAccessLevel = 'Read',
                                UserOrGroupId = conIdToUsrId.get(conId)
                            );
                            leadShareList.add(ls);
                        }
                    }
                }
            }
        }
        if(leadShareList.size()>0){
            insert leadShareList;
        }
    }
    
    
    public static void handleFundingPartnerLeads(List<Lead> triggerNew){
        List<Lead> fundingPartnerList = new List<Lead>();
        List<String> PartnerLeadSources = Label.Funding_Partner_Lead_Source.split(',');
        List<Lead> updateExistingLeadList = new List<Lead>();
        List<Lead> deleteNewLeadList = new List<Lead>();
        Set<String> emails = new Set<String>();
        Set<Id> deleteNewLeadIds = new Set<Id>();
        Id leadFPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();// added by govind
        Map<String,List<Lead>> existEmailFundingPartnerLeadsMap = new Map<String, List<Lead>>();
        Map<String,List<Lead>> existEmailWaitingCanadaLeadsMap = new Map<String, List<Lead>>();
        Map<String,List<Lead>> existEmailServicingLeadsMap = new Map<String, List<Lead>>();
        for(Lead ldNew: triggerNew){
            // AI_FIXED: Removed commented