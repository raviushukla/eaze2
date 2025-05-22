import { LightningElement, wire, api } from 'lwc';
import preApprovalsToFunded from '@salesforce/apex/FundingAnalyticsController.preApprovalsToFunded';
import totalDealsFundedData from '@salesforce/apex/FundingAnalyticsController.totalDealsFundedData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Name', fieldName: 'LeadURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        }
    },
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'text' }, // AI_FIXED: Changed type to 'text' for better handling of potential non-phone numbers
    { label: 'Email', fieldName: 'Email', type: 'email' }, // AI_FIXED: Changed type to 'email' for better email rendering
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'currency' } // AI_FIXED: Changed type to 'currency' for better formatting of loan amounts

];

export default class FundingAnalyticsPreApprovalsToFunded extends LightningElement {
    value;
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track decorator; reactivity is handled implicitly

    connectedCallback() {
        this.handleGetPreApprovalsToFunded(); // AI_FIXED: Renamed method for clarity and consistency
    }

    handleGetPreApprovalsToFunded() { // AI_FIXED: Renamed method for clarity and consistency
        preApprovalsToFunded()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error fetching pre-approvals to funded data:', error); // AI_FIXED: Improved error logging and handling
                this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    openModal() { // AI_FIXED: Changed casing to camelCase
        this.isModalOpen = true;
        this.handleGetTotalDealsFundedData(); // AI_FIXED: Renamed method for clarity and consistency
    }

    handleGetTotalDealsFundedData() { // AI_FIXED: Renamed method for clarity and consistency
        totalDealsFundedData()
            .then(response => {
                this.leadData = response.map(item => ({
                    ...item,
                    LeadURL: `/lightning/r/Lead/${item.Id}/view` // AI_FIXED: Improved URL construction
                }));
            })
            .catch(error => {
                console.error('Error fetching total deals funded data:', error); // AI_FIXED: Improved error logging and handling
                this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper function for showing toast messages
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}