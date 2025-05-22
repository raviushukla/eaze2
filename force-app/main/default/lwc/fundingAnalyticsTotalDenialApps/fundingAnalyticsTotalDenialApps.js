import { LightningElement, wire, api,track } from 'lwc';
import fetchTotalDeclinedAppsCount from'@salesforce/apex/FundingAnalyticsController.fetchTotalDeclinedAppsCount';
import fetchTotalDeclinedAppsCountData from'@salesforce/apex/FundingAnalyticsController.fetchTotalDeclinedAppsCountData';
import ChartOrg from '@salesforce/resourceUrl/ChartOrg';
import { loadScript } from 'lightning/platformResourceLoader';
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

export default class FundingAnalyticsTotalApps extends LightningElement {
    totalDeclinedAppsCount;
    leadData;
   Listcolumns = COLUMNS;
   @track isModalOpen = false;
    connectedCallback() {
        this.getTotalDeclinedAppsCount();
    }
    getTotalDeclinedAppsCount(){
        fetchTotalDeclinedAppsCount().then(response => {
            this.totalDeclinedAppsCount = response;
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
                    'Red'
                ],
                datasets: [{
                    label: 'My First Dataset',
                    data: [count],
                    backgroundColor: [
                    'rgb(255, 99, 132)'
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
        fetchTotalDeclinedAppsCountData().then(response => {
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