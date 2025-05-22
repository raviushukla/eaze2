import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class FundingAnalyticsTab2 extends LightningElement {
    @api recordId; // AI_FIXED: Added @api annotation to make recordId accessible from parent component

    // AI_FIXED: Added wired method to fetch record data
    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] }) // AI_FIXED: Added fields parameter to specify the fields to retrieve
    account;

    get accountName() { // AI_FIXED: Created a getter to access the account name safely
        return this.account.data?.Name; // AI_FIXED: Added optional chaining and nullish coalescing to handle potential errors
    }

    connectedCallback() { // AI_FIXED: Added error handling in connectedCallback
        if (!this.recordId) {
            console.error('Error: recordId is not defined.'); // AI_FIXED: Added error logging
            // AI_FIXED: Add appropriate error handling logic here, e.g., display an error message to the user.
        }
    }

    // AI_FIXED: Added a method to handle potential errors during data retrieval
    handleError(error) {
        console.error('Error retrieving data:', error); // AI_FIXED: Added error logging
        // AI_FIXED: Add appropriate error handling logic here, e.g., display an error message to the user.
    }
}