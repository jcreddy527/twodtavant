/**********************************************************************
 Name:  ClaimTotalAmountService
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used for calculating the total amount of the claims as per applicable cost categories.
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Arun Kumar Anala        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ClaimTotalAmountLogicService {
    global static string NameSpace = SystemUtils.getNameSpace();
    @InvocableMethod
    global static List<Claim__c> CalculateTotalClaimCost(list<InputWrapper> InputWrapperList)
    {
        Set <Id> payDefIdSet = new Set <Id> ();
        Map <Id,Payment_Definitions__c> IdByPayDefs = new Map <Id,Payment_Definitions__c>();
        List<Claim__c> updatedClaims = new List<Claim__c>();
        for(InputWrapper iw : InputWrapperList)
           {
               payDefIdSet.add(iw.ApplicablePaymentDefinition);
           }
           
        if(payDefIdSet!=null && payDefIdSet.size()>0){
           IdByPayDefs = new Map<Id,Payment_Definitions__c>([SELECT Id,(SELECT Id, Payment_Definition__c, Payment_Configuration__r.Claim_Field_Name__c,Payment_Configuration__r.Name FROM Payment_Definition_Items__r) FROM  Payment_Definitions__c WHERE Id IN :payDefIdset]);
        }
        
        for(InputWrapper iw : InputWrapperList)
           {
                Claim__c claim = iw.claim.Clone(true,false);
                //Claim__c claim = iw.claim;
                Set <string> applicablePaymentConfigurations = new Set<string>(); 
                Set <string> apcNames = new Set<string>(); 
                for(Payment_Definition_Items__c pdi : IdByPayDefs.get(claim.Applicable_Payment_Definition__c).Payment_Definition_Items__r)
                {
                    if(Schema.sObjectType.Payment_Definition_Items__c.fields.Payment_Configuration__c.isAccessible() && Schema.sObjectType.Payment_Configuration__c.fields.Claim_Field_Name__c.isAccessible())
                    {
                        applicablePaymentConfigurations.add(pdi.Payment_Configuration__r.Claim_Field_Name__c);
                        apcNames.add(pdi.Payment_Configuration__r.Name);
                    }
                }
                System.Debug('Inside Total Amount Service CULPRIT : ' + applicablePaymentConfigurations);
                double totalClaimCost = 0.00;
            
                for(String apc : applicablePaymentConfigurations)
                {
                    totalClaimCost += DOUBLE.VALUEOF(claim.get(NameSpace+'Final_' + apc +'_Cost__c'));
                }
                
                //if (Schema.sObjectType.Claim__c.fields.Final_Claim_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Final_Claim_Cost__c.isUpdateable()){
                  Claim.put(NameSpace+'Final_Claim_Cost__c', totalClaimCost );
                //}
                if (Schema.sObjectType.Claim__c.fields.Applicable_Payment_Configurations__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Applicable_Payment_Configurations__c.isUpdateable()){
                  //Claim.Applicable_Cost_Categories__c = paymentDefinition.Cost_Category__c; 
                  Claim.Applicable_Payment_Configurations__c = String.Join(new List<String>(apcNames),'\n'); 
                }
                updatedClaims.add(claim);
            }
            
        return updatedClaims;
    }
    
    global class InputWrapper{

        @InvocableVariable(required=true)
        global id ApplicablePaymentDefinition;
        
        @InvocableVariable(required=true)
        global Claim__c claim;
                    
    } 
    
}