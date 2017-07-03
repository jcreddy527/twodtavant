/**********************************************************************
 Name:  InventoryChangeStockToRetail
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
Class is used to collect the inventory records when type change from stock
to retail.                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          10/18/2016     INITIAL DEVELOPMENT            
***********************************************************************/
Global class InventoryChangeStockToRetail{
    
    
    /***********************************************************
     * This method is used to collect all implements inventory 
       stock records 
       And 
       Call the batch class to create warranty registration for
       all implements inventory.
     * *********************************************************/
    @InvocableMethod
    global static void collectImplementsInventory(list<InventoryChangeRequest> InventoryChangeRequestWrpList){
        
        //variable intialization
        List<Id> inventoryIds = new List<Id>();
        List<Inventory__c> implementInvList = new List<Inventory__c>();
        
        try{
            if(InventoryChangeRequestWrpList!=null && !InventoryChangeRequestWrpList.isEmpty()){
                for(InventoryChangeRequest inventiryRequest:InventoryChangeRequestWrpList){
                    inventoryIds.add(inventiryRequest.inventoryId);
                }
                system.debug('The inventory Ids'+inventoryIds);
            }
            
            /*****************************************************
             * query custom settings data for inventory batch size
             * ***************************************************/                          
             WOD__c invBatchSize = WOD__c.getValues('InvBatchSize');           
             Integer invSize = Integer.valueOf(invBatchSize.Trigger_Value__c); 
             
            //call the batch class to pass parent inventory ids as a parameter
            if(inventoryIds!=null && !inventoryIds.isEmpty() && !system.isBatch()){
                ImplementsInventoryWarrantyRegistration  IWR = new ImplementsInventoryWarrantyRegistration(inventoryIds);
                Database.executeBatch(IWR,invSize );
            }           
           
        }
        catch(Exception e){
            system.debug('The exception is'+e);
        }
        
    }
    
    
    /***********************************************************
     * Define Requested parameters
     * *********************************************************/
    global class InventoryChangeRequest{
        @InvocableVariable(required=false)
        global Id inventoryId;
    }
}