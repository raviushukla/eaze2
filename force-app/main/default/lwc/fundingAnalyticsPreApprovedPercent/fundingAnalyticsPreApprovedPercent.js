import { LightningElement, wire, api,track } from 'lwc';
import preApprovedPercentage from'@salesforce/apex/FundingAnalyticsController.preApprovedPercentage';
import fetchTotalPreApprovAppsCountData from'@salesforce/apex/FundingAnalyticsController.fetchTotalPreApprovAppsCountData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLUMNS = [
    {
    label: 'Name', fieldName: 'LeadURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'Name'
        },
        target : '_blank'
    }
},
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'Phone' },
    { label: 'Email', fieldName: 'Email', type: 'Email' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'text' }

    
];

export default class FundingAnalyticsPreApprovedPercent extends LightningElement {
    value;
    leadData;
    Listcolumns = COLUMNS;
    @track isModalOpen = false;
    connectedCallback() {
        this.getPreApprovedPercentage();
    }
    getPreApprovedPercentage(){
        preApprovedPercentage().then(response => {
            this.value = response >0 ? parseFloat(response).toFixed(2) :0;
            //this.showchart(response);
        }).catch(error => {
            console.log('Error: ' +error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    OpenModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        fetchTotalPreApprovAppsCountData().then(response => {
            this.leadData = response;
            if(this.leadData){
                this.leadData.forEach(item => item['LeadURL'] = '/lightning/r/Lead/' +item['Id'] +'/view');
            }
        }).catch(error => {
            console.log('Error: ' +error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}