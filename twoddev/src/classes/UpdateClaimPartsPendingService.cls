/**********************************************************************
 Name:  UpdateClaimPartsPendingService
 Copyright ? 2015  Tavant Technology In
 ==============================================================
===============================================================
Purpose: Class used for updating the Claim Part Pending Service info in Claim
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Neethu        09/09/2015     INITIAL DEVELOPMENT            
***********************************************************************/
global with sharing class UpdateClaimPartsPendingService{
    
    /*******************************************************************
    Purpose: Method which accepts wrapper for updating the 
             Claim Part Pending Approval in Claim    
    ********************************************************************/
    @InvocableMethod
    global static void updatePendingParts(list<ClaimPartPendingWrapper> claimPartPendingWrpList){
        system.debug('##'+claimPartPendingWrpList);
        set<id> claimIdSet = new set<id>();
        list<claim__c> claimList = new list<claim__c>();
        if(claimPartPendingWrpList!=null && claimPartPendingWrpList.size()>0){
            for(ClaimPartPendingWrapper cpWrapper : claimPartPendingWrpList){
            system.debug('$$$'+cpWrapper );
                if(cpWrapper.isChanged){
                  if(!String.isBlank(cpWrapper.targetId)){
                     claimIdSet.add(cpWrapper.targetId);
                   }
                }
            }
        }
        if(claimIdSet!=null && claimIdSet.size()>0){
            claimList = [select id,In_Approval_Process__c,Claim_Parts_Pending_Approval__c,
                            (select id,Is_Approved__c from Removed_Claim_Parts__r where Is_Approved__c=false AND Payment_Condition__c IN ('Pay After Inspection','Pay After Return')) 
                            from claim__c where id in:claimIdSet and in_approval_process__c =false];
            if(claimList!=null && claimList.size()>0){
                for(Claim__c clmRecord: claimList){
                    if (Schema.sObjectType.Claim__c.fields.Claim_Parts_Pending_Approval__c.isCreateable() && 
                    Schema.sObjectType.Claim__c.fields.Claim_Parts_Pending_Approval__c.isUpdateable())
                    clmRecord.Claim_Parts_Pending_Approval__c = clmRecord.Removed_Claim_Parts__r.size();
                }
                
                //database.update(claimList,false);
                if(CrudUtil.isClaimUpdatable()){
                   Database.SaveResult[] claimUpdateList = database.update(claimList,false);
                
                    for(Database.SaveResult sr : claimUpdateList){
                        if (sr.isSuccess()){
                            System.debug('Successfully updated claim part Pending Approval: ' + sr.getId());
                        }else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred while updating claim part pending approval.'+err);                 
                            }
                        }
                    }
               }
               else
               {
                    System.debug('-----INSUFFICIENT_ACCESS---');
               }
            }
        }
    
    }        
    
     global class ClaimPartPendingWrapper{
        @InvocableVariable(required=false)
        global Id targetId;
        //global string targetId;
        
        @InvocableVariable(required=false)
        global Boolean isChanged;
    }
}