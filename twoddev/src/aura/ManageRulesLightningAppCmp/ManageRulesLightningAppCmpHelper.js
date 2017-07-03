({
    doInit: function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                var LogicalGrouping = responseArray['Logical_Grouping__c'];
                component.set("v.LogicalGroupingList", LogicalGrouping);
                var RuleType = responseArray['Rule_Type__c'];
                component.set("v.RuleTypeList", RuleType);
            } else {
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);

        action = component.get("c.getObjectType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                var ObjectType = Object.keys(responseArray);
                ObjectType.unshift('--None--');
                component.set("v.ObjectTypeList", ObjectType);
                component.set("v.ObjectTypeMap", responseArray);
            } else {
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);
    },

    createRecord: function(component, event, helper) {
        var self = helper;
        self.errorMessageHide(component);
        self.showSpinner(component, event, helper);
        var action = component.get("c.createRecord");
        var WarrantyRuleName = component.get('v.WarrantyRuleName');
        var LogicalGrouping = component.find("LogicalGrouping").get("v.value");
        var ObjectType = component.find("ObjectType").get("v.value");
        var RuleType = component.find("RuleType").get("v.value");
        var ObjectTypeMap = component.get('v.ObjectTypeMap');

        if (!(WarrantyRuleName)) {
            component.set("v.error", 'Warranty Rule Name: You must enter a value');
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }        
        if (!(LogicalGrouping) || LogicalGrouping == '--None--') {
            component.set("v.error", 'Please provide value for "Logical Grouping" field.');
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }
        if (!(ObjectType) || ObjectType == '--None--') {
            component.set("v.error", 'Please provide value for "Object Type" field.');
            self.errorMessageShow(component);
            self.hideSpinner(component, event, helper);
            return;
        }


        var ObjectAPIName = ObjectTypeMap[ObjectType];
        action.setParams({
            "WarrantyRuleName": WarrantyRuleName,
            "LogicalGrouping": LogicalGrouping,
            "ObjectType": ObjectType,
            "ObjectAPIName": ObjectAPIName,
            "RuleType": RuleType
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var responseArray = JSON.parse(JSON.stringify(response.getReturnValue()));
                self.hideSpinner(component, event, helper);
                location.replace("/" + responseArray);
            } else {
                self.hideSpinner(component, event, helper);
                console.log('FAIL');
            }
        });
        $A.enqueueAction(action);
    },

    cancel: function(component, event, helper) {
        var self = helper;
        self.errorMessageHide(component);
        //self.reset(component);
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
    showSpinner : function (component, event, helper) {
        var cmpTarget = component.find('group');
        $A.util.addClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();         
    },
    
    hideSpinner : function (component, event, helper) {
        var cmpTarget = component.find('group');
        $A.util.removeClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    reset: function(component) {
       //yet to done
    },

})