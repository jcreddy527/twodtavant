/**********************************************************************
 Name:  PaymentDefinitionTrigger 
 Copyright © 2014  FirstSolar
 ==============================================================
===============================================================
Purpose: 
Trigger for all the events on Payment_Definitions__c object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        21/10/2014      INITIAL DEVELOPMENT            
   2.0 -    Neethu         31/10/2014      Added the framework  
***********************************************************************/
trigger PaymentDefinitionTrigger on Payment_Definitions__c (before insert, before update, before delete,
                                         after insert, after update, after delete, after undelete){
    // Get all 'CustomSettings' records
        WOD__c enablePaymentDefinitionTrigger = WOD__c.getValues('Enable PaymentDefinitionTrigger');   
        if(enablePaymentDefinitionTrigger.isTriggered__c == true){                                  
    new PaymentDefinitionTriggerHandler().executeProcess();
    }
                                                           
}