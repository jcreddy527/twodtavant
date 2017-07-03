({
	doInit : function(component, event, helper) {
        var claimId	=	component.get('v.claimId');
				var action 	= 	component.get('c.findSObjectsBySOQL');
        var nonOEM		=	'Miscellaneous_Part';
				//component.set('v.context',$A.getContext().gg);
				//console.log(':::: context value:'+component.get('v.context'));
        console.log(claimId);
        action.setParams({
            "query" : "SELECT Id, Name,Invoice_Date__c,Invoice_Number__c,Standard_Part_Cost__c, Warranty_Product_Pricebook__c, Total_Amount__c, RecordType.Name, Inventory__r.Name, Inventory__c, Claim__c, Warranty_Product__r.Name, Warranty_Product__c, Quantity__c, Custom_Part_Cost__c, Final_Parts_Cost__c, Total_Parts_Cost__c, Price__c  FROM Claim_Part__c WHERE Claim__c =" + '\''+claimId +'\'' + " AND RecordType.DeveloperName != " +'\'' +nonOEM +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            component.set("v.installedParts",response.getReturnValue());
            component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action);

				var action1 	= 	component.get('c.findSObjectsBySOQL');
        action1.setParams({
            "query" : "SELECT DeveloperName,Id,Name FROM RecordType WHERE SobjectType = 'Claim_Part__c' ORDER BY DeveloperName DESC"
        });
        action1.setCallback(this, function(response) {
            console.log(':::: Response from server record types:');
            console.log(response.getReturnValue());
            component.set("v.installedPartRecordTypes",response.getReturnValue());
            //component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action1);


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

				var action3 	= 	component.get('c.claimInstalledPartsInventoryIds');
        action3.setParams({
            "claimId" : component.get('v.claimId')
        });
        action3.setCallback(this, function(response) {
						console.log('::::: installedPartInventoryIds Avoind Ids :'+response.getReturnValue());
						var ids = [];
						for(var i=0; i<response.getReturnValue().length; i++){
							 ids.push(response.getReturnValue()[i]);
						}
						console.log('::::: ids value:'+ids);
						component.set('v.avoidIds',ids);
				});
				$A.enqueueAction(action3);
	}
})