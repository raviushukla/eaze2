import { LightningElement, track } from 'lwc';
import clientNoApp90 from'@salesforce/apex/FundingAnalyticsController.clientNoApp90';
import percentageClientNoApp90 from'@salesforce/apex/FundingAnalyticsController.percentageClientNoApp90';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLUMNS = [
    {
    label: 'Name', fieldName: 'AccountURL', type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'Name'
        },
        target : '_blank'
    }
},
    { label: 'Primary Contact', fieldName: 'Primary_Contact__c', type: 'text' },
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'Email' },
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }
    
];

export default class FundingAnalyticsNoAppClient90 extends LightningElement {
value;
accountDataSubNoApp90;
Listcolumns = COLUMNS;
@track isModalOpen = false;
    connectedCallback() {
        this.getClientSubmittedAppNoPercentage90();
    }
    getClientSubmittedAppNoPercentage90(){
        percentageClientNoApp90().then(response => {
            this.value = response >0 ? parseFloat(response).toFixed(2) :0;
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
        clientNoApp90().then(response => {
            this.accountDataSubNoApp90 = response;
            if(this.accountDataSubNoApp90){
                this.accountDataSubNoApp90.forEach(item => item['AccountURL'] = '/lightning/r/Account/' +item['Id'] +'/view');
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