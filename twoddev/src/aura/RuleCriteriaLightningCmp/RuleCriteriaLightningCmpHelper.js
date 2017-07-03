({
    doInit: function(component, event, helper) {
        var self = helper;
        self.showSpinner(component, event, helper);
        var action = component.get("c.getlistValues");        
        var WarrantyRuleId = self.getURLParma(component, event, helper);
        
        component.set("v.WarrantyRule", WarrantyRuleId);
        action.setParams({
            "WarrantyRuleId": WarrantyRuleId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                component.set("v.FieldNameList", responseArray['Field Name']);
                component.set("v.CriteriaTypeList", responseArray['Criteria Type']);
                component.set("v.objectName", responseArray['Object Name'][0]);
                component.set("v.searchKey", responseArray['Id'][0]);
            } else {
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.getFieldNames");
        action.setParams({
            "WarrantyRuleId": WarrantyRuleId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                var FieldNameList = Object.keys(responseArray);
                FieldNameList.unshift('--None--');
                component.set("v.FieldNameList", FieldNameList);
                component.set("v.FieldNameMap", responseArray);
                self.hideSpinner(component, event, helper);
            } else {
                helper.hideSpinner(component, event, helper);
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);
    },
    
    getURLParma: function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === 'id') {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },

    onFieldNameChange: function(component, event, helper) {
        var self = helper;
        self.errorMessageHide(component);
        self.showSpinner(component, event, helper);
        var action = component.get("c.getfieldDetails");
        var FieldName = component.find('FieldName').get('v.value');
        var FieldNameMap = component.get("v.FieldNameMap");
        var Objectname = component.get("v.objectName");
        component.set("v.FieldApiName", FieldNameMap[FieldName]);        
        
        /*** reset all other criteria vslues **/		
		component.set("v.CriteriaValueString", undefined);
        component.set("v.CriteriaValuedate", undefined);
        component.set("v.CriteriaValuedateTime", undefined);
        component.set("v.CriteriaValueBoolean", undefined);
        component.set("v.ReferenceTo", undefined);
        component.find("CriteriaValuePickListValue").set("v.value", undefined);

        action.setParams({
            "ObjectName": Objectname,
            "fieldName": FieldNameMap[FieldName]
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                component.set("v.FieldType", responseArray.toUpperCase());
                if ('Picklist' == responseArray) {
                    var actionPL = component.get("c.getPicklistValues");
                    actionPL.setParams({
                        "ObjectName": Objectname,
                        "fieldName": FieldNameMap[FieldName]
                    });
                    actionPL.setCallback(this, function(responsePL) {
                        var statePL = responsePL.getState();
                        if (statePL == 'SUCCESS') {
                            var responseArrayPL = JSON.parse(JSON.stringify(responsePL.getReturnValue()));
                            var CriteriaValuePickValues = Object.keys(responseArrayPL);
                            CriteriaValuePickValues.unshift('--None--');
                            component.set("v.CriteriaValuePickList", CriteriaValuePickValues);
                        } else {
                            console.log('FAIL');
                        }
                    });
                    $A.enqueueAction(actionPL);
                }
                if ('Reference' == responseArray) {
                    var actionRF = component.get("c.getReferenceName");
                    actionRF.setParams({
                        "ObjectName": Objectname,
                        "fieldName": FieldNameMap[FieldName]
                    });
                    actionRF.setCallback(this, function(responseRF) {
                        var stateRF = responseRF.getState();
                        if (stateRF == 'SUCCESS') {
                            var responseArrayRF = JSON.parse(JSON.stringify(responseRF.getReturnValue()));
                            var QuerySOQL = 'Select Id,Name from ' + responseArrayRF;
                            component.set("v.RelatedObject", responseArrayRF);
                            component.set("v.QuerySOQL", QuerySOQL);
                        } else {
                            console.log('FAIL');
                        }
                    });
                    $A.enqueueAction(actionRF);
                }
                self.hideSpinner(component, event, helper);
            } else {
                console.log('FAIL');
                component.set("v.FieldType", '--None--');
                self.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(action);

    },
    createRecord: function(component, event, helper) {
        var self = helper;
        self.errorMessageHide(component);
        self.showSpinner(component, event, helper);
        var action = component.get("c.createRecord");
        var WarrantyRule = component.get('v.WarrantyRule');
        var Sequence = component.get('v.Sequence');
        var FieldName = component.find("FieldName").get("v.value");
        var CriteriaType = component.find("CriteriaType").get("v.value");
        var FieldApiName = component.get('v.FieldApiName');
        var FieldType = component.get('v.FieldType');
        var CriteriaValueString = component.get('v.CriteriaValueString');
        var CriteriaValuedate = component.get('v.CriteriaValuedate');
        var CriteriaValuedateTime = component.get('v.CriteriaValuedateTime');
        var CriteriaValueBoolean = component.get('v.CriteriaValueBoolean');
        var CriteriaValuePickListValueEle = component.find("CriteriaValuePickListValue");
        var ReferenceTo =  component.get("v.ReferenceTo");
        var RelatedObject =  component.get("v.RelatedObject");

        var CriteriaValuePickListValue;
        if (CriteriaValuePickListValueEle != undefined) {
            CriteriaValuePickListValue = CriteriaValuePickListValueEle.get("v.value");
        }

        if (!(WarrantyRule)) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel9"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }
        if (!(Sequence)) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel10"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        } else if (isNaN(Sequence)) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel11"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }
        if (!(FieldName) || (FieldName == '--None--')) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel12"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }
        if (!(CriteriaType) || (CriteriaType == '--None--')) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel13"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }
        if (!(CriteriaValueString) && !(CriteriaValuedate) && !(CriteriaValuedateTime) && !(CriteriaValuePickListValue) && !(CriteriaValueBoolean) || (CriteriaValuePickListValue == '--None--')) {
            component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel14"));
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        } else if (CriteriaValuedate) {
            CriteriaValueString = CriteriaValuedate;
        } else if (CriteriaValuedateTime) {
            CriteriaValueString = CriteriaValuedateTime;
        } else if (CriteriaValueBoolean) {
            CriteriaValueString = CriteriaValueBoolean.toString();
        } else if (CriteriaValuePickListValue) {
            CriteriaValueString = CriteriaValuePickListValue;
        }

        action.setParams({
            "WarrantyRule"	: WarrantyRule,
            "Sequence"		: Sequence,
            "FieldName"		: FieldName,
            "FieldApiName"	: FieldApiName,
            "FieldType"		: FieldType.toUpperCase(),
            "CriteriaType"	: CriteriaType,
            "CriteriaValue"	: CriteriaValueString,
            "ReferenceTo"	: RelatedObject
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                var result = responseArray.split('::');
                self.hideSpinner(component, event, helper);
                if (result[0] == 'SUCCESS') {
                    location.replace("/" + result[1]);
                } else {
                    component.set("v.error", result[1]);
                    self.errorMessageShow(component);
                }
            } else {
                component.set("v.error", $A.get("$Label.c.RuleCriteriaLightningLabel15"));
                self.errorMessageShow(component);
                self.hideSpinner(component, event, helper);
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);

    },
    cancel: function(component, event, helper) {
        var self = helper;
        self.errorMessageHide(component);
        window.history.back();
    },

    errorMessageShow: function(component) {
        var cmpTarget = component.find('errorMessage');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpTarget, 'slds-open');
    },

    errorMessageHide: function(component) {
        var cmpTarget = component.find('errorMessage');
        $A.util.removeClass(cmpTarget, 'slds-open');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    showSpinner: function(component, event, helper) {
        var cmpTarget = component.find('group');
        //$A.util.addClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: true
        });
        evt.fire();
    },

    hideSpinner: function(component, event, helper) {
        var cmpTarget = component.find('group');
        $A.util.removeClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({
            isVisible: false
        });
        evt.fire();
    },

})