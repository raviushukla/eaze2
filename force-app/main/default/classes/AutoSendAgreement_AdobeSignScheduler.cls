global class AutoSendAgreement_AdobeSignScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        list<Lead> paidLeads = [ Select Id, Status from Lead where Status = 'Setup Fee Paid To EAZE' AND Lead_Source__c LIKE 'Funding Partner%' ];
        for(Lead l : paidLeads  ){
            l.Status = 'Approved - New Eaze Partner';
        }
        update paidLeads;
        
   	}
}