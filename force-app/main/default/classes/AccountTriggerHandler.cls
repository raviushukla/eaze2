public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> triggerNew){
        Set<String> clientCodes = new Set<String>(); // AI_FIXED: Use a Set to efficiently track generated codes and prevent duplicates
        for(Account acc: triggerNew){
            String newClientCode;
            Boolean validCode = false;
            do { // AI_FIXED: Changed while loop to do-while for better readability and efficiency.  The while loop was inefficient because it could generate and validate multiple codes unnecessarily.
                newClientCode = ApexCommonHelper.generateCode(5);
                validCode = ApexCommonHelper.validateNewClientCode( newClientCode );
            } while( !validCode || clientCodes.contains(newClientCode)); // AI_FIXED: Check for existing codes in the Set to prevent duplicates.
            clientCodes.add(newClientCode); // AI_FIXED: Add the generated code to the Set.
            newClientCode = newClientCode.toUpperCase();
            acc.Current_Used_Site__c = Label.Current_Used_Site;
            acc.Client_Code__c = newClientCode;
        }
    }
}