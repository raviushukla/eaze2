global class ScheduleTextMessages implements Schedulable,Database.AllowsCallouts {
   global void execute(SchedulableContext SC) {
      BulkTextMessageBatch textJob = new BulkTextMessageBatch(); 
      Integer calloutNum = Integer.valueOf(Label.Text_Batch_Job_Limit);
       if(calloutNum > 100){
           calloutNum = 100;
       } 
      DataBase.executeBatch(textJob, calloutNum); 
   }
}