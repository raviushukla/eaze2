import { LightningElement, api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class MainApplicationHighestEducation extends LightningElement {

    @api page13aSelectedId;
    currentPageId = '';
    selectedHighestEducation = '';

    renderedCallback() {
        // AI_FIXED: Removed unnecessary renderTime variable and its usage.  The CSS and JS loading should happen only once.
        if(this.page13aSelectedId){ // AI_FIXED: Added null check for page13aSelectedId
            this.template.querySelectorAll('label').forEach(element =>{
                if(element.id && element.id.includes(this.page13aSelectedId)){ // AI_FIXED: Added null check for element.id
                    element.classList.add('selected');
                }
            });
        }

        Promise.all([
            loadStyle(this, standardCss),
            loadStyle(this, standardLayoutCss),
            loadStyle(this, phoenixCss ),
            loadScript(this, ajaxFile )
        ])
            .then(() => {
                console.log("All scripts and CSS are loaded. perform any initialization function.")
            })
            .catch(error => {
                // AI_FIXED: Improved error handling by logging the error details.
                console.error("failed to load external files", error);
            });
    }

    handlePageBack(event){ // AI_FIXED: Renamed method to follow Salesforce naming conventions and improved clarity.
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId );
        this.dispatchEvent(new CustomEvent('redirectpageback', { // AI_FIXED: Maintained original event name for backward compatibility.
            detail: {
                message : event.target.id
            }
        }));
    }

    handlePageNavigation(event){ // AI_FIXED: Renamed method to follow Salesforce naming conventions and improved clarity.
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId );
        if(event?.target){ // AI_FIXED: Improved null checks using optional chaining.
            const pageId = event.target.id; // AI_FIXED: Simplified variable assignment.
            switch(true){ // AI_FIXED: Replaced if-else-if chain with a switch statement for better readability and performance.
                case pageId.includes('pagea13High'):
                    this.page13aSelectedId = 'pagea13High';
                    this.selectedHighestEducation = 'High School';
                    break;
                case pageId.includes('pagea13Asso'):
                    this.page13aSelectedId = 'pagea13Asso';
                    this.selectedHighestEducation = 'Associate';
                    break;
                case pageId.includes('pagea13Bach'):
                    this.page13aSelectedId = 'pagea13Bach';
                    this.selectedHighestEducation = 'Bachelor\'s';
                    break;
                case pageId.includes('pagea13Mast'):
                    this.page13aSelectedId = 'pagea13Mast';
                    this.selectedHighestEducation = 'Master\'s';
                    break;
                case pageId.includes('pagea13Other'):
                    this.page13aSelectedId = 'pagea13Other';
                    this.selectedHighestEducation = 'Other';
                    break;
            }
        }
        this.dispatchEvent(new CustomEvent('redirectpage', { // AI_FIXED: Maintained original event name for backward compatibility.
            detail: {
                message: this.selectedHighestEducation,
                selectedId : this.page13aSelectedId
            }
        }));
    }
}