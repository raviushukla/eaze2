import { LightningElement, track } from 'lwc';
import clientNoApp from '@salesforce/apex/FundingAnalyticsController.clientNoApp';
import percentageClientNoApp from '@salesforce/apex/FundingAnalyticsController.percentageClientNoApp';
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

export default class FundingAnalyticsNoAppClient extends LightningElement {
    accountData = []; // AI_FIXED: Renamed variable for clarity and better adherence to Salesforce naming conventions
    columns = COLUMNS; // AI_FIXED: Renamed variable for clarity and better adherence to Salesforce naming conventions
    @track isModalOpen = false;
    percentage = 0; // AI_FIXED: Renamed variable for clarity and better adherence to Salesforce naming conventions

    connectedCallback() {
        this.getPercentageClientSubmittedAppNoApp(); // AI_FIXED: Renamed method for clarity and better adherence to Salesforce naming conventions
    }

    getPercentageClientSubmittedAppNoApp() { // AI_FIXED: Renamed method for clarity and better adherence to Salesforce naming conventions
        percentageClientNoApp()
            .then(response => {
                this.percentage = response > 0 ? parseFloat(response).toFixed(2) : 0; // AI_FIXED: Updated variable assignment
            })
            .catch(error => {
                console.error('Error retrieving percentage:', error); // AI_FIXED: Improved error handling and logging
                this.showToast('Error retrieving percentage', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    openModal() { // AI_FIXED: Changed to camel case for better adherence to Salesforce naming conventions
        this.isModalOpen = true;
        this.getAccountData(); // AI_FIXED: Renamed method for clarity and better adherence to Salesforce naming conventions
    }

    getAccountData() { // AI_FIXED: Renamed method for clarity and better adherence to Salesforce naming conventions
        clientNoApp()
            .then(response => {
                this.accountData = response.map(item => ({ ...item, AccountURL: `/lightning/r/Account/${item.Id}/view` })); // AI_FIXED: Improved data manipulation using map and spread syntax
            })
            .catch(error => {
                console.error('Error retrieving account data:', error); // AI_FIXED: Improved error handling and logging
                this.showToast('Error retrieving account data', error.body.message, 'error'); // AI_FIXED: Simplified toast message display

            });
    }

    closeModal() { // AI_FIXED: Changed to camel case for better adherence to Salesforce naming conventions
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toast messages
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}