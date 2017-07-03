/**********************************************************************
 Name:  WarrantyRegistrationTriggerHandler
 Copyright © 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Handler class for the WarrantyRegistrationTrigger                                                     
-------                                                             
===============================================================
without sharing explanation:
This is class used to check warranty registration data. 
Admin user only have full access on warranty registration object. 
Dealer/Internal users don’t have permissions for all fields on warranty registration object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        15/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
global with sharing class WarrantyRegistrationTriggerHandler extends TriggerHandler{

    //Constructor
    global WarrantyRegistrationTriggerHandler(){
        system.debug('WarrantyRegistrationTriggerHandler Constructor ');  
    }

    
    /*******************************************************************
    Purpose: Calls restrictWRDeletion method before deleting
             any record                                                
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    @TestVisible protected override void beforeDelete(){
        system.debug('Entering beforeDelete: ');
            restrictWRDeletion(Trigger.old);
    }
    
    /*******************************************************************
    Purpose: shows error if any record with status 'Registered' will be 
              tried to be deleted                                      
    Parameters: List of Warranty_Registration__c
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global void restrictWRDeletion(List<Warranty_Registration__c> WRList){  
        if(this.isEnabled('restrictWRDeletion')){
           
           if(WRList != null && WRList.size() > 0)
           {
               for(Warranty_Registration__c tmpWR : WRList)
               {
                   system.debug('tmpWR.Status__c is--->'+tmpWR.Status__c);
                   if(tmpWR.Status__c == System.Label.Registered)
                   {
                       tmpWR.addError(System.Label.WRDeleteMsg);
                   }
               }
           }
               
        }
    }
}