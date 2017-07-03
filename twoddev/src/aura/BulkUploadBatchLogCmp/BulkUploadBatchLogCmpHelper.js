({
	getBatch : function(cmp) {
        
      var batchId = cmp.get("v.BatchId");
      
      var action = cmp.get("c.getBatchJobData");
      action.setParams({
          "batchIdval": batchId
      }); 
      alert('BatchId :'+batchId);
      action.setCallback(this, function(resp) {
          if(resp.getReturnValue()[0]!=null && resp.getReturnValue()[0].length>0){
              cmp.set("v.BatchLogs", resp.getReturnValue()[0]);
              
          }
          if(resp.getReturnValue()[1]!=null && resp.getReturnValue()[1].length>0){
              cmp.set("v.UploadStages", resp.getReturnValue()[1])
              cmp.set("v.StageAvailable", true);
          }else{
              cmp.set("v.StageAvailable", false);
          }
          cmp.set("v.showSpinner",false); 
      });
      
      $A.enqueueAction(action);
	},
})