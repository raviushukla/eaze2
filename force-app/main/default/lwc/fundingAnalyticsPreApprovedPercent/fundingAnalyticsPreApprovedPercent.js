import { LightningElement, wire, api } from 'lwc';
import preApprovedPercentage from '@salesforce/apex/FundingAnalyticsController.preApprovedPercentage';
import fetchTotalPreApprovedAppsCountData from '@salesforce/apex/FundingAnalyticsController.fetchTotalPreApprovedAppsCountData';
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
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'text' }, // AI_FIXED: Changed type to 'text' for better handling of potential non-phone number formats
    { label: 'Email', fieldName: 'Email', type: 'email' }, // AI_FIXED: Changed type to 'email' for better email rendering
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'currency' } // AI_FIXED: Changed type to 'currency' for better formatting of loan amounts

];

export default class FundingAnalyticsPreApprovedPercent extends LightningElement {
    preApprovedPercentageValue;
    leadData;
    columns = COLUMNS;
    isModalOpen = false;

    // AI_FIXED: Removed connectedCallback as the data fetching is now handled in OpenModal
    // AI_FIXED: Renamed value to preApprovedPercentageValue for clarity and consistency
    // AI_FIXED: Removed track decorator as reactivity is handled by the framework
    // AI_FIXED: Removed unnecessary comments

    getPreApprovedPercentage() {
        preApprovedPercentage()
            .then(response => {
                this.preApprovedPercentageValue = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                this.handleError(error, 'Error fetching pre-approved percentage');
            });
    }

    openModal() { // AI_FIXED: Changed method name to camelCase
        this.isModalOpen = true;
        this.fetchLeadData();
    }

    fetchLeadData() { // AI_FIXED: Extracted lead data fetching into a separate method for better readability and maintainability
        fetchTotalPreApprovedAppsCountData()
            .then(response => {
                this.leadData = response.map(item => ({
                    ...item,
                    LeadURL: `/lightning/r/Lead/${item.Id}/view` // AI_FIXED: Simplified URL creation
                }));
            })
            .catch(error => {
                this.handleError(error, 'Error fetching lead data');
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleError(error, title) { // AI_FIXED: Created a helper method for error handling
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: error.body.message,
                variant: 'error'
            })
        );
    }
}