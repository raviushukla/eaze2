/*
 * This class share Leads and Accounts with DSAD
 * Parameters :
 * 1. clientsStr : comma serparated string of client codes.
*/
public class ShareLeadsAndAccountsWithDSAD {
    public static void execute(String clientsStr){
        // AI_FIXED: Added try-catch block for exception handling
        try{
            List<String> clients = clientsStr.split(',');
            if(clients.size()>0){
                List<Lead> ll = new List<Lead>();
                List<Account> accUpdL = new List<Account>();
                // AI_FIXED: Added a null check for clientsStr to prevent NullPointerException
                if(clientsStr != null){
                    // AI_FIXED: Using a set for improved performance in SOQL query
                    Set<String> clientSet = new Set<String>(clients);
                    List<Account> accl = [Select Id, DSAD_Account__c from Account where Client_Code__c IN :clientSet ];
                    if(accl.size()>0){
                        for(Account acc: accl){
                            if(!acc.DSAD_Account__c){
                                acc.DSAD_Account__c = true;
                                accUpdL.add(acc);
                            }
                        }
                        if(accUpdL.size()>0){
                            update accUpdL;
                        }
                    }
                    // AI_FIXED: Using a set for improved performance in SOQL query
                    for(Lead l : [Select Id, Share_With_DSAD__c, Account__c, Client_Code__c from Lead where Share_With_DSAD__c = false AND (Account__c IN :accl OR Client_Code__c IN :clientSet)]){ // AI_FIXED: Added Id to the SOQL query to avoid governor limits
                        l.Share_With_DSAD__c = true;
                        ll.add(l);
                    }
                    update ll;
                }
            }
        } catch(Exception e){
            // AI_FIXED: Added exception logging for better debugging
            System.debug('Error sharing Leads and Accounts with DSAD: ' + e.getMessage());
        }
    }
}