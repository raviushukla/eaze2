public class SendToPayPossibleHelper {
    
    @InvocableMethod(label='Send To Pay Possible')
    public static void sendLeadToPayPossible( list<id> leads ){
        system.debug('leadsProcessMethod '+leads);
        PayPossibleHelper.sendLeadToPayPossibleFuture(leads[0]);
    }
    
}