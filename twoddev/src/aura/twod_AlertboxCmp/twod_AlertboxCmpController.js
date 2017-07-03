({
	alertAction : function(component, event, helper) {

        var onOkay = component.getEvent("onOkay");
				onOkay.fire();

	},
	secondaryAlertAction : function(component, event, helper) {

        var onSecondaryOkay = component.getEvent("onSecondaryOkay");
				onSecondaryOkay.fire();

	}

})