import { LightningElement,track } from 'lwc';
import fetchTotalClients from'@salesforce/apex/FundingAnalyticsController.fetchTotalClients';
import fetchTotalClientsData from'@salesforce/apex/FundingAnalyticsController.fetchTotalClientsData';
import ChartOrg from '@salesforce/resourceUrl/ChartOrg';
import { loadScript } from 'lightning/platformResourceLoader';
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

export default class FundingAnalyticsNumOfClients extends LightningElement {
   totalClients;
   accountData;
   Listcolumns = COLUMNS;
   @track isModalOpen = false;
    connectedCallback() {
        this.getTotalClients();
    }
    getTotalClients(){
        fetchTotalClients().then(response => {
            this.totalClients = response;
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

    showchart(count) {
        //var el = this.template.querySelector("div[class=chart]");
        Promise.all([loadScript(this,ChartOrg)])
        .then(() =>{
            var canvas = this.template.querySelector('canvas');
            var ctx = canvas.getContext('2d');
            var data = {
                labels: [
                    'Yellow'
                ],
                datasets: [{
                    label: 'My First Dataset',
                    data: [count],
                    backgroundColor: [
                    'rgb(255, 205, 86)'
                    ],
                    hoverOffset: 4
                }]
            };
            var myPieChart = new Chart(ctx, {
                type: 'doughnut',
                data: data,
                options: {
                    legend: {
                        display: false
                    },
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        })
        .catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error loading ChartJS',
                    message : error.message,
                    variant : 'error',
                }),
            );
        });  
	}
    
    OpenModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        fetchTotalClientsData().then(response => {
            this.accountData = response;
            if(this.accountData){
                this.accountData.forEach(item => item['AccountURL'] = '/lightning/r/Account/' +item['Id'] +'/view');
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