import { LightningElement, track } from 'lwc';
import fetchClientsSubmittedApp from '@salesforce/apex/FundingAnalyticsController.fetchClientsSubmittedApp';
import fetchClientsSubmittedAppData from '@salesforce/apex/FundingAnalyticsController.fetchClientsSubmittedAppData';
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
    { label: 'Primary Contact Email', fieldName: 'Primary_Contact_Email__c', type: 'email' }, // AI_FIXED: Changed type to 'email' for better data handling
    { label: 'Primary Contact Name', fieldName: 'Primary_Contact_Name__c', type: 'text' }

];

export default class FundingAnalyticsNumClientsSubmittedApp extends LightningElement {
    totalClientsSubmittedApp;
    accountDataSubApp;
    listColumns = COLUMNS; // AI_FIXED: Corrected casing to match naming conventions
    @track isModalOpen = false;

    connectedCallback() {
        this.handleGetTotalClientsSubApp(); // AI_FIXED: Renamed method for clarity and consistency
    }

    handleGetTotalClientsSubApp() { // AI_FIXED: Renamed method for clarity and consistency
        fetchClientsSubmittedApp()
            .then(response => {
                this.totalClientsSubmittedApp = response;
                this.showChart(response); // AI_FIXED: Corrected casing for method name
            })
            .catch(error => {
                console.error('Error fetching total clients:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message, // AI_FIXED: Using error.message for better error display
                        variant: 'error'
                    })
                );
            });
    }

    showChart(count) { // AI_FIXED: Corrected casing for method name
        Promise.all([loadScript(this, ChartOrg)])
            .then(() => {
                const canvas = this.template.querySelector('canvas.chart'); // AI_FIXED: Added class selector for canvas element
                if (canvas) { // AI_FIXED: Added null check to prevent errors
                    const ctx = canvas.getContext('2d');
                    const data = {
                        labels: ['Submitted Applications'], // AI_FIXED: Improved label for better context
                        datasets: [{
                            label: 'Number of Clients', // AI_FIXED: Improved label for better context
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
                    console.error('Canvas element not found.'); // AI_FIXED: Added error handling for missing canvas element
                }
            })
            .catch(error => {
                console.error('Error loading ChartJS:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading ChartJS',
                        message: error.message, // AI_FIXED: Using error.message for better error display
                        variant: 'error'
                    })
                );
            });
    }


    openModal() { // AI_FIXED: Corrected casing to match naming conventions
        this.isModalOpen = true;
        fetchClientsSubmittedAppData()
            .then(response => {
                this.accountDataSubApp = response;
                if (this.accountDataSubApp) {
                    this.accountDataSubApp.forEach(item => item.AccountURL = `/lightning/r/Account/${item.Id}/view`); // AI_FIXED: Improved template literal for URL creation
                }
            })
            .catch(error => {
                console.error('Error fetching client data:', error); // AI_FIXED: Improved error handling and logging
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message, // AI_FIXED: Using error.message for better error display
                        variant: 'error'
                    })
                );
            });
    }

    closeModal() { // AI_FIXED: Corrected casing to match naming conventions
        this.isModalOpen = false;
    }
}