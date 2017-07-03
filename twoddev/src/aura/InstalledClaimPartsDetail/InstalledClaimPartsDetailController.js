({
	myAction : function(component, event, helper) {
		
	},
    
    onSelectChange : function(component, event, helper) {
		var selected = component.find("levels").get("v.value");
    },
    
    saveClaimLaborRecords :function(component, event, helper) {
        var claimLaborRecord = component.get("v.claimLaborDetail_SObj") ; 
        console.log(claimLaborRecord.Warranty_Product__c);
        if(claimLaborRecord.Warranty_Product__c != null && claimLaborRecord.Warranty_Product__c != '' && typeof claimLaborRecord.Warranty_Product__c != "undefined"){
            component.set('v.claimLaborDetail_SObj.Warranty_Product__r.Id',claimLaborRecord.Warranty_Product__c);
        }
        
        var sObjectList = component.get("v.sObjectList") ;  
        sObjectList.push(claimLaborRecord);
        console.log(claimLaborRecord );
        console.log(sObjectList[0] );
        console.log(claimLaborRecord.Warranty_Product__c);
        
        var actionMethod = "c.InsertSObjects";
        if(claimLaborRecord.Id){
            actionMethod = "c.UpdateSObjects";
        }
        var action = component.get(actionMethod);
        action.setParams({
            inputSObjectList : sObjectList
        });
        action.setCallback(this, function(response) {
        	console.log(response.getState());
            var state = response.getState();
            if(state == "ERROR"){
                var errors = response.getError();
                if (errors) {
					if (errors[0] && errors[0].message) {
						component.set('v.errors' ,errors);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            } else if(state == "SUCCESS"){
                var saveResult = response.getReturnValue()[0];
                console.log(':::::: Save Result');
                console.log(saveResult);
                if(saveResult.success == Boolean(1)){
                    component.set("v.claimLaborDetail_SObj.Id",saveResult.sObjID);
                    if(claimLaborRecord.Warranty_Product__c != null) {
                    }
                    if(claimLaborRecord.Inventory__c != null) {
                    }
                    
                    component.set("v.sObjectList","");
                    console.log(component.get("v.claimLaborDetail_SObj"));
                    component.set('v.isEdit', Boolean(0));
                } else {
                    component.set("v.errors",saveResult.errorCodeList);
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    editClaimLaborRecords :function(component, event, helper) {
        //event.preventDefault();
        component.set('v.inventoryName',component.get("v.claimLaborDetail_SObj.Inventory__r.Name"));
        var inventoryId		= component.get('v.claimLaborDetail_SObj.Inventory__c');
        
        var warrantyId		= component.get('v.claimLaborDetail_SObj.Warranty_Product__c');
        
        if(inventoryId != null && inventoryId != '' && typeof inventoryId != "undefined") {
            component.set('v.inventoryName',component.get("v.claimLaborDetail_SObj.Inventory__r.Name"));
            //component.set('v.claimLaborDetail_SObj.Warranty_Product__r.Name',null);
            //component.set('v.claimLaborDetail_SObj.Warranty_Product__r.Id',null);
            component.set('v.isDisabledWarranty',true);
        } 
        else
        if(warrantyId != null && warrantyId != '' && typeof warrantyId != "undefined") {
            component.set('v.warrantyProductName',component.get("v.claimLaborDetail_SObj.Warranty_Product__r.Name"));
            //component.set('v.claimLaborDetail_SObj.Inventory__r.Name',null);
            //component.set('v.claimLaborDetail_SObj.Inventory__r.Id',null);
            component.set('v.isDisabledInventory',true);
        }else {
            component.set('v.isDisabledInventory',false);
            component.set('v.isDisabledWarranty',false);
        }
        component.set('v.isEdit', Boolean(1));
        
        
    },
    cancelClaimLaborRecords :function(component, event, helper) {
        component.set('v.isEdit', Boolean(0));
        var claimLaborRecord = component.get("v.claimLaborDetail_SObj") ; 
        if(!(claimLaborRecord.Id)){
            component.set('v.isDelete', Boolean(1));
        }
    },
	deleteClaimLaborRecords :function(component, event, helper) {
        
        var claimLaborRecord = component.get("v.claimLaborDetail_SObj") ; 
        var sObjectList = component.get("v.sObjectList") ; 
        sObjectList.push(claimLaborRecord);
        var action = component.get("c.DeleteSObjects");
        action.setParams({
            inputSObjectList : sObjectList
        });
        
         action.setCallback(this, function(response) {
        	console.log(response.getState());
            var state = response.getState();
            if(state == "ERROR"){
                var errors = response.getError();
                if (errors) {
					if (errors[0] && errors[0].message) {
						component.set('v.errors' ,errors[0].message );
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            } else if(state == "SUCCESS"){
                var saveResult = response.getReturnValue()[0];
                if(saveResult.success == Boolean(1)){
                    component.set("v.claimLaborDetail_SObj.Id",saveResult.sObjID)
                    component.set('v.isDelete', Boolean(1));
                } else {
                    component.set("v.errors",saveResult.errorCodeList);
                }
            }
            component.set('v.isEdit', Boolean(0));
        });
        $A.enqueueAction(action);
    },
    
    // Disable the warranty product field
    disableWarrantyProduct : function(component, event, helper) {
        //event.preventDefault();
        console.log('::: disable warranty product');
        //var disableWarranty = component.find("warrantyId");
        var inventoryId		= component.get('v.claimLaborDetail_SObj.Inventory__c');
        component.set('v.claimLaborDetail_SObj.Inventory__c',inventoryId);
        console.log(component.get('v.inventoryName'));
        console.log(':::: inventory Id:'+inventoryId);
        if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined") {
            component.set('v.claimLaborDetail_SObj.Inventory__c',null);
            component.set('v.isDisabledWarranty',false);
            component.set('v.isDisabledInventory',false);
            
        } else {
            component.set('v.claimLaborDetail_SObj.Warranty_Product__c',null);
            component.set('v.isDisabledWarranty',true);
            console.log('::: inventory inside to disable');
        }
    },
    
    // Disable the inventory field
    disableInventory : function(component, event, helper) {
        //event.preventDefault();
        var warrantyId		= component.get('v.claimLaborDetail_SObj.Warranty_Product__c');
        console.log(':::: Warranty Id:'+warrantyId);
        console.log(':::: Warranty Product name:'+component.get('v.warrantyProductName'));
        if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined") {
            component.set('v.isDisabledInventory',false);
            component.set('v.isDisabledWarranty',false);
        } else {
            component.set('v.claimLaborDetail_SObj.Inventory__c',null);
            component.set('v.isDisabledInventory',true);
        }
    }
})