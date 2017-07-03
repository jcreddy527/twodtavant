public without sharing class ProcessBulkUpload{
   
   public boolean value {get; set;}
   public list<AsyncApexJob> asyncApec {get; set;}
   public string test {get;set;}
   PUblic list<Bulk_Upload__c> bulkUpload {get; set;}
   public integer totRec {get;set;}
   public integer FailRec {get;set;}
   public integer succRec {get;set;}
   ID batchId;
   
   
   public ProcessBulkUpload(){
      
         value = false;
      
      
   }
   
   Public void StartBatchProcess() {
         
        //string query = 'select Errors__c from Bulk_Upload__c where Errors__c = \'\'';
        List<Bulk_Upload__c > buList = [select Errors__c from Bulk_Upload__c ];
        totRec = buList.size();
        string query = 'select Row_Detail__c, Data_JSON__c, Process_Type__c, Errors__c from Bulk_Upload__c';
        BulkUploadBtchClss bUpload = new BulkUploadBtchClss('WR', query);
        batchId = Database.executeBatch(bUpload,1 ); 
        GetStatus();

   }
   
   public void GetStatus(){
        value = true;
        asyncApec  = [SELECT NumberOfErrors,Status,TotalJobItems, JobItemsProcessed FROM AsyncApexJob where id =: batchId] ;   
        System.debug('batchId'+batchId);
        test ='batchId'+asyncApec;
        bulkUpload = [select Batch_Id__c, Row_Detail__c, Errors__c from Bulk_Upload__c ];
        failRec = bulkUpload .size();
        succRec = totRec - FailRec;      
      
   }
   
   /* Testing for WR creation done so commented
   
   public void createRecords(){
      
      Inventory__c CurrentInventory = new Inventory__c();

      //hardcoding data for WR creation

      //Params for WR creation

      CurrentInventory.id = 'a052800000J86Rl';
      CurrentInventory.Serial_Number__c = '986557';
      CurrentInventory.name = 'UA InventoryTest1';
      CurrentInventory.Model_Number__c = 'Asus Zenfone';
      CurrentInventory.Account__c = '00128000012gJ3L';
      boolean isWRCreated = false;
      String CurrentInventoryDetails = 'WR creation through prog';
      String InstDate = '07/03/2017';
      Id WRId = null;
      String WRUsageType = 'Commercial';
      String InventoryCustomer = '00128000012gJ3L';
      
      
      //Params for policy pick
      Boolean isDeleted = false;
      Boolean preowned = false;
      Id inventoryId = 'a052800000J86Rl';
      String regType = 'Standard';      
      
      //Param for inventory, WR, WC creation
      String coverageEndDate = '10/04/2017';



      List<WarrantyRegistrationController.Response> rsWr = WarrantyRegistrationController.createWarrantyRegistration(isWRCreated,CurrentInventory, CurrentInventoryDetails, InstDate, WRId, WRUsageType, InventoryCustomer);

      //wrc.createWarrantyRegistration(isWRCreated,CurrentInventory, CurrentInventoryDetails, InstDate, WRId, WRUsageType, InventoryCustomer);
      
      system.debug('BalaWRResponse '+ rsWr);
      
      system.debug('rsWr.WarrantyRegistration'+rsWr[0].WarrantyRegistration);
      Warranty_Registration__c newWrList = rsWr[0].WarrantyRegistration;
      system.debug('balanewWrList :'+ newWrList);
      
      newWrList.Account__c = '00128000012gJ3L';



      List<WarrantyRegistrationController.Response> rsPolicyList =  WarrantyRegistrationController.fetchPolicyDefinitionsMngr(isDeleted, newWrList, preowned, inventoryId, regType);
      //wrc.fetchPolicyDefinitionsMngr(isDeleted, newWrList[0], preowned, inventoryId, regType);
      system.debug('polResponse '+ rsPolicyList);
      List<PolicyDefinitionWrapper> PolicyDefinitionList = new List<PolicyDefinitionWrapper>();
      for(WarrantyRegistrationController.Response wrRes : rsPolicyList){
          
          for(PolicyDefinitionWrapper pdw : wrRes.PolicyDefWrapper){
             
             PolicyDefinitionList.add(PDW);
          }
         
      }
      //list<TurnoverTarget__c> li_TurnoverTargetstoUpdate = (list<TurnoverTarget__c>) JSON.deserialize(JSONString, list<TurnoverTarget__c>.class);
      
      system.debug('balaPolicyDefinitionList'+ PolicyDefinitionList);
      
      String PolicyDefinitionListt = JSON.serialize(PolicyDefinitionList);
      
      system.debug('balaPolicyDefinitionListt' +PolicyDefinitionListt);


      WRID = null;
      List<WarrantyRegistrationController.Response> rsinverr = WarrantyRegistrationController.registerInventory(PolicyDefinitionListt,CurrentInventoryDetails,CurrentInventory, InstDate, WRID, WRUsageType, InventoryCustomer,coverageEndDate);

      //wrc.registerInventory(PolicyDefinitionList,CurrentInventoryDetails,CurrentInventory, InstDate, WRID, WRUsageType, InventoryCustomer,coverageEndDate);
      system.debug('balarsinverr'+rsinverr);      
      
      
   }
   */ 
   //Testing for batch flow

   
   
}