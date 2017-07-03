/**********************************************************************
 Name:  PaymentDefinitionItemsTrigger 
 Copyright © 2014  FirstSolar
 ==============================================================
===============================================================
Purpose: 
Trigger for before insert/update events on Warranty_Rule_Association__c object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Bhanu          25/11/2014      INITIAL DEVELOPMENT            
   
***********************************************************************/

trigger WarrantyRuleAssociationTrigger on Warranty_Rule_Association__c (before insert, before update) {
    //calls the trigger handler class to initiate the process 
     // Get all 'CustomSettings' records
        WOD__c enableWarrantyRuleAssociationTrigger = WOD__c.getValues('Enable WarrantyRuleAssociationTrigger');
         if(enableWarrantyRuleAssociationTrigger.isTriggered__c == true){
            new WarrantyRuleAssociationTriggerHandler().executeProcess();
        }

}