import { LightningElement, api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class SelfEmployedYearsGaPortal extends LightningElement {

    @api pageSelectedId;
    currentPageId = '';

    renderTime = 0;

    renderedCallback() {
        
        if(this.pageSelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.pageSelectedId) ){
                    element.classList.add('selected');
                    console.log('class is add', element.classList )
                }
            });
        }

        if(this.renderTime == 0 ){
            Promise.all([
                loadStyle(this, standardCss),
                loadStyle(this, standardLayoutCss),
                loadStyle(this, phoenixCss ),
                loadScript(this, ajaxFile )
                /*loadStyle(this, bootstrapMin ),
                loadScript  (this, bootstrapCDN ),
                loadScript(this, popperMin)*/
            ])
                .then(() => {
                    console.log("All scripts and CSS are loaded. perform any initialization function.")
                })
                .catch(error => {
                    console.log("failed to load external files", error );
                });
        }
        this.renderTime = 1;
    }

    redirectPageBack(event){
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId );
        this.dispatchEvent(new CustomEvent('redirectpageback', {
            detail: {
                message : event.target.id
            }
        }));
    }

    redirectPage(event){

        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId );
        if(event != null && event != undefined && event.target != null && event.target != undefined ){
            console.log('id  - > ', event.target.id);
            var pageId = event.target.id;
            if( pageId.includes('pagea15Years2_3') ){
                this.pageSelectedId = 'pagea15Years2_3';
                this.selectedSelfEmployeeYears = '2-3 Years';
            }else if( pageId.includes('pagea15Years3_5') ){
                this.pageSelectedId = 'pagea15Years3_5';
                this.selectedSelfEmployeeYears = '3-5 Years';
            }else if( pageId.includes('pagea15Years5') ){
                this.pageSelectedId = 'pagea15Years5';
                this.selectedSelfEmployeeYears = '5 Years or More';
            }
        }
        this.dispatchEvent(new CustomEvent('redirectpage', {
            detail: {
                message: this.selectedSelfEmployeeYears,
                selectedId : this.pageSelectedId
            }
        }));
    }
}