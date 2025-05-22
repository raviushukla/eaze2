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
        List<EmailTemplate> templateList = new List<EmailTemplate>([SELECT ID, Name FROM EmailTemplate]);
        Map<String, Id> templateMap = new  Map<String, Id>();
        for(EmailTemplate et: templateList){
            templateMap.put(et.Name, et.Id);
        }
        Date todayDate, tomorrowDate, fiveDaysToEmailScheduling;
        if(Test.isRunningTest()){
            todayDate = Date.today() + 1;
            tomorrowDate = Date.today() + 2;
        }
        else{
            todayDate = Date.today();
            tomorrowDate = Date.today() + 1;
        }
        leadList = [Select Id, Email, Is_Meeting_Scheduled__c, Agent_Name__r.Id , Agent_Name__r.Email, Email_scheduling_date__c FROM Lead 
                    WHERE Is_Meeting_Scheduled__c =: false ]; 
        for(Lead l : leadList){
            fiveDaysToEmailScheduling = l.Email_scheduling_date__c.addDays(5);
            if(l.Agent_Name__c != null && l.Email_scheduling_date__c > todayDate &&  todayDate < fiveDaysToEmailScheduling ){ 
                /**********Sends Email to Agent**************/
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new list<String>{l.Agent_Name__r.Email});
                mail.setTargetObjectId(l.Agent_Name__r.Id);
                mail.setSaveAsActivity(true);
                mail.setTemplateId(templateMap.get('Lead - Meeting reminder to Agent')); 
                singleEmail.add(mail);
            }
            if(l.Email != null && l.Email_scheduling_date__c > todayDate &&  todayDate < fiveDaysToEmailScheduling ){
                /**********Sends Email to Customer**************/
                Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                mail2.setToAddresses(new list<String>{l.Email});
                mail2.setTargetObjectId(l.Id);
                mail2.setSaveAsActivity(true);
                mail2.setTemplateId(templateMap.get('Lead - Meeting reminder to Customer'));   
                singleEmail.add(mail2);
                Messaging.sendEmail(singleEmail);
            }
        }   
    }
}