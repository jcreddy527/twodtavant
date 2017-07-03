({
	doInit : function(component, event, helper) {
		helper.showAlert(component, event, {});
        component.set('v.body', []);
        
        //if initialed by claim page
        var fromClaimId =  component.get("v.fromClaimId");
        
                var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('&'), sParameterName, i;
                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('=');

                    if (sParameterName[0] === 'fromClaimId') {
                        fromClaimId = sParameterName[1] === undefined ? true : sParameterName[1];
                    }
                }           

        if(fromClaimId!==undefined && fromClaimId!==null && fromClaimId!==''){
            
            helper.initialize(component, event, fromClaimId,true);
            
        }else{
            
            //if initialted elsewhere
            helper.initialize(component, event, null,true);
            
        }
        
	},
    selectTargetClaim: function(component, event, helper) {
        
        var isSelected = event.getSource().get('v.value');
        var claimName = event.getSource().get('v.text');
        helper.selectTargetClaim(component, event, isSelected, claimName);
        
    },
    
    selectRemovedPart: function(component, event, helper) {
        
        var selectedMainClaimWrapper = JSON.parse(JSON.stringify(component.get('v.selectedMainClaimWrapper')));
        var mainClaimWrapperList = JSON.parse(JSON.stringify(component.get('v.mainClaimWrapperList')));
        var selectedRemovedPartId = event.getSource().get('v.text');
        var removedPartList = selectedMainClaimWrapper['removePartListWrap'];
        var indexSelected = event.getSource().get('v.labelClass');
        var claimNumberSelected = null;
        
        //get the claim number
        if (!helper.isNullUndefined(removedPartList[indexSelected]['removePartWr']['Claim__r'])) {
            claimNumberSelected = removedPartList[indexSelected]['removePartWr']['Claim__r']['Name'];
        }
        
        //find the index of main claim in main claim wrapper list
        var indexOfMainClaimWrapper = helper.findIndexWithProperty(mainClaimWrapperList, 'claimNumber', claimNumberSelected);
        if (indexOfMainClaimWrapper > -1) {
            if (indexSelected > -1) {
                var isSelectedByCheckbox = event.getSource().get('v.value');
                
                if (isSelectedByCheckbox) {
                    removedPartList[indexSelected]['isSelected'] = true;
                } else {
                    removedPartList[indexSelected]['isSelected'] = false;
                }
                selectedMainClaimWrapper['removePartListWrap'] = removedPartList;
                mainClaimWrapperList[indexOfMainClaimWrapper] = selectedMainClaimWrapper;
                component.set('v.selectedMainClaimWrapper', selectedMainClaimWrapper);
                component.set('v.selectedClaimId', selectedMainClaimWrapper['removePartListWrap'][0]['removePartWr']['Claim__c']);
            }
        }
        
    },
    
    setShippedQty: function(component, event, helper) {
        
        var shippedQuantity = event.getSource().get('v.value');
        var indexSelected = event.getSource().get('v.labelClass');
        var selectedMainClaimWrapper = JSON.parse(JSON.stringify(component.get('v.selectedMainClaimWrapper')));
        var removedPartList = JSON.parse(JSON.stringify(selectedMainClaimWrapper['removePartListWrap']));
        if (!helper.isNullUndefined(shippedQuantity)) {
            removedPartList[indexSelected]['shippedQty'] = shippedQuantity;
            selectedMainClaimWrapper['removePartListWrap'] = removedPartList;
            component.set('v.selectedMainClaimWrapper', selectedMainClaimWrapper);
            component.set('v.selectedClaimId', selectedMainClaimWrapper['removePartListWrap'][0]['removePartWr']['Claim__c']);
        }
        
    },
    
    createShipment: function(component, event, helper) {
        
        var selectedMainClaimWrapper = JSON.parse(JSON.stringify(component.get('v.selectedMainClaimWrapper')));
        var removedPartList;
        
        if (!helper.isNullUndefined(selectedMainClaimWrapper)) {
            
            removedPartList = JSON.parse(JSON.stringify(selectedMainClaimWrapper['removePartListWrap']));
            var selectedRemovedPartList = removedPartList.filter(function(a) {
                if (a['isSelected'] === true) {
                    return a;
                }
            });
            
            if (!helper.isListNullEmpty(selectedRemovedPartList)) {
                
                var shipmentQuantitiesAreValid = helper.quantityValidation(component, selectedRemovedPartList);
                
                if (shipmentQuantitiesAreValid) {
                    
                    //list of unique shipments
                    var shipmentToInsertList = [];
                    
                    //add the no. of shipment objects in the above list which corrospond to same return location
                    selectedRemovedPartList.map(function(a) {
                        
                        if (!helper.isNullUndefined(a)) {
                            var returnLocationId = a['removePartWr']['Return_Location__c'];
                            
                            //find if the shipment object with same return location exist in the list or not
                            var alreadyExist = helper.findIndexWithProperty(shipmentToInsertList, 'Return_Location__c', returnLocationId);
                            
                            //if shipment is unique, then make a new object
                            if (alreadyExist === -1) {
                                var shipmentToInsert = {
                                    sobjectType: "Shipment_Detail__c",
                                    Return_Location__c: a['removePartWr']['Return_Location__c']
                                };
                                shipmentToInsertList.push(shipmentToInsert);
                            }
                        }
                        
                    });
                    
                    //if list of shipmenty is not empty , then insert the shipment
                    if (!helper.isListNullEmpty(shipmentToInsertList)) {
                        
                        //set the spinner
                        component.set('v.spinnerAndPageBool.actionSpinner', true);
                        
                        //insert shipment operation
                        helper.insertRaw(component, event, helper, shipmentToInsertList, function(shipmentInsertResponse) {
                            
                            var sObjectAndStatusList = shipmentInsertResponse['sobjectsAndStatus'];
                            
                            if (!helper.isListNullEmpty(sObjectAndStatusList)) {
                                
                                //shipment item list
                                var shipmentItemList = [];
                                
                                //for each shipment, collect the items for shipment
                                sObjectAndStatusList.map(function(a) {
                                    
                                    if (a !== undefined && a !== null && a['status'] === 'successful') {
                                        
                                        //get the target removed part list for the shipment
                                        var tempTargetRemovedPartList = removedPartList.filter(function(removedPart) {
                                            if ((removedPart['removePartWr']['Return_Location__c'] ===
                                                 a['sObject']['Return_Location__c']) && removedPart['isSelected'] === true) {
                                                return a;
                                            }
                                        });
                                        
                                        //for all the removed part of that shipments, fill the shipment item array with relevant data
                                        if (!helper.isListNullEmpty(tempTargetRemovedPartList)) {
                                            var tempShipmentItemList = tempTargetRemovedPartList.map(function(tempTargetRemovedPart) {
                                                var shipmentItem = {
                                                    sobjectType: 'Claim_Shipment__c',
                                                    Quantity__c: tempTargetRemovedPart['shippedQty'],
                                                    Removed_Claim_Part__c: tempTargetRemovedPart['removePartWr']['Id'],
                                                    Shipment_Detail__c: a['sObject']['Id']
                                                };
                                                
                                                return shipmentItem;
                                                
                                            });
                                            if (!helper.isListNullEmpty(tempShipmentItemList)) {
                                                shipmentItemList = shipmentItemList.concat(tempShipmentItemList);
                                            }
                                        }
                                    }
                                });
                                
                                if (!helper.isListNullEmpty(shipmentItemList)) {
                                    
                                    helper.insertRaw(component, event, helper, shipmentItemList, function(shipmentItemInsertResponse) {
                                        var shipmentItemInserted = shipmentItemInsertResponse['sobjectsAndStatus'];
                                        if (shipmentItemInserted.length > 0) {
                                            var shipmentId = shipmentItemInserted[0]['sObject']['Shipment_Detail__c'];
                                            helper.redirectToClaim(component, shipmentId);
                                        }else{
                                            helper.redirectToClaim(component, undefined);
                                        }                                        
                                    });
                                    
                                } else {
                                    helper.redirectToClaim(component, undefined);
                                }
                            }
                        });
                    }
                    
                    
                } else {
                    
                    // show the error message of service campaign found
                    var alertboxContent = {
                        message: $A.get('$Label.c.Shipment_Quantity_Alert'),
                        heading: 'Shipment page  says..',
                        class: 'slds-theme--info',
                        callableFunction: component.getReference('c.closeAlert'),
                        buttonHeading: $A.get("$Label.c.OK")
                    };
                    helper.showAlert(component, event, alertboxContent);
                }
            }
        } else {
            
            // show the error message of service campaign found
            var alertboxContent = {
                message: $A.get('$Label.c.No_Shipment_Part_Selected'),
                heading: 'Shipment page  says..',
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            helper.showAlert(component, event, alertboxContent);
            
        }
    },
    
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
    
    closeAlertWithRedirect: function(component, event, helper) {
        component.set('v.body', []);
        var claimId = component.get('v.fromClaimId');
        var sitePrefix = component.get('v.sitePrefix');
        if (!helper.isNullUndefined(claimId) && claimId !== '') {
            
            if (!helper.isNullUndefined(sitePrefix) && sitePrefix !== '') {
                window.location.href = sitePrefix + '/' + claimId;
            } else {
                window.location.href = '/' + claimId;
            }
            
        }
        
        
    },
    
    searchResetClaim: function(component, event, helper) {
        
        var selectedClaimObject = JSON.parse(JSON.stringify(event.getParam('selectedObject')));
        var mainClaimWrapperList = JSON.parse(JSON.stringify(component.get('v.mainClaimWrapperList')));
        
        if (!helper.isListNullEmpty(mainClaimWrapperList)) {
            
            //is claim present in current main claim list
            var indexInCurrent = helper.findIndexWithProperty(mainClaimWrapperList, "claimNumber", selectedClaimObject['Name']);
            
            if (indexInCurrent > -1) {
                
                mainClaimWrapperList[indexInCurrent]['isSelected'] = true;
                component.set('v.mainClaimWrapperList', [mainClaimWrapperList[indexInCurrent]]);
                component.set('v.selectedMainClaimWrapper', mainClaimWrapperList[indexInCurrent]);
                component.set('v.selectedClaimId', mainClaimWrapperList[indexInCurrent]
                              ['removePartListWrap'][0]['removePartWr']['Claim__c']);
                
            } else {
                //make a server call
                helper.initialize(component, event, selectedClaimObject['Id'],false);
            }
            
        }
        
    },
    
    resetTheMainList: function(component, event, helper) {
        
        var name = event.getSource().get('v.objectName');
        if (name === null || name === '') {
            
            component.set('v.mainClaimWrapperList', component.get('v.backupClaimWrapperList'));
            component.set('v.selectedMainClaimWrapper', null);
            component.set('v.selectedClaimId', null);
        }
        
        
    },
    
    cancel: function(component, event, helper) {
        
        window.history.back();
        
    }
})