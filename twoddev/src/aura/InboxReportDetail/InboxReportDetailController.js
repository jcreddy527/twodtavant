({
	myAction : function(component, event, helper) {
		
	},
    doInit : function(component, event, helper) {
        
        helper.fetchReportRecordCount(component,event);
        var reportId=component.get("v.reportDetail.Id");
        var reportDevName = component.get("v.reportDetail.DeveloperName");
        
        var imageName=component.get("v.reportDetail.Report_Image")
        var resource='$Resource.'+imageName;        
         var profUrl = $A.get(resource);        
        component.set("v.Report_Image",profUrl);
        helper.totalRecordCountInReport(component, event, helper , reportId,function(result){
             var spinner = component.find('spinnerID');
             $A.util.removeClass(spinner,'slds-show');
             $A.util.addClass(spinner,'slds-hide');
             component.set("v.recordCount",result.response);
            
        } );
	},
    
    changeIcon : function(component, event, helper) {
		//console.log('hello I am mover hovering');  
        component.set("v.folderStatus","Open");
	},
    retainIcon : function(component, event, helper) {
		//console.log('hello I moving out of this.'); 
        component.set("v.folderStatus","Close");
	}
})