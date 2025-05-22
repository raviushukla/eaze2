@RestResource(urlMapping='/submitloanapplication/*')
global class LoanApplicationWebService {
    
    @HttpPost
    global static LoanApplicationResponceWrapper submitLoanApplication() {
        LoanApplicationResponceWrapper objWrapper = new LoanApplicationResponceWrapper();
        try{
            String  body;
            RestRequest req = RestContext.request;
            body = req.requestBody.toString();
            
            Lead objlead = (Lead)JSON.deserialize(body,Lead.class);
            
            if(objlead.Years_With_Employer__c != 'Less than 6 months' && String.isNotBlank(objlead.Years_With_Employer__c) && objlead.Loan_Amount__c >= 5000 && objlead.Monthly_Gross_Income__c >= 2500)
            {
                objlead.Credit_Score_Text__c = 'good';
                objlead.LeadSource = 'OTF Application';
                objlead.Is_From_Lead_Torro__c = true;
                objlead.Annual_Pre_Tax_Income__c = objlead.Monthly_Gross_Income__c * 12;
                Database.insert(objlead);
                objWrapper.isSuccess = True;
                objWrapper.isAccepted = True;
                objWrapper.errorMessage = '';
                if(objlead.LeadSource == 'OTF Application'){
                	objWrapper.url = 'https://www.sbsfinancing.com/application-results/?id='+objlead.Id;
                }else if(objlead.LeadSource == 'OTF Medical Application' && objlead.Application_id__c != null){
                    objWrapper.url = 'https://www.sbsfinancing.com/application-results/?id=&aid='+objlead.Application_id__c;
                }
                PayPossibleHelper.sendLeadToPayPossibleFuture(objlead.Id);
            }else{
                objWrapper.isSuccess = True;
                objWrapper.isAccepted = false;
                objWrapper.errorMessage = '';
                objWrapper.url = null;
            }
        }catch(Exception e){
            objWrapper.isSuccess = false;
            objWrapper.errorMessage = e.getMessage();
            objWrapper.isAccepted = False;
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