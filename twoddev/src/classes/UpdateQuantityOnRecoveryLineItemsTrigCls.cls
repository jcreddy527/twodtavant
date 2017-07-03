/*
without sharing explanation:
This is class used to check recovery claim shipment and supply recovery line items data. 
Admin user only have full access recovery claim shipment and supply recovery line items objects. 
Dealer/Internal users don’t have permissions for all fields on recovery claim shipment and supply recovery line items objects.
*/
global without sharing class UpdateQuantityOnRecoveryLineItemsTrigCls {


global void UpdateQuantityOnRecoveryLineItemsTrigMethod(list<Recovery_Claim_Shipment__c> RecClaimShipList){
list<Supply_Recovery_Claim_Line_Items__c> updatedclaimLineitemsList = new list<Supply_Recovery_Claim_Line_Items__c>();
Set<Id> distinctLineitems = new Set<Id>();
Set<Id> distinctShipmentIdSet = new Set<Id>();
Map<Id,Shipment_Detail__c> shipmentById = new Map<Id,Shipment_Detail__c>();
Map<Id,Supply_Recovery_Claim_Line_Items__c> SupplyRecClmLineItemById = new Map<Id,Supply_Recovery_Claim_Line_Items__c>();
    
            
            for(Recovery_Claim_Shipment__c tempshiprecordsold : RecClaimShipList){
                distinctLineitems.add(tempshiprecordsold.Supply_Recovery_Claim_Line_Item__c);
                distinctShipmentIdSet.add(tempshiprecordsold.Shipment__c);
            }
            if(distinctLineitems.size() > 0){           
            SupplyRecClmLineItemById = new Map<Id,Supply_Recovery_Claim_Line_Items__c>([select id,Quantity__c,Pending_Shipment_Quantity__c from Supply_Recovery_Claim_Line_Items__c where id =:distinctLineitems ]);
            }
         
            If(distinctShipmentIdSet.size() > 0){
                shipmentById = new Map<Id,Shipment_Detail__c>([SELECT Id, Name, isShipped__c FROM Shipment_Detail__c WHERE Id =:distinctShipmentIdSet ]);
            }
            
         
            
            for(Recovery_Claim_Shipment__c tempshiprecords : RecClaimShipList){
            
            if((shipmentById.get(tempshiprecords.Shipment__c)).isShipped__c){
                tempshiprecords.addError(System.Label.ErrorMessageOnUpdateQuantShipmentTrigger); 
            } else{
                    Supply_Recovery_Claim_Line_Items__c tempClaimLineitemRecord = new Supply_Recovery_Claim_Line_Items__c();
                    
                    
                        tempClaimLineitemRecord.id =   tempshiprecords.Supply_Recovery_Claim_Line_Item__c;
                    
                    
                    if(SupplyRecClmLineItemById.containskey(tempshiprecords.Supply_Recovery_Claim_Line_Item__c) == True &&  Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isCreateable() && Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isUpdateable()){
                         if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isCreateable() && Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isUpdateable() ){
                             tempClaimLineitemRecord.Pending_Shipment_Quantity__c = SupplyRecClmLineItemById.get(tempshiprecords.Supply_Recovery_Claim_Line_Item__c).Pending_Shipment_Quantity__c + tempshiprecords.Quantity__c;
                         }
                         updatedclaimLineitemsList.add(tempClaimLineitemRecord);
                    } 
                    
                
              }
            }
            if(updatedclaimLineitemsList.size() > 0)
            {   
                if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.isCreateable() && Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.isUpdateable()) {
                    upsert updatedclaimLineitemsList;
                }
                
            }
    
    
  
    
}
}