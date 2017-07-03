/**********************************************************************
 Name:  FindClaimPolicyService
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used for updating the Policy Definition 
         for the claim
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class FindClaimPolicyService
{

    /*******************************************************************
    Purpose:  to update the Policy Definition for the claim                                                   
    Parameters: N/A
    Returns: none
    Throws [Exceptions]:                                                      
    ********************************************************************/
    
    @InvocableMethod
    global static void findClaimPolicy(List<Claim__c> ObjClaimList){
        list<Claim__c> ClmUpdateList = new list<Claim__c>();
        list<Policy_Definition__c> PolicyDefList = new list<Policy_Definition__c>();
        ClaimManager objClmManager = new ClaimManager();
        
        try
        {
            for(Claim__c tmpClm : ObjClaimList)
            {
                PolicyDefList = objClmManager.findPolicyDefinitionList(tmpClm);
                Claim__c crntClm = new Claim__c(Id=tmpClm.Id);
                if (Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isUpdateable()){
                    system.debug('PolicyDefList.size() is----->>>'+PolicyDefList.size());
                    crntClm.Applicable_Policy__c = PolicyDefList.size() > 0 ? PolicyDefList[0].Id :null;
                }
                ClmUpdateList.add(crntClm);
            }
            
            if(ClmUpdateList != null && ClmUpdateList.size() > 0)
            {
                //updates the ratedetails for every claim
                if(CrudUtil.isClaimUpdatable()){
                    Database.SaveResult[] claimUpdateList = database.update(ClmUpdateList ,false);
                
                    for(Database.SaveResult sr : claimUpdateList){
                        if (sr.isSuccess()){
                            System.debug('Successfully updated claim Policy: ' + sr.getId());
                        }else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred while updating claim Policy.'+err);                 
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
        catch(exception ex)
        {
            system.debug('exception is --->>>'+ex);
        }
        
        
    }
}