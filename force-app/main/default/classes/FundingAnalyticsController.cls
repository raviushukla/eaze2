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
        if(fetchTotalAppsCount() == 0){
        return 0;
        }
        else{
        return (fetchTotalPreApprovAppsCount()/fetchTotalAppsCount())*100;
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
        if(fetchTotalPreApprovAppsCount() == 0){
        return 0;
        }
        else{
       return (totalDealsFunded()/fetchTotalPreApprovAppsCount())*100;
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
        if(fetchTotalAppsCount()==0){
            return 0;
        }
        else{
        return (totalDealsFunded()/fetchTotalAppsCount())*100;
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
        return (Decimal)groupedResults[0].get('expr0');
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
        Decimal count = (Decimal)groupedResults[0].get('expr0');
        Decimal amount = (Decimal)groupedResults[0].get('expr1');
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
        System.debug(groupedResults[0].get('expr0'));
        Decimal closedLoastAmount = (Decimal)groupedResults[0].get('expr0');

        List<String> preApprovedStatus = Label.Funding_Analytics_Pre_Approved_Status.split(',');
        AggregateResult[] groupedResults2 = [SELECT SUM(Loan_Amount__c) FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: preApprovedStatus AND Loan_Amount__c != null];
        System.debug(groupedResults2[0].get('expr0'));
        Decimal PreApprovAmount = (Decimal)groupedResults2[0].get('expr0');
        if(closedLoastAmount == null || PreApprovAmount == null)
            return 0;
        else
            return closedLoastAmount/PreApprovAmount;
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
        if(fetchTotalClients()==0){
        return 0;
        }else{
        return (fetchClientsSubmiitedApp()/fetchTotalClients())*100;
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
        if(fetchTotalClients()==0){
            return 0;
        }
        else{
        return (totalClientDealsFunded()/fetchTotalClients())*100;
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
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c,ID FROM Account Where CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth];
    }
/**************************************************************************************************
 * Method Name: fetchClientsSubmiitedAppData
 * Author: Vivek Raturi
 * Date: 16-12-2021
 * Description: Fetching Data of Clients with atleast one related Lead in current month.
 **************************************************************************************************/
    @AuraEnabled
    public static List<Account> fetchClientsSubmiitedAppData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Id IN (Select Account__c From Lead Where CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Account__c != null)];
    }
/**************************************************************************************************
 * Method Name: totalClientDealsFundedData
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: Fetching data of clients with at least one related lead whose status is fundedDeals of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static List<Account> totalClientDealsFundedData(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
      List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Id IN (SELECT Account__c FROM Lead WHERE Status IN: fundedDeals and CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Account__c != null)];  
    }
/**************************************************************************************************
 * Method Name: clientNoApp
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: fetching data of clients which have no Leads at all.
 **************************************************************************************************/
    @AuraEnabled
    public static List<Account> clientNoApp(){
        Date Today_date = Date.today();
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Id Not IN (Select Account__c From Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Account__c != null)];    
    }
/**************************************************************************************************
 * Method Name: percentageClientNoApp
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: Calulating Percentage of clients which have no Leads at all.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal percentageClientNoApp(){
        if(fetchTotalClients() == 0){
            return 0;
        }
        else{
        return (clientNoApp().size()/fetchTotalClients())*100;
        }
    }
/**************************************************************************************************
 * Method Name: clientNoApp90
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: fetching data of clients which have no Leads in past 90 days.
 **************************************************************************************************/
    @AuraEnabled
    public static List<Account> clientNoApp90(){
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate = LAST_90_DAYS and Id Not IN (Select Account__c From Lead Where CreatedDate = LAST_90_DAYS and Account__c != null)];   
    }
    /**************************************************************************************************
 * Method Name: fetchTotalClients90
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: fetching total Number of clients of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalClients90(){
        return [SELECT COUNT() FROM Account  WHERE CreatedDate = LAST_90_DAYS];
    }
/**************************************************************************************************
 * Method Name: percentageClientNoApp90
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: Calulating Percentage of clients which have no Leads in past 90 days.
 **************************************************************************************************/
     @AuraEnabled
    public static Decimal percentageClientNoApp90(){
        if(fetchTotalClients() == 0){
            return 0;
        }
        else{
        return (clientNoApp90().size()/fetchTotalClients90())*100;
        }
    }
    
/**************************************************************************************************
 * Method Name: clientNoApp180
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: fetching data of clients which have no Leads in past 180 days.
 **************************************************************************************************/
     @AuraEnabled
    public static List<Account> clientNoApp180(){
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate = LAST_N_DAYS:180 and Id Not IN (Select Account__c From Lead Where CreatedDate = LAST_N_DAYS:180 and Account__c != null)];   
    }
       /**************************************************************************************************
 * Method Name: fetchTotalClients180
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: fetching total Number of clients of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalClients180(){
        return [SELECT COUNT() FROM Account  WHERE CreatedDate = LAST_N_DAYS:180];
    }
/**************************************************************************************************
 * Method Name: percentageClientNoApp180
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: Calulating Percentage of clients which have no Leads in past 180 days.
 **************************************************************************************************/
     @AuraEnabled
    public static Decimal percentageClientNoApp180(){
        if(fetchTotalClients() == 0){
            return 0;
        }
        else{
        return (clientNoApp180().size()/fetchTotalClients180())*100;
        }
    }
