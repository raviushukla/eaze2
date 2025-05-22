import { LightningElement, track } from 'lwc';
import clientNoApp90 from '@salesforce/apex/FundingAnalyticsController.clientNoApp90';
import percentageClientNoApp90 from '@salesforce/apex/FundingAnalyticsController.percentageClientNoApp90';
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
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Changed 'Email' to 'email' for consistency
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsNoAppClient90 extends LightningElement {
    value;
    accountDataSubNoApp90;
    listColumns = COLUMNS; // AI_FIXED: Corrected variable name to follow camel case convention
    @track isModalOpen = false;

    connectedCallback() {
        this.getPercentageClientNoApp90(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getPercentageClientNoApp90() { // AI_FIXED: Renamed method for clarity and consistency
        percentageClientNoApp90()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving percentage:', error); // AI_FIXED: Improved error logging
                this.showToast('Error retrieving percentage', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    openModal() { // AI_FIXED: Corrected method name to follow camel case convention
        this.isModalOpen = true;
        this.getClientNoApp90(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getClientNoApp90() { // AI_FIXED: Created separate method for data retrieval
        clientNoApp90()
            .then(response => {
                this.accountDataSubNoApp90 = response.map(item => ({ // AI_FIXED: Use map for immutability
                    ...item,
                    AccountURL: `/lightning/r/Account/${item.Id}/view` // AI_FIXED: Simplified URL creation
                }));
            })
            .catch(error => {
                console.error('Error retrieving client data:', error); // AI_FIXED: Improved error logging
                this.showToast('Error retrieving client data', error.body.message, 'error'); // AI_FIXED: Simplified toast message display

            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for toast messages
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}