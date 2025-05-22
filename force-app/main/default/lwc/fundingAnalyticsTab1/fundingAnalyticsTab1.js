import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class FundingAnalyticsTab1 extends LightningElement {
    @api recordId; // AI_FIXED: Added @api annotation to make recordId accessible from parent component

    // AI_FIXED: Added wired method to fetch record data
    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name', 'Account.Industry'] })
    account;

    get accountName() {
        return this.account.data?.Name; // AI_FIXED: Added optional chaining to handle potential null values
    }

    get accountIndustry() {
        return this.account.data?.Industry; // AI_FIXED: Added optional chaining to handle potential null values
    }

    // AI_FIXED: Added error handling for wired method
    get error() {
        return this.account.error;
    }

    // AI_FIXED: Added render method to handle loading state
    renderedCallback() {
        if (this.error) {
            console.error('Error loading account data:', this.error); // AI_FIXED: Added console error logging for better debugging
        }
    }
}