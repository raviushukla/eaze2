import { LightningElement, track } from 'lwc';
import totalClientDealsFunded from '@salesforce/apex/FundingAnalyticsController.totalClientDealsFunded';
import totalClientDealsFundedData from '@salesforce/apex/FundingAnalyticsController.totalClientDealsFundedData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Name', fieldName: 'AccountURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank'
        }
    },
    { label: 'Primary Contact', fieldName: 'Primary_Contact__c', type: 'text' },
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Changed type to 'email' for better data handling
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsClientFundDeal extends LightningElement {
    value;
    accountDataFundDeal;
    columns = COLUMNS; // AI_FIXED: Corrected variable name to follow camel case convention
    @track isModalOpen = false;
    connectedCallback() {
        this.getTotalClientDealsFunded(); // AI_FIXED: Corrected method name to follow camel case convention
    }
    getTotalClientDealsFunded() { // AI_FIXED: Corrected method name to follow camel case convention
        totalClientDealsFunded().then(response => {
            this.value = response;
        }).catch(error => {
            console.error('Error retrieving total client deals funded:', error); // AI_FIXED: Improved error handling and logging
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while retrieving total client deals funded.', // AI_FIXED: Improved toast message
                    variant: 'error'
                })
            );
        });
    }

    openModal() { // AI_FIXED: Corrected method name to follow camel case convention
        this.isModalOpen = true;
        totalClientDealsFundedData().then(response => {
            this.accountDataFundDeal = response;
            if (this.accountDataFundDeal) {
                this.accountDataFundDeal.forEach(item => item['AccountURL'] = `/lightning/r/Account/${item.Id}/view`); // AI_FIXED: Improved string interpolation for AccountURL
            }
        }).catch(error => {
            console.error('Error retrieving client deal data:', error); // AI_FIXED: Improved error handling and logging
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while retrieving client deal data.', // AI_FIXED: Improved toast message
                    variant: 'error'
                })
            );
        });
    }
    closeModal() {
        this.isModalOpen = false;
    }
}