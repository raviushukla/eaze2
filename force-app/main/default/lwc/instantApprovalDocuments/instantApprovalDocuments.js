import { LightningElement, api, wire } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId'

export default class InstantApprovalDocuments extends LightningElement {
    @api recordId;
    filesList =[];
    filesListUsed = [];
    numOfRec = 0;
    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){ 
        if(data){ 
            console.log(data)
            data.forEach((item) => {
                let fileObj = {};
                fileObj.url = `/sfc/servlet.shepherd/document/download/${item.docId}`;
                fileObj.previewUrl = `/${item.docId}`;
                fileObj.createdDate = item.createdDate;
                fileObj.title = item.title;
                this.filesList.push(fileObj);
            });
            
            this.showList();
        }
        if(error){ 
            console.log(error)
        }
    }

    showList(){
        this.numOfRec = this.filesList.length < this.numOfRec ? this.filesList.length :  this.numOfRec += 3;
        this.filesListUsed = this.filesList.slice(0, this.numOfRec)
    }

    handleDownloadClick(event){
        window.open(event.target.dataset.url,"_blank");
    }


}