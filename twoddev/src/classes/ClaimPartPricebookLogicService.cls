/**********************************************************************
 Name:  ClaimAmountModifierService
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used for calculating the Amount Modifiers for the claim payment.
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Arun Kumar Anala        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ClaimPartPricebookLogicService {

    @InvocableMethod
    global static list<Id> SetPartPriceBook(list<ClaimPartWrapper> ClaimPartWrapperList)
    {
        set<Id> productIdSet = new set<Id>();
        set<Id> countryIdSet = new set<Id>();
        list<Id> claimPartPriceBookIds = new list<Id>();
        Boolean foundFlag = false;       
        Id defaultPriceBook = WOD__c.getInstance('Default Price').Trigger_Value__c;
        Map<Id,Warranty_Product__c> warrantyProductByIdMap = new Map<Id,Warranty_Product__c>();
        
        for(ClaimPartWrapper cpw : ClaimPartWrapperList){
              countryIdSet.add(cpw.claimPart.Dealer_Country__c);
              productIdSet.add(cpw.warrantyProductId);
        }
        
        if(countryIdSet!=null && countryIdSet.size()>0 && productIdSet!=null && productIdSet.size()>0){
            warrantyProductByIdMap = new Map<Id,Warranty_Product__c>([SELECT Id, (SELECT Id, Country__c, Valid_From__c, Valid_Until__c FROM Warranty_Product_Pricebooks__r WHERE Country__c in :countryIdSet order by Valid_From__c asc) FROM Warranty_Product__c WHERE Id in :productIdSet]);
        }
        
        for(ClaimPartWrapper cpw : ClaimPartWrapperList){
            foundFlag = false;
            for( Warranty_Product_Pricebook__c wpp : warrantyProductByIdMap.get(cpw.warrantyProductId).Warranty_Product_Pricebooks__r){
            	if(Schema.sObjectType.Warranty_Product_Pricebook__c.fields.Valid_From__c.isAccessible() &&
            	   Schema.sObjectType.Warranty_Product_Pricebook__c.fields.Valid_Until__c.isAccessible()
            	)
            	{
	                if(cpw.claimRepairDate >= wpp.Valid_From__c && cpw.claimRepairDate <= wpp.Valid_Until__c)
	                {
	                    claimPartPriceBookIds.add(wpp.Id);
	                    foundFlag = true;
	                    break;
	                }
            	}
            }
            if(foundFlag == false)
            {
                claimPartPriceBookIds.add(defaultPriceBook);
            }
        }
        
        return claimPartPriceBookIds;
    }
    
    /*******************************************************************
    Purpose: Wrapper class that get the values from the process builder                                 
    ********************************************************************/
    global class ClaimPartWrapper{
    
        @InvocableVariable(required=true)
        global id warrantyProductId;
        
        @InvocableVariable(required=true)
        global date claimRepairDate;
        
        @InvocableVariable(required=true)
        global Claim_Part__c claimPart;
                    
    }  

}