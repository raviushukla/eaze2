import { LightningElement, wire, api } from 'lwc';
import fetchTotalAppsCount from '@salesforce/apex/FundingAnalyticsController.fetchTotalAppsCount';
import fetchTotalAppsCountData from '@salesforce/apex/FundingAnalyticsController.fetchTotalAppsCountData';
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
    totalAppsCount;
    leadData;
    columns = COLUMNS; // AI_FIXED: Renamed Listcolumns to columns to follow Salesforce naming conventions
    isModalOpen = false; // AI_FIXED: Removed @track decorator; reactivity is handled implicitly

    connectedCallback() {
        this.getTotalAppsCount();
    }

    getTotalAppsCount() {
        fetchTotalAppsCount()
            .then(response => {
                this.totalAppsCount = response;
                this.showChart(response); // AI_FIXED: Corrected casing for method name
            })
            .catch(error => {
                console.error('Error fetching total apps count:', error); // AI_FIXED: Improved error logging
                this.showToast('Error fetching total apps count', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    showChart(count) { // AI_FIXED: Corrected casing for method name
        Promise.all([loadScript(this, ChartOrg)])
            .then(() => {
                const canvas = this.template.querySelector('canvas.chart'); // AI_FIXED: Added class selector for canvas
                if (canvas) { // AI_FIXED: Added null check for canvas
                    const ctx = canvas.getContext('2d');
                    const data = {
                        labels: ['Yellow'],
                        datasets: [{
                            label: 'My First Dataset',
                            data: [count],
                            backgroundColor: ['rgb(255, 205, 86)'],
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
                    console.error('Canvas element not found'); // AI_FIXED: Added error handling for missing canvas
                }
            })
            .catch(error => {
                this.showToast('Error loading ChartJS', error.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    openModal() { // AI_FIXED: Corrected casing for method name
        this.isModalOpen = true;
        fetchTotalAppsCountData()
            .then(response => {
                this.leadData = response;
                if (this.leadData) {
                    this.leadData.forEach(item => item.LeadURL = `/lightning/r/Lead/${item.Id}/view`); // AI_FIXED: Improved template literal usage
                }
            })
            .catch(error => {
                console.error('Error fetching lead data:', error); // AI_FIXED: Improved error logging
                this.showToast('Error fetching lead data', error.body.message, 'error'); // AI_FIXED: Simplified toast message display
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) { // AI_FIXED: Created helper method for showing toasts
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}