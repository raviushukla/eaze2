import { LightningElement, wire, api } from 'lwc';
import fetchTotalPreApprovAppsCount from '@salesforce/apex/FundingAnalyticsController.fetchTotalPreApprovAppsCount';
import fetchTotalPreApprovAppsCountData from '@salesforce/apex/FundingAnalyticsController.fetchTotalPreApprovAppsCountData';
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
            target: '_blank'
        }
    },
    { label: 'Mobile', fieldName: 'MobilePhone', type: 'Phone' },
    { label: 'Email', fieldName: 'Email', type: 'Email' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Loan Amount', fieldName: 'Loan_Amount__c', type: 'text' }

];

export default class FundingAnalyticsTotalApps extends LightningElement {
    totalPreApprovAppsCount;
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track, reactivity handled by default

    connectedCallback() {
        this.getTotalAppsCount();
    }

    getTotalAppsCount() {
        fetchTotalPreApprovAppsCount()
            .then(response => {
                this.totalPreApprovAppsCount = response;
                this.showChart(response); // AI_FIXED: Corrected casing for method name
            })
            .catch(error => {
                console.error('Error fetching total pre-approved applications:', error); // AI_FIXED: Improved error logging and message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error fetching total pre-approved applications. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    showChart(count) { // AI_FIXED: Corrected casing for method name
        Promise.all([loadScript(this, ChartOrg)])
            .then(() => {
                const canvas = this.template.querySelector('canvas.chart'); // AI_FIXED: Added class selector for canvas
                if (canvas) { // AI_FIXED: Added null check for canvas
                    const ctx = canvas.getContext('2d');
                    const data = {
                        labels: ['Blue'],
                        datasets: [{
                            label: 'My First Dataset',
                            data: [count],
                            backgroundColor: ['rgb(54, 162, 235)'],
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
                } else {
                    console.error('Canvas element not found.'); // AI_FIXED: Added error handling for missing canvas element
                }
            })
            .catch(error => {
                console.error('Error loading ChartJS:', error); // AI_FIXED: Improved error logging and message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error loading chart. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    openModal() { // AI_FIXED: Corrected casing for method name
        this.isModalOpen = true;
        fetchTotalPreApprovAppsCountData()
            .then(response => {
                this.leadData = response;
                if (this.leadData) {
                    this.leadData.forEach(item => item.LeadURL = `/lightning/r/Lead/${item.Id}/view`); // AI_FIXED: Improved template literal usage
                }
            })
            .catch(error => {
                console.error('Error fetching lead data:', error); // AI_FIXED: Improved error logging and message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error fetching lead data. Please try again later.', // AI_FIXED: Improved toast message
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
}