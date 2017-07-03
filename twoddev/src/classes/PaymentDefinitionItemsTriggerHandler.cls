/**********************************************************************
 Name:  PaymentDITriggerHandler()
 Copyright © 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Handler class for the PaymentDefinitionItemsTrigger that redirects the flow to the
right trigger events                                                      
-------                                                             
===============================================================
without sharing explanation: This is class used to check payment definition item data. 
Payment definition Item data is master data. Admin user only have full access on payment definition object. 
Dealer/Internal users don’t have permissions for all fields on payment definition object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Susmita        22/10/2014      INITIAL DEVELOPMENT            
   2.0 -    Neethu         31/10/2014      Added the framework
***********************************************************************/
global without sharing class PaymentDefinitionItemsTriggerHandler extends TriggerHandler{
    //Constructor
    global PaymentDefinitionItemsTriggerHandler(){
        system.debug('PaymentDefinitionItemsTriggerHandler Constructor ');   
    }
    
    /*******************************************************************
    Purpose: Restricts the user from deleting mandatory payment definition
             items                                                       
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    protected override void beforeDelete() {
        system.debug('Entering beforeDelete: ');
        mandatoryCheck(trigger.old);
            
    }
    
    global void mandatoryCheck(List<Payment_Definition_Items__c> paymentDefItemList){
        if(this.isEnabled('mandatoryCheck')){
            for(Payment_Definition_Items__c objPaymentDefinitionItem : paymentDefItemList){
                            if(objPaymentDefinitionItem.Is_Mandatory__c == true){            
                            objPaymentDefinitionItem.addError(System.Label.PaymentDefinitionItemDeletionMessage);                
                        
                    }
            }
        
        }
    }
}