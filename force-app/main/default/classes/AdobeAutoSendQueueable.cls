public without sharing class AdobeAutoSendQueueable implements Queueable, Database.AllowsCallouts {

    String templateId;
    String masterRecordId;
    
    public AdobeAutoSendQueueable (String templateId, String masterRecordId) {
       	this.templateId = templateId;
        this.masterRecordId = masterRecordId;
    }
    
    public void execute(QueueableContext context) {
        if( !Test.isRunningTest() ){
            echosign_dev1.AgreementTemplateService.load(this.templateId, this.masterRecordId);
        }    
    }

}