/**************************************************************************************************
 * Method Name: clientNoApp270
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: fetching data of clients which have no Leads in past 365 days.
 **************************************************************************************************/
     @AuraEnabled
    public static List<Account> clientNoApp270(){
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate = LAST_N_DAYS:270 and Id Not IN (Select Account__c From Lead WHERE CreatedDate = LAST_N_DAYS:270 and Account__c != null)];   
    }
       /**************************************************************************************************
 * Method Name: fetchTotalClients270
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: fetching total Number of clients of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalClients270(){
        return [SELECT COUNT() FROM Account  WHERE CreatedDate = LAST_N_DAYS:270];
    }
/**************************************************************************************************
 * Method Name: percentageClientNoApp270
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: Calulating Percentage of clients which have no Leads in past 270 days.
 **************************************************************************************************/
     @AuraEnabled
    public static Decimal percentageClientNoApp270(){
        if(fetchTotalClients() == 0){
            return 0;
        }
        else{
        return (clientNoApp270().size()/fetchTotalClients270())*100;
        }
    }
/**************************************************************************************************
 * Method Name: clientNoApp365
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: fetching Data of clients which have no Leads in past 365 days.
 **************************************************************************************************/
     @AuraEnabled
    public static List<Account> clientNoApp365(){
        return [SELECT Name,Primary_Contact__c,Primary_Contact_Email__c,Primary_Contact_Name__c FROM Account WHERE CreatedDate = LAST_N_DAYS:365 and Id Not IN (Select Account__c From Lead WHERE CreatedDate = LAST_N_DAYS:365 and Account__c != null)];   
    }
          /**************************************************************************************************
 * Method Name: fetchTotalClients365
 * Author: Vivek Raturi
 * Date: 15-12-2021
 * Description: fetching total Number of clients of current month.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal fetchTotalClients365(){
        return [SELECT COUNT() FROM Account  WHERE CreatedDate = LAST_N_DAYS:365];
    }
/**************************************************************************************************
 * Method Name: percentageClientNoApp365
 * Author: Vivek Raturi
 * Date: 17-12-2021
 * Description: Calulating Percentage of clients which have no Leads in past 365 days.
 **************************************************************************************************/
     @AuraEnabled
    public static Decimal percentageClientNoApp365(){
        if(fetchTotalClients() == 0){
            return 0;
        }
        else{
        return (clientNoApp365().size()/fetchTotalClients365())*100;
        }
    }

/**************************************************************************************************
 * Method Name: totalRecurringMonthsFundedDeals
 * Author: Pranav Yadav
 * Date: 04-07-2022
 * Description: Calulating Number of clients which have funded in recurring months.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalRecurringMonthsFundedDeals(){
        Date Today_date = Date.today().addMonths(-1);
        Date firstDateOfMonth = Today_date.toStartOfMonth();
        Date lastDateOfMonth = firstDateOfMonth.addMonths(1).addDays(-1);
        List<String> fundedDeals = Label.Funding_Analytics_Funded_Status.split(',');
        return [SELECT COUNT() FROM Account WHERE Id IN (SELECT Account__c FROM Lead WHERE CreatedDate>=:firstDateOfMonth and CreatedDate<=:lastDateOfMonth and Status IN: fundedDeals)];  
    }
/**************************************************************************************************
 * Method Name: percentageRecurringMonthsFundedDeals
 * Author: Pranav Yadav
 * Date: 04-07-2022
 * Description: Calulating Percantage of clients which have funded in recurring months.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal percentageRecurringMonthsFundedDeals(){
        if(fetchTotalClients()==0){
            return 0;
        }
        else{
        return (totalRecurringMonthsFundedDeals()/fetchTotalClients())*100;
        }
    }
/**************************************************************************************************
 * Method Name: totalNonConsecutiveFundedDeals
 * Author: Pranav Yadav
 * Date: 04-07-2022
 * Description: Calulating Number of clients which have funded in non consecutive months.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal totalNonConsecutiveFundedDeals(){
        return 0;    
    }
/**************************************************************************************************
 * Method Name: percentageNonConsecutiveFundedDeals
 * Author: Pranav Yadav
 * Date: 04-07-2022
 * Description: Calulating Percentage of clients which have funded in non consecutive months.
 **************************************************************************************************/
    @AuraEnabled
    public static Decimal percentageNonConsecutiveFundedDeals(){
        if(fetchTotalClients()==0){
            return 0;
        }
        else{
        return (totalRecurringMonthsFundedDeals()/fetchTotalClients())*100;
        }
    }
}