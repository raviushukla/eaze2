public class AgentDeclinedEmailHelper {
    public String LeadId;
    public Lead leads{Get;Set;}
    public String subject{get;set;}
    public String selectedvalue{get;set;}
    Public String CCEmail{get;set;}
    Public String body{get;set;}
    public String plainBody{get;set;}
    
    //Constructor
    public AgentDeclinedEmailHelper(ApexPages.StandardController stdController){
        LeadId = stdController.getId();
        system.debug('LeadId'+LeadId);
        //LeadId = ApexPages.currentPage().getParameters().get('id');
        System.debug('LeadId-- : '+LeadId);
        String leadApiNames = ApexCommonHelper.getAllField('Lead');
        String queryOnLead = 'Select '+leadApiNames+',Agent_Name__r.email,Agent_Name__r.Name,Agent_Name__r.AccountId from Lead where Id =:leadId';
        list<Lead> LeadList = database.Query(queryOnLead);
        if(LeadList != null && LeadList.size()>0){
            leads = LeadList[0];
            if(String.isNotBlank(leads.Agent_Name__c)){
                try{
                    list<Emailtemplate> agentDeclindEmailTemp = [Select Id, Name, HtmlValue,Body, Subject from EmailTemplate where 
                                                                 DeveloperName = 'Agent_Declined_Email_Template' limit 1];
                    if(agentDeclindEmailTemp != null && agentDeclindEmailTemp.size()>0){
                        subject = agentDeclindEmailTemp[0].Subject;
                        if(subject.contains('{!Lead.')){
                            String field = subject.substringBetween('{!Lead.','}');
                            String fieldValue = String.valueOf(leads.get(field));
                            subject = subject.replace('{!Lead.'+field+'}',fieldValue);
                        }
                        body = agentDeclindEmailTemp[0].HtmlValue;
                        body = body.remove('width');
                        body = body.remove(' cke_show_border');
                        body = body.remove('<![CDATA[');
                        body = body.remove(']]>');
                        body = body.remove(']]>');
                        while(body.contains('{!Lead.')){
                            String field = body.substringBetween('{!Lead.','}');
                            String fieldValue = String.valueOf(leads.get(field));
                            body = body.replace('{!Lead.'+field+'}',fieldValue);
                        }
                        plainBody = agentDeclindEmailTemp[0].Body;
                        while(plainBody.contains('{!Lead.') ){
                            String field = plainBody.substringBetween('{!Lead.','}');
                            String fieldValue = String.valueOf(leads.get(field));
                            plainBody = plainBody.replace('{!Lead.'+field+'}',fieldValue);
                        } 
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
        PageReference parentPage;
        if(String.isNotBlank(leads.Agent_Name__r.email)){
            try{
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new list<string>{leads.Agent_Name__r.email});
                if(CCemailList != null && CCemailList.size()>0){
                    mail.setCcAddresses(CCemailList);
                }
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                List<String> strEmailAndDisplayNAme = selectedvalue.split(',');
                mail.setReplyTo(strEmailAndDisplayNAme[1]);
                mail.setSaveAsActivity(true);
                mail.setSenderDisplayName(strEmailAndDisplayNAme[0]);
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
        return parentPage;
    }
    
    //Cancel Button
    public PageReference Cancel(){
        PageReference parentPage = new PageReference('/' + LeadId);
        parentPage.setRedirect(true);
        return parentPage;
    }

}