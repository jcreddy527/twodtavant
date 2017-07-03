({
	myAction : function(component, event, helper) {
	},

	doInit : function(component, event, helper) { 
			
		helper.fetchFolderData(component,event);
	},
    
    readReportByOwnerID:function(component, event, helper) { 
         console.log('event ' + event);
        console.log(event);	
        var reportOwnerId=document.getElementById("reportId").value;
        helper.fetchReportData(component,event, reportOwnerId);
	},
    
    changeIcon : function(component, event, helper) {
		component.set("v.folderStatus","Open");
	},
    retainIcon : function(component, event, helper) {
		component.set("v.folderStatus","Close");
	}

})