({
    RecordType_Query: 'Select id from RecordType  where Name = ',
    Shipment_Query: 'Select id,name,Return_Location__r.Name,Carrier__c,isShipped__c,Received__c,Receiver_Comments__c,Return_Location__c,Shipment_Date__c,Total_Items__c,Total_Items_Recovery_Claim__c,Tracking_Number__c,Type_Of_Shipment__c from Shipment_Detail__c where isShipped__c = false and Return_Location__c = ', 
    Recovery_Claim: 'Select id,name,Supplier_Contract__c,Status__c,Supplier_Contract__r.Part_Return_Location__c from Supplier_Recovery_Claim__c where id = ',
    NavigateToShipmentPage : function(component,ShipmentRecordId) {
        var ReturnUrl = component.get("v.baseURL") +   '/apex/RecoveryClaimShipmentVfpage?id=' + ShipmentRecordId;
        window.location.href = ReturnUrl;  
        console.log(ReturnUrl);
	},
    
    NavigateToRecoveryClaimPage : function(component,ShipmentRecordId) {
        var ReturnUrl = component.get("v.baseURL") +  '/' + ShipmentRecordId;
        window.location.href = ReturnUrl; 
    }
})