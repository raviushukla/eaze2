/*
 * This class share Leads and Accounts with DSAD
 * Parameters :
 * 1. clientsStr : comma serparated string of client codes.
*/
public class ShareLeadsAndAccountsWithDSAD {
    public static void execute(String clientsStr){
        List<String> clients = clientsStr.split(',');
        if(clients.size()>0){
            List<Lead> ll = new List<Lead>();
            List<Account> accUpdL = new List<Account>();
            List<Account> accl = [Select Id, DSAD_Account__c from Account where Client_Code__c IN :clients ];
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
            for(Lead l : [Select Share_With_DSAD__c from Lead where Share_With_DSAD__c = false AND (Account__c IN: accl OR Client_Code__c IN: clients)]){
                l.Share_With_DSAD__c = true;
                ll.add(l);
            }
            update ll;
        }
    }
}