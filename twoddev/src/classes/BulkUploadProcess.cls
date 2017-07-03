Public without sharing class BulkUploadProcess{

   //Variable initialize
   map<string,object> mapobj;
   Warranty_Registration__c WRC;
   Inventory__c Inv;
   Account Acc;
   public String Err;
   Id accountId;
   boolean isWRCreated;
   String regComments;
   String InstDate;
   Id WrId;
   String WRUsageType;
   String InventoryCustomer;
   Boolean isDeleted;
   Boolean preowned;
   Id inventoryId;
   String regType;
   String coverageEndDate;
   List<Inventory__c> invRec;
   Inventory__c invValue;
   Bulk_Upload__c bulkUploadData;
   
   //Constructor
   public BulkUploadProcess(Bulk_Upload__c bulkUploadRec){
      bulkUploadData = bulkUploadRec;
      system.debug('bulkUploadData '+bulkUploadData );
      mapobj = new map<string,object>();
      WRC = new Warranty_Registration__c();
      Inv = new Inventory__c();
      Acc = new Account();
      
      BulkUploadMapper bulkUploadMap = new BulkUploadMapper(bulkUploadData);
      mapobj = bulkUploadMap.getMapperObjects();
                                                                              
   }   
   
   //Data Validation for WR process
   Public string validateData()
   {
      err = '';
      invValue = null; 
      Acc = (Account)mapObj.get('AccountMapObj');
      Inv = (Inventory__c)mapObj.get('InventoryMapObj');
      WRC = (Warranty_Registration__c)mapObj.get('WRMapObj');
        
      List<Inventory__c> invRec = [Select id,Name,Model_Number__c,Account__c,Inventory__c.Type__c,Serial_Number__c,Units_Run__c,Stolen_inventory__c,Scrapped__c,Visual_Checklist_Completed__c from Inventory__c where Serial_Number__c =: Inv.Serial_Number__c];
        if(invRec.isEmpty())
        {
           err = Label.INVENTORY_NOT_FOUND+'; ';
           return err;
        }
        else
        {
         invValue = invRec[0];
         if(invValue.type__c == 'Retail')
         {
           err = Label.Warranty_Registration_Completed+'; ';
           return err;      
         }
         if(invValue.Stolen_inventory__c || invValue.Scrapped__c)
         {
           err = err+Label.Page_Blocker_Message+'; ';
         }
         if(!(invValue.Visual_Checklist_Completed__c))
         {
           err = err+Label.Visual_Checklist_Alert+'; ';
         }
         if(Inv.Install_Date__c == null)
         {
           err = err+Label.Purchase_Date_Warranty_Registration_Error+'; ';
         }
         if(Inv.Install_Date__c > Date.today())
         {
           err = err+Label.Purchase_Date_Exceed_Today_Date_Error+'; ';
         }
         if(Inv.Units_Run__c < 0)
         {
          err= err+Label.Units_Run_Negative+'; ';
         }
         if(Inv.Units_Run__c < invValue.Units_Run__c)
         {
          err = err+Label.Units_Run_Less_Than_Inventory+invValue.Units_Run__c+'; ';
         }
         // Getting Usage Type Picklist Values
         Set<String> usageTypePickListValues = new Set<String>();
         Schema.DescribeFieldResult fieldResult = Warranty_Registration__c.Usage_Type__c.getDescribe();
         List<Schema.PicklistEntry> pickListEntryValue = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry f : pickListEntryValue)
         {
          UsageTypePickListValues.add(f.getValue());
         }       
         if(!(usageTypePickListValues.contains(WRC.Usage_Type__c)))
         {
           err = err+Label.Invalid_Usage_Type+'; ';
         }
         if(Acc.Name == '' || Acc.Name == null)
         {
           err = err+Label.CustomerName_Mandatory+'; ';
         }
         if(Acc.Email__c == '' || Acc.Email__c == null)
         {
           err = err+Label.CustomerEmail_Mandatory+'; ';
         }
       }
      return Err;      
   }
   //Account creation
   //This code need to be changed based on the user selection
   //User can select either Account/WR
   Public void AccCreation(){
      system.debug('Emaildet'+acc.Email__c);
      List<Account> acctData = [select id from account where Email__c =: acc.Email__c]; 
      system.debug('query'+acctData);
      if(acctData.size()>0){
         accountId = acctData[0].id;
      }else{
         Upsert acc;
         accountId = acc.id;
      }
   }
   //Warranty registration
   Public string ProcessCreation(){
      err = '';
      try{
          AccCreation();
      }catch(exception e){
          err = e.getmessage();
          return err;
      }
      system.debug('Start');
      
      //Params for WR creation
      isWRCreated = false;
      regComments = WRC.Registration_Comments__c;            
      //InstDate = '10/03/2017'; 
      Integer month = Inv.Install_Date__c.Month();
      Integer day = Inv.Install_Date__c.Day();
      Integer year = Inv.Install_Date__c.Year();
      InstDate = day+'/'+month+'/'+year; 
      WrId = null;
      WRUsageType = WRC.Usage_Type__c;
      system.debug('End'+invValue);
      InventoryCustomer = accountId;
      
      //Params for policy pick
      isDeleted = false;
      preowned = false;   
      system.debug('Invdata'+invValue.id);  
      inventoryId = invValue.id;
      regType = 'Standard';   

      //Param for inventory, WR, WC creation
      //coverageEndDate = '17/03/2017';
      coverageEndDate = null;   

      //Temp WR creation
      List<WarrantyRegistrationController.Response> rsWr;
      try{
         rsWr = WarrantyRegistrationController.createWarrantyRegistration(isWRCreated,invValue, regComments, InstDate, WRId, WRUsageType, InventoryCustomer);
         system.debug('BalaWRResponse '+ rsWr);
      }catch(exception e){
         err = e.getMessage();
         return err;
      }
      system.debug('BalaWRResponse '+ rsWr);
      system.debug('BalaWRResponse '+ rsWr[0].error);
      //Checking the response after temp WR creation
      if(rsWr[0].error == null){
         //Fetching the policy
         List<WarrantyRegistrationController.Response> rsPolicyList;
         try{
            Warranty_Registration__c newWr = rsWr[0].WarrantyRegistration;
            rsPolicyList =  WarrantyRegistrationController.fetchPolicyDefinitionsMngr(isDeleted, newWr, preowned, inventoryId, regType);
            system.debug('polResponse '+ rsPolicyList);
            
         }catch(exception e){
            err = e.getMessage();
            return err;            
         }
         
         List<PolicyDefinitionWrapper> PolicyDefinitionList = new List<PolicyDefinitionWrapper>();
         //Checking error message after policy pickup
         for(WarrantyRegistrationController.Response wrRes : rsPolicyList){
            if(wrRes.error != null){
               err = wrRes.error;
               return err;
            }
            for(PolicyDefinitionWrapper pdw : wrRes.PolicyDefWrapper){
               
               PolicyDefinitionList.add(PDW);
            }
            
         }   
         if(PolicyDefinitionList==null || PolicyDefinitionList.isEmpty()){
            err = Label.No_Policies_With_Inventory;
            return err;
         }
         system.debug('PolicyDefinitionList' +PolicyDefinitionList);
         //Creating WC, WR and updating Inventory
         List<WarrantyRegistrationController.Response> rsinverr;
         WrId = null;
         try{
            String PolicyDefinitionListt = JSON.serialize(PolicyDefinitionList);
            rsinverr = WarrantyRegistrationController.registerInventory(PolicyDefinitionListt,regComments,invValue, InstDate, WRID, WRUsageType, InventoryCustomer,coverageEndDate);
         }catch(exception e){
            err = e.getMessage();
            return err;               
         }
      }else{
         err = rsWr[0].error;
         return err;
      }      
      return err;
   }
}