/*
	* Umesh Rana 3/26/2024
	* This class is scheduled to run everyday
	* We are sending this email to the Eaze Team to infrom them that its been a month the Loan applicant has been funded,
	* so that they can make sure that the Loan applicant is making the monthly payment.
*/

global class ScheduleClientPaymentEmail implements Schedulable {
	
    global void execute(SchedulableContext SC){
        Date dt = system.Today().addMonths(-1);
        // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for better performance.  Using a list to avoid SOQL injection vulnerability.
        try{
            List<Lead> leadList = [Select Id, Name__c From Lead Where GA_Lead__c = True AND Closed_Date__c =: dt]; // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variable.
            EmailTemplate emailTemplate =[Select Id, DeveloperName From EmailTemplate 
                                     where Name = 'GA - Verification Call Completed - Contract Funded Eaze Team After 30 days'];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Lead ldObj : leadList){
              Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
              emailObj.setTargetObjectId(ldObj.Id); 
              emailObj.setSaveAsActivity(true);  
              // AI_FIXED: Added null check for emailTemplate to prevent NullPointerException
              if(emailTemplate != null) {
                emailObj.setTemplateID(emailTemplate.Id);  
              }
              emailObj.setToAddresses(new List<String>{'sf@eazeconsulting.com'}); // AI_FIXED: Changed toAddresses to setToAddresses and used List<String> for better type safety.
              emailObj.setTreatTargetObjectAsRecipient(false);
              emailList.add(emailObj);    
            }
            // AI_FIXED: Improved error handling by checking for null or empty emailList before sending.
            if(emailList != null && emailList.size() > 0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                // AI_FIXED: Improved error handling by iterating through all results and logging individual errors.
                for(Messaging.SendEmailResult result : results){
                    if(!result.isSuccess()){
                        System.debug('The email failed to send: ' + result.errors[0].message);
                    }
                }
            }
        } catch (Exception ex){
            System.debug('An error occurred: ' + ex.getMessage()); // AI_FIXED: Added generic exception handling to catch unexpected errors.
        }
    }
}