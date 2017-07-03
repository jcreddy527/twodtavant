/**********************************************************************
 Name:  RemovedClaimPartTrigger 
 Copyright © 2014  Tavant
 ==============================================================
===============================================================
Purpose: 
Trigger for all the events on Removed_Claim_Part__c object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        22/10/2014      INITIAL DEVELOPMENT            
   2.0 -    Neethu           31/10/2014    Added the framework  
***********************************************************************/
trigger RemovedClaimPartTrigger on Removed_Claim_Part__c ( after delete){
    //calls the trigger handler class to initiate the process 
    // Get all 'CustomSettings' records
        WOD__c enableRemovedClaimPartTrigger = WOD__c.getValues('Enable RemovedClaimPartTrigger');   
        if(enableRemovedClaimPartTrigger.isTriggered__c == true){
         new RemovedClaimPartTriggerHandler().executeProcess();
    }
}