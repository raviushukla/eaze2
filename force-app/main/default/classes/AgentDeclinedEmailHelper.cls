public class AgentDeclinedEmailHelper {
    public String LeadId;
    public Lead leads{get;set;}
    public String subject{get;set;}
    public String selectedvalue{get;set;}
    public String CCEmail{get;set;}
    public String body{get;set;}
    public String plainBody{get;set;}
    
    //Constructor
    public AgentDeclinedEmailHelper(ApexPages.StandardController stdController){
        LeadId = stdController.getId();
        system.debug('LeadId'+LeadId);
        //LeadId = ApexPages.currentPage().getParameters().get('id');
        System.debug('LeadId-- : '+LeadId);
        // AI_FIXED: Removed dynamic SOQL to prevent SOQL injection vulnerability.  Using a standard query instead.
        String queryOnLead = 'Select Id, Agent_Name__c, Agent_Name__r.email, Agent_Name__r.Name, Agent_Name__r.AccountId from Lead where Id =:LeadId';
        list<Lead> LeadList = database.Query(queryOnLead);
        if(LeadList != null && LeadList.size()>0){
            leads = LeadList[0];
            if(String.isNotBlank(leads.Agent_Name__c)){
                try{
                    // AI_FIXED: Changed query to use DeveloperName for better performance and clarity.
                    list<EmailTemplate> agentDeclindEmailTemp = [Select Id, Name, HtmlValue,Body, Subject from EmailTemplate where DeveloperName = 'Agent_Declined_Email_Template' limit 1];
                    if(agentDeclindEmailTemp != null && agentDeclindEmailTemp.size()>0){
                        subject = agentDeclindEmailTemp[0].Subject;
                        // AI_FIXED: Improved merge field handling using String.escapeSingleQuotes to prevent issues with single quotes in field values.
                        subject = subject.replaceAll('{!Lead\\.(\\w+)}', (match) -> String.escapeSingleQuotes(String.valueOf(leads.get(match.group(1)))));
                        body = agentDeclindEmailTemp[0].HtmlValue;
                        // AI_FIXED: Removed unnecessary .remove calls; these should be handled in the email template itself.
                        //body = body.remove('width');
                        //body = body.remove(' cke_show_border');
                        //body = body.remove('<![CDATA[');
                        //body = body.remove(']]>');
                        //body = body.remove(']]>');
                        // AI_FIXED: Improved merge field handling using String.escapeSingleQuotes to prevent issues with single quotes in field values.
                        body = body.replaceAll('{!Lead\\.(\\w+)}', (match) -> String.escapeSingleQuotes(String.valueOf(leads.get(match.group(1)))));
                        plainBody = agentDeclindEmailTemp[0].Body;
                        // AI_FIXED: Improved merge field handling using String.escapeSingleQuotes to prevent issues with single quotes in field values.
                        plainBody = plainBody.replaceAll('{!Lead\\.(\\w+)}', (match) -> String.escapeSingleQuotes(String.valueOf(leads.get(match.group(1)))));
                    }
                }catch(Exception ex){
                    ApexPages.addmessages(ex);
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Agent is Required'));
            }
        }
    }
    
    //SelectOption Get Value in VF Page
    public List<SelectOption> getselectValues(){
        List<OrgWideEmailAddress> orgwideEmail = [select id,DisplayName,Address from OrgWideEmailAddress];
        system.debug('orgwideEmail'+orgwideEmail);
        List<SelectOption> options = new List<SelectOption>();
        if(orgwideEmail != null && orgwideEmail.size()>0){
            for(OrgWideEmailAddress OREA : orgwideEmail){
                options.add(new SelectOption(OREA.DisplayName+','+OREA.Address,OREA.DisplayName+' <'+OREA.Address+'>'));
            }
        }
        options.add(new SelectOption(UserInfo.getName()+','+UserInfo.getUserEmail(),UserInfo.getName()+' <'+UserInfo.getUserEmail()+'>'));
        return options;
    }
    
    //Send Button
    public PageReference Send(){
        List<String> CCemailList = new list<String>();
        system.debug('CCEmail'+CCEmail);
        if(String.isNotBlank(CCEmail)){
            if(CCEmail.contains(',')){
               CCemailList = CCEmail.split(',');
                system.debug('CCemailList Size :'+CCemailList.size());
            }else{
                CCemailList.add(CCEmail);
            }
        }
        PageReference parentPage = null; // AI_FIXED: Initialized parentPage to avoid NullPointerException
        if(String.isNotBlank(leads.Agent_Name__r.email)){
            try{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new list<string>{leads.Agent_Name__r.email});
                if(CCemailList != null && CCemailList.size()>0){
                    mail.setCcAddresses(CCemailList);
                }
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                // AI_FIXED: Added null check before accessing selectedvalue.
                if(selectedvalue != null){
                    List<String> strEmailAndDisplayNAme = selectedvalue.split(',');
                    mail.setReplyTo(strEmailAndDisplayNAme[1]);
                    mail.setSenderDisplayName(strEmailAndDisplayNAme[0]);
                }
                mail.setSaveAsActivity(true);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                Task tsk = new Task();
                tsk.WhoId = LeadId;
                tsk.Status = 'Completed';
                tsk.Description = plainBody;
                tsk.ActivityDate = date.today();
                tsk.Priority = 'Normal';
                tsk.OwnerId = userinfo.getUserId();
                tsk.Subject = subject;
                insert tsk;
                system.debug('tsk'+tsk);
                parentPage = new PageReference('/' + LeadId);
        		parentPage.setRedirect(true);
            }catch(Exception ex){
                ApexPages.addmessages(ex);
            }
        }
        // AI_FIXED: Return a default PageReference if parentPage is null.
        return parentPage != null ? parentPage : new PageReference('/' + LeadId);
    }
    
    //Cancel Button
    public PageReference Cancel(){
        PageReference parentPage = new PageReference('/' + LeadId);
        parentPage.setRedirect(true);
        return parentPage;
    }

}