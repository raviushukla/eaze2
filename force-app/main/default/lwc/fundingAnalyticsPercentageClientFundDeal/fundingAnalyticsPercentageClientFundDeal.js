import { LightningElement, track } from 'lwc';
import percentageClientsDealsFunded from '@salesforce/apex/FundingAnalyticsController.percentageClientsDealsFunded';
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

export default class FundingAnalyticsPercentageClientFundDeal extends LightningElement {
    percentage; // AI_FIXED: Renamed 'value' to 'percentage' for clarity
    accountDataFundDeal;
    columns = COLUMNS; // AI_FIXED: Renamed 'Listcolumns' to 'columns' to follow naming conventions
    @track isModalOpen = false;

    connectedCallback() {
        this.getPercentageClientFundDeal(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getPercentageClientFundDeal() { // AI_FIXED: Renamed method for clarity and consistency
        percentageClientsDealsFunded()
            .then(response => {
                this.percentage = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving percentage:', error); // AI_FIXED: Improved error handling and logging
                this.showToast('Error retrieving percentage', error.body.message, 'error'); // AI_FIXED: Using helper method for toast
            });
    }

    openModal() { // AI_FIXED: Changed to camelCase
        this.isModalOpen = true;
        totalClientDealsFundedData()
            .then(response => {
                this.accountDataFundDeal = response.map(item => ({ ...item, AccountURL: `/lightning/r/Account/${item.Id}/view` })); // AI_FIXED: Improved data manipulation using map and template literals
            })
            .catch(error => {
                console.error('Error retrieving account data:', error); // AI_FIXED: Improved error handling and logging
                this.showToast('Error retrieving account data', error.body.message, 'error'); // AI_FIXED: Using helper method for toast
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toast
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}