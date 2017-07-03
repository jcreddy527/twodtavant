/**********************************************************************
 Name:  ImplementsInventoryWarrantyRegistration
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
Class is used to invoke the warranty registration controller.
-------                                                             
===============================================================
without sharing explanation: This class is used to create warranty registration for implements/Attachments records. 
In start method, we will query required inventory fields data. Internal/dealer users don’t have access all fields in inventory object. 
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          10/18/2016     INITIAL DEVELOPMENT            
***********************************************************************/
Global without sharing class ImplementsInventoryWarrantyRegistration implements Database.Batchable<sObject>{
    
     global static string NameSpace;
  static{
    NameSpace = SystemUtils.getNameSpace();
    system.debug('---NameSpace-'+NameSpace);
  } 
    
    //variable initialization
    global List<Id> inventoryIds;
    string query;
    private static final string invType = 'Stock';
    
    //constructor declaration
    global ImplementsInventoryWarrantyRegistration (List<Id> invIds){
        inventoryIds = new List<Id>();
        inventoryIds = invIds;      
    }
    
    
    
    
    /************************************************************************
    *Batch Start Method  
    *Query the implement inventory record".
    *************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'select id,'+NameSpace+'Account__c,'+NameSpace+'Customer__c,'+NameSpace+'Install_Date__c,'+NameSpace+'Inventory__r.'+NameSpace+'Install_Date__c from '+NameSpace+'Inventory__c where '+NameSpace+'Inventory__c IN:inventoryIds And '+NameSpace+'Type__c =:invType ';       
        return Database.getQueryLocator(query);
    }
    
     
    /*************************************************************************
    Batch Execute Method.
    Process the batch of records to invoke warranty registration controller. 
    **************************************************************************/
    global void execute(Database.BatchableContext BC, List<Inventory__c> scope) {
        system.debug('the scope is'+scope);
        try{
            //call the warranty registration controller.
            for(Inventory__c inv: scope){
                Integer policySelcted = 0;
                if(inv.Inventory__r.Install_Date__c!=null && Schema.sObjectType.Inventory__c.fields.Install_Date__c.isCreateable() && Schema.sObjectType.Inventory__c.fields.Install_Date__c.isUpdateable()){
                   inv.Install_Date__c = inv.Inventory__r.Install_Date__c;
                }
                else{
                    if(Schema.sObjectType.Inventory__c.fields.Install_Date__c.isCreateable() && Schema.sObjectType.Inventory__c.fields.Install_Date__c.isUpdateable()){
                        inv.Install_Date__c = date.today();
                    }
                } 
                if(Schema.sObjectType.Inventory__c.fields.Customer__c.isCreateable()){                           
                    inv.Customer__c = inv.Account__c;
                }
                ApexPages.StandardController sc = new ApexPages.StandardController(inv);
                WarrantyRegistrationCtrl  WRCtrl = new WarrantyRegistrationCtrl(sc);
                WRCtrl.fetchPolicyDefinitions();
                system.debug('the policy list'+WRCtrl.PolicyDefinitionWrapperList);
                if(WRCtrl.PolicyDefinitionWrapperList!=null && !WRCtrl.PolicyDefinitionWrapperList.isEmpty()){
                    for(PolicyDefinitionWrapper pDW : WRCtrl.PolicyDefinitionWrapperList){
                        if(pDW.selected == false){
                            policySelcted = policySelcted +1;
                        }
                    }
                    if(policySelcted == 0){  
                        WRCtrl.PolicyDefinitionWrapperList[0].selected  = true;
                    }  
                }
                                             
                WRCtrl.registerInventory();
            }
        }
        catch(Exception e){
            system.debug('The Exception is'+e);
        }
    }
    
    /************************************************************************
    *Batch Finish Method  
    *************************************************************************/
    global void finish(Database.BatchableContext BC) {
        
    }
}