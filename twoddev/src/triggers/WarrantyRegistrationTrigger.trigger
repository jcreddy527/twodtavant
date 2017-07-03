/**********************************************************************
 Name:  WarrantyRegistrationTrigger 
 Copyright © 2015  FirstSolar
 ==============================================================
===============================================================
Purpose: 
Trigger for all the events on Warranty Register object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        14/09/2015      INITIAL DEVELOPMENT            
***********************************************************************/
trigger WarrantyRegistrationTrigger on Warranty_Registration__c (before insert, before update, before delete,
                                         after insert, after update, after delete, after undelete) {
    // Get all 'CustomSettings' records
        WOD__c enableWarrantyRegistrationTrigger = WOD__c.getValues('Enable WarrantyRegistrationTrigger');  
        if(enableWarrantyRegistrationTrigger.isTriggered__c == true){
           new WarrantyRegistrationTriggerHandler().executeProcess();
    }
}