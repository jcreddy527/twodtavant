/**********************************************************************
 Name:  PaymentDefinitionItemsTrigger 
 Copyright © 2014  FirstSolar
 ==============================================================
===============================================================
Purpose: 
Trigger for before Rule Criteria Object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita          25/11/2014      INITIAL DEVELOPMENT            
   
***********************************************************************/

trigger WarrantyRuleCriteriaTrigger on Warranty_Rule_Criteria__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // Get all 'CustomSettings' records
        WOD__c enableWarrantyRuleCriteriaTrigger = WOD__c.getValues('Enable WarrantyRuleCriteriaTrigger');
       //calls the trigger handler class to initiate the process 
        if(enableWarrantyRuleCriteriaTrigger.isTriggered__c == true){
            new WarrantyRuleCriteriaTriggerHandler().executeProcess();
       }

}