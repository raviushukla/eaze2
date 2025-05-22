public without sharing class ApplicantPortal_Offers {
    
    @AuraEnabled
    public static List<Loan_Connect_Offer__c> fetchOfferData(String recordId){
        try{
            return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c,Select_URL__c 
                from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY Amount__c ASC];
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Error fetching offer data: ' + e.getMessage());
            return new List<Loan_Connect_Offer__c>();
        }
    }
    @AuraEnabled
    public static Lead fetchLeadData(string recordId){
        try{
            return [Select Id,CreatedDate, Loan_Amount__c,Meeting_Scheduled__c,Status,name from Lead Where Id =: recordId];
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Error fetching lead data: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static List<Loan_Connect_Offer__c> orderByOfferData(String recordId, String orderBy){
        String orderByClause = 'Amount__c ASC'; // AI_FIXED: Default order by clause

        // AI_FIXED: Using a switch statement for better readability and maintainability.  Also added null checks for orderBy.
        if(orderBy != null){
            switch on orderBy {
                when 'Interest Rate' {
                    orderByClause = 'Apr_Range_Low__c ASC';
                }
                when 'Monthly Payment' {
                    orderByClause = 'Monthly_Payment_Range_Low__c ASC';
                }
            }
        }

        try{
            return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c 
                    from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY :orderByClause];   
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Error ordering offer data: ' + e.getMessage());
            return new List<Loan_Connect_Offer__c>();
        }
    }
}