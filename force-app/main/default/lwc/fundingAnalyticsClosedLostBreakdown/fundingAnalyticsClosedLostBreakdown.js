import { LightningElement, wire, api } from 'lwc';
import closedLostBreakdown from'@salesforce/apex/FundingAnalyticsController.closedLostBreakdown';
import fetchTotalAppsCount from'@salesforce/apex/FundingAnalyticsController.fetchTotalAppsCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FundingAnalyticsClosedLostBreakdown extends LightningElement {
    closedLostStatusApps;
    connectedCallback() {
        this.getTotalAppsCount();
    }
    getTotalAppsCount(){
        fetchTotalAppsCount().then(response => {
            this.getClosedLostBreakdown(response);
        }).catch(error => {
            console.log('Error: ' +error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    getClosedLostBreakdown(totalApp){
        closedLostBreakdown().then(response => {
            this.formate(response, totalApp);
        }).catch(error => {
            console.log('Error: ' +error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    formate(apps, totalApp){
        var closedLostStatusObj = [{'status':'','count':0, 'amount':0, 'isTableHead':false}];
        var isFirstclosedLostApp = true;
        for(var i=0; i<apps.length; i++){
            var status = apps[i].Status;
            if(status.indexOf('Closed Lost') != -1){
                var amount = (apps[i].Loan_Amount__c ? apps[i].Loan_Amount__c : 0);
                var isStatusFound = false;
                if(isFirstclosedLostApp){
                    closedLostStatusObj[0].status = status
                    closedLostStatusObj[0].count = 0;
                    closedLostStatusObj[0].amount = 0;
                    closedLostStatusObj[0].isTableHead = false;
                    isFirstclosedLostApp = false;
                }
                for(var j=0; j<closedLostStatusObj.length; j++){
                    if(closedLostStatusObj[j].status == status){
                        closedLostStatusObj[j].count = closedLostStatusObj[j].count + 1;
                        closedLostStatusObj[j].amount = closedLostStatusObj[j].amount + amount;
                        closedLostStatusObj[j].isTableHead = false;
                        isStatusFound = true;
                    }
                }
                if(!isStatusFound){
                    closedLostStatusObj.push({'status':status,'count':1, 'amount':amount, 'isTableHead':false});
                }
            }
        }
        var totalClosedLostCount = 0;
        var totalClosedLostAmount = 0
        var totalClosedLostPer = 0;
        if(closedLostStatusObj[0].count != 0){
            for(var i=0; i<closedLostStatusObj.length; i++){
                var percent = (closedLostStatusObj[i].count*100)/totalApp;
                closedLostStatusObj[i].percent = percent.toFixed(2);
                totalClosedLostCount = totalClosedLostCount + closedLostStatusObj[i].count;
                totalClosedLostAmount = totalClosedLostAmount + closedLostStatusObj[i].amount;
                totalClosedLostPer = totalClosedLostPer + percent;
                closedLostStatusObj[i].amount = closedLostStatusObj[i].amount.toFixed(2);
            }
        }
        else{
            closedLostStatusObj = [];
        }
        closedLostStatusObj.push({'status':'Closed Lost','count':totalClosedLostCount, 'amount':totalClosedLostAmount.toFixed(2), 'percent':totalClosedLostPer.toFixed(2), 'isTableHead':true});
        closedLostStatusObj.sort(function(a, b) {
            return b.count - a.count;
        });
        console.log('closedLostStatusObj : ',closedLostStatusObj);
        this.closedLostStatusApps = closedLostStatusObj;
    }
}