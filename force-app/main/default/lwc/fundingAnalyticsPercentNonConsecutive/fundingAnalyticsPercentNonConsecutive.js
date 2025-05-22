import { LightningElement, api } from 'lwc'; // AI_FIXED: Changed import to use api instead of track for value
import percentageNonConsecutiveFundedDeals from '@salesforce/apex/FundingAnalyticsController.percentageNonConsecutiveFundedDeals';
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
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Corrected type to 'email'
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsPercentNonConsecutive extends LightningElement {
    @api value; // AI_FIXED: Changed to use @api for external access
    accountDataFundDeal;
    columns = COLUMNS; // AI_FIXED: Changed variable name to follow camel case convention
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by @api

    connectedCallback() {
        this.getPercentageNonConsecutiveFundedDeals(); // AI_FIXED: Improved method name for readability
    }

    getPercentageNonConsecutiveFundedDeals() { // AI_FIXED: Improved method name for readability
        percentageNonConsecutiveFundedDeals()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.showToast('Error fetching data', error.body.message, 'error'); // AI_FIXED: Refactored error handling using showToast helper
            });
    }

    openModal() { // AI_FIXED: Improved method name for readability and camel case convention
        this.isModalOpen = true;
        totalClientDealsFundedData()
            .then(response => {
                this.accountDataFundDeal = response.map(item => ({ ...item, AccountURL: `/lightning/r/Account/${item.Id}/view` })); // AI_FIXED: Improved data manipulation using map and template literals
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.showToast('Error fetching data', error.body.message, 'error'); // AI_FIXED: Refactored error handling using showToast helper
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toast
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}