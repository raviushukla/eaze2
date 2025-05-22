public without sharing class ApplicantPortal_Offers {
    
    @AuraEnabled
    public static List<Loan_Connect_Offer__c> fetchOfferData(String recordId){
        return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c,Select_URL__c 
                from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY Amount__c ASC];
    }
    @AuraEnabled
    public static Lead fetchLeadData(string recordId){
        return [Select Id,CreatedDate, Loan_Amount__c,Meeting_Scheduled__c,Status,name from Lead Where Id =: recordId];
    }
    @AuraEnabled
    public static List<Loan_Connect_Offer__c> orderByOfferData(String recordId, String orderBy){
        if(orderBy == 'Interest Rate'){
            return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c 
                    from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY Apr_Range_Low__c ASC];   
        }else if (orderBy == 'Monthly Payment'){
            return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c 
                    from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY Monthly_Payment_Range_Low__c ASC]; 
        }else{
            return [Select Amount__c, Term__c, Lender_Name__c, Monthly_Payment_Range_High__c, Monthly_Payment_Range_Low__c,Lender_Logo__c,Term_years__c,Apr_Range_Low__c 
                from Loan_Connect_Offer__c Where Lead__c =: recordId ORDER BY Amount__c ASC]; //Lead__r.Loan_Amount__c 
        }
    }
}