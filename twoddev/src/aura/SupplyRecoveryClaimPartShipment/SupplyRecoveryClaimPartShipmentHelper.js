({
	SUPPLY_RECOVERY_SHIPPMENT_QUERY : 'SELECT Id, Name, CreatedDate,Type_Of_Shipment__c,isShipped__c,Carrier__c, Return_Location__c, Return_Location__r.Name, Tracking_Number__c, (SELECT Id, Name, Supply_Recovery_Claim_Line_Item__c,Supply_Recovery_Claim_Line_Item__r.Name, Shipment__c, Quantity__c FROM Recovery_Claim_Shipments__r) FROM Shipment_Detail__c WHERE Id = ',
	//SUPPLY_RECOVERY_CLAIM_LINE_ITEM : 'select id,Name,Is_Part_Return_Required__c,Part_Return_Location__c,Part_Type__c,Pending_Shipment_Quantity__c,Quantity__c,Supplier_Product__c,Supplier_Recovery_Claim__r.name,Supplier_Recovery_Claim__c,Warranty_Product__c, Warranty_Product__r.name from Supply_Recovery_Claim_Line_Items__c where Pending_Shipment_Quantity__c > 0 and Part_Return_Location__c != Null',
	SUPPLY_RECOVERY_CLAIM_LINE_ITEM : 'select id,Name,Removed_Claim_Part__c,Removed_Claim_Part__r.Is_Approved__c,Removed_Claim_Part__r.Payment_Condition__c,Is_Part_Return_Required__c,Part_Return_Location_Warehouse__c,Part_Return_Location_Warehouse__r.Name,Part_Type__c,Pending_Shipment_Quantity__c,Quantity__c,Supplier_Product__c,Supplier_Recovery_Claim__r.name,Supplier_Recovery_Claim__c,Warranty_Product__c, Warranty_Product__r.name from Supply_Recovery_Claim_Line_Items__c where Pending_Shipment_Quantity__c > 0  and Part_Return_Location_Warehouse__c = ',
	readSupplyRecoveryClaimLineItem : function(component,event) {
		
        component.set("v.PartType",'Removed');
    	var query1 = this.SUPPLY_RECOVERY_CLAIM_LINE_ITEM + "'" + component.get("v.shipmentDetail.Return_Location__c") + "'";
        query1 = query1 + ' and  Part_Type__c = ' + "'" + component.get("v.PartType") + "'";
	
        var actionReadClaim = component.get("c.ReadSObjects");
		actionReadClaim.setParams({
			query : query1
		});
		actionReadClaim.setCallback(this, function(response) {
			if(response.getState() == 'SUCCESS')
			{
				console.log(response.getReturnValue().sObjList);	
                component.set("v.supplyRecoveryClaimLineItemArr",response.getReturnValue().sObjList);
			}
            var spinnermp = component.find('SpinnerId');
            $A.util.removeClass(spinnermp,'slds-show');
            $A.util.addClass(spinnermp,'slds-hide');
		}
	);
		$A.enqueueAction(actionReadClaim);
	},
    
    DeleteSelRecordFunc : function(component,event,helper){

        if(typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0){
           var currentRecordNumClick = event.target.parentElement.tabIndex; 
        }else{
           var currentRecordNumClick = event.target.parentNode.parentElement.tabIndex;
        }

   	    var allRecords1		=	component.get('v.supplyRecoveryClaimShipmentArr');
        var ShipmentRecord	= allRecords1[currentRecordNumClick];
        allRecords1.splice(currentRecordNumClick,1);
        component.set('v.supplyRecoveryClaimShipmentArr',allRecords1);

				helper.deleteRaw(component, event, ShipmentRecord, function(returnedValues) {
				var myEvent = $A.get("e.c:DeleteRecordfromShipmentEvent");
				myEvent.setParams({
							ShipmentRecord: ShipmentRecord
				});
				myEvent.fire();
		} );
        
    },
    
    DonotShowShipmentpage : function(component,RecordId){
        var ReturnUrl = component.get("v.baseURL") + '/' + RecordId;
        window.location.href = ReturnUrl;     
	}
 
})