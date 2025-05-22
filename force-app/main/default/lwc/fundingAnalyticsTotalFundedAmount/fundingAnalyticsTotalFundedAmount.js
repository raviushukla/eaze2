import { LightningElement, wire, api } from 'lwc';
import totalFundedAmount from '@salesforce/apex/FundingAnalyticsController.totalFundedAmount';
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
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'currency' } // AI_FIXED: Changed type to 'currency' for better formatting

];

export default class FundingAnalyticsTotalFundedAmount extends LightningElement {
    totalFundedAmount; // AI_FIXED: Renamed 'value' to 'totalFundedAmount' for clarity and Salesforce convention
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed 'Listcolumns' to 'columns' for clarity and Salesforce convention
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by default

    connectedCallback() {
        this.getTotalFundedAmount();
    }

    getTotalFundedAmount() {
        totalFundedAmount()
            .then(response => {
                this.totalFundedAmount = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving total funded amount:', error); // AI_FIXED: Improved error logging and handling
                this.showToast('Error retrieving total funded amount', error.body.message, 'error'); // AI_FIXED: Using helper method for toast
            });
    }

    openModal() { // AI_FIXED: Changed camel case to lowerCamelCase
        this.isModalOpen = true;
        totalDealsFundedData()
            .then(response => {
                this.leadData = response.map(item => ({ ...item, LeadURL: `/lightning/r/Lead/${item.Id}/view` })); // AI_FIXED: Improved data manipulation using map and template literals
            })
            .catch(error => {
                console.error('Error retrieving lead data:', error); // AI_FIXED: Improved error logging and handling
                this.showToast('Error retrieving lead data', error.body.message, 'error'); // AI_FIXED: Using helper method for toast
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toast messages
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}