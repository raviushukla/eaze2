/* ****************************************************************************************************
* Created date: Apr 16, 2019
* Auther: Jai Singh
* Des: This is web Service for fetching Lead and Offers.
* ---------------------------------
* Change 1;
* Date: Apr 16, 2019
* Auther: SNEH VERMA
* Des: Change wrapper PayPossibleOffersWrapper class to PayPossibleLeadWrapper class.
* ---------------------------------
* Change 2;
* Date: Apr 17, 2019
* Auther: SNEH VERMA
* Des: return another wrapper class which contains PayPossibleLeadWrapper, min Amount and Max Amount.
* *****************************************************************************************************/
//Web Service class getLead Id ANd returns the offers.
@RestResource(urlMapping='/fetchLeadOffers/*')
global class LeadOffersWebService {
    
    @HttpGet
    global static LeadOffersResponseWrapper getLeadOffers(){
        
        LeadOffersResponseWrapper lorw = new LeadOffersResponseWrapper();
        try{
            //get request context values 
            RestRequest req = RestContext.request;
            //RestResponse res = RestContext.response; // AI_FIXED: Removed unused variable
            String leadId = req.params.get('id'); // AI_FIXED: Using req directly for better readability
            String applicationId = req.params.get('aid'); // AI_FIXED: Using req directly for better readability

            // AI_FIXED: Added null checks for leadId and applicationId
            if (String.isBlank(leadId) && String.isBlank(applicationId)) {
                lorw.isSuccess = false;
                lorw.errorMessage = 'Both Lead ID and Application ID cannot be blank.';
                return lorw;
            }

            system.debug('LeadId'+leadId);
            //query lead and offers
            // AI_FIXED: Removed unnecessary API name fetching, assuming fields are consistent.  Adjust as needed.
            String queryOnLead = 'Select Id, FirstName, LastName, Pay_Possible_Status__c, Loan_Amount__c, Offers__r.Amount__c, Offers__r.Apply_url__c from Lead where Id =:leadId OR (Application_Id__c =: applicationId)'; // AI_FIXED: Optimized SOQL query to select only necessary fields.  Added error handling for blank IDs.
            list<Lead> LeadList = database.Query(queryOnLead);
            system.debug('LeadList'+LeadList.size()+' '+LeadList);
            if( !LeadList.isEmpty() ){
                Lead ld = LeadList[0];
                system.debug('lead='+ld);
            
                //Wrapper Class..
                PayPossibleLeadWrapper PPOferWrap = new PayPossibleLeadWrapper();
                list<PayPossibleLeadWrapper.offers> PPListOffers = new list<PayPossibleLeadWrapper.offers>();
                decimal minAmt = null; // AI_FIXED: Initialized to null to handle cases with no offers
                decimal maxAmt = null; // AI_FIXED: Initialized to null to handle cases with no offers
                PPOferWrap.status = ld.Pay_Possible_Status__c;
                
                PayPossibleLeadWrapper.personal per = new PayPossibleLeadWrapper.personal(); 
                per.first_name = ld.FirstName;
                per.last_name = ld.LastName;
                PPOferWrap.personal = per;
                
                if(String.isNotBlank(PPOferWrap.status) && PPOferWrap.status.equalsIgnoreCase('approved') && ld.Offers__r != null && ld.Offers__r.size() > 0){
                    for(Offer__c offr : ld.Offers__r){
                        decimal amt = offr.Amount__c;
                        if (minAmt == null || amt < minAmt){ // AI_FIXED: Improved min/max logic for null handling
                            minAmt = amt;
                        }
                        if (maxAmt == null || amt > maxAmt){ // AI_FIXED: Improved min/max logic for null handling
                            maxAmt = amt;
                        }
                        PayPossibleLeadWrapper.offers PPListOffr = new PayPossibleLeadWrapper.offers(); // AI_FIXED: Created offer object inside loop
                        PPListOffr.amount = String.valueOf(offr.Amount__c);
                        PPListOffr.apply_url = offr.Apply_url__c;
                        PPListOffers.add(PPListOffr);
                    }
                    PPOferWrap.offers = PPListOffers; // AI_FIXED: Set offers after the loop
                    system.debug('PPListOffers'+PPListOffers);
                } 
                lorw.pplWrap = PPOferWrap;
                lorw.minAmount = minAmt;
                lorw.maxAmount = maxAmt;
                lorw.isSuccess = true;
            }else{
                lorw.isSuccess = false;
                lorw.errorMessage = 'Your information not found with provided SFID ' + (leadId != null ? leadId : applicationId); // AI_FIXED: Improved error message
            }
        }catch(Exception ex ){
            lorw.pplWrap = null;
            lorw.minAmount = null;
            lorw.maxAmount = null;
            lorw.isSuccess = false;
            lorw.errorMessage = 'An unexpected error occurred: ' + ex.getMessage(); // AI_FIXED: Improved error message
        }
        return lorw;
    }
}