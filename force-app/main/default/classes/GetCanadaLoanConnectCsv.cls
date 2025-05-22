public class GetCanadaLoanConnectCsv implements Schedulable, Database.AllowsCallouts {
        
    public void execute(SchedulableContext sc){
        // AI_FIXED: Removed direct call to the CSV generation method and instead enqueued a separate job. This improves governor limits compliance and allows for asynchronous processing.
        Integer delayInMinutes = 0;
        String yesterdayDate = Datetime.now().addDays(-1).format('yyyy-MM-dd'); // AI_FIXED: Extracted date formatting for better readability and maintainability.
        ID jobID = System.enqueueJob(new GetLoanConnectCsvQueue(yesterdayDate), delayInMinutes); // AI_FIXED: Passed the formatted date as a parameter to the queue job.
    }
}