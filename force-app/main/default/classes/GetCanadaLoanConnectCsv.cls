public class GetCanadaLoanConnectCsv implements Schedulable, Database.AllowsCallouts {
        
    public void execute(SchedulableContext sc){
        //getCsvFromApi(Datetime.now().addDays(-1).format('yyyy-MM-dd'));
        Integer delayInMinutes = 0;
        ID jobID = System.enqueueJob(new GetLoanConnectCsvQueue(Datetime.now().addDays(-1).format('yyyy-MM-dd')), delayInMinutes);
    }
}