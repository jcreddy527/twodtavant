({
    doInit : function(component, event, helper) {
       helper.doInit(component, event, helper);	
    },
    save : function(component, event, helper) {
       helper.createRecord(component, event, helper);	
    },
    cancel : function(component, event, helper) {
       helper.cancel(component, event, helper);	
    }
})