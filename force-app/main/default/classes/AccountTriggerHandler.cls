public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> triggerNew){
        for(Account acc: triggerNew){
            String newClientCode;
            Boolean validCode = false;
            while( !validCode ){
                newClientCode = ApexCommonHelper.generateCode(5);
                validCode = ApexCommonHelper.validateNewClientCode( newClientCode );
            }
            newClientCode = newClientCode.toUpperCase();
            acc.Current_Used_Site__c = Label.Current_Used_Site;
            acc.Client_Code__c = newClientCode;
        }
    }
}