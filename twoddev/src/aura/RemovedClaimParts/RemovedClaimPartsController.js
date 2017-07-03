({
	doInit : function(component, event, helper) {
        var claimId	=	component.get('v.claimId');
		var action 	= 	component.get('c.findSObjectsBySOQL');
		//component.set('v.context',$A.getContext().gg);
        console.log(claimId);
        action.setParams({
            "query" : "SELECT Id, Name, Claim__c, RecordType.Name, Inventory__r.Name, Inventory__c, Warranty_Product__r.Name, Warranty_Product__c, Quantity__c  FROM Removed_Claim_Part__c WHERE Claim__c =" + '\''+claimId +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            component.set("v.installedParts",response.getReturnValue());
            component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action);

				var action2 	= 	component.get('c.findSObjectsBySOQL');
        action2.setParams({
            "query" : "SELECT DeveloperName,Id,Name FROM RecordType WHERE SobjectType = 'Removed_Claim_Part__c' ORDER BY DeveloperName DESC"
        });
        action2.setCallback(this, function(response) {
            console.log(':::: Response from server removedPartRecordTypes:');
            console.log(response.getReturnValue());
            component.set("v.removedPartRecordTypes",response.getReturnValue());
            //component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action2);
	}
})