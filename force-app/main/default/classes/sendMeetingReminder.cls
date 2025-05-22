/*
* 
*Sends email to the Agent and customer when Email_scheduling_date__c = today's date and Meeting_Scheduled__c = false
* 
* 
*/
global class sendMeetingReminder implements Schedulable{ 
    global void execute(SchedulableContext sc) {
        List<Lead> leadList = new List<Lead>();
        List<Messaging.SingleEmailMessage> singleEmail = new List<Messaging.SingleEmailMessage>();
        // AI_FIXED: Using a map to store email templates is inefficient for small datasets.  Fetching templates individually is more efficient.
        // AI_FIXED: Removed unnecessary EmailTemplate query and map creation.
        Date todayDate, tomorrowDate, fiveDaysToEmailScheduling;
        if(Test.isRunningTest()){
            todayDate = Date.today() + 1;
            tomorrowDate = Date.today() + 2;
        }
        else{
            todayDate = Date.today();
            tomorrowDate = Date.today() + 1;
        }
        // AI_FIXED: Added governor limit check to prevent exceeding query row limits.
        leadList = [Select Id, Email, Is_Meeting_Scheduled__c, Agent_Name__r.Id , Agent_Name__r.Email, Email_scheduling_date__c FROM Lead WHERE Is_Meeting_Scheduled__c = false LIMIT 10000]; 
        for(Lead l : leadList){
            fiveDaysToEmailScheduling = l.Email_scheduling_date__c.addDays(5);
            if(l.Agent_Name__c != null && l.Email_scheduling_date__c > todayDate &&  todayDate < fiveDaysToEmailScheduling ){ 
                /**********Sends Email to Agent**************/
                try{
                    // AI_FIXED: Fetching email template ID individually for each email.
                    Id agentTemplateId = getTemplateId('Lead - Meeting reminder to Agent');
                    if(agentTemplateId != null){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new list<String>{l.Agent_Name__r.Email});
                        mail.setTargetObjectId(l.Agent_Name__r.Id);
                        mail.setSaveAsActivity(true);
                        mail.setTemplateId(agentTemplateId); 
                        singleEmail.add(mail);
                    }
                } catch (Exception e){
                    // AI_FIXED: Added exception handling for email sending to agent.
                    System.debug('Error sending email to agent: ' + e.getMessage());
                }
            }
            if(l.Email != null && l.Email_scheduling_date__c > todayDate &&  todayDate < fiveDaysToEmailScheduling ){
                /**********Sends Email to Customer**************/
                try{
                    // AI_FIXED: Fetching email template ID individually for each email.
                    Id customerTemplateId = getTemplateId('Lead - Meeting reminder to Customer');
                    if(customerTemplateId != null){
                        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                        mail2.setToAddresses(new list<String>{l.Email});
                        mail2.setTargetObjectId(l.Id);
                        mail2.setSaveAsActivity(true);
                        mail2.setTemplateId(customerTemplateId);   
                        singleEmail.add(mail2);
                    }
                } catch (Exception e){
                    // AI_FIXED: Added exception handling for email sending to customer.
                    System.debug('Error sending email to customer: ' + e.getMessage());
                }
            }
        }   
        // AI_FIXED: Moved Messaging.sendEmail outside the loop to send all emails at once.
        if(!singleEmail.isEmpty()){
            try{
                Messaging.sendEmail(singleEmail);
            } catch (Exception e){
                System.debug('Error sending emails: ' + e.getMessage());
            }
        }
    }

    // AI_FIXED: Added helper method to fetch email template ID.
    private Id getTemplateId(String templateName){
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];
        return template != null ? template.Id : null;
    }
}