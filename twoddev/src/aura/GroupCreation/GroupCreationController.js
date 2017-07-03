({
    doInit : function(component, event, helper) {
        
        var action=component.get("c.getGroups");
        action.setParams({"objectName":component.get("v.objectName")});
        action.setCallback(this, function(a) {
            
            var result = a.getReturnValue();
          
            if(result.length > 0){
                component.set("v.showTable",true);
                component.set("v.groupWrap", result);
            }
            if(result.length == 0  ){
                component.set("v.showTable",false);
                component.set("v.showNew",true);
            } 
             
        });
        $A.enqueueAction(action);
        
    },
    
    addtoGroup: function(component, event, helper) {
      
        component.set("v.showSpinner",true);
        component.set("v.showTable",false);
        var groups=component.get("v.groupWrap");
        var selectedids=[];
        for(var i=0;i<groups.length;i++){
            if(groups[i].isSelected){
                
                selectedids.push(groups[i].groupWr.Id);
            }
        }
        var ids=component.get("v.groups");
        var idsArray=[];
        idsArray=ids.split(",");
        var grp=groups.toString();
        if(selectedids.length>0 && ids.length>0){
            var action=component.get("c.AddGroupMember");
            action.setParams({"wrpGroupList":selectedids,"idsList":idsArray});
            action.setCallback(this, function(a) { 
                
                window.history.go(-1);
                
            });
            $A.enqueueAction(action); 
        }
        else{
            component.set("v.showError",true);
            component.set("v.showSpinner",false);
        }
        
    },
    createGroup: function(component, event, helper) {
        
        component.set("v.showTable",false);
        component.set("v.showNew",true);
    },
    cancel: function(component, event, helper) {
        window.history.go(-1); 
    },
    
    searchGroup:function(component,event){
        component.set("v.showSpinner",true);
        var cmpTarget = component.find("outer");
        
        $A.util.addClass(cmpTarget,"blur");
        
        var strSearch = event.getSource().get('v.value');
        component.set("v.showToast", false);
        var action=component.get("c.groupSearch");
        action.setParams({"objectName":component.get("v.objectName"),"searchString":strSearch});
        action.setCallback(this, function(a) {
            component.set("v.showTable",true);
            var result = a.getReturnValue();
            component.set("v.groupWrap", result);
            component.set("v.showSpinner",false);
            $A.util.removeClass(cmpTarget,'blur');
          
            
        });
        $A.enqueueAction(action);
    },
    gotoListView:function(component,event){
        window.history.go(-1);
        component.set("v.showError",false); 
        component.set("v.showTable",true);
    }
})