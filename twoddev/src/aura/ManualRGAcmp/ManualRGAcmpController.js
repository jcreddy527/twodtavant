({
    doInit: function(component, event, helper) {

        var claimId = component.get('v.claimId');
        var initializeDataLoaderAction = component.get('c.getInitialData');
        var spinner = {
            actionSpinner: false,
            pageSpinner: true
        };
        component.set('v.spinner', spinner);

        initializeDataLoaderAction.setParams({
            claimId: claimId
        });

        var removedPartListHandelerObject = {
            DOM: [],
            editable: []
        };
        component.set('v.removedPartListHandelerObject', removedPartListHandelerObject);
        helper.showAlert(component, event, {});


        initializeDataLoaderAction.setCallback(this, function(response) {


            var responseStatus = response.getState();
            if (responseStatus === 'SUCCESS') {

                var responseData = response.getReturnValue();
                if (responseData !== null && responseData !== undefined) {

                    responseData = JSON.parse(responseData);
                    var claim = responseData['claim'];
                    component.set('v.claim', claim);
                    var removedPartList = claim['Removed_Claim_Parts__r'];

                    if (removedPartList !== undefined && removedPartList !== null) {

                        removedPartList = claim['Removed_Claim_Parts__r']['records'];
                        if (removedPartList !== null && removedPartList !== undefined) {
                            //set the payment condition
                            var paymentConditionList = JSON.parse(responseData['paymentConditionListJSON']);
                            component.set('v.paymentConditionList', paymentConditionList);

                            removedPartList = removedPartList.map(function(a) {
                                a['selected'] = false;
                                a['Payment_Condition__c'] = paymentConditionList[paymentConditionList.length - 1]['value'];
                                return a;
                            });
							
                            component.set('v.removedPartListHandelerObject.DOM', removedPartList);
                            component.set('v.removedPartListHandelerObject.editable', removedPartList);

                            //hide spinner
                            component.set('v.spinner.pageSpinner', false);

                        } else {

                            //set the dom and updatable values of removed part list
                            component.set('v.removedPartListHandelerObject.DOM', []);
                            component.set('v.removedPartListHandelerObject.editable', []);

                            //hide spinner
                            component.set('v.spinner.pageSpinner', false);

                        }

                    } else {

                        //hide spinner
                        component.set('v.spinner.pageSpinner', false);

                        //show the alert on no parts found
                        var alertboxContent = {
                            message: $A.get('$Label.c.No_Parts_To_be_Shipped_On_Claim'),
                            heading: $A.get('$Label.c.Manual_RGA_Page_Says'),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.returnToClaim'),
                            buttonHeading: 'Return to claim'
                        };
                        helper.showAlert(component, event, alertboxContent);

                    }

                }

            } else {

                //hide spinner
                component.set('v.spinner.pageSpinner', false);

                //show the server error
                var alertboxContent = {
                    message: $A.get('$Label.c.Server_Side_Error_Occurred'),
                    heading: $A.get('$Label.c.Manual_RGA_Page_Says'),
                    class: 'slds-theme--error',
                    callableFunction: component.getReference('c.returnToClaim'),
                    buttonHeading: 'Return to claim'
                };
                helper.showAlert(component, event, alertboxContent);

            }


        });
        $A.enqueueAction(initializeDataLoaderAction);

    },

    fillSubmittableDetails: function(component, event, helper) {

        var componentId = event.getSource().getLocalId();
        var removedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartListHandelerObject.editable')));

        switch (componentId) {

            case "returnLocation":
                {

                    var index = event.getSource().get('v.iterableId');
                    var returnedLocation = JSON.parse(JSON.stringify(event.getParam('selectedObject')));
                    removedPartList[index]['Return_Location__c'] = returnedLocation['Id'];
                    component.set('v.removedPartListHandelerObject.editable', removedPartList);

                    break;
                }

            case "paymentCondition":
                {

                    var index = event.getSource().get('v.labelClass');
                    var paymentCondition = event.getSource().get('v.value');
                    removedPartList[index]['Payment_Condition__c'] = paymentCondition;
                    component.set('v.removedPartListHandelerObject.editable', removedPartList);

                    break;
                }

            case "selector":
                {
                    var index = event.getSource().get('v.text');
                    var selected = event.getSource().get('v.value');
                    removedPartList[index]['selected'] = selected;
                    component.set('v.removedPartListHandelerObject.editable', removedPartList);

                    break;
                }

        }

    },

    submitReturnLocation: function(component, event, helper) {

        var removedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartListHandelerObject.editable')));
        removedPartList = removedPartList.filter(function(a) {

            if (a['Return_Location__c'] !== undefined && a['Return_Location__c'] !== null && a['selected']) {
                return a;
            }

        });

        if (removedPartList !== undefined && removedPartList !== null && removedPartList.length !== 0) {

            component.set('v.spinner.actionSpinner', true);
            helper.updateRaw(component, event, helper, removedPartList, function(updateRemovedPartResponse) {


                var sObjectAndStatusList = updateRemovedPartResponse['sobjectsAndStatus'];
                var allSuccessfullyUpdated = helper.checkIfAllSuccessfullyUpdated(sObjectAndStatusList);

                if (allSuccessfullyUpdated) {
                    component.set('v.spinner.actionSpinner', false);
                    window.location.href = '/' + component.get('v.claimId');

                } else {

                    component.set('v.spinner.actionSpinner', false);
                    var alertboxContent = {
                        message: $A.get('$Label.c.Incomplete_Return_Location_Error'),
                        heading: $A.get('$Label.c.Update_Unsuccessful'),
                        class: 'slds-theme--error',
                        callableFunction: component.getReference('c.returnToClaim'),
                        buttonHeading: 'Return to claim'
                    };
                    helper.showAlert(component, event, alertboxContent);

                }

            });

        }

    },

    returnToClaim: function(component, event, helper) {
        window.location.href = '/' + component.get('v.claimId');
    },

    cancel: function(component, event, helper) {
        window.location.href = '/' + component.get('v.claimId');
    }


})