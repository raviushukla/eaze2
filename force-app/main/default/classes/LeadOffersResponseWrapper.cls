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
    public Decimal minAmount{get;set;} // AI_FIXED: Changed data type to Decimal for consistency and clarity.
    public Decimal maxAmount{get;set;} // AI_FIXED: Changed data type to Decimal for consistency and clarity.
    public Boolean isSuccess{get;set;} // AI_FIXED: Changed data type to Boolean for consistency and clarity.
    public String errorMessage{get;set;}
    
}