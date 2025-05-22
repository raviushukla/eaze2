/* ***************************************************************************
 * Created date: Apr 17, 2019
 * Auther: SNEH VERMA
 * Des: This Class binds up PayPossibleLeadWrapper class with min. Amount and max. Amount.
 * ---------------------------------
 * Change 1;
 * Date: 
 * Auther: 
 * Des: 
 * ***************************************************************************/
global class LeadOffersResponseWrapper {
    
    public PayPossibleLeadWrapper pplWrap{get;set;}
    public decimal minAmount{get;set;}
    public decimal maxAmount{get;set;}
    public boolean isSuccess{get;set;}
    public String errorMessage{get;set;}
    
}