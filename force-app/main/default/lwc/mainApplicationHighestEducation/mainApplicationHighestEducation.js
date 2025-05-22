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

    renderTime = 0;

    renderedCallback() {
        console.log('Select Id '+ this.page13aSelectedId);
        if(this.page13aSelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page13aSelectedId) ){
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
            if( pageId.includes('pagea13High') ){
                this.page13aSelectedId = 'pagea13High';
                this.selectedHighestEducation = 'High School';
            }else if( pageId.includes('pagea13Asso') ){
                this.page13aSelectedId = 'pagea13Asso';
                this.selectedHighestEducation = 'Associate';
            }else if( pageId.includes('pagea13Bach') ){
                this.page13aSelectedId = 'pagea13Bach';
                this.selectedHighestEducation = 'Bachelor\'s';
            }else if( pageId.includes('pagea13Mast') ){
                this.page13aSelectedId = 'pagea13Mast';
                this.selectedHighestEducation = 'Master\'s';
            }else if( pageId.includes('pagea13Other') ){
                this.page13aSelectedId = 'pagea13Other';
                this.selectedHighestEducation = 'Other';
            }
        }
        this.dispatchEvent(new CustomEvent('redirectpage', {
            detail: {
                message: this.selectedHighestEducation,
                selectedId : this.page13aSelectedId
            }
        }));
    }
}