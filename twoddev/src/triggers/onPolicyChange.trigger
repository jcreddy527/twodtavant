/**************************************************************
 Name:  onPolicyChange 
 Copyright © 2016  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Trigger for all the events on Claim__c object and Updating same on Claim_Financial__c child object                                                        
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION    AUTHOR              DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -   Chethan Sharma L    8/10/2016       INITIAL DEVELOPMENT            
    
**************************************************************************************************/

trigger onPolicyChange on Claim__c (after update, after insert, before delete) {
  
        // Get all 'CustomSettings' records
        WOD__c enablePolicyConfig = WOD__c.getValues('Enable OnPolicyChange');
        
        //ClaimFinancialController claimFinController = new ClaimFinancialController();
        ClaimFinancialController claimFinController = ClaimFinancialController.getInstance();
        
        // Check whether the trigger is enabled
        if(enablePolicyConfig.isTriggered__c == true){
            
            if(ClaimFinancialControllerHelper.firstRun == true){ //this line added by siva
                 // Insert/Update (Upsert) Claim Financial 
                if(Trigger.Isafter){
                    if(Trigger.isUpdate || Trigger.isInsert ){
                       claimFinController.claimFinanceOnUpsert(Trigger.new);
                    }
                }
            
                // Delete Claim Financial
                if(Trigger.isBefore && Trigger.isDelete){
                        claimFinController.claimFinancialsDelete(Trigger.OldMap.keyset());
                }    
            }
           
        }
        
        // Below lines is added by shambhavi
        if(Trigger.isUpdate ){
           // system.debug('trigger is updated================');
            for (Claim__c clm: Trigger.new){
                   if(Trigger.oldMap.get(clm.Id).Date_of_Failure__c != Trigger.newMap.get(clm.Id).Date_of_Failure__c){ 
                       // system.debug('Date of failure got change====================================');                
                        DateOfFailureChangesOnClaim_Class  dtfailChange=new DateOfFailureChangesOnClaim_Class();
                        dtfailChange.checkRemovedPart(clm);
                      
                   }
             }
       }
   
}