({
	okResponse : function(component, event, helper) {
        console.log('ok clicked');
        component.set('v.response',true);
        component.set('v.isPopup',false);
        var myEvent = $A.get("e.c:ConfirmationEvent");
        myEvent.setParams({
        });
        myEvent.fire();
        
        var modelEvent = $A.get("e.c:ConfirmationModelEvent");
        modelEvent.setParams({
            "response" : component.get('v.response'),
            "isPopup"  : component.get('v.isPopup')
        });
        modelEvent.fire();
        
	},
    cancelResponse : function(component, event, helper) {
        console.log('cancel clicked');
		component.set('v.response',false);
        component.set('v.isPopup',false);
        
        var modelEvent = $A.get("e.c:ConfirmationModelEvent");
        modelEvent.setParams({
            "response" : component.get('v.response'),
            "isPopup"  : component.get('v.isPopup')
        });
        modelEvent.fire();
        
    }
})