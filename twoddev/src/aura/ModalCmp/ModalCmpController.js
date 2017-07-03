({
    doInit: function(component, helper) {
        //component.set('v.context',$A.getContext().gg);
        var isLarge = component.get("v.isLarge");
        if(isLarge)
        	component.set("v.ModalSize","slds-modal slds-fade-in-open slds-visible");   
        else
            component.set("v.ModalSize","slds-modal slds-fade-in-open slds-visible");
    },

     hidepopup: function(component, helper) {
        component.set("v.isPopup",false);
        var myEvent = $A.get("e.c:ModalCloseEvent");
        myEvent.setParams({
            "isModalEnabled":false
        });
        myEvent.fire();
    }
})