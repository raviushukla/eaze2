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
            RestResponse res = RestContext.response;
            String leadId = RestContext.request.params.get('id');
            String applicationId = RestContext.request.params.get('aid');
            
            system.debug('LeadId'+leadId);
            //query lead and offers
            String offerApiNames = ApexCommonHelper.getAllField('Offer__c');
            String leadApiNames = ApexCommonHelper.getAllField('Lead');
            String queryOnLead = 'Select '+leadApiNames+', (SELECT '+offerApiNames+' FROM Offers__r) from Lead where (Id =:leadId OR (Application_Id__c != null AND Application_Id__c != \'\' AND Application_Id__c =: applicationId) )';
            list<Lead> LeadList = database.Query(queryOnLead);
            system.debug('LeadList'+LeadList.size()+' '+LeadList);
            if( !LeadList.isEmpty() ){
            	Lead ld = LeadList[0];
            	system.debug('lead='+ld);
            
                //Wrapper Class..
                PayPossibleLeadWrapper PPOferWrap = new PayPossibleLeadWrapper();
                list<PayPossibleLeadWrapper.offers> PPListOffers = new list<PayPossibleLeadWrapper.offers>();
                decimal minAmt = 0;
                decimal maxAmt = 0;
                //PPOferWrap.id = ld.Pay_Possible_lead_ID__c;
                PPOferWrap.status = ld.Pay_Possible_Status__c;
                //PPOferWrap.credit_score = ld.Credit_Score_Text__c;
                //PPOferWrap.amount = integer.valueOf(ld.Loan_Amount__c);
                
                PayPossibleLeadWrapper.personal per = new PayPossibleLeadWrapper.personal(); 
                per.first_name = ld.FirstName;
                per.last_name = ld.lastName;
                //per.dob = Date.valueOf(ld.Date_of_Birth__c);
                //per.ssn = ld.Social_Security_Number__c;
                //per.email = ld.Email;
                //per.phone = ld.MobilePhone;
                PPOferWrap.personal = per;
                
                /*PayPossibleLeadWrapper.income incom = new PayPossibleLeadWrapper.income();
                incom.annual_income = ld.Annual_Pre_Tax_Income__c;
                incom.payroll_frequency = ld.Payroll_Frequency__c;
                incom.payroll_type = ld.Payroll_Type__c;
                PPOferWrap.income = incom;
                */
                /*PayPossibleLeadWrapper.employment emp = new PayPossibleLeadWrapper.employment();
                emp.status = ld.Income_Source_1__c;
                emp.job_title = ld.Position__c;
                emp.hire_date = String.valueOf(ld.Hire_Date__c);
                emp.employer_name = ld.Current_Employer__c;
                PPOferWrap.employment = emp;
                */
                /*PayPossibleLeadWrapper.address add = new PayPossibleLeadWrapper.address();
                add.address_length = Integer.valueof(ld.Year_at_Address__c);
                add.city = ld.City;
                add.state = ld.State;
                add.status = ld.Status;
                add.street1 = ld.Street;
                add.zip = ld.PostalCode;
                PPOferWrap.address = add;
                */
                if( String.isNotBlank( PPOferWrap.status ) && PPOferWrap.status.equalsIgnoreCase('approved') && ld.Offers__r != null && ld.Offers__r.size() > 0){
                    for(Offer__c offr : ld.Offers__r){
                        //PayPossibleLeadWrapper.offers PPListOffr = new PayPossibleLeadWrapper.offers();
                        //PPListOffr.id = offr.Offre_Id__c;
                        //PPListOffr.amount = String.valueof(offr.Amount__c);
                        //PPListOffr.apply_url = offr.Apply_url__c;
                        //PPListOffr.apr = String.valueof(offr.apr__c);
                        //PPListOffr.date_created = offr.Date_Created__c;
                        //PPListOffr.date_updated = offr.Date_Updated__c;
                        //PPListOffr.monthly_payment = String.valueof(offr.Monthly_Payment__c);
                        //PPListOffr.term = offr.Term__c;
                        //PPListOffr.terms = offr.Terms__c;
                        
                        /*PayPossibleLeadWrapper.originator org = new PayPossibleLeadWrapper.originator();
                        org.description = offr.Description__c;
                        org.disclaimer = offr.Disclaimer__c;
                        org.email = offr.Image__c;
                        org.name = offr.Name;
                        org.phone = offr.Phone__c;
                        org.website = offr.Website__c;
                        PPListOffr.originator = org;
                        */
                        //PPListOffers.add(PPListOffr);
                        //PPOferWrap.offers = PPListOffers;
                        
                        decimal amt = offr.Amount__c;
                        if( minAmt == 0 ){
                            minAmt = amt;
                        }
                        if(amt < minAmt)
                        {
                            minAmt = amt;
                        }
                        if(amt > maxAmt)
                        {
                            maxAmt = amt;
                        }
                    }
                    system.debug('PPListOffers'+PPListOffers);
                } 
                lorw.pplWrap = PPOferWrap;
                lorw.minAmount = minAmt;
                lorw.maxAmount = maxAmt;
                lorw.isSuccess = true;
            }else{
                //lorw.pplWrap = PPOferWrap;
                //lorw.minAmount = minAmt;
                //lorw.maxAmount = maxAmt;
                lorw.isSuccess = false;
                lorw.errorMessage = '"Your information not found with provided SFID '+leadId+'"';
            }
        }catch(Exception ex ){
            lorw.pplWrap = null;
            lorw.minAmount = null;
            lorw.maxAmount = null;
            lorw.isSuccess = false;
            lorw.errorMessage = ex.getMessage();
        }
        return lorw;
    }
}