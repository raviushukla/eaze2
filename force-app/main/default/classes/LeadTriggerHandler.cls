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
        Contact conObj = new Contact();
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
                        conObj.Id = conId;
                        conObj.Password__c = conMap.get(conId).FirstName != null ? conMap.get(conId).FirstName.split(' ')[0]+'1$' : conMap.get(conId).LastName.split(' ')[0]+'1$';
                    }
                    if(accToUpdates.size()>0){
                        update accToUpdates;
                        update conObj;
                    }                    
                }
            }
            catch(exception ex){
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
        
        Set<String> leadShareClient = new Set<String>();
        leadShareClient.addAll(Label.Lead_Share_Clients.split(','));
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
            if(l.Social_Security_Number__c != null && l.Social_Security_Number__c.contains('-')){
                l.Social_Security_Number__c = l.Social_Security_Number__c.replace('-','');
            }
            if(l.Payroll_Frequency__c != null && l.Payroll_Frequency__c.contains('-')){
                l.Payroll_Frequency__c = l.Payroll_Frequency__c.replace('-','');
            }
            if(l.Payroll_Type__c != null && l.Payroll_Type__c.contains('-')){
                l.Payroll_Type__c = l.Payroll_Type__c.replace('-','');
            }
            if(l.Current_Residence_Status__c != null && l.Current_Residence_Status__c.contains('-')){
                l.Current_Residence_Status__c = l.Current_Residence_Status__c.replace('-','');
            }
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
        
        Set<String> leadShareClient = new Set<String>();
        leadShareClient.addAll(Label.Lead_Share_Clients.split(','));
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
            else if(ld.Agent_Name__c != null){
                accId = Id.valueOf(ld.Account_Id__c);
            }
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
            if( /*PartnerLeadSources.contains(ldNew.LeadSource) &&*/ ldNew.RecordTypeId == leadFPRecordTypeId){
                emails.add(ldNew.Email);
                fundingPartnerList.add(ldNew);
            }
        }
        List<Lead> existingLeads = [SELECT FirstName, LastName, Company, MobilePhone, Email, Website, street, city, country, state, PostalCode, LeadSource,
                                    In_Business_from_Year__c, Sales_Agent_Count__c, Who_were_you_referred_by__c, Total_Sales_FY_in_2018__c, 
                                    Average_Month_Sales_In_2019__c , Accounting_Associate__c, Accounting_Associate_s_Email__c, Status, Send_to_Quickbooks__c,
                                    Name_of_Business__c, Sales_Agents__c, Last_12_Months_Sales__c,Current_Monthly_Sales_Canada__c, Current_Monthly_Sales__c,
                                    Anticipated_Monthly_Sales__c, Associate_s_Name__c, Niche__c, Current_Month_Volume__c, Last_12_Months_Sales_LoanServicing__c,
                                    Paid_Payment_Plan_Vs_Pay_In_Full__c, Payment_Plan_Choice__c, Payment_Plan_Completion_Percentage__c, Deposit_Required__c,
                                    Amount_Of_Hours__c, Monthly_Volume_In_Payment_Plan__c, Price_Point__c, Program_Duration__c, Your_main_benefit_of_Outsourcing__c,
                                    Payment_Extension__c, How_soon_to_Implement_Outsourcing__c
                                    FROM Lead WHERE Id NOT IN :fundingPartnerList AND Email IN: emails AND RecordTypeId =: leadFPRecordTypeId AND IsConverted = false ];
        for(Lead ld: existingLeads){
            if(ld.LeadSource == 'Funding Partner Contact Us' || ld.LeadSource == 'Funding Partner Intro Done'){
                if(!existEmailFundingPartnerLeadsMap.containsKey(ld.Email.toLowerCase())){
                    existEmailFundingPartnerLeadsMap.put(ld.Email.toLowerCase(), new List<Lead>());
                }
                existEmailFundingPartnerLeadsMap.get(ld.Email.toLowerCase()).add(ld);
            }else if(ld.LeadSource == 'Waiting List Canada'){
                if(!existEmailWaitingCanadaLeadsMap.containsKey(ld.Email.toLowerCase())){
                    existEmailWaitingCanadaLeadsMap.put(ld.Email.toLowerCase(), new List<Lead>());
                }
                existEmailWaitingCanadaLeadsMap.get(ld.Email.toLowerCase()).add(ld);
            }else if(ld.LeadSource == 'Loan Service Waiting'){
                if(!existEmailServicingLeadsMap.containsKey(ld.Email.toLowerCase())){
                    existEmailServicingLeadsMap.put(ld.Email.toLowerCase(), new List<Lead>());
                }
                existEmailServicingLeadsMap.get(ld.Email.toLowerCase()).add(ld);
            }
        }
        for(Lead ldNew: fundingPartnerList){
            if(existEmailFundingPartnerLeadsMap.containsKey(ldNew.email.toLowerCase()) && (ldNew.LeadSource == 'Funding Partner Contact Us' || ldNew.LeadSource == 'Funding Partner Intro Done')){
                for(Lead ldExist : existEmailFundingPartnerLeadsMap.get(ldNew.email.toLowerCase())){
                    ldExist.FirstName = ldNew.FirstName;
                    ldExist.LastName = ldNew.LastName;
                    ldExist.Company = ldNew.Company;
                    ldExist.MobilePhone = ldNew.MobilePhone;
                    ldExist.Website = ldNew.Website;
                    ldExist.street = ldNew.street;
                    ldExist.city = ldNew.city;
                    ldExist.country = ldNew.country;
                    ldExist.state = ldNew.state;
                    ldExist.PostalCode = ldNew.PostalCode;
                    ldExist.In_Business_from_Year__c = ldNew.In_Business_from_Year__c;
                    ldExist.Sales_Agent_Count__c = ldNew.Sales_Agent_Count__c;
                    ldExist.Who_were_you_referred_by__c = ldNew.Who_were_you_referred_by__c;
                    ldExist.Accounting_Associate__c = ldNew.Accounting_Associate__c;
                    ldExist.Accounting_Associate_s_Email__c = ldNew.Accounting_Associate_s_Email__c;
                    ldExist.Total_Sales_FY_in_2018__c = ldNew.Total_Sales_FY_in_2018__c;
                    ldExist.Average_Month_Sales_In_2019__c = ldNew.Average_Month_Sales_In_2019__c;
                    ldExist.Associate_s_Name__c = ldNew.Associate_s_Name__c;
                    ldExist.Business_Incorporated_State__c = ldNew.Business_Incorporated_State__c;
                    ldExist.Type_of_Client_to_Fund__c = ldNew.Type_of_Client_to_Fund__c;
                    
                    if( ldExist.Status == 'New Lead' ){
                        if(ldNew.LeadSource == 'Funding Partner Intro Done' ){
                            if( ldExist.LeadSource == 'Funding Partner Contact Us'){
                                ldExist.LeadSource = ldNew.LeadSource;
                            }
                        }
                    }
                    updateExistingLeadList.add(ldExist);
                    deleteNewLeadIds.add(ldNew.Id);
                }
            }
            if(existEmailWaitingCanadaLeadsMap.containsKey(ldNew.email.toLowerCase()) && ldNew.LeadSource == 'Waiting List Canada'){
                for(Lead ldExist : existEmailWaitingCanadaLeadsMap.get(ldNew.email.toLowerCase())){
                    ldExist.FirstName = ldNew.FirstName;
                    ldExist.LastName = ldNew.LastName;
                    ldExist.Company = ldNew.Company;
                    ldExist.MobilePhone = ldNew.MobilePhone;
                    ldExist.Website = ldNew.Website;
                    ldExist.street = ldNew.street;
                    ldExist.city = ldNew.city;
                    ldExist.country = ldNew.country;
                    ldExist.state = ldNew.state;
                    ldExist.PostalCode = ldNew.PostalCode;
                    ldExist.Name_of_Business__c = ldNew.Name_of_Business__c;
                    ldExist.Sales_Agents__c = ldNew.Sales_Agents__c;
                    ldExist.Last_12_Months_Sales__c = ldNew.Last_12_Months_Sales__c;
                    ldExist.Current_Monthly_Sales_Canada__c = ldNew.Current_Monthly_Sales_Canada__c;
                    ldExist.Current_Monthly_Sales__c = ldNew.Current_Monthly_Sales__c;
                    ldExist.Anticipated_Monthly_Sales__c = ldNew.Anticipated_Monthly_Sales__c;
                    ldExist.Associate_s_Name__c = ldNew.Associate_s_Name__c;
                    
                    updateExistingLeadList.add(ldExist);
                    deleteNewLeadIds.add(ldNew.Id);
                }
            } 
            if(existEmailServicingLeadsMap.containsKey(ldNew.email.toLowerCase()) && ldNew.LeadSource == 'Loan Service Waiting'){
                for(Lead ldExist : existEmailServicingLeadsMap.get(ldNew.email.toLowerCase())){
                    ldExist.FirstName = ldNew.FirstName;
                    ldExist.LastName = ldNew.LastName;
                    ldExist.Company = ldNew.Company;
                    ldExist.MobilePhone = ldNew.MobilePhone;
                    ldExist.Website = ldNew.Website;
                    ldExist.street = ldNew.street;
                    ldExist.city = ldNew.city;
                    ldExist.country = ldNew.country;
                    ldExist.state = ldNew.state;
                    ldExist.PostalCode = ldNew.PostalCode;
                    ldExist.Name_of_Business__c = ldNew.Name_of_Business__c;
                    ldExist.Niche__c = ldNew.Niche__c;
                    ldExist.Current_Month_Volume__c = ldNew.Current_Month_Volume__c;
                    ldExist.Last_12_Months_Sales_LoanServicing__c = ldNew.Last_12_Months_Sales_LoanServicing__c;
                    ldExist.Paid_Payment_Plan_Vs_Pay_In_Full__c = ldNew.Paid_Payment_Plan_Vs_Pay_In_Full__c;
                    ldExist.Payment_Plan_Choice__c = ldNew.Payment_Plan_Choice__c;
                    ldExist.Payment_Plan_Completion_Percentage__c = ldNew.Payment_Plan_Completion_Percentage__c;
                    ldExist.Associate_s_Name__c = ldNew.Associate_s_Name__c;
                    ldExist.Amount_Of_Hours__c = ldNew.Amount_Of_Hours__c;
                    ldExist.Deposit_Required__c = ldNew.Deposit_Required__c;
                    ldExist.Monthly_Volume_In_Payment_Plan__c = ldNew.Monthly_Volume_In_Payment_Plan__c;
                    ldExist.Price_Point__c = ldNew.Price_Point__c;
                    ldExist.Program_Duration__c = ldNew.Program_Duration__c;
                    ldExist.Your_main_benefit_of_Outsourcing__c = ldNew.Your_main_benefit_of_Outsourcing__c;
                    ldExist.Payment_Extension__c = ldNew.Payment_Extension__c;
                    ldExist.How_soon_to_Implement_Outsourcing__c = ldNew.How_soon_to_Implement_Outsourcing__c;
                    
                    updateExistingLeadList.add(ldExist);
                    deleteNewLeadIds.add(ldNew.Id);
                }
            }  
        }
        if(updateExistingLeadList.size()>0){
            update updateExistingLeadList;
        }
        if(deleteNewLeadIds.size()>0){
            list<Id> delIds = new list<Id>();
            delIds.addAll(deleteNewLeadIds);
            database.delete(delIds, false);
        }
    }
    
    // Convert Canada Funding partner Leads
    public static void convertCanadaFundingPartnerLeads(List<Lead> fundingLeadList){
        Map<Id, Lead> triggerNewMap = new Map<Id, Lead>();
        Map<String,String> emailNameMap = new Map<String,String>();
        Map<String, Account> accNameObjMap = new Map<String, Account>();
        Map<String, Account> accConNameObjMap = new Map<String, Account>();
        List<String> companyList = new List<String>();
        for(Lead ld : fundingLeadList){
            emailNameMap.put(ld.Email.toLowerCase(), ld.Name__c.toLowerCase());
            companyList.add(ld.Company.toLowerCase());
        }
        system.debug('emailNameMap : '+emailNameMap +'  '+'companyList'+'   '+companyList);
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        list<Database.LeadConvert> leadConvertsUpdate = new list<Database.LeadConvert>(); // Account and Contact record already present.  
        Map<String, Contact> email2ContactMap =  new Map<String, Contact>(); 
        Map<String, Contact> name2ContactMap =  new Map<String, Contact>(); 
        Map<Id, Id> accIdToConIdMap =  new Map<Id, Id>(); 
        List<Account> accList = [Select Id, Name, Primary_Contact__r.Email, Primary_Contact__r.Name From Account Where Name IN: companyList AND Primary_Contact__c != null];
        for(Account acc : accList){
        	accNameObjMap.put(acc.Name.toLowerCase(), acc);
            accConNameObjMap.put(acc.Primary_Contact__r.Name.toLowerCase(), acc);
        } 
        List<Account> accToUpdates = new List<Account>();
        system.debug(emailNameMap  +'   '+[Select Email, Name, AccountId From Contact Where Name IN: emailNameMap.values()]);
        for(Contact con: [Select Email, Name, AccountId From Contact Where Email IN: emailNameMap.keySet() OR Name IN: emailNameMap.values()]){
            email2ContactMap.put(con.Email.toLowerCase(), con);
            name2ContactMap.put(con.Name.toLowerCase(), con);
        }
        for(Lead ld: fundingLeadList){
            system.debug('name2ContactMap : '+name2ContactMap );
            if(accNameObjMap.containsKey(ld.Company.toLowerCase().trim()) && accConNameObjMap.containsKey(ld.Name__c.toLowerCase().trim()) && accNameObjMap.get(ld.Company.toLowerCase().trim()).Id == accConNameObjMap.get(ld.Name__c.toLowerCase().trim()).Id){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(accNameObjMap.get(ld.Company.toLowerCase().trim()).Id);
                lc.setContactId(accConNameObjMap.get(ld.Name__c.toLowerCase().trim()).Primary_Contact__c);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else if(email2ContactMap.containsKey(ld.Email.toLowerCase().trim()) && name2ContactMap.containsKey(ld.Name__c.toLowerCase().trim()) && email2ContactMap.get(ld.Email.toLowerCase().trim()).Id == name2ContactMap.get(ld.Name__c.toLowerCase().trim()).Id){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(email2ContactMap.get(ld.Email.toLowerCase().trim()).AccountId);
                lc.setContactId(email2ContactMap.get(ld.Email.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else if(email2ContactMap.containsKey(ld.Email.toLowerCase().trim())){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(email2ContactMap.get(ld.Email.toLowerCase().trim()).AccountId);
                lc.setContactId(email2ContactMap.get(ld.Email.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
        	}else if(name2ContactMap.containsKey(ld.Name__c.toLowerCase().trim())){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(name2ContactMap.get(ld.Name__c.toLowerCase().trim()).AccountId);
                lc.setContactId(name2ContactMap.get(ld.Name__c.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else{
                ld.addError('Did not find the matching Account and Contact for the Lead.');
            }            
            
        }
        
        if(leadConvertsUpdate.size()>0){ // Account updated
            try{
                List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConvertsUpdate, false);
                for(Database.LeadConvertResult lcr: lcrList){
                    system.debug('lcr : '+lcr);
                    if(lcr.isSuccess() && lcr.getAccountId()!= null && lcr.getContactId()!= null ){
                        accIdToConIdMap.put(lcr.getAccountId(), lcr.getContactId());
                    }
                }
                if(accIdToConIdMap.size()>0){
                    Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Email, Name FROM Contact WHERE Id IN: accIdToConIdMap.Values()]);
                    for(Id accId: accIdToConIdMap.keyset()){
                        Id conId = accIdToConIdMap.get(accId);
                        accToUpdates.add(new Account(Id = accId, Approved_For_CAN_Funding__c = 'Yes' ));
                    }
                    if(accToUpdates.size()>0){
                        update accToUpdates;
                    }             
                    system.debug('accToUpdates : '+accToUpdates);
                }
            }
            catch(exception ex){triggerNewMap.values()[0].addError(ex.getMessage());}
        }
        
    }
    
    // Convert Servicing partner Leads
    public static void convertServicingPartnerLeads(List<Lead> servicingLeadList){
        Map<Id, Lead> triggerNewMap = new Map<Id, Lead>();
        Map<String,String> emailNameMap = new Map<String,String>();
        Map<String, Account> accNameObjMap = new Map<String, Account>();
        Map<String, Account> accConNameObjMap = new Map<String, Account>();
        List<String> companyList = new List<String>();
        for(Lead ld : servicingLeadList){
            emailNameMap.put(ld.Email.toLowerCase(), ld.Name__c.toLowerCase());
            companyList.add(ld.Company.toLowerCase());
        }
        system.debug('emailNameMap : '+emailNameMap +'  '+'companyList'+'   '+companyList);
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        list<Database.LeadConvert> leadConvertsUpdate = new list<Database.LeadConvert>(); // Account and Contact record already present.  
        Map<String, Contact> email2ContactMap =  new Map<String, Contact>(); 
        Map<String, Contact> name2ContactMap =  new Map<String, Contact>(); 
        Map<Id, Id> accIdToLeadIdMap =  new Map<Id, Id>(); 
        List<Account> accList = [Select Id, Name, Primary_Contact__r.Email, Primary_Contact__r.Name From Account Where Name IN: companyList AND Primary_Contact__c != null];
        for(Account acc : accList){
        	accNameObjMap.put(acc.Name.toLowerCase(), acc);
            accConNameObjMap.put(acc.Primary_Contact__r.Name.toLowerCase(), acc);
        } 
        List<Account> accToUpdates = new List<Account>();
        system.debug(emailNameMap  +'   '+[Select Email, Name, AccountId From Contact Where Name IN: emailNameMap.values()]);
        for(Contact con: [Select Email, Name, AccountId From Contact Where Email IN: emailNameMap.keySet() OR Name IN: emailNameMap.values()]){
            email2ContactMap.put(con.Email.toLowerCase(), con);
            name2ContactMap.put(con.Name.toLowerCase(), con);
        }
        for(Lead ld: servicingLeadList){
            system.debug('name2ContactMap : '+name2ContactMap );
            if(accNameObjMap.containsKey(ld.Company.toLowerCase().trim()) && accConNameObjMap.containsKey(ld.Name__c.toLowerCase().trim()) && accNameObjMap.get(ld.Company.toLowerCase().trim()).Id == accConNameObjMap.get(ld.Name__c.toLowerCase().trim()).Id){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(accNameObjMap.get(ld.Company.toLowerCase().trim()).Id);
                lc.setContactId(accConNameObjMap.get(ld.Name__c.toLowerCase().trim()).Primary_Contact__c);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else if(email2ContactMap.containsKey(ld.Email.toLowerCase().trim()) && name2ContactMap.containsKey(ld.Name__c.toLowerCase().trim()) && email2ContactMap.get(ld.Email.toLowerCase().trim()).Id == name2ContactMap.get(ld.Name__c.toLowerCase().trim()).Id){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(email2ContactMap.get(ld.Email.toLowerCase().trim()).AccountId);
                lc.setContactId(email2ContactMap.get(ld.Email.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else if(email2ContactMap.containsKey(ld.Email.toLowerCase().trim())){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(email2ContactMap.get(ld.Email.toLowerCase().trim()).AccountId);
                lc.setContactId(email2ContactMap.get(ld.Email.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
        	}else if(name2ContactMap.containsKey(ld.Name__c.toLowerCase().trim())){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(ld.Id);
                lc.convertedStatus='Qualified';
                lc.setAccountId(name2ContactMap.get(ld.Name__c.toLowerCase().trim()).AccountId);
                lc.setContactId(name2ContactMap.get(ld.Name__c.toLowerCase().trim()).Id);
                lc.setDoNotCreateOpportunity(True);
                leadConvertsUpdate.add(lc);
            }else{
                ld.addError('Did not find the matching Account and Contact for the Lead.');
            }            
            
        }
        
        if(leadConvertsUpdate.size()>0){ // Account updated
            try{
                List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConvertsUpdate, false);
                for(Database.LeadConvertResult lcr: lcrList){
                    system.debug('lcr : '+lcr);
                    if(lcr.isSuccess() && lcr.getAccountId()!= null && lcr.getContactId()!= null ){
                        accIdToLeadIdMap.put(lcr.getAccountId(), lcr.getLeadId());
                    }
                }
                if(accIdToLeadIdMap.size()>0){
                    Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Email, Niche__c, Last_12_Months_Sales_LoanServicing__c, Payment_Extension__c,Your_main_benefit_of_Outsourcing__c,
                    Current_Month_Volume__c, Monthly_Volume_In_Payment_Plan__c, Amount_Of_Hours__c, Payment_Plan_Completion_Percentage__c, Program_Duration__c, Price_Point__c
                    FROM Lead WHERE Id IN: accIdToLeadIdMap.Values()]);
                    for(Id accId: accIdToLeadIdMap.keyset()){
                        Lead ld = leadMap.get(accIdToLeadIdMap.get(accId));
                        accToUpdates.add(new Account(Id = accId, Loan_Servicing_Lead_Converted__c = True,  Niche__c = ld.Niche__c, Last_12_Months_Sales_LoanServicing__c = ld.Last_12_Months_Sales_LoanServicing__c, Payment_Extension__c = ld.Payment_Extension__c, Your_main_benefit_of_Outsourcing__c = ld.Your_main_benefit_of_Outsourcing__c,
                        Current_Monthly_Volume__c = ld.Current_Month_Volume__c, Monthly_Volume_In_Payment_Plan__c = ld.Monthly_Volume_In_Payment_Plan__c, Amount_Of_Hours__c = ld.Amount_Of_Hours__c, Payment_Plan_Completion_Percentage__c = ld.Payment_Plan_Completion_Percentage__c, Program_Duration__c = ld.Program_Duration__c, Price_Point__c = ld.Price_Point__c));
                    }
                    if(accToUpdates.size()>0){
                        update accToUpdates;
                    }             
                    system.debug('accToUpdates : '+accToUpdates);
                }
            }
            catch(exception ex){servicingLeadList[0].addError(ex.getMessage());}
        }
        
    }
    
    
}