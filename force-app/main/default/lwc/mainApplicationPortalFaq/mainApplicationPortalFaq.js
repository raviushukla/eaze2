import { LightningElement } from 'lwc';

export default class MainApplicationPortalFaq extends LightningElement {

    showIcon1 = true;answer1Div = false;
    showIcon2 = true;answer2Div = false;
    showIcon3 = true;answer3Div = false;
    showIcon4 = true;answer4Div = false;
    showIcon5 = true;answer5Div = false;
    showIcon6 = true;answer6Div = false;
    showIcon7 = true;answer7Div = false;
    showIcon8 = true;answer8Div = false;
    showIcon9 = true;answer9Div = false;
    showIcon10 = true;answer10Div = false;
    showIcon11 = true;answer11Div = false;
    showIcon12 = true;answer12Div = false;
    showIcon13 = true;answer13Div = false;
    showIcon14 = true;answer14Div = false;
    showIcon15 = true;answer15Div = false;

    btnClick(event){
        var qtnId = event.target.id;
        console.log('qId',qtnId );
        if( qtnId.includes("question01") ){
            if(this.answer1Div == false){
                this.showIcon1 = false;
                this.answer1Div = true;
            }else {
                this.showIcon1 = true;
                this.answer1Div = false;
            }
        }else if( qtnId.includes("question2") ){
            if(this.answer2Div == false){
                this.showIcon2 = false;
                this.answer2Div = true;
            }else {
                this.showIcon2 = true;
                this.answer2Div = false;
            }
        }else if( qtnId.includes("question3") ){
            if(this.answer3Div == false){
                this.showIcon3 = false;
                this.answer3Div = true;
            }else {
                this.showIcon3 = true;
                this.answer3Div = false;
            }
        }else if( qtnId.includes("question4") ){
            if(this.answer4Div == false){
                this.showIcon4 = false;
                this.answer4Div = true;
            }else {
                this.showIcon4 = true;
                this.answer4Div = false;
            }
        }else if( qtnId.includes("question5") ){
            if(this.answer5Div == false){
                this.showIcon5 = false;
                this.answer5Div = true;
            }else {
                this.showIcon5 = true;
                this.answer5Div = false;
            }
        }else if( qtnId.includes("question6") ){
            if(this.answer6Div == false){
                this.showIcon6 = false;
                this.answer6Div = true;
            }else {
                this.showIcon6 = true;
                this.answer6Div = false;
            }
        }else if( qtnId.includes("question7") ){
            if(this.answer7Div == false){
                this.showIcon7 = false;
                this.answer7Div = true;
            }else {
                this.showIcon7 = true;
                this.answer7Div = false;
            }
        }else if( qtnId.includes("question8") ){
            if(this.answer8Div == false){
                this.showIcon8 = false;
                this.answer8Div = true;
            }else {
                this.showIcon8 = true;
                this.answer8Div = false;
            }
        }else if( qtnId.includes("question9") ){
            if(this.answer9Div == false){
                this.showIcon9 = false;
                this.answer9Div = true;
            }else {
                this.showIcon9 = true;
                this.answer9Div = false;
            }
        }else if( qtnId.includes("question10") ){
            if(this.answer10Div == false){
                this.showIcon10 = false;
                this.answer10Div = true;
            }else {
                this.showIcon10 = true;
                this.answer10Div = false;
            }
        }else if( qtnId.includes("question11") ){
            if(this.answer11Div == false){
                this.showIcon11 = false;
                this.answer11Div = true;
            }else {
                this.showIcon11 = true;
                this.answer11Div = false;
            }
        }else if( qtnId.includes("question12") ){
            if(this.answer12Div == false){
                this.showIcon12 = false;
                this.answer12Div = true;
            }else {
                this.showIcon12 = true;
                this.answer12Div = false;
            }
        }else if( qtnId.includes("question13") ){
            if(this.answer13Div == false){
                this.showIcon13 = false;
                this.answer13Div = true;
            }else {
                this.showIcon13 = true;
                this.answer13Div = false;
            }
        }else if( qtnId.includes("question14") ){
            if(this.answer14Div == false){
                this.showIcon14 = false;
                this.answer14Div = true;
            }else {
                this.showIcon14 = true;
                this.answer14Div = false;
            }
        }else if( qtnId.includes("question15") ){
            if(this.answer15Div == false){
                this.showIcon15 = false;
                this.answer15Div = true;
            }else {
                this.showIcon15 = true;
                this.answer15Div = false;
            }
        }
    }
}