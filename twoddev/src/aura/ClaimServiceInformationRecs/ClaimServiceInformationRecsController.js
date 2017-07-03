({
	doInit : function(component, event, helper) {
        var claimId	=	component.get('v.claimId');
				var action 	= 	component.get('c.findSObjectsBySOQL');
        console.log(':::: Claim Id:');
				//component.set('v.context',$A.getContext().gg);
        console.log(claimId);
        action.setParams({
            "query" : "SELECT Id, Name, Additional_Labor_Hour__c, Service_Job_Code__c, Service_Job_Code__r.Description__c, Service_Job_Code__r.Name, Reason_Additional_Labor_hour__c, Total_Labor_hours__c, Claim__c FROM Claim_Service_Information__c WHERE Claim__c = " + '\''+claimId +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            component.set("v.claimServiceInfoRecs",response.getReturnValue());
            component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action);
	},
})