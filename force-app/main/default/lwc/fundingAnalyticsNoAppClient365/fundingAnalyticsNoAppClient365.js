import { LightningElement, track } from 'lwc';
import clientNoApp365 from '@salesforce/apex/FundingAnalyticsController.clientNoApp365';
import percentageClientNoApp365 from '@salesforce/apex/FundingAnalyticsController.percentageClientNoApp365';
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
export default class FundingAnalyticsNoAppClient365 extends LightningElement {
    value;
    accountDataSubNoApp;
    listColumns = COLUMNS; // AI_FIXED: Corrected variable name to follow camel case convention
    @track isModalOpen = false;
    connectedCallback() {
        this.getClientSubmittedAppNoPercentage();
    }
    getClientSubmittedAppNoPercentage() {
        percentageClientNoApp365()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.body ? error.body.message : error.message, // AI_FIXED: Handle different error structures
                        variant: 'error'
                    })
                );
            });
    }
    openModal() { // AI_FIXED: Corrected method name to follow camel case convention
        this.isModalOpen = true;
        clientNoApp365()
            .then(response => {
                this.accountDataSubNoApp = response;
                if (this.accountDataSubNoApp) {
                    this.accountDataSubNoApp.forEach(item => item['AccountURL'] = '/lightning/r/Account/' + item['Id'] + '/view');
                }
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.body ? error.body.message : error.message, // AI_FIXED: Handle different error structures
                        variant: 'error'
                    })
                );
            });
    }
    closeModal() {
        this.isModalOpen = false;
    }
}