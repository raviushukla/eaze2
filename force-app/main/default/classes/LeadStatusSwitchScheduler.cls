global class LeadStatusSwitchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<Lead> lead2UpdateList = new List<Lead>();
        List<String> ldStatus = New List<String>{'Terms Pitched - Email to Agent To Follow Up','Pre-Approved Pending Income Verification'};
        Date tempDate = Date.Today().addDays(-15);
        List<Lead> leadList = [Select Status, Terms_Pitched_Date__c, Pre_Approval_Date__c
                               From Lead 
                               Where Status IN: ldStatus
                               AND (Terms_Pitched_Date__c <=: tempDate OR Pre_Approval_Date__c <=: tempDate)];
        for(Lead ld: leadList){
            if(ld.Status == 'Terms Pitched - Email to Agent To Follow Up' && ld.Terms_Pitched_Date__c <= tempDate){
            	ld.Status = 'Closed Lost - Terms Pitched - Client Did Not Move Forward With Offer';
                lead2UpdateList.add(ld);
            }
            else if(ld.Status == 'Pre-Approved Pending Income Verification' && ld.Pre_Approval_Date__c <= tempDate){
                ld.Status = 'Closed Lost - Pre-Approved - Client Never Scheduled Appointment With EAZE';
                lead2UpdateList.add(ld);
            }
        }
        if(lead2UpdateList.size()>0){
        	Update lead2UpdateList;
        }
        schedulerRunNotification(lead2UpdateList);
    }
    global void schedulerRunNotification(List<Lead> lead2UpdateList){
        List<String> leadIdList = new List<String>();
        String body = 'Here are the Lead Ids those are updated during Lead Status Switch Scheduler run:<br/><br/>';
        if(lead2UpdateList.size()>0){
            for(Lead ld: lead2UpdateList){
                leadIdList.add(ld.Id);
            }
        }
        if(leadIdList.size()>0){
            body += string.join(leadIdList,',')+'<br/><br/>';
        }   
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> addresses = Label.Scheduler_Run_Notification_Addresses.split(',');
        email.setToAddresses(addresses);
        String htmlBody = 'Hello, <br/><br/>'+
            body+
            'Regards,<br/>'+
            'EAZE Consulting Team';
        email.setHtmlBody(htmlBody);
        emailList.add(email);
        try{
            Messaging.sendEmail(emailList);
        }
        catch(exception ex){
            system.debug('exception : '+ ex.getMessage());
        }
    }
}