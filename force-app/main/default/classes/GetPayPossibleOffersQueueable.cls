public class GetPayPossibleOffersQueueable implements Queueable, Database.AllowsCallouts   {
    
    public String ld; 
    public DateTime startTime;
    public GetPayPossibleOffersQueueable (String ld, DateTime startTime) {
        this.ld = ld;
        this.startTime = startTime;
    }
    
    public void execute( QueueableContext context ) {
    	PayPossibleHelper.leadGetfromPayPossibleFuture( this.ld, this.startTime);   
    }
    
}