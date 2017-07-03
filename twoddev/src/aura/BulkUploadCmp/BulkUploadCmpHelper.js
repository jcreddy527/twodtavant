({
	createStageRec: function(component, fileContents, helper) {
	
        var action = component.get("c.saveTheFile");
        var processType = component.get("v.processTypeName");
        action.setParams({
            "bulkUploadData": fileContents,
            "processType": processType
        });
        action.setCallback(this, function(a) {
            console.log(a.getState());
        });
        $A.enqueueAction(action);
		
		helper.StartBatchProcess(component);
		
	},
	
	StartBatchProcess: function(component){
	
		var action = component.get("c.getBatchId");
		console.log("Batch Start Started!!");
		action.setCallback(this, function(a) {
			console.log('bLogId :' +a.getReturnValue().BatchLogId);
			console.log('batchId :'+ a.getReturnValue().BatchId );
			console.log('recCnt :'+a.getReturnValue().RecordCnt);
			if(a.getReturnValue() != null){
				component.set("v.bLogId", a.getReturnValue().BatchLogId);
				component.set("v.batchId", a.getReturnValue().BatchId);
				component.set("v.RecCnt", a.getReturnValue().RecordCnt);
				component.set("v.shwBatchDetails", true);
				component.set("v.showSection1", false);
				component.set("v.showSection2", false);
				component.set("v.showSection3", false);
			}
		
		});
		$A.enqueueAction(action);
	
	},
	
})