/**********************************************************************
Name:  twod_ManualRGACntrl 
 Copyright � 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose:  For manually processing PRC on removed parts on the claim.
                                                      
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                 FEATURES/CSR/TTP
1.0 -    AMAN SAWHNEY      12/27/2016      INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ManualRGACntrl {
    
    @AuraEnabled
    global static String getInitialData(String claimId) {
        
        String returnableJSON = '{}';
        
        MainWrapper mainWrapper = new MainWrapper();
        Schema.DescribeFieldResult fieldResult = Removed_Claim_Part__c.Payment_Condition__c.getDescribe();
        List<Object> paymentConditionList = fieldResult.picklistValues ;
        mainWrapper.claim = [select Id,Name,Claim_Record_Type__c,Approved_Claim_Cost__c,Final_Claim_Cost__c,Causal_Part_Number__r.Name,
                             (select Id,Name,Inventory__r.Name,Inventory__r.Item__r.Description__c,Warranty_Product__r.Name,
                              Warranty_Product__r.Description__c,Remaining_Quantity__c from Removed_Claim_Parts__r where
                              Remaining_Quantity__c>0 AND Return_Location__c=null) from Claim__c where Id =:claimId ];
        
        mainWrapper.paymentConditionListJSON = JSON.serialize(paymentConditionList);
        
        returnableJSON = JSON.serialize(mainWrapper);
        
        return returnableJSON;
    }
    
    global class MainWrapper{
        
        @AuraEnabled
        Claim__c claim{get;set;}
        
        @AuraEnabled
        String paymentConditionListJSON {get;set;}
        
        
    }
}