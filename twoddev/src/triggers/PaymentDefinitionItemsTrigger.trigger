/**********************************************************************
 Name:  PaymentDefinitionItemsTrigger 
 Copyright © 2014  FirstSolar
 ==============================================================
===============================================================
Purpose: 
Trigger for all the events on Payment_Definition_Items__c object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        22/10/2014      INITIAL DEVELOPMENT            
   2.0 -    Neethu           31/10/2014    Added the framework  
***********************************************************************/
trigger PaymentDefinitionItemsTrigger on Payment_Definition_Items__c (before insert, before update, before delete,
                                         after insert, after update, after delete, after undelete){
      // Get all 'CustomSettings' records
        WOD__c enablePaymentDefinitionItemsTrigger = WOD__c.getValues('Enable PaymentDefinitionItemsTrigger');                                   
     if(enablePaymentDefinitionItemsTrigger.isTriggered__c == true){                                    
    //calls the trigger handler class to initiate the process 
    new PaymentDefinitionItemsTriggerHandler().executeProcess();
    }
}