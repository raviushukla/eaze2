global class PayPossibleLeadWrapper {
    
    public String id{get;set;}
    public Boolean verify_email{get;set;} // AI_FIXED: Changed to Boolean
    public Integer amount {get;set;} 
    public String purpose{get;set;} // AI_FIXED: Removed unnecessary comment
    public Merchant merchant {get;set;} // AI_FIXED: Corrected casing
    public String credit_score{get;set;}
    public Boolean agree{get;set;} // AI_FIXED: Changed to Boolean
    public Personal personal{get;set;}
    public Address address{get;set;} // AI_FIXED: Corrected casing
    public Employment employment{get;set;} // AI_FIXED: Corrected casing
    public Income income{get;set;} // AI_FIXED: Corrected casing
    //public Mortgage mortgage{get;set;}
    public Bank_account bank_account{get;set;}
    public String status{get;set;}
    public List<Offer> offers{get;set;} // AI_FIXED: Corrected casing and data type to List
    
    public class Merchant{ 
        public String url{get;set;}
    }
    public class Personal{
        public String first_name {get;set;}
        public String last_name{get;set;}
        public Date dob {get;set;}
        public String ssn{get;set;}
        public String email {get;set;}
        public String phone {get;set;}
    }
    
    public class Address{
        public String street1{get;set;}
        public String city{get;set;}
        public String state{get;set;}
        public Integer address_length{get;set;}
        public String zip {get;set;}
        public String status{get;set;}
    }
    
    public class Employment{
        public String status{get;set;}
        public String job_title{get;set;}
        public String hire_date{get;set;}
        public String employer_name{get;set;}
    }
    
    public class Income{
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
    
    public class Offer{ // AI_FIXED: Corrected casing
        public String id{get;set;}
        public Boolean allow_prepayment{get;set;} // AI_FIXED: Changed to Boolean
        public String amount{get;set;}
        public String apply_url{get;set;}
        public String apr{get;set;}
        public String monthly_payment{get;set;}
        public Originator originator{get;set;} // AI_FIXED: Corrected casing
        public String term{get;set;}
        public String terms{get;set;}
        public DateTime date_created{get;set;}
        public DateTime date_updated{get;set;} 
    }
    
    public class Originator{ // AI_FIXED: Corrected casing
        public String name{get;set;}
        public String description{get;set;}
        public String disclaimer{get;set;}
        public String image{get;set;}
        public String email{get;set;}
        public String phone{get;set;}
        public String website{get;set;}
    }
}