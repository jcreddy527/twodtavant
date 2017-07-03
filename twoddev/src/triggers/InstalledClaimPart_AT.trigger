trigger InstalledClaimPart_AT on Claim_Part__c (before insert) {
  // Get all 'CustomSettings' records
        WOD__c enableInstalledClaimPart_AT = WOD__c.getValues('Enable InstalledClaimPart_AT');
        if(enableInstalledClaimPart_AT.isTriggered__c == true){
    //List<Claim_Part__c> listClaimParts  
    system.debug('::::::: claim parts:'+Trigger.new);
    if(Trigger.isBefore && Trigger.isInsert){
        for(Claim_Part__c objClaimPart : Trigger.new){
            /*
            if(objClaimPart.Inventory__c != null && objClaimPart.Inventory__c != ''){
                //objClaimPart.RecordTypeId = Schema.SObjectType.Claim_Part__c.getRecordTypeInfosByName().get('Serialized Part').getRecordTypeId();
            }else if(objClaimPart.Warranty_Product__c != null && objClaimPart.Warranty_Product__c != ''){
                objClaimPart.RecordTypeId = Schema.SObjectType.Claim_Part__c.getRecordTypeInfosByName().get('Non-Serialized Part').getRecordTypeId();
            } else {
                objClaimPart.RecordTypeId = Schema.SObjectType.Claim_Part__c.getRecordTypeInfosByName().get('Miscellaneous Part').getRecordTypeId();
            }
            */
        }
    }
    }
}