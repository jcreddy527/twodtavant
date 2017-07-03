/**********************************************************************
 Name:  RemovedClaimPartTriggerHandler()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Handler class for the RemovedClaimPartTrigger that redirects the flow to the
right trigger events                                                      
-------                                                             
===============================================================
without sharing explanation:This is class used to check remove part data. 
Admin user only have full access on remove part object. Dealer/Internal users don’t have permissions for all fields on remove part object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Neethu        10/9/2015      INITIAL DEVELOPMENT  
***********************************************************************/
global without sharing class RemovedClaimPartTriggerHandler extends TriggerHandler{
    //Constructor
    global RemovedClaimPartTriggerHandler(){
        system.debug('RemovedClaimPartTriggerHandlerConstructor ');   
    }
    
    /*******************************************************************
    Purpose: Update the pending part for approval on claim via class                                                       
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void afterDelete() {
        system.debug('Entering beforeDelete: ');        
        if(Trigger.isDelete)
            updatePendingPart(trigger.old);            
            
    }
    
    global void updatePendingPart(list<removed_claim_part__c> removedPartList){
    list<UpdateClaimPartsPendingService.ClaimPartPendingWrapper> claimPartPendingWrpList = new list<UpdateClaimPartsPendingService.ClaimPartPendingWrapper>();
        for(Removed_Claim_Part__c  removedPart: removedPartList){
            UpdateClaimPartsPendingService.ClaimPartPendingWrapper wrp = new UpdateClaimPartsPendingService.ClaimPartPendingWrapper();
            wrp.targetId = removedPart.Claim__c;
            wrp.isChanged  = true;
            claimPartPendingWrpList.add(wrp);
        }
        UpdateClaimPartsPendingService.updatePendingParts(claimPartPendingWrpList);
    }
    
}