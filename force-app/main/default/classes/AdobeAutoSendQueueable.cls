public without sharing class AdobeAutoSendQueueable implements Queueable, Database.AllowsCallouts {

    String templateId;
    String masterRecordId;
    
    public AdobeAutoSendQueueable (String templateId, String masterRecordId) {
       	this.templateId = templateId;
        this.masterRecordId = masterRecordId;
    }
    
    public void execute(QueueableContext context) {
        try {
            if( !Test.isRunningTest() ){
                // AI_FIXED: Added try-catch block for exception handling
                echosign_dev1.AgreementTemplateService.load(this.templateId, this.masterRecordId); 
            }    
        } catch (Exception e) {
            // AI_FIXED: Added logging for better debugging and monitoring
            System.debug('Error in AdobeAutoSendQueueable: ' + e.getMessage());
            // AI_FIXED: Consider adding more robust error handling, such as sending an email notification or updating a custom error log object.
        }
    }

}