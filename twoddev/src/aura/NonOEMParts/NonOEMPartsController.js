({
	doInit : function(component, event, helper) {
		var claimId	=	component.get('v.claimId');
        var objectName	=	'Claim_Part__c';
        var action2	=	component.get('c.findSObjectsBySOQL');
        action2.setParams({
            "query" : "SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = "+'\''+ objectName +'\''
        });
        action2.setCallback(this, function(response) {
            var result	=	response.getReturnValue();
            console.log('::::: Result value:');
            console.log(result);
            for(var i=0;i < result.length; i++){
                if(result[i].DeveloperName =  'Miscellaneous_Part'){
                    //recordTypeId	=	result[i].Id;
                    console.log('::::: Developer name:'+result[i].DeveloperName);
                    component.set('v.recordTypeId',result[i].Id);
                }
            }
        });
        $A.enqueueAction(action2);
        
        
        
		var action 	= 	component.get('c.findSObjectsBySOQL');
		//component.set('v.context',$A.getContext().gg);
		//console.log(':::: context value:'+component.get('v.context'));
        console.log(claimId);
        action.setParams({
            "query" : "SELECT Id, Name, Miscellaneous_Part_Name__c, RecordType.Name, Inventory__c, Claim__c, Quantity__c, Custom_Part_Cost__c, Total_Parts_Cost__c, Price__c  FROM Claim_Part__c WHERE Claim__c =" + '\''+claimId +'\'' + ' AND RecordType.DeveloperName = ' + '\'' + component.get('v.recordTypeName') +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            component.set("v.nonOEMParts",response.getReturnValue());
            component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action);
	}
})