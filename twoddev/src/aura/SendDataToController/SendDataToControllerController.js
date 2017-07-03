({
	saveRecord : function(component, event, helper) {
        console.log(':::: Contact Record:');
        console.log(component.get('v.contactRec'));
        var fullName	=	component.get('v.contactRec.FirstName') + ' ' + component.get('v.contactRec.LastName');
        component.set('v.accountRec.Name',fullName);
        component.set('v.accountRec.Email__c', component.get('v.contactRec.Email'));
        var listRec = [];
        listRec.push(component.get('v.accountRec'));
        listRec.push(component.get('v.contactRec'));
        var action = component.get('c.insertContactAndAccountRecords');
		action.setParams({
				"receivedData" : listRec
		});
		action.setCallback(this, function(response) {
				console.log('::::: Response value:'+response.getReturnValue());
		});
		$A.enqueueAction(action);
	}
})