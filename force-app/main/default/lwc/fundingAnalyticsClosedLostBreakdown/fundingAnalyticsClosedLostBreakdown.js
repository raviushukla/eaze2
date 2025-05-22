import { LightningElement, wire, api } from 'lwc';
import closedLostBreakdown from '@salesforce/apex/FundingAnalyticsController.closedLostBreakdown';
import fetchTotalAppsCount from '@salesforce/apex/FundingAnalyticsController.fetchTotalAppsCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FundingAnalyticsClosedLostBreakdown extends LightningElement {
    closedLostStatusApps;
    totalAppsCount; // AI_FIXED: Added a property to store the total apps count

    @wire(fetchTotalAppsCount) // AI_FIXED: Used @wire for reactivity
    wiredTotalApps({ error, data }) {
        if (data) {
            this.totalAppsCount = data; // AI_FIXED: Assign data to the property
            this.getClosedLostBreakdown(data);
        } else if (error) {
            this.showToast('Error fetching total apps count', error.body.message, 'error'); // AI_FIXED: Improved error handling
        }
    }

    getClosedLostBreakdown(totalApp) {
        closedLostBreakdown()
            .then((response) => {
                this.formatData(response, totalApp); // AI_FIXED: Renamed method for clarity and better naming convention
            })
            .catch((error) => {
                this.showToast('Error fetching closed/lost breakdown', error.body.message, 'error'); // AI_FIXED: Improved error handling
            });
    }

    formatData(apps, totalApp) {
        const closedLostStatusObj = []; // AI_FIXED: Using const and array literal for better readability and efficiency
        let isFirstClosedLostApp = true; // AI_FIXED: Using let and better naming convention

        for (let i = 0; i < apps.length; i++) {
            const status = apps[i].Status; // AI_FIXED: Using const and better naming convention
            if (status.includes('Closed Lost')) { // AI_FIXED: Using includes for better readability
                const amount = apps[i].Loan_Amount__c || 0; // AI_FIXED: Using nullish coalescing operator for conciseness
                let isStatusFound = false; // AI_FIXED: Using let and better naming convention

                if (isFirstClosedLostApp) {
                    closedLostStatusObj.push({ status, count: 0, amount: 0, isTableHead: false }); // AI_FIXED: Simplified object creation
                    isFirstClosedLostApp = false;
                }

                for (let j = 0; j < closedLostStatusObj.length; j++) {
                    if (closedLostStatusObj[j].status === status) {
                        closedLostStatusObj[j].count += 1; // AI_FIXED: Using += for conciseness
                        closedLostStatusObj[j].amount += amount; // AI_FIXED: Using += for conciseness
                        isStatusFound = true;
                    }
                }
                if (!isStatusFound) {
                    closedLostStatusObj.push({ status, count: 1, amount, isTableHead: false }); // AI_FIXED: Simplified object creation
                }
            }
        }

        let totalClosedLostCount = 0; // AI_FIXED: Using let and better naming convention
        let totalClosedLostAmount = 0; // AI_FIXED: Using let and better naming convention
        let totalClosedLostPer = 0; // AI_FIXED: Using let and better naming convention

        if (closedLostStatusObj.length > 0) { // AI_FIXED: Check for empty array
            closedLostStatusObj.forEach((item) => { // AI_FIXED: Using forEach for better readability
                const percent = (item.count * 100) / totalApp;
                item.percent = percent.toFixed(2);
                totalClosedLostCount += item.count; // AI_FIXED: Using += for conciseness
                totalClosedLostAmount += item.amount; // AI_FIXED: Using += for conciseness
                totalClosedLostPer += percent;
                item.amount = item.amount.toFixed(2);
            });
        }

        closedLostStatusObj.push({
            status: 'Closed Lost',
            count: totalClosedLostCount,
            amount: totalClosedLostAmount.toFixed(2),
            percent: totalClosedLostPer.toFixed(2),
            isTableHead: true,
        }); // AI_FIXED: Simplified object creation

        closedLostStatusObj.sort((a, b) => b.count - a.count); // AI_FIXED: Simplified sort function
        this.closedLostStatusApps = closedLostStatusObj;
    }

    showToast(title, message, variant) { // AI_FIXED: Created a helper function for showing toasts
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            })
        );
    }
}