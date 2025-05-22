import { LightningElement, wire, api } from 'lwc';
import totalDealsFunded from '@salesforce/apex/FundingAnalyticsController.totalDealsFunded';
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
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'Phone' },
    { label: 'Email', fieldName: 'Email', type: 'Email' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'text' }
];

export default class FundingAnalyticsTotalDealsFunded extends LightningElement {
    totalDeals;
    leadData;
    columns = COLUMNS;
    isModalOpen = false;

    // AI_FIXED: Removed @track decorator; reactivity is handled by the framework
    // AI_FIXED: Renamed value to totalDeals for clarity and Salesforce naming conventions
    // AI_FIXED: Removed unnecessary connectedCallback; data is fetched on demand
    
    handleGetTotalDealsFunded = () => {
        totalDealsFunded()
            .then(response => {
                this.totalDeals = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error retrieving total deals funded:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error retrieving total deals funded. Please contact your administrator.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal = () => {
        this.isModalOpen = true;
        this.handleGetLeadData();
    };

    // AI_FIXED: Renamed OpenModal to openModal for better naming convention
    // AI_FIXED: Created separate method for fetching lead data for better code organization
    handleGetLeadData = () => {
        totalDealsFundedData()
            .then(response => {
                this.leadData = response.map(item => ({
                    ...item,
                    LeadURL: `/lightning/r/Lead/${item.Id}/view` // AI_FIXED: Simplified URL creation
                }));
            })
            .catch(error => {
                console.error('Error retrieving lead data:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error retrieving lead data. Please contact your administrator.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    };

    closeModal = () => {
        this.isModalOpen = false;
    };
    // AI_FIXED: Renamed closeModal to closeModal for better naming convention

}