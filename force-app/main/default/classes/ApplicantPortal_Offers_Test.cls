@isTest
public class ApplicantPortal_Offers_Test {
    public static testMethod void method(){
        
        Lead leadObj = new Lead();
        leadObj.FirstName = 'Test';
        leadObj.LastName = 'lead'; 
        leadObj.Loan_Amount__c =  200000;  
        leadObj.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        insert leadObj;
        
        Loan_Connect_Offer__c offerObj = new Loan_Connect_Offer__c();
        offerObj.Name = 'Test Offer';
        offerObj.Lead__c = leadObj.Id;
        
        ApplicantPortal_Offers.fetchLeadData(string.valueOf(leadObj.Id));
        ApplicantPortal_Offers.fetchOfferData(string.valueOf(leadObj.Id));
        ApplicantPortal_Offers.orderByOfferData(string.valueOf(leadObj.Id), 'Interest Rate');
        ApplicantPortal_Offers.orderByOfferData(string.valueOf(leadObj.Id), 'Monthly Payment');
        ApplicantPortal_Offers.orderByOfferData(string.valueOf(leadObj.Id), '');
        
    }
}