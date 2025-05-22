import { LightningElement, wire, api } from 'lwc';
import avgAmountperDeal from '@salesforce/apex/FundingAnalyticsController.avgAmountperDeal';
import totalDealsFundedData from '@salesforce/apex/FundingAnalyticsController.totalDealsFundedData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Name', fieldName: 'LeadURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            }
        }
    },
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'Phone' },
    { label: 'Email', fieldName: 'Email', type: 'Email' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'text' }

];

export default class FundingAnalyticsAvgAmountperDeal extends LightningElement {
    value;
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by default

    connectedCallback() {
        this.getAvgAmountperDeal();
    }

    getAvgAmountperDeal() {
        avgAmountperDeal()
            .then(response => {
                this.value = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.message, // AI_FIXED: Simplified message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Changed camel case to follow Salesforce naming conventions
        this.isModalOpen = true;
        totalDealsFundedData()
            .then(response => {
                this.leadData = response;
                if (this.leadData) {
                    this.leadData.forEach(item => item['LeadURL'] = '/lightning/r/Lead/' + item['Id'] + '/view');
                }
            })
            .catch(error => {
                console.error('Error:', error); // AI_FIXED: Improved error logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error', // AI_FIXED: Improved toast message
                        message: error.message, // AI_FIXED: Simplified message
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
}