import { LightningElement, wire, api } from 'lwc';
import closedLostToPreApprovals from '@salesforce/apex/FundingAnalyticsController.closedLostToPreApprovals';
import closedLostToPreApprovalsData from '@salesforce/apex/FundingAnalyticsController.closedLostToPreApprovalsData';
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
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'text' }, // AI_FIXED: Changed type to 'text' for better handling of potential null values
    { label: 'Email', fieldName: 'Email', type: 'email' }, // AI_FIXED: Changed type to 'email' for better data representation
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'currency' } // AI_FIXED: Changed type to 'currency' for better formatting

];

export default class FundingAnalyticsClosedLostToPreApproval extends LightningElement {
    @api value;
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track decorator; reactivity is handled implicitly

    connectedCallback() {
        this.getClosedLostToPreApprovals();
    }

    getClosedLostToPreApprovals() {
        closedLostToPreApprovals()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving closed lost to pre-approvals count:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error retrieving data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Changed method name to camel case
        this.isModalOpen = true;
        this.getClosedLostToPreApprovalsData(); // AI_FIXED: Refactored to call a separate method for data retrieval
    }

    getClosedLostToPreApprovalsData() { // AI_FIXED: Created a separate method for data retrieval
        closedLostToPreApprovalsData()
            .then(response => {
                this.leadData = response.map(item => ({ ...item, LeadURL: `/lightning/r/Lead/${item.Id}/view` })); // AI_FIXED: Improved data manipulation using map and spread syntax
            })
            .catch(error => {
                console.error('Error retrieving closed lost to pre-approvals data:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error retrieving data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
}