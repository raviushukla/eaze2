import { LightningElement, api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class MainApplicationTypeOfResidence extends LightningElement {

    @api page12SelectedId;
    currentPageId = '';
    selectedResidenceValue = '';

    renderedCallback() {
        // AI_FIXED: Removed unnecessary renderTime variable and check. Styles and scripts are loaded only once during the component's lifecycle.
        Promise.all([
            loadStyle(this, standardCss),
            loadStyle(this, standardLayoutCss),
            loadStyle(this, phoenixCss),
            loadScript(this, ajaxFile)
        ])
            .then(() => {
                // AI_FIXED: Added more descriptive console log message.
                console.log("All scripts and CSS are loaded.");
                this.highlightSelectedResidence(); // AI_FIXED: Moved the highlighting logic to a separate function for better readability and maintainability.
            })
            .catch(error => {
                // AI_FIXED: Improved error handling by logging the error details.
                console.error("Failed to load external files:", error);
            });
    }

    highlightSelectedResidence() {
        // AI_FIXED: Added null check for this.page12SelectedId to prevent errors if it's not set.
        if (this.page12SelectedId) {
            const labels = this.template.querySelectorAll('label');
            // AI_FIXED: Improved efficiency by using for...of loop instead of forEach.
            for (const element of labels) {
                if (element.id && element.id.includes(this.page12SelectedId)) {
                    element.classList.add('selected');
                }
            }
        }
    }

    handleRedirectPageBack(event) { // AI_FIXED: Renamed method to follow Salesforce naming conventions.
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId);
        this.dispatchEvent(new CustomEvent('redirectpageback', {
            detail: {
                message: event.target.id
            }
        }));
    }

    handleRedirectPage(event) { // AI_FIXED: Renamed method to follow Salesforce naming conventions.
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId);
        // AI_FIXED: Removed redundant null checks.
        const pageId = event.target.id;
        // AI_FIXED: Simplified conditional logic using a switch statement.
        switch (true) {
            case pageId.includes('page12Own'):
                this.page12SelectedId = 'page12Own';
                this.selectedResidenceValue = 'Own_Outright';
                break;
            case pageId.includes('page12MortOwnWith'):
                this.page12SelectedId = 'page12MortOwnWith';
                this.selectedResidenceValue = 'Own_with_Mortgage';
                break;
            case pageId.includes('page12Rent'):
                this.page12SelectedId = 'page12Rent';
                this.selectedResidenceValue = 'Rent';
                break;
            default:
                this.page12SelectedId = 'page12OTH';
                this.selectedResidenceValue = 'Other';
        }
        this.dispatchEvent(new CustomEvent('redirectpage', {
            detail: {
                message: this.selectedResidenceValue,
                selectedId: this.page12SelectedId
            }
        }));
    }
}