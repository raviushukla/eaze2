import { LightningElement,api } from 'lwc';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class MainApplicationTypeOfResidence extends LightningElement {

    @api page12SelectedId;
    currentPageId = '';
    selectedResidenceValue = '';

    renderTime = 0;

    renderedCallback() {
        console.log('Selected Id : '+ this.page12SelectedId);
        if(this.page12SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page12SelectedId) ){
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
            if( pageId.includes('page12Own') ){
                this.page12SelectedId = 'page12Own';
                this.selectedResidenceValue = 'Own_Outright';
            }else if( pageId.includes('page12MortOwnWith') ){
                this.page12SelectedId = 'page12MortOwnWith';
                this.selectedResidenceValue = 'Own_with_Mortgage';
            }else if( pageId.includes('page12Rent') ){
                this.page12SelectedId = 'page12Rent';
                this.selectedResidenceValue = 'Rent';
            }else {
                this.page12SelectedId = 'page12OTH';
                this.selectedResidenceValue = 'Other';
            } 
        }
        this.dispatchEvent(new CustomEvent('redirectpage', {
            detail: {
                message: this.selectedResidenceValue,
                selectedId : this.page12SelectedId
            }
        }));
    }
}