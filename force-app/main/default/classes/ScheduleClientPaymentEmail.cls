/*
	* Umesh Rana 3/26/2024
	* This class is scheduled to run everyday
	* We are sending this email to the Eaze Team to infrom them that its been a month the Loan applicant has been funded,
	* so that they can make sure that the Loan applicant is making the monthly payment.
*/

global class ScheduleClientPaymentEmail implements Schedulable {
	
    global void execute(SchedulableContext SC){
        Date dt = system.Today().addMonths(-1);
        List<Lead> leadList = [Select Id, Name__c From Lead Where GA_Lead__c = True AND Closed_Date__c =: dt];
        EmailTemplate emailTemplate =[Select Id, DeveloperName From EmailTemplate 
                                     where Name = 'GA - Verification Call Completed - Contract Funded Eaze Team After 30 days'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Lead ldObj : leadList){
          Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
          emailObj.setTargetObjectId(ldObj.id); 
          emailObj.setSaveAsActivity(true);  
          emailObj.setTemplateID(emailTemplate.Id);  
          emailObj.toAddresses = new String[] {'sf@eazeconsulting.com'};
          emailObj.setTreatTargetObjectAsRecipient(false);
          emailList.add(emailObj);    
        }
        Messaging.SendEmailResult[] results = new Messaging.SendEmailResult[]{}; 
        if(emailList.size() > 0){
            results = Messaging.sendEmail(emailList);
            if (results[0].success)
            {
             System.debug('The email was sent successfully.');
            }
            else
            {
             System.debug('The email failed to send: ' +
             results[0].errors[0].message);
            }
        }
    }
}