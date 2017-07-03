/**********************************************************************
 Name:  WarrantyRegistrationCtrl
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose:  To create Warranty Registration and Warranty Coverages from Inventory
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Abhishek        17/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class WarrantyRegistrationCtrl {
    
    global Inventory__c CurrentInventory {get;set;}// not
    global list<PolicyDefinitionWrapper> PolicyDefinitionWrapperList {get;set;}
    global string CurrentInventoryDetails {get;set;}
    global boolean isSearched {get;set;}
    global Inventory__c Inventory{get;set;} 
    global InventoryManager inventoryManagerObj;
    global Account CustomerInfoDetail {get;set;}
    Apexpages.StandardController stdcon;
    boolean isWRCreated;
    
    global WarrantyRegistrationCtrl(Apexpages.StandardController stdcon)
    {
        this.CurrentInventory = (Inventory__c)stdcon.getRecord();
        Inventory = [select id,name,Install_Date__c,Customer__c,Warranty_End_Date__c,Item__c,Units_Run__c from Inventory__c where id =: CurrentInventory.id];
        PolicyDefinitionWrapperList = new list<PolicyDefinitionWrapper>();
        CurrentInventoryDetails = '';
        isSearched = false;
        isWRCreated = false;
        inventoryManagerObj = new InventoryManager();
        getCustomerInfo();
    }
    
    /*******************************************************************
    PURPOSE:   To get all Policy Definitions                                                   
    PARAMETERS: N/A
    RETURNS: N/A
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global void fetchPolicyDefinitions() {
    
        //Field validation Added
        if(CurrentInventory.Units_Run__c == null || CurrentInventory.Units_Run__c <0)
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, Label.Negative_Units_Usage));
        }
     
        isSearched = true;
        system.debug('Aman is here'+CurrentInventory.Install_Date__c);
        isWRCreated = inventoryManagerObj.createWarrantyRegistration(isWRCreated,CurrentInventory,CurrentInventoryDetails);
        PolicyDefinitionWrapperList = inventoryManagerObj.fetchPolicyDefinitionsMngr();
        system.debug('Aman is here');
        system.debug(PolicyDefinitionWrapperList);
        
     }
    
  
    /*******************************************************************
    PURPOSE:   To update Warranty Registration and Insert Warranty Coverage Records based on the user's selection                                                   
    PARAMETERS: N/A
    RETURNS: Pagereference
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    
     global pageReference registerInventory()    {
       
       if(CurrentInventory.Customer__c != Null){  
            try{
                if (Schema.sObjectType.Inventory__c.fields.Type__c.isCreateable() && Schema.sObjectType.Inventory__c.fields.Type__c.isUpdateable() ){
                    CurrentInventory.Type__c='Retail';
                }
                if(Schema.sObjectType.Inventory__c.isCreateable() && Schema.sObjectType.Inventory__c.isUpdateable()){    
                    upsert CurrentInventory;
                }
              
            }
             catch(DMLException e){
             System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        
        return inventoryManagerObj.registerInventoryMngr(PolicyDefinitionWrapperList,CurrentInventoryDetails,CurrentInventory);
         
    }
    
    /*******************************************************************
    PURPOSE:   To cancel registration process                                                   
    PARAMETERS: N/A
    RETURNS: Pagereference
    THROWS [EXCEPTIONS]: N/A  
    ********************************************************************/
    global pageReference cancelRegistration()
    {
        return inventoryManagerObj.cancel(CurrentInventory,true);
    }
    
    /*******************************************************************
    PURPOSE:   To do registration without warranty                                                   
    PARAMETERS: N/A
    RETURNS: Pagereference
    THROWS [EXCEPTIONS]: N/A  
    *******************************************************************
    global pageReference registerWOWarranty()
    {
        return inventoryManagerObj.registerWOWarranty(CurrentInventory,CurrentInventoryDetails);
    }*/
    
    global void getCustomerInfo(){
        system.debug('-->'+Inventory);
        system.debug('-->'+Inventory.Customer__c);
    if(Inventory.Customer__c != null ){
        system.debug('-->Inside If');    
        CustomerInfoDetail= [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode from Account where id =: Inventory.Customer__c ];
        CurrentInventory.Customer__c = CustomerInfoDetail.Id;   
    
    }
    
  }
     
}