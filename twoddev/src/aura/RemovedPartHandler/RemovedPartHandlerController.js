({
    doInit : function(component, event, helper) {
        
        console.log('::::: Removed parts recvord types:');
        console.log(component.get('v.removedPartRecordTypes'));
        
        for(var i=0; i<component.get('v.removedPartRecordTypes').length; i++){
            console.log(':::: inside for loop');
            console.log(component.get('v.removedPartRecordTypes')[i]);
            if(component.get('v.removedPartRecordTypes')[i].DeveloperName == 'Serialized_Part'){
                component.set('v.serializedRemovedPartId',component.get('v.removedPartRecordTypes')[i].Id);
            } else if(component.get('v.removedPartRecordTypes')[i].DeveloperName == 'Non_Serialized_Part'){
                component.set('v.nonSerializedRemovedPartId',component.get('v.removedPartRecordTypes')[i].Id);
            }
        }
        console.log('entered::')
        var allRemovedPartsQuary = 'Select Id,Warranty_Product__c,Warranty_Product__r.Id FROM Removed_Claim_Part__c WHERE Claim__c = ' + '\'' +component.get('v.claimId') + '\'';
        console.log('-----'+allRemovedPartsQuary)
        helper.readDom(component, event, allRemovedPartsQuary, "v.allRemovedParts", "v.dmlErrors", function(returnedValues) {
            console.log('allRemovedParts');
            console.log( component.get('v.allRemovedParts'))
            for(var i=0;i< component.get('v.allRemovedParts').length;i++){
                    console.log('Inside for');
                
                if(component.get('v.allRemovedParts')[i].Warranty_Product__c != null && typeof component.get('v.allRemovedParts')[i].Warranty_Product__c != 'undefined'){
                    console.log('Inside if');
                    helper.allRemovedPartsIds.push(component.get('v.allRemovedParts')[i].Warranty_Product__r.Id);
                }
            }
            console.log('helper.allRemovedPartsIds');
            console.log(helper.allRemovedPartsIds)
        });
        
        var action1 = component.get('c.getAllInventoryIds');
        action1.setParams({
            "claimId" : component.get('v.claimId')
        });
        action1.setCallback(this, function(response) {
            console.log('::::: Response value:'+response.getReturnValue());
            component.set('v.inventoriesToAvoid', response.getReturnValue());
            console.log(':::: Avoid ids from server call:'+component.get('v.inventoriesToAvoid'));
        });
        $A.enqueueAction(action1);
        
        console.log(':::::::: Removed parts record types:');
        console.log(component.get('v.serializedRemovedPartId'));
        console.log(component.get('v.nonSerializedRemovedPartId'));
        
        var partId	=	component.get('v.partId');
        if(partId != null && partId != '') {
            var queryString		=	'SELECT Id, Name, RecordType.Name, Inventory__c, Warranty_product__c, Inventory__r.Name, Warranty_Product__r.Name, Quantity__c, Price__c FROM Removed_Claim_Part__c WHERE id = ' + '\'' +partId + '\'';
            console.log('::: Query String:' +queryString);
            var action = component.get('c.findSObjectsBySOQL');
            action.setParams({
                "query" : queryString
            });
            action.setCallback(this, function(response) {
                console.log(':::: Response from server installed part handler:');
                console.log(response.getReturnValue());
                var recordValue	=	response.getReturnValue();
                component.set('v.installedPart', response.getReturnValue());
                var inventory	=	recordValue[0].Inventory__r.Name;
                var warrantyName=	recordValue[0].Warranty_Product__r.Name;
                component.set('v.inventoryName',inventory);
                component.set('v.warrantyProductName',warrantyName);
                console.log(':::: Inventory');
                console.log(':::: Warrantysss Product Name:'+warrantyName);
                console.log(inventory);
                console.log(component.get('v.installedPart'));
            });
            $A.enqueueAction(action);
        }
    },
    
    // To save the record
    saveRecord : function(component, event, helper) {
        event.preventDefault();
        var isNew		=	component.get('v.isNewRecord');
        var saveRecord	=	component.get('v.installedPart');
        saveRecord.Claim__c = component.get('v.claimId');
        console.log(':::: is new record:'+isNew);
        console.log('::::: save record value:');
        console.log(saveRecord);
        var hasErrors	=	'false';
        var errorCount = 0;
        // Quantity validation
        console.log(':::: Warranty Product Id:');
        console.log(component.get('v.warrantyProductId'));
        
        var invId 	=	component.get('v.inventoryId');
        var warrId 	=	component.get('v.warrantyProductId');
        console.log('::: inv id:'+invId);
        console.log('::: warr id:'+warrId);
        if((warrId == null || warrId == '' || typeof warrId == "undefined") && (invId == null || invId == '' || typeof invId == "undefined")){
            component.set("v.dmlErrors",": Please select either Inventory or Part Number");
            console.log('::::: product selection error');
            errorCount ++;
        }else{
            component.set("v.dmlErrors",null);
        }
        
        
        if(component.get('v.warrantyProductId') != null && component.get('v.warrantyProductId') != '' && typeof component.get('v.warrantyProductId') != "undefined"){
            var quantity 	= component.find("quantity");
            console.log(':::: entered inside');
            console.log(quantity);
            
            
            
            var amt 		= quantity.get("v.value");
            if(amt != null && amt != '' && typeof amt != "undefined"){
                if (isNaN(amt) || amt < 0){
                    errorCount ++;
                    quantity.set("v.errors", [{message:"Quantity should be a number with positive sign"}]);
                }
                else
                    if(amt % 1 != 0){
                        errorCount ++;
                        quantity.set("v.errors", [{message:"Quantity shouldn't have decimal places"}]);
                    }
                // Quantity Completed
            }
            if(amt == null || amt == '' || typeof amt == "undefined"){
                //if (isNaN(amt) || amt < 0){
                errorCount ++;
                quantity.set("v.errors", [{message:"Please enter Quantity value"}]);
                //}
                // Quantity Completed
            }
        }
        
        
        
        var inputCmp 					= 	component.find("warrantyProductId");
        var warrantyProductvalue 		= 	inputCmp.get("v.value");
        var isWarrantySave				=	component.get('v.isDisabledInventory');
        console.log(':::: warrantyProductvalue:'+warrantyProductvalue);
        console.log(':::: is warranty save:'+isWarrantySave);
        if (isWarrantySave) {
            if(warrantyProductvalue == null || warrantyProductvalue == '' || typeof warrantyProductvalue == "undefined"){
                hasErrors	=	'true';
                errorCount ++;
                component.set('v.warrantyProductError','Please enter Warranty value');
                //inputCmp.set("v.errors", [{message:"Please enter Warranty value"}]);
            } else {
                saveRecord.Warranty_Product__c = warrantyProductvalue;
                component.set('v.warrantyProductError','');
                hasErrors	=	'false';
                inputCmp.set("v.errors",null);
            }
        }
        console.log('::: warranty product value:');
        console.log(warrantyProductvalue);
        
        var inputInvValue				= 	component.find("inventoryId");
        var invIdvalue 					= 	inputInvValue.get("v.value");
        var isInvSave						=		component.get('v.isDisabledWarranty');
        console.log(':::: invIdvalue:'+invIdvalue);
        console.log(':::: isInvSave:'+isInvSave);
        if (isInvSave) {
            if(invIdvalue == null || invIdvalue == '' || typeof invIdvalue == "undefined"){
                hasErrors	=	'true';
                errorCount ++;
                component.set('v.inventoryError','Please enter an Inventory value');
                //inputInvValue.set("v.errors", [{message:"Please enter Inventory value"}]);
            }else {
                component.set('v.inventoryError','');
                //component.set('v.installedPart.Quantity__c',1);
                saveRecord.Inventory__c = invIdvalue;
                saveRecord.Quantity__c = 1;
                hasErrors	=	'false';
                inputInvValue.set("v.errors", null);
            }
        }
        
        console.log('::::: is inv save:'+isInvSave);
        console.log('::::: is isWarrantySave:'+isWarrantySave);
        if(!isInvSave && !isWarrantySave ) {
            hasErrors	=	'true';
            errorCount ++;
            inputInvValue.set("v.errors", [{message:"Please enter Inventory value"}]);
            inputCmp.set("v.errors", [{message:"Please enter Warranty value"}]);
        }
        
        if(isInvSave){
            var inventoryIds 	=	component.get('v.inventoriesToAvoid');
            var index 				=	inventoryIds.indexOf(component.get('v.inventoryId'));
            if(index < 0) {
                component.set("v.dmlErrors",null);
            } else {
                component.set("v.dmlErrors",": You can't use the already used Inventory");
                errorCount ++;
            }
        }
        
        console.log('helper.allRemovedPartsIds :: ');
        console.log(helper.allRemovedPartsIds);
        console.log(component.get('v.warrantyProductId'));
        if((helper.allRemovedPartsIds.indexOf(component.get('v.warrantyProductId')) >= 0)&&component.get('v.isNewRecord')){
            var dmlErrors = [];
            dmlErrors.push('Claim Part selected is already added');
            console.log(dmlErrors);
            component.set('v.dmlErrors',dmlErrors);
            errorCount ++;
        }else{
            component.set("v.dmlErrors",null);
        }
        
        
        console.log('::: inv value:');
        console.log(invIdvalue);
        console.log(':::: has errors:'+hasErrors);
        if(errorCount < 1) {
            console.log('::::: Entered inside of the execution');
            console.log(saveRecord);
            var listRecs	=	[];
            var recordtype='';
            if(isNew){
                if(saveRecord.Inventory__c != null && saveRecord.Inventory__c != '' && typeof saveRecord.Inventory__c != "undefined"){
                    saveRecord.RecordTypeId	=	component.get('v.serializedRemovedPartId');
                    recordtype=component.get('v.serializedRemovedPartId');
                    console.log('coming in   serialized part');
                    
                }else{
                    saveRecord.RecordTypeId	=	component.get('v.nonSerializedRemovedPartId');
                    recordtype=component.get('v.nonSerializedRemovedPartId');
                    console.log('coming in   non serialized part'+component.get('v.nonSerializedRemovedPartId'));
                }
            }
            listRecs.push(saveRecord);
            
            var action 	= 	component.get('c.UpdateSObjects');
            if(isNew) {
                action 	= 	component.get('c.InsertSObjectsForRemovedParts')
            }
            action.setParams({
                "inputSObjectList" : listRecs
            });
            
            
            console.log("invIdValue");
            console.log(invIdvalue);
            if(isNew){
                action.setParams({
                    "inputSObjectList" : listRecs,
                    "claimId" : component.get('v.claimId'),
                    "warrantyId" : component.get('v.warrantyProductId'),
                    "inventoryId" : invIdvalue,
                    "recordtype":recordtype
                });
            }
            
            console.log("is new-->"+isNew);
            action.setCallback(this, function(response) {
                console.log('::::: Respose value:');
                console.log(response.getReturnValue());
                console.log(':::: Status:'+response.getState());
                var state = response.getState();
                var dmlErrors = [];
                if(state === "ERROR"){
                    
                    console.log("Hey ya Error");
                    console.log(response.getErrors());
                    if (response.error[0].fieldErrors) {
                        for (var key in response.error[0].fieldErrors) {
                            console.log('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                            dmlErrors.push('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        }
                    }
                    
                } else if(state == "SUCCESS"){
                    
                    console.log("Hey ya success");
                    console.log(response.getReturnValue());
                    console.log(':::::: response return value::::');
                    console.log(response.getReturnValue());
                    component.set('v.installedPart',component.get('v.tempInstalledPart'));
                    component.set('v.isNewRecord',false);
                    if (response.getReturnValue()[0].errorCodeList) {
                        for  (var key in response.getReturnValue()[0].errorCodeList) {
                            console.log(response.getReturnValue()[0].errorCodeList[key]);
                            dmlErrors.push(response.getReturnValue()[0].errorCodeList[key]);
                        }
                    }
                    var saveResult = response.getReturnValue()[0];
                    if(saveResult.success == Boolean(1)){
                        component.set("v.claimLaborDetail_SObj.Id",saveResult.sObjID);
                        component.set("v.sObjectList","");
                        console.log(component.get("v.claimLaborDetail_SObj"));
                        component.set('v.isEdit', Boolean(0));
                    } else {
                        //
                    }
                    console.log(':::: updating the installed and removed parts');
                    var myEvent = $A.get("e.c:UpdateInstalledParts");
                    myEvent.setParams({
                    });
                    myEvent.fire();
                    
                    var myEvent = $A.get("e.c:ModalCloseEvent");
                    myEvent.setParams({
                        "isModalEnabled":false
                    });
                    myEvent.fire();
                    /*
												var myEvent2 = $A.get("e.c:DeselectPartIds");
												myEvent2.setParams({
												});
												myEvent2.fire();
												*/
                }
                component.set("v.dmlErrors",": "+dmlErrors);
                
            });
            $A.enqueueAction(action);
        }
        
    },
    
    // Disable the warranty product field
    disableWarrantyProduct : function(component, event, helper) {
        console.log('::: disable warranty product');
        //var disableWarranty = component.find("warrantyId");
        var inventoryId		= component.get('v.inventoryId');
        var isNew		= component.get('v.isNewRecord');
        if(isNew){
            
            console.log(':::: inventory Id:'+inventoryId);
            if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined") {
                component.set('v.isDisabledWarranty',false);
                component.set('v.isDisabledInventory',false);
            } else {
                component.set('v.isDisabledWarranty',true);
                component.set('v.installedPart.Warranty_Product__c',null);
            }
        } else {
            if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined") {
                component.set('v.isDisabledWarranty',true);
                component.set('v.isDisabledInventory',false);
            } else {
                component.set('v.isDisabledWarranty',true);
                component.set('v.installedPart.Warranty_Product__c',null);
            }
        }
        
        if(inventoryId != null){
            component.set('v.isWarrantySave',false);
            component.set('v.isInvSave',true);
        }
        if((component.get('v.warrantyProductId') == null || component.get('v.warrantyProductId') == '' ||  typeof	component.get('v.warrantyProductId') == "undefined") && (inventoryId == null || inventoryId == '')){
            component.set('v.isWarrantySave',false);
            component.set('v.isInvSave',false);
        }
        
        
    },
    
    // Disable the inventory field
    disableInventory : function(component, event, helper) {
        var isNew		= component.get('v.isNewRecord');
        var warrantyId		= component.get('v.warrantyProductId');
        if(isNew){
            console.log(':::: Warranty Product name:'+component.get('v.warrantyProductName'));
            if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined") {
                component.set('v.isDisabledInventory',false);
                component.set('v.isDisabledWarranty',false);
            } else {
                component.set('v.isDisabledInventory',true);
                component.set('v.installedPart.Inventory__c',null);
            }
        } else {
            
            console.log(':::: Warranty Product name:'+component.get('v.warrantyProductName'));
            if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined") {
                component.set('v.isDisabledInventory',true);
                component.set('v.isDisabledWarranty',false);
            } else {
                component.set('v.isDisabledInventory',true);
                component.set('v.installedPart.Inventory__c',null);
            }
        }
        
        if(warrantyId != null){
            component.set('v.isWarrantySave',true);
            component.set('v.isInvSave',false);
        }
        if((warrantyId == null || warrantyId == '' ) && (component.get('v.inventoryId') == null || component.get('v.inventoryId') == '' || typeof	component.get('v.inventoryId') == "undefined")){
            component.set('v.isWarrantySave',false);
            component.set('v.isInvSave',false);
        }
    },
    
    changeModalClose	: function(component, event, helper){
        event.preventDefault();
        var myEvent = $A.get("e.c:ModalCloseEvent");
        myEvent.setParams({
            "isModalEnabled":false
        });
        myEvent.fire();
    }
})