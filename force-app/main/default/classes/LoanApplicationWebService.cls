@RestResource(urlMapping='/submitloanapplication/*')
global class LoanApplicationWebService {
    
    @HttpPost
    global static LoanApplicationResponceWrapper submitLoanApplication() {
        LoanApplicationResponceWrapper objWrapper = new LoanApplicationResponceWrapper();
        try{
            String body;
            RestRequest req = RestContext.request;
            body = req.requestBody.toString();
            
            Lead objlead = (Lead)JSON.deserialize(body,Lead.class);
            
            if(objlead.Years_With_Employer__c != null && objlead.Years_With_Employer__c != 'Less than 6 months' && String.isNotBlank(objlead.Years_With_Employer__c) && objlead.Loan_Amount__c >= 5000 && objlead.Monthly_Gross_Income__c >= 2500) // AI_FIXED: Added null check for Years_With_Employer__c to prevent NullPointerException
            {
                objlead.Credit_Score_Text__c = 'good';
                objlead.LeadSource = 'OTF Application';
                objlead.Is_From_Lead_Torro__c = true;
                objlead.Annual_Pre_Tax_Income__c = objlead.Monthly_Gross_Income__c * 12;
                insert objlead; // AI_FIXED: Changed Database.insert to insert for better readability and conciseness
                objWrapper.isSuccess = true; // AI_FIXED: Changed True to true for consistency
                objWrapper.isAccepted = true; // AI_FIXED: Changed True to true for consistency
                objWrapper.errorMessage = '';
                if(objlead.LeadSource == 'OTF Application'){
                	objWrapper.url = 'https://www.sbsfinancing.com/application-results/?id='+objlead.Id;
                }else if(objlead.LeadSource == 'OTF Medical Application' && objlead.Application_id__c != null){
                    objWrapper.url = 'https://www.sbsfinancing.com/application-results/?id=&aid='+objlead.Application_id__c;
                }
                PayPossibleHelper.sendLeadToPayPossibleFuture(objlead.Id);
            }else{
                objWrapper.isSuccess = true; // AI_FIXED: Changed True to true for consistency
                objWrapper.isAccepted = false;
                objWrapper.errorMessage = 'Loan application not accepted. Please check your application details.'; // AI_FIXED: Added a more informative error message
                objWrapper.url = null;
            }
        }catch(Exception e){
            objWrapper.isSuccess = false;
            objWrapper.errorMessage = 'An unexpected error occurred: ' + e.getMessage(); // AI_FIXED: Improved error message for better user experience
            objWrapper.isAccepted = false; // AI_FIXED: Changed False to false for consistency
            objWrapper.url = null;
        }
        return objWrapper;
    }
    global class LoanApplicationResponceWrapper{
        global boolean isSuccess{ get; set; }
        global String errorMessage{get;set;}
        global boolean isAccepted{get;set;}
        global String url{get;set;}
    }
}