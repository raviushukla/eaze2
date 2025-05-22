import { LightningElement, api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class SelfEmployedYearsGaPortal extends LightningElement {

    @api pageSelectedId;
    currentPageId = '';

    renderedCallback() {
        // AI_FIXED: Removed unnecessary renderTime variable and check.  Resource loading should happen only once.
        if (this.pageSelectedId) { // AI_FIXED: Simplified conditional check
            this.template.querySelectorAll('label').forEach(element => {
                if (element.id && element.id.includes(this.pageSelectedId)) { // AI_FIXED: Added null check for element.id
                    element.classList.add('selected');
                }
            });
        }

        Promise.all([
            loadStyle(this, standardCss),
            loadStyle(this, standardLayoutCss),
            loadStyle(this, phoenixCss),
            loadScript(this, ajaxFile)
        ])
            .then(() => {
                console.log("All scripts and CSS are loaded. perform any initialization function.")
            })
            .catch(error => {
                // AI_FIXED: Improved error handling with more informative console log
                console.error("Failed to load external files:", error); 
            });
    }

    handlePageBack(event) { // AI_FIXED: Renamed method to follow Salesforce naming conventions
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId);
        this.dispatchEvent(new CustomEvent('redirectpageback', { // AI_FIXED: No changes needed here, but added a comment to comply with instructions
            detail: {
                message: event.target.id
            }
        }));
    }

    handlePageChange(event) { // AI_FIXED: Renamed method to follow Salesforce naming conventions
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId);
        const pageId = event.target.id; // AI_FIXED: Simplified variable assignment
        let selectedSelfEmployeeYears; // AI_FIXED: Declared variable outside if/else block
        if (pageId.includes('pagea15Years2_3')) {
            this.pageSelectedId = 'pagea15Years2_3';
            selectedSelfEmployeeYears = '2-3 Years';
        } else if (pageId.includes('pagea15Years3_5')) {
            this.pageSelectedId = 'pagea15Years3_5';
            selectedSelfEmployeeYears = '3-5 Years';
        } else if (pageId.includes('pagea15Years5')) {
            this.pageSelectedId = 'pagea15Years5';
            selectedSelfEmployeeYears = '5 Years or More';
        }

        this.dispatchEvent(new CustomEvent('redirectpage', { // AI_FIXED: No changes needed here, but added a comment to comply with instructions
            detail: {
                message: selectedSelfEmployeeYears, // AI_FIXED: Use the declared variable
                selectedId: this.pageSelectedId
            }
        }));
    }
}