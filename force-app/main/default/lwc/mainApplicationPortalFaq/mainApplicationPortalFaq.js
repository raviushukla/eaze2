import { LightningElement } from 'lwc';

export default class MainApplicationPortalFaq extends LightningElement {

    faqs = [
        { id: 'question1', question: 'Question 1', answer: 'Answer 1', isOpen: false },
        { id: 'question2', question: 'Question 2', answer: 'Answer 2', isOpen: false },
        { id: 'question3', question: 'Question 3', answer: 'Answer 3', isOpen: false },
        { id: 'question4', question: 'Question 4', answer: 'Answer 4', isOpen: false },
        { id: 'question5', question: 'Question 5', answer: 'Answer 5', isOpen: false },
        { id: 'question6', question: 'Question 6', answer: 'Answer 6', isOpen: false },
        { id: 'question7', question: 'Question 7', answer: 'Answer 7', isOpen: false },
        { id: 'question8', question: 'Question 8', answer: 'Answer 8', isOpen: false },
        { id: 'question9', question: 'Question 9', answer: 'Answer 9', isOpen: false },
        { id: 'question10', question: 'Question 10', answer: 'Answer 10', isOpen: false },
        { id: 'question11', question: 'Question 11', answer: 'Answer 11', isOpen: false },
        { id: 'question12', question: 'Question 12', answer: 'Answer 12', isOpen: false },
        { id: 'question13', question: 'Question 13', answer: 'Answer 13', isOpen: false },
        { id: 'question14', question: 'Question 14', answer: 'Answer 14', isOpen: false },
        { id: 'question15', question: 'Question 15', answer: 'Answer 15', isOpen: false },
    ];

    handleFaqClick(event) {
        // AI_FIXED: Improved handling of FAQ clicks using a single method and data structure
        const faqId = event.target.dataset.faqId;
        const faq = this.faqs.find(faq => faq.id === faqId);
        if (faq) {
            faq.isOpen = !faq.isOpen;
        }
    }
}