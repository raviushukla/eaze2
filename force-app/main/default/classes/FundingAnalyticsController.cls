/**************************************************************************************************
 * Class Name: FundingAnalyticsController
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
public class FundingAnalyticsController {
/**************************************************************************************************
 * Method Name: fetchTotalAppsCount
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalAppsCount(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT COUNT() FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth];
    }
/**************************************************************************************************
 * Method Name: fetchTotalAppsCountData
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static List<Lead> fetchTotalAppsCountData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,MobilePhone,Email,Status,Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth];
    }
/**************************************************************************************************
 * Method Name: fetchTotalPreApprovAppsCount
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalPreApprovAppsCount(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> preApprovedStatus = Label.Funding_Analytics_Pre_Approved_Status.split(',');
        return [SELECT COUNT() FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: preApprovedStatus];
    }
/**************************************************************************************************
 * Method Name: fetchTotalPreApprovAppsCountData
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static List<Lead> fetchTotalPreApprovAppsCountData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> preApprovedStatus = Label.Funding_Analytics_Pre_Approved_Status.split(',');
        return [SELECT Name,MobilePhone,Email,Status,Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: preApprovedStatus];
    }
/**************************************************************************************************
 * Method Name: fetchTotalDeclinedAppsCount
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalDeclinedAppsCount(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT COUNT() FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status LIKE '%declined%'];
    }
/**************************************************************************************************
 * Method Name: fetchTotalDeclinedAppsCountData
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static List<Lead> fetchTotalDeclinedAppsCountData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,MobilePhone,Email,Status,Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status LIKE '%declined%'];
    }
/**************************************************************************************************
 * Method Name: preApprovedPercentage
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal preApprovedPercentage(){
        Decimal totalApps = fetchTotalAppsCount();
        // AI_FIXED: Added null check to handle potential division by zero
        if(totalApps == 0){
            return 0;
        }
        else{
            return (fetchTotalPreApprovAppsCount()/totalApps)*100;
        }
    }
/**************************************************************************************************
 * Method Name: totalDealsFunded
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalDealsFunded(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        return [SELECT COUNT() FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals];
    }
/**************************************************************************************************
 * Method Name: totalDealsFundedData
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static List<Lead> totalDealsFundedData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        return [SELECT Name,MobilePhone,Email,Status,Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals];
    }
/**************************************************************************************************
 * Method Name: preApprovalsToFunded
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal preApprovalsToFunded(){
        Decimal totalPreApprovals = fetchTotalPreApprovAppsCount();
        // AI_FIXED: Added null check to handle potential division by zero
        if(totalPreApprovals == 0){
            return 0;
        }
        else{
           return (totalDealsFunded()/totalPreApprovals)*100;
        }
        
    }
/**************************************************************************************************
 * Method Name: totalAppsToFunded
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalAppsToFunded(){
        Decimal totalApps = fetchTotalAppsCount();
        // AI_FIXED: Added null check to handle potential division by zero
        if(totalApps == 0){
            return 0;
        }
        else{
        return (totalDealsFunded()/totalApps)*100;
        }
    }
/**************************************************************************************************
 * Method Name: totalFundedAmount
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalFundedAmount(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        AggregateResult[] groupedResults = [SELECT SUM(Loan_Amount__c) FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals AND Loan_Amount__c != null];
        // AI_FIXED: Added null check to handle potential NullPointerException
        return (Decimal)(groupedResults.size() > 0 ? groupedResults[0].get('expr0') : 0);
    }
/**************************************************************************************************
 * Method Name: avgAmountperDeal
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal avgAmountperDeal(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        AggregateResult[] groupedResults = [SELECT COUNT(Loan_Amount__c), SUM(Loan_Amount__c) FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals AND Loan_Amount__c != null];
        Decimal count = (Decimal)(groupedResults.size() > 0 ? groupedResults[0].get('expr0') : 0);
        Decimal amount = (Decimal)(groupedResults.size() > 0 ? groupedResults[0].get('expr1') : 0);
        // AI_FIXED: Added null check to handle potential division by zero
        if(count==0 || amount ==0 ){
            return 0;
        }else{
        return amount/count;
        }
    }
/**************************************************************************************************
 * Method Name: closedLostToPreApprovals
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal closedLostToPreApprovals(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        AggregateResult[] groupedResults = [SELECT SUM(Loan_Amount__c) FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status LIKE '%Closed Lost%' AND Loan_Amount__c != null];
        Decimal closedLoastAmount = (Decimal)(groupedResults.size() > 0 ? groupedResults[0].get('expr0') : 0);

        List<String> preApprovedStatus = Label.Funding_Analytics_Pre_Approved_Status.split(',');
        AggregateResult[] groupedResults2 = [SELECT SUM(Loan_Amount__c) FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: preApprovedStatus AND Loan_Amount__c != null];
        Decimal PreApprovAmount = (Decimal)(groupedResults2.size() > 0 ? groupedResults2[0].get('expr0') : 0);
        // AI_FIXED: Added null check to handle potential division by zero
        if(PreApprovAmount == 0){
            return 0;
        } else {
            return closedLoastAmount/PreApprovAmount;
        }
    }
/**************************************************************************************************
 * Method Name: closedLostToPreApprovalsData
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static List<Lead> closedLostToPreApprovalsData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,MobilePhone,Email,Status,Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status LIKE '%Closed Lost' AND Loan_Amount__c != null];
    }
/**************************************************************************************************
 * Method Name: closedLostBreakdown
 * Author: 
 * Date: 
 * Description: 
 **************************************************************************************************/
    @AuraEnabled
    public static Object closedLostBreakdown(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<Lead> leadList = [SELECT Status, Loan_Amount__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status LIKE '%Closed Lost%'];
        return leadList;
    }
