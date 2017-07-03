/**********************************************************************
 Name:  ValidateClaimCtrl
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: To validate a Claim and displaying all eligible Policy Definitions
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Susmita        04/11/2014      INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ValidateClaimCtrl{
    
    global list<Policy_Definition__c> PolicyDefinitionList{get;set;}
    global Claim__c CurrentClaim;
    ClaimManager objClaimManager ;
    
    global ValidateClaimCtrl(Apexpages.StandardController stdcon)
    {
        this.CurrentClaim = (Claim__c)stdcon.getRecord();
        objClaimManager = new ClaimManager();
        PolicyDefinitionList = objClaimManager.findPolicyDefinitionList(CurrentClaim);
    }
    
}