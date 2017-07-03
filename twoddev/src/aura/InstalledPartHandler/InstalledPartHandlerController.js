({
	doInit : function(component, event, helper) {
        console.log('----------inside installed part handler------doinit--------');
        var claimId = component.get('v.claimId');
        var allInstalledPartsQuery = 'Select Id,Warranty_Product__c FROM Claim_Part__c WHERE Claim__c = ' + '\'' +claimId + '\'';
         helper.readDom(component, event, allInstalledPartsQuery, "v.allInstalledParts", "v.dmlErrors", function(returnedValues) {
             for(var i=0;i< component.get('v.allInstalledParts').length;i++){
                 if(component.get('v.allInstalledParts')[i].Warranty_Product__c != null && typeof component.get('v.allInstalledParts')[i].Warranty_Product__c != 'undefined'){
                     helper.allInstalledPartIds.push(component.get('v.allInstalledParts')[i].Warranty_Product__c);
                 }
             }
         });
        
        component.set('v.showSpinner',true);
		console.log(':::: All Record types for installedParts:');
		console.log(component.get('v.installedPartRecordTypes'));
		//component.set('v.context',$A.getContext().gg);
		console.log(':::: length:'+component.get('v.installedPartRecordTypes').length);
		for(var i=0; i<component.get('v.installedPartRecordTypes').length; i++){
			console.log(':::: inside for loop');
			console.log(component.get('v.installedPartRecordTypes')[i]);
			if(component.get('v.installedPartRecordTypes')[i].DeveloperName == 'Serialized_Part'){
					component.set('v.serializedPartId',component.get('v.installedPartRecordTypes')[i].Id);
			} else if(component.get('v.installedPartRecordTypes')[i].DeveloperName == 'Non_Serialized_Part'){
					component.set('v.nonSerializedPartId',component.get('v.installedPartRecordTypes')[i].Id);
			}
		}

		var action1 = component.get('c.getAllInventoryIds');
		action1.setParams({
				"claimId" : component.get('v.claimId')
		});
		action1.setCallback(this, function(response) {
				console.log('::::: Response value:'+response.getReturnValue());
				component.set('v.inventoriesToAvoid', response.getReturnValue());
				console.log(':::: Avoid ids from server call:'+component.get('v.inventoriesToAvoid'));
				component.set('v.showSpinner',false);
		});
		$A.enqueueAction(action1);


		for(var i=0; i<component.get('v.removedPartRecordTypes').length; i++){
			console.log(':::: inside for loop');
			console.log(component.get('v.removedPartRecordTypes')[i]);
			if(component.get('v.removedPartRecordTypes')[i].DeveloperName == 'Serialized_Part'){
					component.set('v.serializedRemovedPartId',component.get('v.removedPartRecordTypes')[i].Id);
			} else if(component.get('v.removedPartRecordTypes')[i].DeveloperName == 'Non_Serialized_Part'){
					component.set('v.nonSerializedRemovedPartId',component.get('v.removedPartRecordTypes')[i].Id);
			}
		}


		console.log('::::: Serailized part:'+component.get('v.serializedPartId'));
		console.log('::::: nonSerializedPartId :'+component.get('v.nonSerializedPartId'));
		console.log('::::: Serailized Removed part:'+component.get('v.serializedRemovedPartId'));
		console.log('::::: nonSerialized removed PartId :'+component.get('v.nonSerializedRemovedPartId'));
		var partId	=	component.get('v.partId');
        if(partId != null && partId != '') {
        	var queryString		=	'SELECT Id, Name,Invoice_Number__c,Invoice_Date__c, RecordType.Name, Inventory__c, Warranty_product__c, Inventory__r.Name, Warranty_Product__r.Name, Quantity__c, Price__c FROM Claim_Part__c WHERE id = ' + '\'' +partId + '\'';
        	console.log('::: Query String:' +queryString);
            var action = component.get('c.findSObjectsBySOQL');
            action.setParams({
                "query" : queryString
								//"invId" :
            });
            action.setCallback(this, function(response) {
                console.log(':::: Response from server installed part handler:');
                console.log(response.getReturnValue());
                var recordValue	=	response.getReturnValue();
                component.set('v.installedPart', response.getReturnValue());
                var inventory	=	recordValue[0].Inventory__r.Name;
                var warrantyName=	recordValue[0].Warranty_Product__r.Name;
                component.set('v.inventoryName',inventory);
                console.log("aman inventory name"+inventory);
                component.set('v.warrantyProductName',warrantyName);
                console.log(':::: Inventory');
                console.log(':::: Warrantysss Product Name:'+warrantyName);
                console.log(inventory);
                console.log(component.get('v.installedPart'));
                component.set('v.showSpinner',false);
            });
            $A.enqueueAction(action);
        }
				//component.set('v.showSpinner',false);
	},

    // To save the record
    saveRecord : function(component, event, helper) {
        console.log('-------inside save record installed part ----');
       
            component.set("v.dmlErrors",null);
            event.preventDefault();
				//component.set('v.showSpinner',true);
				/***********************************************************************
				// Code to get the related inventory records information
				var inventoryId	=	component.get('v.inventoryId');
				if(inventoryId != null && inventoryId != '' && typeof inventoryId != "undefined"){
						var action	=	component.get('c.getRelatedInventories');
						action.setParams({
								"selectedId" : inventoryId,
								"query" : queryString
						});
						action.setCallback(this, function(response) {
								console.log('::::: Inventories need to select for removed parts');
								console.log(response.getReturnValue());
								component.set('v.requiredInventories',response.getReturnValue());

								component.set('v.listIds',response.getReturnValue());
								console.log('::::: list ids for related inventories:'+response.getReturnValue());
						});
						$A.enqueueAction(action);
				}

				/************************************************************************/
        var removedPart	=	component.get('v.removedPart');
		console.log(':::::::: Removed part record:');
		console.log(removedPart);
        var isNew		=	component.get('v.isNewRecord');
        var saveRecord	=	component.get('v.installedPart');
        console.log(':::: claim record id:');
        console.log(component.get('v.claimId'));
        //saveRecord.Claim__c = component.get('v.claimId');
        console.log(':::: is new record:'+isNew);
        console.log('::::: save record value:');
        console.log(component.get('v.installedPart'));
        var hasErrors	=	'false';
				var errorCount = 0;
				//component.set("v.dmlErrors",dmlErrors);
				var warrantyProductIdVal	=	component.get('v.warrantyProductId');
				var inventoryIdVal	=	component.get('v.inventoryId');
				if((warrantyProductIdVal == null || warrantyProductIdVal == '' || typeof warrantyProductIdVal == "undefined") && (inventoryIdVal == null || inventoryIdVal == '' || typeof inventoryIdVal == "undefined")){
					component.set("v.dmlErrors",": Please select either Inventory or Part Number");
					console.log('::::: product selection error');
					errorCount ++;
					//component.set('v.showSpinner',false);
					return;
				}else{
					 component.set("v.dmlErrors",null);
				}


        var price 		= component.find("price");
        var amt 		= price.get("v.value");
				var regex  = /(?=.)^\$?(([1-9][0-9]{0,2}(,[0-9]{3})*)|0)?(\.[0-9]{1,2})?$/;
				if(amt != null && amt != '' && typeof amt != "undefined"){
					var ind = amt.toString().indexOf(',');
					if(ind > -1){
						 amt = amt.split(',').join('');
					}
				}
				//amt.replace(",", "");
				console.log(':::: final resultant value:'+amt);
				if(amt != null && amt != '' && typeof amt != "undefined"){
						if (isNaN(amt)){
								if (!regex.test(amt)){
										price.set("v.errors", [{message:"Price should be a number with positive sign"}]);
										hasErrors = true;
										errorCount ++;
								}else{
										price.set("v.errors", null);
								}
						}
				}
				var standardCost = component.get('v.costValue');
				console.log('::::: standardCost:'+standardCost);
				// v.installedPart.Price__c

				/*
				if( (standardCost == null || standardCost == '' || typeof standardCost == "undefined" || standardCost == 0) && (amt == null || amt == '' || typeof amt == "undefined") ){
						price.set("v.errors", [{message:"Custom Price is mandatory if Price is 0"}]);
						hasErrors = true;
						errorCount ++;
				}else{
						price.set("v.errors", null);
				}

				if( (standardCost != null && standardCost != '' && typeof standardCost != "undefined") && (amt == null || amt == '' || typeof amt == "undefined") ){
						component.set('v.installedPart.Price__c', standardCost);
				}
				*/
				var isWarrantySave				=	false;
				console.log('::: isWarrantySave:'+isWarrantySave);
				console.log('::::: at quantity checking');
				if(component.get('v.warrantyProductId') != null && component.get('v.warrantyProductId') != '' && typeof component.get('v.warrantyProductId') != "undefined"){
					isWarrantySave	=	true;
					var quantity 	= component.find("quantity");
					var val 		= quantity.get("v.value");
					if (isNaN(val) || val < 0){
							quantity.set("v.errors", [{message:"Quantity should be a number with positive sign"}]);
							hasErrors = true;
							errorCount ++;
					}else
					if(val % 1 != 0){
							errorCount ++;
							quantity.set("v.errors", [{message:"Quantity shouldn't have decimal places"}]);
					}else{
							quantity.set("v.errors", null);
					}
				}


				console.log('::::: at warranty Product checking');
        var inputCmp 					= 	component.find("warrantyProductId");
        var warrantyProductvalue 		= 	inputCmp.get("v.value");
				var isWarrantySave				=	component.get('v.isDisabledInventory');

				if(warrantyProductvalue == null || warrantyProductvalue == '' || typeof warrantyProductvalue == "undefined"){
						isWarrantySave = false;
				}

        if (isWarrantySave) {
					console.log('::::: inside of warranty Product checking');
            if(warrantyProductvalue == null || warrantyProductvalue == '' || typeof warrantyProductvalue == "undefined"){
                hasErrors	=	'true';
								errorCount ++;
								console.log(':::::::::: Displaying error message');
                component.set('v.warrantyError','Please enter Warranty value');
                //inputCmp.set("v.errors", [{message:""}]);
            } else {
                hasErrors	=	'false';
                component.set('v.installedPart.Warranty_Product__c',component.get('v.warrantyProductId'));
                saveRecord.Warranty_Product__c = component.get('v.warrantyProductId');
                component.set('v.warrantyError','');
                inputCmp.set("v.errors",null);
            }
        }
        console.log('::: warranty product value:');
        console.log(warrantyProductvalue);

        var inputInvValue				= 	component.find("inventoryId");
        var invIdvalue 					= 	inputInvValue.get("v.value");
				var isInvSave					=	component.get('v.isDisabledWarranty');
				console.log(':::::: input inv value:'+invIdvalue);
				if(invIdvalue == null || invIdvalue == '' || typeof invIdvalue == "undefined"){
						isInvSave = false;
				}
        if (isInvSave) {
						console.log('::::::: invIdvalue:'+invIdvalue);
            if(invIdvalue == null || invIdvalue == '' || typeof invIdvalue == "undefined"){
                hasErrors	=	'true';
								errorCount ++;
								console.log(':::::: dispalying inventory Error');
                component.set('v.inventoryError','Please enter Inventory value');
                inputInvValue.set("v.errors", [{message:"Please enter Inventory value"}]);
            }else {
                component.set('v.installedPart.Inventory__c',component.get('v.inventoryId'));
								component.set('v.installedPart.Quantity__c',1);
                saveRecord.Inventory__c = component.get('v.inventoryId');
                component.set('v.inventoryError','');
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
        }else{
						inputInvValue.set("v.errors", null);
						inputCmp.set("v.errors", null);
				}
        var insertRemovedPart	=	$A.get("$Label.c.Is_Removed_Part_Required");

        if(isNew){
            var inventoryIds 	=	component.get('v.inventoriesToAvoid');
            var index 				=	inventoryIds.indexOf(component.get('v.inventoryId'));
            if(index < 0) {
                component.set("v.dmlErrors",null);
            } else {
                component.set("v.dmlErrors",": You can't use the already used Inventory");
                errorCount ++;
            }
        }
        
        /**************************************************************************************/
        console.log('::::::: installedPart:');
        console.log(component.get('v.installedPart'));
        /**************************************************************************************/
        
        console.log('::: inv value:');
        console.log(invIdvalue);
        console.log(':::: as errors:'+hasErrors);
		console.log('::: Error count:'+errorCount);
        console.log(':::: Getting the claim record id:');
        console.log(component.get('v.claimId'));
        saveRecord.Claim__c = component.get('v.claimId');
        console.log(saveRecord.Claim__c);
        //saveRecord.Claim__c				=	removedPart.Claim__c;
        console.log(':::: Quantity value:');
		console.log(component.get('v.installedPart.Quantity__c'));
        saveRecord.Quantity__c 			= component.get('v.installedPart.Quantity__c');
        console.log(':::::::: cost value:');
        console.log(component.get('v.costValue'));
        console.log(component.get('v.installedPart.Price__c'));
        if(component.get('v.installedPart.Price__c') != null && component.get('v.installedPart.Price__c') && typeof component.get('v.installedPart.Price__c') != 'undefined'){
            saveRecord.Price__c	= component.get('v.installedPart.Price__c');
        }else{
        	saveRecord.Price__c 			= component.get('v.costValue');
        }
        /*if(component.get('v.installedPart.Custom_Part_Cost__c') != null && component.get('v.installedPart.Custom_Part_Cost__c') && typeof component.get('v.installedPart.Custom_Part_Cost__c') != 'undefined'){
            saveRecord.Custom_Part_Cost__c	= component.get('v.installedPart.Custom_Part_Cost__c');
        }else{
        	saveRecord.Custom_Part_Cost__c 			= 0;
        }*/
         // aman added
        saveRecord.Custom_Part_Cost__c	= component.get('v.installedPart.Price__c');
        saveRecord.Invoice_Number__c 	= component.get('v.installedPart.Invoice_Number__c');
        saveRecord.Invoice_Date__c		= component.get('v.installedPart.Invoice_Date__c');
        if(errorCount < 1) {
						//component.set('v.showSpinner',true);
            console.log('::::: Entered inside of the execution');
           var listRecs	=	[];
             
						console.log('::::: IS NEW:'+isNew);
            console.log('::::: IS saveRecord:'+saveRecord);
            console.log('::::: IS listRecs:'+listRecs);
            var action 	= 	component.get('c.UpdateSObjectRecords');
            
            if(isNew) {
                if(insertRemovedPart == 'TRUE'){
                    if(component.get('v.inventoryId') != null && component.get('v.inventoryId') != '' && typeof component.get('v.inventoryId') != "undefined"){
                         //removedPart.Inventory__c		=	saveRecord.Inventory__c;
												 console.log('::::::: Entered here::::::::::: for Inventory::::11111111');
                         removedPart.RecordTypeId		=	 component.get('v.serializedRemovedPartId');
                         saveRecord.RecordTypeId		=	 component.get('v.serializedPartId');
                    }
                    if(component.get('v.warrantyProductId') != null && component.get('v.warrantyProductId') != '' && typeof component.get('v.warrantyProductId') != "undefined"){
                        removedPart.Warranty_Product__c	=	saveRecord.Warranty_Product__c;
						console.log('::::::: Entered here::::::::::: for Inventory::::22222222');
                        removedPart.RecordTypeId		=	component.get('v.nonSerializedRemovedPartId');
                        saveRecord.RecordTypeId			=	component.get('v.nonSerializedPartId');
						console.log('::::: warranty product id:'+component.get('v.warrantyProductId'));
												//helper.updateValues(component, event);
                    }
                    removedPart.Name				=	'';
                    removedPart.Claim__c			=	saveRecord.Claim__c;
                    
                    //if(saveRecord.Quantity__c <)
                    console.log(':::: Save Record:');
                    console.log(saveRecord.Quantity__c);
                    removedPart.Quantity__c			=	component.get('v.installedPart.Quantity__c'); //saveRecord.Quantity__c;
                    
                    if(saveRecord.Inventory__c == null || saveRecord.Inventory__c == '' || typeof saveRecord.Inventory__c == "undefined"){
                        console.log('::::: claimID:');
                        console.log(saveRecord.Claim__c);
                        console.log("removedPart");
                        console.log(removedPart);
                        listRecs.push(removedPart);
                    }

                    console.log('::::: listRecs:');
                    console.log(listRecs);
                    
                }else{
                    if(component.get('v.inventoryId') != null && component.get('v.inventoryId') != '' && typeof component.get('v.inventoryId') != "undefined"){
                         saveRecord.RecordTypeId		=	 component.get('v.serializedPartId');
                    }
                    if(component.get('v.warrantyProductId') != null && component.get('v.warrantyProductId') != '' && typeof component.get('v.warrantyProductId') != "undefined"){
                        saveRecord.RecordTypeId			=	component.get('v.nonSerializedPartId');
                    }
                }
                listRecs.push(saveRecord);
              	action 	= 	component.get('c.insertInstalledPartAndRemovedPartRecords');
				component.set('v.showSpinner',false);
            }
             
            console.log(':::::: sobjectRecordsToInsert:');
            console.log(component.get('v.sobjectRecordsToInsert'));
            console.log(':::: list records:');
            console.log(listRecs);
            
            console.log(':::: Save Record:');
            console.log(saveRecord);
            component.set('v.removedPartObject',removedPart);
            console.log(':::: removedPart:');
            console.log(component.get('v.removedPartObject'));
            var installedPart = JSON.stringify(saveRecord);
            var removedPart	 = JSON.stringify(removedPart);
            if(component.get('v.inventoryId') != '' && component.get('v.inventoryId') != null && typeof component.get('v.inventoryId')){
                removedPart = '';
            }
            console.log(':::: my json string:');
            console.log(installedPart);
            console.log(removedPart);
            action.setParams({
                "installedPart" : installedPart,
                "removedPart" 	: removedPart
            });
            action.setCallback(this, function(response) {
                console.log('::::: Respose value:');
				component.set('v.showSpinner',false);
                console.log(response);
                console.log(':::: Status:'+response.getState());
                var state = response.getState();
                var dmlErrors = [];
                if(state == "ERROR"){
					if (response.error[0].fieldErrors) {
						for (var key in response.error[0].fieldErrors) {
                            console.log('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        	dmlErrors.push('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                      	}
                    }
                } else if(state == "SUCCESS"){
                    console.log(response.getReturnValue());
                    console.log('::::::: is new record:'+isNew);
                    if(isNew){
                        var removedPartId	=	response.getReturnValue()[0].sObjID;
                        console.log(':::: removed part id:'+removedPartId);
                    }

                    component.set('v.installedPart',component.get('v.tempInstalledPart'));
                    component.set('v.isNewRecord',false);
                    if (response.getReturnValue()[0].errorCodeList) {
                      	for(var key in response.getReturnValue()[0].errorCodeList) {
                            console.log(response.getReturnValue()[0].errorCodeList[key]);
                            dmlErrors.push(': '+response.getReturnValue()[0].errorCodeList[key]);
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
                  	console.log(':::: Removed part value:'+insertRemovedPart);

                    if(insertRemovedPart == 'TRUE'){
                        console.log(':::: Going to insertRemovedPart');

                        if(saveRecord.Inventory__c != null && saveRecord.Inventory__c != '' && typeof saveRecord.Inventory__c != "undefined"){
														if(isNew){
															console.log(':::: Going to update the inventory');
                              component.set('v.removedPartId',removedPartId);
															component.set('v.tempInvId',saveRecord.Inventory__c);
															component.set('v.isShowInv',true);
															saveRecord.Inventory__c = null;
															console.log(':::::::: show isShowInv:'+component.get('v.isShowInv'));
															console.log(':::::: list ids length:'+component.get('v.listIds'));
															if(component.get('v.listIds').length >0 ){
																	component.set('v.isUpdateRemovedPart',true);
															}else{
																	helper.updateValues(component, event);
															}

													  }else{
															console.log('::::::11111111111');
                              helper.updateValues(component, event);
														}
                        }else{
                            console.log('selected Wr----------'+saveRecord);
                                console.log('::::::222222222222');
                            	helper.updateValues(component, event);
                    } 
                    }else{
                                console.log('::::::3333333333');
                            	helper.updateValues(component, event);
                }

                }
								console.log(':::::::: DML ERRORS:');
								console.log(dmlErrors);
                component.set("v.dmlErrors",dmlErrors);
								//component.set('v.showSpinner',false);

            });
            console.log(helper.allInstalledPartIds);
            console.log(component.get('v.warrantyProductId'));          
            if((helper.allInstalledPartIds.indexOf(component.get('v.warrantyProductId')) >= 0)&&component.get('v.isNewRecord')){
                var dmlErrors = [];
                dmlErrors.push("You can't use the already used Warranty Product");
                console.log(dmlErrors);
                component.set('v.dmlErrors',dmlErrors);
            }else{
                 $A.enqueueAction(action);
            }

        }else{
            component.set('v.showSpinner',false);
        }
    },

    // Disable the warranty product field
    disableWarrantyProduct : function(component, event, helper) {
        
        //event.preventDefault();
        console.log('::: disable warranty product');
        var isNew			=	component.get('v.isNewRecord');
        var inventoryId		= 	component.get('v.inventoryId');
        //console.log(component.get('v.inventoryName'));
        console.log(':::: inventory Id:'+inventoryId);
        console.log(isNew);
        if(isNew){
            if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined") {
                component.set('v.isDisabledWarranty',false);
                component.set('v.isDisabledInventory',false);
				component.set('v.installedPart.Quantity__c',1);
            } else {
                component.set('v.installedPart.Inventory__c',null);
                component.set('v.isDisabledWarranty',true);
            }
        }else{
             if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined") {
                component.set('v.isDisabledWarranty',true);
                component.set('v.isDisabledInventory',false);
            } else {
                component.set('v.installedPart.Inventory__c',null);
                component.set('v.isDisabledWarranty',true);
            }
        }
      	
        if(inventoryId != null){
            
            component.set('v.isWarrantySave',false);
            
            //commented by aman//
            helper.inventoryProductCost(component, event, true);
            
            component.set('v.isInvSave',true);
            console.log('coming in inventory loop');
        }
        if((component.get('v.warrantyProductId') == null || component.get('v.warrantyProductId') == '' ||  typeof	component.get('v.warrantyProductId') == "undefined") && (inventoryId == null || inventoryId == '')){
            component.set('v.isWarrantySave',false);
            component.set('v.isInvSave',false);
        }


		console.log("Hey");

				// Code to control the removed part inventory adding based on inventory product
				var queryString		=	'SELECT Id, Name FROM Inventory__c';
				if(inventoryId != null && inventoryId != '' && typeof inventoryId != "undefined"){
						var action	=	component.get('c.getRelatedInventories');
						action.setParams({
								"selectedId" : inventoryId,
								"query" : queryString
						});
						action.setCallback(this, function(response) {
								console.log('::::: Inventories need to select for removed parts');
								console.log(response.getReturnValue());
								component.set('v.requiredInventories',response.getReturnValue());

								component.set('v.listIds',response.getReturnValue());
								console.log('::::: list ids:'+response.getReturnValue());
						});
						$A.enqueueAction(action);
				}


/*
				 else {
						component.set('v.isWarrantySave',true);
						component.set('v.isInvSave',false);
				}
*/
    },

    // Disable the inventory field
    disableInventory : function(component, event, helper) {
        //event.preventDefault();
        var warrantyId		= component.get('v.warrantyProductId');
        var isNew			=	component.get('v.isNewRecord');
        console.log(':::: Warranty Product name:'+component.get('v.warrantyProductName'));
        if(isNew){
            if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined") {
                component.set('v.isDisabledInventory',false);
                component.set('v.isDisabledWarranty',false);
            } else {
                helper.inventoryProductCost(component, event, false);
                component.set('v.installedPart.Warranty_Product__c',null);
                component.set('v.isDisabledInventory',true);
            }
        }else{
            if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined") {
                component.set('v.isDisabledInventory',true);
                component.set('v.isDisabledWarranty',false);
            } else {
                helper.inventoryProductCost(component, event, false);
                component.set('v.installedPart.Warranty_Product__c',null);
                component.set('v.isDisabledInventory',true);
            }
        }
		
        if(warrantyId != null){
            component.set('v.isWarrantySave',true);
            component.set('v.isInvSave',false);
						//component.set('v.showSpinner',true);
            helper.inventoryProductCost(component, event, false);
						//component.set('v.showSpinner',false);
        }
        if((warrantyId == null || warrantyId == '' ) && (component.get('v.inventoryId') == null || component.get('v.inventoryId') == '' || typeof	component.get('v.inventoryId') == "undefined")){
            component.set('v.isWarrantySave',false);
            component.set('v.isInvSave',false);
        }
/*
				else {
						component.set('v.isWarrantySave',false);
						component.set('v.isInvSave',true);
				}
*/
    },

		changeModalClose	: function(component, event, helper){
				event.preventDefault();
				component.set('v.installedPart.Price__c',0);
				component.set('v.installedPart.Quantity__c',0);
				var myEvent = $A.get("e.c:ModalCloseEvent");
				myEvent.setParams({
						"isModalEnabled":false
				});
				myEvent.fire();
            
    }
})