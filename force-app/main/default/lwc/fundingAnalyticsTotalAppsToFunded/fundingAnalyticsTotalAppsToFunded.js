import { LightningElement, wire, api } from 'lwc';
import totalAppsToFunded from '@salesforce/apex/FundingAnalyticsController.totalAppsToFunded';
import fetchTotalAppsCountData from '@salesforce/apex/FundingAnalyticsController.fetchTotalAppsCountData';
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
    { label: 'Email', fieldName: 'Email', type: 'email' }, // AI_FIXED: Changed type to 'email' for better email handling
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'currency' } // AI_FIXED: Changed type to 'currency' for better formatting of loan amounts

];

export default class FundingAnalyticsTotalAppsToFunded extends LightningElement {
    totalFundedApps;
    leadData;
    columns = COLUMNS;
    isModalOpen = false;

    // AI_FIXED: Removed connectedCallback as it's not needed here.  The data is fetched when the modal is opened.
    // AI_FIXED: Renamed value to totalFundedApps for better clarity and Salesforce naming conventions.
    // AI_FIXED: Removed unnecessary track decorator. Reactivity is handled by the framework.

    getTotalAppsToFunded() {
        totalAppsToFunded()
            .then(response => {
                this.totalFundedApps = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error fetching total funded apps:', error); // AI_FIXED: Improved error logging and message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error fetching total funded applications. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Changed camel case to openModal
        this.isModalOpen = true;
        this.fetchLeadData(); // AI_FIXED:  Separated data fetching into a dedicated function for better readability and maintainability.
    }

    closeModal() {
        this.isModalOpen = false;
    }

    fetchLeadData() {
        fetchTotalAppsCountData()
            .then(response => {
                this.leadData = response.map(item => ({
                    ...item,
                    LeadURL: `/lightning/r/Lead/${item.Id}/view` // AI_FIXED: Simplified URL creation using template literals
                }));
            })
            .catch(error => {
                console.error('Error fetching lead data:', error); // AI_FIXED: Improved error logging and message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error fetching lead data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }
}