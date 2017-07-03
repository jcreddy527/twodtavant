global class BulkUploadBatch implements Database.Batchable<Bulk_Upload__c>
{
    List<Bulk_Upload__c> bulkUp = new List<Bulk_Upload__c>();
    public BulkUploadBatch(List<Bulk_Upload__c> data)
    {
        this.bulkUp = data;
               system.debug('checking bulkUp :'+bulkUp);
    }
    global Iterable<Bulk_Upload__c> start(Database.BatchableContext info){
       return bulkUp;
   }
   global void execute(Database.BatchableContext info, List<Bulk_Upload__c> batch)
   {
      List<Bulk_Upload__c> bulkData = new List<Bulk_Upload__c>();
       for(Bulk_Upload__c obj:batch)
       {
       bulkData.add(obj);
       }
       system.debug('checking batch :'+batch);
       insert batch;
   }
   global void finish(Database.BatchableContext info){    
   }
}