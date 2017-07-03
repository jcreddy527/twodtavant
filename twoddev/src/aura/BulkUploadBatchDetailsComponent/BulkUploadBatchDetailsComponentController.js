({
	cancel :function (component,event,helper){

		window.location.href = '/apex/BulkUploadLightning';		
	},
	
	getBatchLogId :function (component,event,helper){

		var batchLogId = component.get("v.batchLogId");
		console.log('url  :'+'/'+batchLogId);
		window.location.href = '/'+batchLogId;
	},
})