({

    initialize: function(component, event, claimId, isInitialLoad) {

        var self = this;

        //initialize spinner booleans
        var spinnerAndPageBool = {
            pageSpinner: false,
            actionSpinner: false,
            showMainBody: false
        };

        component.set('v.spinnerAndPageBool', spinnerAndPageBool);
        var action = null;

        if (self.isNullUndefined(claimId) || claimId === '') {

            component.set('v.spinnerAndPageBool.pageSpinner', true);
            component.set('v.spinnerAndPageBool.showMainBody', false);
            component.set('v.selectedMainClaimWrapper', null);
            component.set('v.selectedClaimId', null);

            //main wrapper action
            action = component.get("c.getpartsTobeReturn");
            action.setParams({
                claimId: null,
                isInitialLoad: isInitialLoad
            });

            action.setCallback(this, function(a) {

                if (a.getState() == "SUCCESS") {
                    var mainWrapper = JSON.parse(a.getReturnValue());
                    var result = mainWrapper['claimWrapperList'];
                    var whereConditionForClaimLookup = self.makeWhereCondition(mainWrapper['validClaimListForSearch']);
                    component.set('v.claimWhereCondition', whereConditionForClaimLookup);

                    if (!self.isListNullEmpty(result)) {
                        if (result.length === 1) {
                            result[0]['isSelected'] = true;
                            component.set('v.selectedMainClaimWrapper', result[0]);
                            var claimId = result[0]['removePartListWrap'][0]['removePartWr']['Claim__c'];
                            component.set('v.selectedClaimId', claimId);

                        }
                        component.set("v.mainClaimWrapperList", result);
                        component.set("v.backupClaimWrapperList", result);
                        //hide spinner
                        component.set('v.spinnerAndPageBool.pageSpinner', false);
                        component.set('v.spinnerAndPageBool.showMainBody', true);


                    } else {

                        //send empty array

                        component.set("v.mainClaimWrapperList", []);
                        component.set("v.backupClaimWrapperList", []);
                        component.set('v.spinnerAndPageBool.pageSpinner', false);
                        component.set('v.spinnerAndPageBool.showMainBody', false);


                        // show the error message of no claim wraper found
                        var alertboxContent = {
                            message: 'No claim with removed parts found...',
                            heading: 'Shipment page  says..',
                            class: 'slds-theme--info',
                            callableFunction: component.getReference('c.cancel'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        self.showAlert(component, event, alertboxContent);

                    }
                } else {

                    ///hide spinner
                    component.set('v.spinnerAndPageBool.pageSpinner', false);
                    component.set('v.spinnerAndPageBool.showMainBody', false);

                    // show the error message of no claim wraper found
                    var alertboxContent = {
                        message: 'No claim with removed parts found...',
                        heading: 'Shipment page  says..',
                        class: 'slds-theme--info',
                        callableFunction: component.getReference('c.cancel'),
                        buttonHeading: $A.get("$Label.c.OK")
                    };
                    self.showAlert(component, event, alertboxContent);
                }
            });
            $A.enqueueAction(action);

        } else {

            component.set('v.spinnerAndPageBool.actionSpinner', true);
            component.set('v.spinnerAndPageBool.showMainBody', true);

            //main wrapper action
            action = component.get("c.getpartsTobeReturn");
            action.setParams({
                claimId: claimId,
                isInitialLoad: isInitialLoad
            });

            action.setCallback(this, function(a) {
                if (a.getState() == "SUCCESS") {

                    var mainWrapper = JSON.parse(a.getReturnValue());
                    var result = mainWrapper['claimWrapperList'];
                    component.set('v.validClaimListForSearch', []);

                    if (!self.isListNullEmpty(result)) {

                        result[0]['isSelected'] = true;
                        component.set('v.selectedMainClaimWrapper', result[0]);
                        var claimId = result[0]['removePartListWrap'][0]['removePartWr']['Claim__c'];
                        component.set('v.selectedClaimId', claimId);
                        component.set("v.mainClaimWrapperList", result);

                        //hide spinner
                        component.set('v.spinnerAndPageBool.actionSpinner', false);
                        component.set('v.spinnerAndPageBool.showMainBody', true);


                    } else {

                        //set tha main wrapper list with backup
                        var backupClaimWrapperList = JSON.parse(JSON.stringify(component.get('v.backupClaimWrapperList')));
                        component.set("v.mainClaimWrapperList", backupClaimWrapperList);
                        component.set('v.spinnerAndPageBool.actionSpinner', false);
                        component.set('v.spinnerAndPageBool.showMainBody', true);

                        // show the error message of no claim wraper found
                        var alertboxContent = {
                            message: $A.get('$Label.c.No_Parts_To_be_Shipped_On_Claim'),
                            heading: $A.get('$Label.c.Shipment_Page_Says'),
                            class: 'slds-theme--info',
                            callableFunction: component.getReference('c.closeAlertWithRedirect'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        self.showAlert(component, event, alertboxContent);
                        var claimLookupComponent = component.find('claim');
                        if (!self.isNullUndefined(claimLookupComponent) && typeof(claimLookupComponent.set) === 'function') {
                            claimLookupComponent.set('v.objectName', '');
                        }

                    }
                } else {

                    ///hide spinner
                    component.set('v.spinnerAndPageBool.actionSpinner', false);
                    component.set('v.spinnerAndPageBool.showMainBody', true);

                    // show the error message of no claim wraper found
                    var alertboxContent = {
                        message: 'No removed parts to be shipped found for this claim...',
                        heading: 'Shipment page  says..',
                        class: 'slds-theme--info',
                        callableFunction: component.getReference('c.closeAlertWithRedirect'),
                        buttonHeading: $A.get("$Label.c.OK")
                    };
                    self.showAlert(component, event, alertboxContent);
                    var claimLookupComponent = component.find('claim');
                    if (!self.isNullUndefined(claimLookupComponent) && typeof(claimLookupComponent.set) === 'function') {
                        claimLookupComponent.set('v.objectName', '');
                    }

                }
            });
            $A.enqueueAction(action);


        }



    },

    /***functional methods***/
    selectTargetClaim: function(component, event, isSelected, claimName) {

        var self = this;
        var mainClaimWrapperList = JSON.parse(JSON.stringify(component.get("v.mainClaimWrapperList")));
        var indexInCurrent = self.findIndexWithProperty(mainClaimWrapperList, "claimNumber", claimName);

        if (isSelected) {
            if (indexInCurrent !== -1) {
                component.set('v.selectedMainClaimWrapper', mainClaimWrapperList[indexInCurrent]);

                var claimId = mainClaimWrapperList[indexInCurrent]['removePartListWrap'][0]['removePartWr']['Claim__c'];
                component.set('v.selectedClaimId', claimId);

                //set the claim wrapper as selected
                if (mainClaimWrapperList[indexInCurrent]['isSelected'] === false) {
                    mainClaimWrapperList[indexInCurrent]['isSelected'] = true;
                }

                //set the other claim wrappers as disselected
                for (var i = 0, len = mainClaimWrapperList.length; i < len; i++) {

                    if (i !== indexInCurrent) {
                        mainClaimWrapperList[i]['isSelected'] = false;
                    }
                    var targetMainClaimWrapper = mainClaimWrapperList[i]['removePartListWrap'];
                    if (!self.isListNullEmpty(targetMainClaimWrapper)) {
                        targetMainClaimWrapper = targetMainClaimWrapper.map(function(a) {
                            a['isSelected'] = false;
                            return a;
                        });
                        mainClaimWrapperList[i]['removePartListWrap'] = targetMainClaimWrapper;
                    }

                }

            }

        }

        component.set("v.mainClaimWrapperList", mainClaimWrapperList);


    },

    findIndexWithProperty: function(array, attr, value) {

        for (var i = 0; i < array.length; i += 1) {
            if (array[i][attr] === value) {
                return i;
            }
        }
        return -1;
    },

    /***alert box helper method***/
    showAlert: function(component, event, alertboxContent) {

        // create dynamic alert box with some initializations
        var self = this;
        var test;
        $A.createComponent(
            "c:AlertboxCmp", {
                message: alertboxContent.message,
                heading: alertboxContent.heading,
                class: alertboxContent.class,
                onOkay: alertboxContent.callableFunction,
                onSecondaryOkay: alertboxContent.secondaryCallableFunction,
                buttonHeading: alertboxContent.buttonHeading,
                secondaryButtonHeading: alertboxContent.secondaryButtonHeading
            },
            function(alertbox) {


                if (alertbox !== undefined && alertbox !== null && alertbox.isValid()) {
                    var body = [];
                    body.push(alertbox);
                    if (!alertbox.isInstanceOf("c:AlertboxCmp")) {
                        component.set("v.body", []);
                    } else {
                        component.set("v.body", body);
                    }

                }
            }

        );

    },

    quantityValidation: function(component, selectedRemovedPartList) {
        var validationSuccesss = true;
        if (selectedRemovedPartList !== null && selectedRemovedPartList !== undefined && selectedRemovedPartList.length !== 0) {
            for (var i = 0, len = selectedRemovedPartList.length; i < len; i++) {
                var inputQuantity = selectedRemovedPartList[i]['shippedQty'];
                var maxQuantity = selectedRemovedPartList[i]['removePartWr']['Quantity__c'];
                if (inputQuantity === null || inputQuantity === undefined || (inputQuantity !== parseInt(inputQuantity, 10)) ||
                    inputQuantity > maxQuantity || inputQuantity <= 0) {
                    validationSuccesss = false;
                    break;
                }
            }
        } else {
            validationSuccesss = false;
        }

        return validationSuccesss;

    },

    isListNullEmpty: function(givenList) {

        if (givenList !== undefined && givenList !== null && Array.isArray(givenList) && givenList.length !== 0) {
            return false;
        } else {
            return true;
        }

    },

    isNullUndefined: function(givenObject) {

        if (givenObject !== undefined && givenObject !== null) {
            return false;
        } else {
            return true;
        }

    },

    redirectToClaim: function(component, shipmentId) {
		var targetId;
        if(shipmentId == undefined )
        	targetId = component.get('v.selectedClaimId');
        else{
            targetId = shipmentId;
        }
        
        if (component.get('v.sitePrefix') !== '') {
            window.location.href = component.get('v.sitePrefix') + "/" +
                targetId;
        } else {
            window.location.href = "/" + targetId;
        }


    },

    makeWhereCondition: function(claimNameList) {

        var whereCondition = "";

        if (claimNameList !== undefined && claimNameList !== null && claimNameList.length !== 0) {

            whereCondition = " AND Name In (";

            for (var i = 0, len = claimNameList.length; i < len; i++) {
                if (i == len - 1) {
                    whereCondition += "'" + claimNameList[i] + "'";
                } else {
                    whereCondition += "'" + claimNameList[i] + "',";
                }
            }
            whereCondition += ") ";

        }

        return whereCondition;

    }
})