/**************************************************************************************************
 * Method Name: fetchTotalClients
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: fetching total Number of clients of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalClients(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT COUNT() FROM Account  WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth];
    }
/**************************************************************************************************
 * Method Name: fetchClientsSubmiitedApp
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: Fetching Number of Clients with atleast one related Lead in current month. 
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchClientsSubmiitedApp(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT COUNT() FROM Account WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Id IN (Select Account__c From Lead Where CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Account__c != null)];
    }
/**************************************************************************************************
 * Method Name: percentageClientsSubmittedApp
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: Calculating percentage of Number of Clients with atleast one related Lead in current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal percentageClientsSubmittedApp(){
        Decimal totalClients = fetchTotalClients();
        // AI_FIXED: Added null check to handle potential division by zero
        if(totalClients == 0){
            return 0;
        }else{
        return (fetchClientsSubmiitedApp()/totalClients)*100;
        }
    }
/**************************************************************************************************
 * Method Name: totalClientDealsFunded
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: Fetching total Number of clients with at least one related lead whose status is fundedDeals in current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalClientDealsFunded(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        return [SELECT COUNT() FROM Account WHERE Id IN (SELECT Account__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals)];  
    }
/**************************************************************************************************
 * Method Name: percentageClientsDealsFunded
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: Calculating Percentage of total Number of clients with at least one related lead whose status is fundedDeals in current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal percentageClientsDealsFunded(){
        Decimal totalClients = fetchTotalClients();
        // AI_FIXED: Added null check to handle potential division by zero
        if(totalClients == 0){
            return 0;
        }
        else{
        return (totalClientDealsFunded()/totalClients)*100;
        }
    }
/**************************************************************************************************
 * Method Name: fetchTotalClientsData
 * Author: Vivek Raturi
 * Date: 16-12-2021
 * Description: fetching Clients Data of current month.
 **************************************************************************************************/ 
    @AuraEnabled
    public static List<Account> fetchTotalClientsData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c,ID FROM Account Where CreatedDate>=:firstDateOfMonth