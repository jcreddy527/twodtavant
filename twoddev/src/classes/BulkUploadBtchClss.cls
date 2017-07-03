Global with sharing class BulkUploadBtchClss implements Database.batchable<sobject>,Database.Stateful{
    
   //variable initialization
   string ProcessName;
   String query;
   String errMsg;
   Boolean errFlag;
   List<Bulk_Upload__c> bulkUploadErrList = new List<Bulk_Upload__c>();
   List<Bulk_Upload__c> bulkUploadSuccessList = new List<Bulk_Upload__c>();
   Integer totCnt;
   Integer succCnt;
   Integer failCnt;
   Integer errorCnt = 0;
   String[] errorList;
   
   //constructor declaration
   global BulkUploadBtchClss(String pName, String Qry){
      ProcessName = pName;
      Query = Qry;
   }
   
   /************************************************************************
   *Batch Start Method  
   *Query the select stage records which are all ready for process".
   *************************************************************************/
   
   global Database.QueryLocator start(Database.BatchableContext BC) { 
      system.debug('query'+query);
      return Database.getQueryLocator(query);
   }
   
    
   /*************************************************************************
   Batch Execute Method.
   Process the batch of records to create warranty registration 
   Updating the Bulk Upload stage object
   **************************************************************************/
    global void execute(Database.BatchableContext BC, List<Bulk_Upload__c> uStage) {
        system.debug('the scope is'+uStage);
        totCnt = uStage.size();
        for(Bulk_Upload__c bulkUploadRec : uStage){
           system.debug('bulkUploadRec '+bulkUploadRec );
           errMsg = '';
           bulkUploadRec.Batch_Id__c = BC.getJobId();
           BulkUploadProcess bulkUploadProcess = new BulkUploadProcess(bulkUploadRec );
           try{
              errMsg = bulkUploadProcess.validateData();
              if(errMsg == ''){
                 errMsg = bulkUploadProcess.ProcessCreation();
              }
              system.debug('errMsg (try)'+errMsg );
              
           }catch(Exception e){
              errMsg = e.getMessage();
              errFlag = true;
              system.debug('errmsg(catch)'+errMsg );
           }
           if(errMsg != ''){
              bulkUploadRec.Errors__c = errMsg;
              // Getting list of Errorcounts
              errorList = errMsg.split(';');
              errorCnt = errorList.size() - 1;
              bulkUploadRec.Error_Count__c = errorCnt;
              bulkUploadErrList.add(bulkUploadRec);
           }else{
              bulkUploadSuccessList.add(bulkUploadRec);
           }
        }
          succCnt = bulkUploadSuccessList.size();
          failCnt = bulkUploadErrList.size();
    }
   
   /************************************************************************
   *Batch Finish Method  
   *************************************************************************/
    global void finish(Database.BatchableContext BC) {
        //Creating the batch log file
        Batch_Log__c batchLog = new Batch_Log__c();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        system.debug('BatchIdBclas' + a.Id);
        List<Batch_Log__c > batchLogList = [Select Name, JobID__c, Process_Type__c, Status__c, Total_Record_Count__c, Success_Record_Count__c, Failure_Record_Count__c from Batch_Log__c where JobID__c =:BC.getJobId()];
        batchLogList[0].Status__c = a.Status;
        batchLogList[0].Success_Record_Count__c = succCnt ;
        batchLogList[0].Failure_Record_Count__c = failCnt;
        Upsert batchLogList[0];
        //Updating Stage record with batch log Id
        List<Bulk_Upload__c> updatedBulkUpload = new List<Bulk_Upload__c>();
        if(failCnt > 0){
            for(Bulk_Upload__c tempBulkUpload: bulkUploadErrList ){
                tempBulkUpload.JobID__c = batchLogList[0].Id;
                updatedBulkUpload.add(tempBulkUpload);
            }
           upsert updatedBulkUpload;
        }
        if(succCnt > 0){
           delete bulkUploadSuccessList;
        }        
    }
}