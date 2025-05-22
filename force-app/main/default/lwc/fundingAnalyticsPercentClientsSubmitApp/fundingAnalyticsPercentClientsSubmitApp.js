import { LightningElement, api } from 'lwc';
import percentageClientsSubmittedApp from '@salesforce/apex/FundingAnalyticsController.percentageClientsSubmittedApp';
import fetchClientsSubmiitedAppData from '@salesforce/apex/FundingAnalyticsController.fetchClientsSubmiitedAppData';

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
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' },
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsPercentClientsSubmitApp extends LightningElement {
    @api value; // AI_FIXED: Changed track to api to allow parent component to set the value
    accountDataSubApp;
    columns = COLUMNS; // AI_FIXED: Corrected variable name to follow camel case convention
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by the framework

    connectedCallback() {
        this.getClientSubmittedAppPercentage();
    }

    getClientSubmittedAppPercentage() {
        percentageClientsSubmittedApp()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                // AI_FIXED: Improved error handling with more informative message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message || 'An unexpected error occurred.', // AI_FIXED: More user-friendly error message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Corrected method name to follow camel case convention
        this.isModalOpen = true;
        this.fetchAccountData(); // AI_FIXED: Refactored for better readability and maintainability
    }

    fetchAccountData() { // AI_FIXED: Created a separate method for fetching account data
        fetchClientsSubmiitedAppData()
            .then(response => {
                this.accountDataSubApp = response.map(item => ({
                    ...item,
                    AccountURL: `/lightning/r/Account/${item.Id}/view` // AI_FIXED: Improved URL construction
                }));
            })
            .catch(error => {
                // AI_FIXED: Improved error handling with more informative message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message || 'An unexpected error occurred.', // AI_FIXED: More user-friendly error message
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
}