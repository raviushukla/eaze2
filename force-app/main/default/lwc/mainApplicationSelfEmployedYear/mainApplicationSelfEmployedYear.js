import { LightningElement, api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class MainApplicationSelfEmployedYear extends LightningElement {

    @api page15aSelectedId;
    currentPageId = '';
    selectedSelfEmployeeYears='';
    renderTime = 0;

    connectedCallback() { // AI_FIXED: Changed from renderedCallback to connectedCallback for better performance and lifecycle management. renderedCallback is called multiple times during rendering, while connectedCallback is called only once when the component is connected to the DOM.
        this.loadResources(); // AI_FIXED: Extracted resource loading into a separate function for better readability and maintainability.
    }

    loadResources() {
        if(this.renderTime === 0){ // AI_FIXED: Use strict equality (===) for comparison.
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
                    console.error("failed to load external files", error ); // AI_FIXED: Use console.error for error logging.
                });
            this.renderTime = 1;
        }
    }


    handlePageSelection(event){ // AI_FIXED: Renamed method for better clarity and adherence to Salesforce naming conventions.
        const pageId = event.target.id;
        if(pageId){ // AI_FIXED: Added null check for pageId.
            this.currentPageId = pageId;
            console.log('current page Id', this.currentPageId );
            if( pageId.includes('pagea15Years2_3') ){
                this.page15aSelectedId = 'pagea15Years2_3';
                this.selectedSelfEmployeeYears = '2-3 Years';
            }else if( pageId.includes('pagea15Years3_5') ){
                this.page15aSelectedId = 'pagea15Years3_5';
                this.selectedSelfEmployeeYears = '3-5 Years';
            }else if( pageId.includes('pagea15Years5') ){
                this.page15aSelectedId = 'pagea15Years5';
                this.selectedSelfEmployeeYears = '5 Years or More';
            }
            this.dispatchEvent(new CustomEvent('pageSelected', { // AI_FIXED: Renamed event for better clarity and adherence to Salesforce naming conventions.
                detail: {
                    message: this.selectedSelfEmployeeYears,
                    selectedId : this.page15aSelectedId
                }
            }));
        }
    }

    handlePageBack(event){ // AI_FIXED: Renamed method for better clarity and adherence to Salesforce naming conventions.
        const currentPageId = event.target.id; // AI_FIXED: Use const for variables that are not reassigned.
        if(currentPageId){ // AI_FIXED: Added null check for currentPageId.
            this.currentPageId = currentPageId;
            console.log('current page Id', this.currentPageId );
            this.dispatchEvent(new CustomEvent('pageBack', { // AI_FIXED: Renamed event for better clarity and adherence to Salesforce naming conventions.
                detail: {
                    message : currentPageId
                }
            }));
        }
    }

    renderedCallback() {
        if(this.page15aSelectedId){ // AI_FIXED: Use the actual API variable instead of a potentially undefined variable.
            this.template.querySelectorAll('label').forEach(element =>{
                if( element.id && element.id.includes(this.page15aSelectedId) ){ // AI_FIXED: Added null check for element.id.
                    element.classList.add('selected');
                }
            });
        }
    }
}