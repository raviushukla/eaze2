import { LightningElement, track } from 'lwc';
import clientNoApp270 from '@salesforce/apex/FundingAnalyticsController.clientNoApp270';
import percentageClientNoApp270 from '@salesforce/apex/FundingAnalyticsController.percentageClientNoApp270';
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

export default class FundingAnalyticsNoAppClient270 extends LightningElement {
    value;
    accountDataSubNoApp;
    listColumns = COLUMNS; // AI_FIXED: Corrected casing to match naming conventions
    @track isModalOpen = false;

    connectedCallback() {
        this.handleGetClientSubmittedAppNoPercentage(); // AI_FIXED: Renamed method for clarity and better naming convention
    }

    handleGetClientSubmittedAppNoPercentage() { // AI_FIXED: Renamed method for clarity and better naming convention
        percentageClientNoApp270()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.body ? error.body.message : error.message, // AI_FIXED: Improved error handling for toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Corrected casing to match naming conventions
        this.isModalOpen = true;
        this.handleGetAccountData(); // AI_FIXED: Renamed method for clarity and better naming convention
    }

    handleGetAccountData() { // AI_FIXED: Renamed method for clarity and better naming convention
        clientNoApp270()
            .then(response => {
                this.accountDataSubNoApp = response;
                if (this.accountDataSubNoApp) {
                    this.accountDataSubNoApp.forEach(item => item.AccountURL = `/lightning/r/Account/${item.Id}/view`); // AI_FIXED: Improved template literal for URL creation
                }
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.body ? error.body.message : error.message, // AI_FIXED: Improved error handling for toast message
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() { // AI_FIXED: Corrected casing to match naming conventions
        this.isModalOpen = false;
    }
}