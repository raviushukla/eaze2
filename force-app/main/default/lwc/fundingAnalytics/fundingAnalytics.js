import { LightningElement, api, wire } from 'lwc';
import getFundingData from '@salesforce/apex/FundingAnalyticsController.getFundingData'; // AI_FIXED: Imported necessary Apex method and added import statement for wire

export default class FundingAnalytics extends LightningElement {
    @api recordId; // AI_FIXED: Added @api decorator to make recordId accessible from parent component
    fundingData;
    error;

    @wire(getFundingData, { recordId: '$recordId' }) // AI_FIXED: Wired the Apex method to the component using recordId
    wiredFundingData({ error, data }) {
        if (data) {
            this.fundingData = data;
            this.error = undefined; // AI_FIXED: Cleared error message when data is available
        } else if (error) {
            this.error = error;
            this.fundingData = undefined; // AI_FIXED: Cleared fundingData when error occurs
        }
    }

    get hasData() { // AI_FIXED: Added getter to check if data is available
        return this.fundingData && this.fundingData.length > 0;
    }

    get hasError() { // AI_FIXED: Added getter to check if error occurred
        return this.error;
    }
}