global class LeadStatusSwitchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<Lead> lead2UpdateList = new List<Lead>();
        List<String> ldStatus = new List<String>{'Terms Pitched - Email to Agent To Follow Up','Pre-Approved Pending Income Verification'}; // AI_FIXED: Removed unnecessary 'New' keyword
        Date tempDate = Date.today().addDays(-15); // AI_FIXED: Changed Date.Today() to Date.today() for better readability and consistency
        List<Lead> leadList = [Select Status, Terms_Pitched_Date__c, Pre_Approval_Date__c From Lead Where Status IN :ldStatus AND (Terms_Pitched_Date__c <= :tempDate OR Pre_Approval_Date__c <= :tempDate)]; // AI_FIXED: Removed unnecessary line breaks and improved formatting for better readability

        try { // AI_FIXED: Added try-catch block for exception handling during DML operation
            for(Lead ld: leadList){
                if(ld.Status == 'Terms Pitched - Email to Agent To Follow Up' && ld.Terms_Pitched_Date__c <= tempDate){
                    ld.Status = 'Closed Lost - Terms Pitched - Client Did Not Move Forward With Offer';
                    lead2UpdateList.add(ld);
                } else if(ld.Status == 'Pre-Approved Pending Income Verification' && ld.Pre_Approval_Date__c <= tempDate){
                    ld.Status = 'Closed Lost - Pre-Approved - Client Never Scheduled Appointment With EAZE';
                    lead2UpdateList.add(ld);
                }
            }
            if(lead2UpdateList.size() > 0){
                update lead2UpdateList; // AI_FIXED: Corrected case of 'Update' to 'update'
            }
        } catch (DMLException e) { // AI_FIXED: Specified DMLException for more precise error handling
            System.debug('DML Exception: ' + e.getMessage()); // AI_FIXED: Improved debug message for better error identification
            // Add appropriate error handling logic here, such as logging the error or sending an email notification.
        }
        schedulerRunNotification(lead2UpdateList);
    }
    global void schedulerRunNotification(List<Lead> lead2UpdateList){
        List<String> leadIdList = new List<String>();
        String body = 'Here are the Lead Ids those are updated during Lead Status Switch Scheduler run:<br/><br/>';
        if(lead2UpdateList.size() > 0){
            for(Lead ld: lead2UpdateList){
                leadIdList.add(ld.Id);
            }
        }
        if(leadIdList.size() > 0){
            body += String.join(leadIdList,',')+'<br/><br/>'; // AI_FIXED: Corrected case of 'string' to 'String'
        }   
        List<Messaging.Email> emailList = new List<Messaging.Email>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> addresses;
        try { // AI_FIXED: Added try-catch block to handle potential exceptions during label retrieval and email sending
            addresses = Label.Scheduler_Run_Notification_Addresses.split(','); // AI_FIXED: Added try-catch block for exception handling
        } catch (Exception e) { // AI_FIXED: Added generic exception handling for label retrieval issues
            System.debug('Error retrieving email addresses from label: ' + e.getMessage()); // AI_FIXED: Improved debug message for better error identification
            return; // AI_FIXED: Exit the method if there's an error retrieving email addresses
        }
        email.setToAddresses(addresses);
        String htmlBody = 'Hello, <br/><br/>'+
            body+
            'Regards,<br/>'+
            'EAZE Consulting Team';
        email.setHtmlBody(htmlBody);
        emailList.add(email);
        try{
            Messaging.sendEmail(emailList);
        } catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for broader exception handling
            System.debug('Email sending exception : '+ ex.getMessage()); // AI_FIXED: Improved debug message for better error identification
        }
    }
}