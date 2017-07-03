({
	helperMethod : function() {
		
	},
    
    fetchReportRecordCount:function(component,event){
        
    /*    var reportRecordCount = component.get("c.totalRecordsCount");
        var spinner = component.find('spinnerID');
        // reportRecordCount.setAbortable();
        reportRecordCount.setParams({
            reportIdVal : [component.get("v.reportDetail.Id")]
        });  
        reportRecordCount.setCallback(this, function(response) {
            
            console.log(response.getState());
            console.log('the response is');
            console.log(response);
            console.log("XYZZZ");
            console.log(response.getReturnValue()[0]);
            if(response.getState() == 'SUCCESS')
            {
                
             //   $A.util.removeClass(spinner,'slds-show');
             //   $A.util.addClass(spinner,'slds-hide');
                if(typeof response.getReturnValue()[0] != "undefined" ){
                    component.set("v.recordCount",response.getReturnValue()[0]);
                }
                else{
                    component.set("v.recordCount",0);
                }
                console.log(component.get("v.recordCount"));
            }else{
                var spinner = component.find('spinnerID');
                $A.util.addClass(spinner,'slds-hide');
            }
        });
        $A.enqueueAction(reportRecordCount);  */
    }
})