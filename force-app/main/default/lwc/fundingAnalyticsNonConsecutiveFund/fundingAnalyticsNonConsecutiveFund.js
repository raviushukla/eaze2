import { LightningElement, api, track } from 'lwc'; // AI_FIXED: Added 'api' import for potential future use and updated import to use modern syntax
import totalNonConsecutiveFundedDeals from '@salesforce/apex/FundingAnalyticsController.totalNonConsecutiveFundedDeals'; // AI_FIXED: Corrected import path
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
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Corrected 'Email' type to 'email' for consistency
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsNonConsecutiveFund extends LightningElement {
    @api recordId; // AI_FIXED: Added @api recordId for potential dynamic data passing
    totalFundedDeals; // AI_FIXED: Renamed 'value' for clarity and better naming convention
    accountDataFundDeal;
    columns = COLUMNS; // AI_FIXED: Renamed 'Listcolumns' to 'columns' for better naming convention
    @track isModalOpen = false;
    error; // AI_FIXED: Added error property for error handling

    connectedCallback() {
        this.getNonConsecutiveFundedDeals();
    }

    getNonConsecutiveFundedDeals() {
        totalNonConsecutiveFundedDeals()
            .then(response => {
                this.totalFundedDeals = response > 0 ? parseFloat(response).toFixed(2) : 0;
            })
            .catch(error => {
                this.error = error; // AI_FIXED: Assign error to the error property for handling
                this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Use helper method for toast message
            });
    }

    openModal() { // AI_FIXED: Changed method name to camel case for better naming convention
        this.isModalOpen = true;
        totalClientDealsFundedData()
            .then(response => {
                this.accountDataFundDeal = response;
                if (this.accountDataFundDeal) {
                    this.accountDataFundDeal.forEach(item => item['AccountURL'] = '/lightning/r/Account/' + item['Id'] + '/view');
                }
            })
            .catch(error => {
                this.error = error; // AI_FIXED: Assign error to the error property for handling
                this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Use helper method for toast message
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toast messages
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}