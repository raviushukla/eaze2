import { LightningElement, track } from 'lwc';
import clientNoApp180 from '@salesforce/apex/FundingAnalyticsController.clientNoApp180';
import percentageClientNoApp180 from '@salesforce/apex/FundingAnalyticsController.percentageClientNoApp180';
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

export default class FundingAnalyticsNoAppClient180 extends LightningElement {
    accountDataSubNoApp;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    @track isModalOpen = false;
    percentage; // AI_FIXED: Added a variable to store the percentage

    connectedCallback() {
        this.getPercentageClientNoApp(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getPercentageClientNoApp() {
        percentageClientNoApp180()
            .then(response => {
                this.percentage = response > 0 ? parseFloat(response).toFixed(2) : 0; // AI_FIXED: Store the percentage in a dedicated variable
            })
            .catch(error => {
                console.error('Error retrieving percentage:', error); // AI_FIXED: Improved error logging
                this.showToast('Error retrieving percentage', error.body.message, 'error'); // AI_FIXED: Use helper method for toast
            });
    }

    openModal() { // AI_FIXED: Changed method name to camel case
        this.isModalOpen = true;
        this.getClientNoApp(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getClientNoApp() {
        clientNoApp180()
            .then(response => {
                this.accountDataSubNoApp = response.map(item => ({
                    ...item,
                    AccountURL: `/lightning/r/Account/${item.Id}/view` // AI_FIXED: Simplified URL creation
                }));
            })
            .catch(error => {
                console.error('Error retrieving account data:', error); // AI_FIXED: Improved error logging
                this.showToast('Error retrieving account data', error.body.message, 'error'); // AI_FIXED: Use helper method for toast
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toasts
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}