trigger MasterRecoveryClaimShipmentTrigger on Recovery_Claim_Shipment__c (before insert, after insert,before update, after update,before delete, after delete) {
// Get all 'CustomSettings' records
        WOD__c enableMasterRecoveryClaim = WOD__c.getValues('Enable MasterRecoveryClaim');
if(enableMasterRecoveryClaim.isTriggered__c == true){
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                // Call class logic here!
                } 
                if (Trigger.isUpdate) {
                // Call class logic here!
                    
                }
                if (Trigger.isDelete) {
                    UpdateQuantityOnRecoveryLineItemsTrigCls Classmethod = new UpdateQuantityOnRecoveryLineItemsTrigCls();
                    Classmethod.UpdateQuantityOnRecoveryLineItemsTrigMethod(trigger.Old);
                }
            }

  }
}