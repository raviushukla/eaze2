public class GetOfferFromPayPossible {
	@AuraEnabled
    public static string offerFromPayPossible(String leadId){
        String result = '';
        try{
            PayPossibleWebServiceClass.getOfferFromPayPossible(leadId);
            result = 'Success';
        }
        catch(Exception ex){
            return ex.getMessage();
        }
        return result;
    }
}