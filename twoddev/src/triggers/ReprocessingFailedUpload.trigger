//Trigger to upload the failed records from Staging object(after fixing the errors) to WR.
  trigger ReprocessingFailedUpload on  Bulk_Upload__c(before update,after update) {
  //variable initialization
   String ErrMessage = '';
   Integer errorCnt = 0;
   String[] errorList;
   List<Bulk_Upload__c> bulkUploadErrRec = new list<Bulk_Upload__c>();
   List<Bulk_Upload__c> bulkUploadSuccessRec = new list<Bulk_Upload__c>();
   
   for(Bulk_Upload__c bulkUploadRec : Trigger.new){ 
      BulkUploadProcess bulkUploadProcess = new BulkUploadProcess(bulkUploadRec);
     
      if(Trigger.isBefore && !(String.isEmpty(bulkUploadRec.Errors__c))){
          ErrMessage = bulkUploadProcess.validateData();
          if(ErrMessage == '')
          {                  
            ErrMessage = bulkUploadProcess.ProcessCreation();
          }
          bulkUploadRec.Errors__c = ErrMessage;
          errorList = ErrMessage.split(';');
          errorCnt = errorList.size() - 1;
          bulkUploadRec.Error_Count__c = errorCnt;
      }                                  
      if(Trigger.isAfter && String.isEmpty(bulkUploadRec.Errors__c)){
           Bulk_Upload__c deleteSuccessObj = new Bulk_Upload__c ();
           deleteSuccessObj.Id = bulkUploadRec.Id;
           bulkUploadSuccessRec.add(deleteSuccessObj);
      }       
   }
   if(bulkUploadSuccessRec.size()>0)
   {
     delete bulkUploadSuccessRec;
   } 
}