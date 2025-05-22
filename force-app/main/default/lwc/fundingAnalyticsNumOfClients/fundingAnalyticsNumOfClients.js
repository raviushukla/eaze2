import { LightningElement, track } from 'lwc';
import fetchTotalClients from '@salesforce/apex/FundingAnalyticsController.fetchTotalClients';
import fetchTotalClientsData from '@salesforce/apex/FundingAnalyticsController.fetchTotalClientsData';
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
            target: '_blank'
        }
    },
    { label: 'Primary Contact', fieldName: 'Primary_Contact__c', type: 'text' },
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Changed 'Email' to 'email' for consistency
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsNumOfClients extends LightningElement {
    totalClients;
    accountData;
    listColumns = COLUMNS; // AI_FIXED: Changed variable name to follow camel case convention
    @track isModalOpen = false;
    error; // AI_FIXED: Added error property to handle errors

    connectedCallback() {
        this.getTotalClients();
    }

    getTotalClients() {
        fetchTotalClients()
            .then(response => {
                this.totalClients = response;
                this.showChart(response); // AI_FIXED: Corrected typo in method name
            })
            .catch(error => {
                this.error = error; // AI_FIXED: Assign error to the error property
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error fetching total clients', // AI_FIXED: Improved toast message
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    showChart(count) { // AI_FIXED: Corrected typo in method name
        Promise.all([loadScript(this, ChartOrg)])
            .then(() => {
                const canvas = this.template.querySelector('canvas.chart'); // AI_FIXED: Added class selector for canvas
                if (canvas) { // AI_FIXED: Added null check for canvas
                    const ctx = canvas.getContext('2d');
                    const data = {
                        labels: [
                            'Total Clients' // AI_FIXED: Improved label for clarity
                        ],
                        datasets: [{
                            label: 'Total Clients', // AI_FIXED: Improved label for clarity
                            data: [count],
                            backgroundColor: [
                                'rgb(255, 205, 86)'
                            ],
                            hoverOffset: 4
                        }]
                    };
                    new Chart(ctx, { // AI_FIXED: Removed unnecessary variable assignment
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
                }
            })
            .catch(error => {
                this.error = error; // AI_FIXED: Assign error to the error property
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading ChartJS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Changed method name to camel case
        this.isModalOpen = true;
        fetchTotalClientsData()
            .then(response => {
                this.accountData = response;
                if (this.accountData) {
                    this.accountData.forEach(item => item['AccountURL'] = '/lightning/r/Account/' + item['Id'] + '/view');
                }
            })
            .catch(error => {
                this.error = error; // AI_FIXED: Assign error to the error property
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error fetching account data', // AI_FIXED: Improved toast message
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
}