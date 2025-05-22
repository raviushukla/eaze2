global class PayPossibleLeadWrapper {
    
    public String id{get;set;}
    public boolean verify_email{get;set;}
    public Integer amount {get;set;} 
    public String purpose{get;set;} //auto,baby,boat,bussiness,dept_consolidation,green,home_improvement,househole_expenses,large_purchases,medical_dental,moving_relocation,student_loan,taxes,vacation,wedding,other)
    public merchant merchant {get;set;}
    public String credit_score{get;set;}//excellent,good,fair,poor
    public boolean agree{get;set;}
    public Personal personal{get;set;}
    public address address{get;set;}
    public employment employment{get;set;}
    public income income{get;set;}
    //public Mortgage mortgage{get;set;}
    public Bank_account bank_account{get;set;}
    Public String status{get;set;}
    public list<offers> offers{get;set;} //class lin no 6
    
    public class merchant{ 
        public String url{get;set;}
        //public String id{get;set;}
        //public String name{get;set;}
        //public String code{get;set;}
    }
    public class personal{
        public String first_name {get;set;}
        public String last_name{get;set;}
        public Date dob {get;set;}
        public String ssn{get;set;}
        public String email {get;set;}
        public String phone {get;set;}
    }
    
    public class address{
        public String street1{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public Integer address_length{get;set;}
        public String zip {get;set;}
        public String status{get;set;}
    }
    
    public class employment{
        public String status{get;set;}
        public String job_title{get;set;}
        public String hire_date{get;set;}
        public String employer_name{get;set;}
    }
    
    public class income{
        public Decimal annual_income{get;set;}
        public String payroll_frequency{get;set;}
        public String payroll_type{get;set;}
    }
    
    /*public class Mortgage {
        public String lender_name {get;set;} 
        public String mortgage_payment {get;set;} 
        public String has_fha_loan {get;set;} 
        public String current_with_loan {get;set;} 
    }*/
    
    public class Bank_account {
        public String routing_number {get;set;} 
        public String account_number {get;set;} 
        public String account_type {get;set;} 
        public String bank_name {get;set;} 
        public String account_length {get;set;} 
        public String payment_method {get;set;} 
    }
    
    public class offers{
        public String id{get;set;}
        public Boolean allow_prepayment{get;set;}
        public String amount{get;set;}
        public String apply_url{get;set;}
        public String apr{get;set;}
        public String monthly_payment{get;set;}
        public originator originator{get;set;} //class line no 22 
        public String term{get;set;}
        public String terms{get;set;}
        public DateTime date_created{get;set;}
        public DateTime date_updated{get;set;} //class line no 9
    }
    
    public Class originator{
        public String name{get;set;}
        public String description{get;set;}
        Public String disclaimer{get;set;}
        Public String image{get;set;}//url type  
        public String email{get;set;}
        public String phone{get;set;}
        public String website{get;set;}//url type
    }
    
    

}