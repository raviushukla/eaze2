import { LightningElement, api } from 'lwc';
import totalRecurringMonthsFundedDeals from '@salesforce/apex/FundingAnalyticsController.totalRecurringMonthsFundedDeals';
import totalClientDealsFundedData from '@salesforce/apex/FundingAnalyticsController.totalClientDealsFundedData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Name', fieldName: 'AccountURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        }
    },
    { label: 'Primary Contact', fieldName: 'Primary_Contact__c', type: 'text' },
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Changed type to 'email' for better data handling
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsFundedRecurringMonths extends LightningElement {
    @api value; // AI_FIXED: Changed track to api to allow parent component to set the value
    accountDataFundDeal;
    columns = COLUMNS; // AI_FIXED: Changed variable name to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by the framework

    connectedCallback() {
        this.getRecurringMonthsFunding();
    }

    getRecurringMonthsFunding() {
        totalRecurringMonthsFundedDeals()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving recurring months funded data:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to retrieve recurring months funded data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Changed method name to follow Salesforce naming conventions
        this.isModalOpen = true;
        this.loadAccountData(); // AI_FIXED: Refactored code for better readability and maintainability
    }

    closeModal() {
        this.isModalOpen = false;
    }

    loadAccountData() {
        totalClientDealsFundedData()
            .then(response => {
                this.accountDataFundDeal = response.map(item => ({
                    ...item,
                    AccountURL: `/lightning/r/Account/${item.Id}/view` // AI_FIXED: Improved URL construction
                }));
            })
            .catch(error => {
                console.error('Error retrieving account data:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to retrieve account data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }
}