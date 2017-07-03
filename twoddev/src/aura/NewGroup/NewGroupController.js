({
	createGroup : function(component, event, helper) {
        component.set("v.showSpinner",true);
         component.set("v.showTable",false);
        var action=component.get("c.createNewGroup");
        var objGrp=component.get("v.newGroup");
        var recordIds=[];
        var ids=component.get("v.recordIds");
        var name=objGrp.Name__c;
         
        if(ids.length>0 && (objGrp.Name__c  )){
        recordIds=component.get("v.recordIds").split(",");
        objGrp.Object_Name__c=component.get("v.objectName");
        action.setParams({"objGroup":objGrp,"recordids":recordIds});
        action.setCallback(this, function(a) { 
         var result = a.getReturnValue();
               window.history.go(-1);
            });
        $A.enqueueAction(action);
        }
        else {
         component.set("v.showSpinner",false);
         component.set("v.showError",true);
         component.set("v.showTable",false); 
        }
	},
    cancel : function(component, event, helper) {
        window.history.go(-1);
    },
    gotoListView:function(component, event, helper) {
        window.history.go(-1);
    }
})