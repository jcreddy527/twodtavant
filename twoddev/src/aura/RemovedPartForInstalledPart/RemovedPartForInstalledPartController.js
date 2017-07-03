({
	doInit	: function(component, event, helper){
			var action1 = component.get('c.getAllInventoryIds');
			action1.setParams({
					"claimId" : component.get('v.claimId')
			});
			action1.setCallback(this, function(response) {
					console.log('::::: Response value:'+response.getReturnValue());
					component.set('v.inventoriesToAvoid', response.getReturnValue());
					console.log(':::: Avoid ids from server call:'+component.get('v.inventoriesToAvoid'));
			});
			$A.enqueueAction(action1);
	},

	saveRecord : function(component, event, helper) {

				event.preventDefault();

				var errorCount = 0;
        console.log(':::::::::::: Inventory ids:');
				console.log(component.get('v.inventoriesToAvoid'));
				var Recs	=	component.get('v.removedPart');
        console.log('--claimid---'+component.get('v.claimId'));
        Recs.claim__c=component.get('v.claimId');
        console.log('::::: Recs:');
        console.log('::::: removedPartId:'+component.get('v.removedPartId'));
        console.log('::::: Inventory Id:'+component.get('v.inventoryId'));
        //component.set('v.removedPart.Id',component.get('v.removedPartId'));
        var inventoryId	=	component.get('v.inventoryId');
        if(component.get('v.isShowInv')){
            component.set('v.removedPart.Inventory__c',component.get('v.inventoryId'));
            Recs.Inventory__c	=	inventoryId;
        }else{
            component.set('v.removedPart.Warranty_Product__c',component.get('v.inventoryId'));
            Recs.Warranty_Product__c	=	inventoryId;
        }
        if(component.get('v.tempInvId') == inventoryId){
            component.set("v.dmlErrors",": You can't use the already used Inventory");
            errorCount ++;
        }
        console.log('::: Invnetory Id value:'+inventoryId);
        console.log(Recs);
        console.log(component.get('v.removedPart'));
        var listRecs	=	[];
        listRecs.push(component.get('v.removedPart'));
        var isError	=	false;
        if(component.get('v.inventoryId') == null || component.get('v.inventoryId') == '' || typeof component.get('v.inventoryId') == "undefined"){
            if(component.get('v.isShowInv')){
                errorCount ++;
                component.set('v.inventoryError','Please select an Inventory');
            }else{
                errorCount ++;
                component.set('v.inventoryError','Please select a Part');
            }
            isError = true;
        }

        var inventoryIds 	=	component.get('v.inventoriesToAvoid');
        var index 				=	inventoryIds.indexOf(component.get('v.inventoryId'));
        if(index < 0) {
            component.set("v.dmlErrors",null);
        } else {
            component.set("v.dmlErrors",": You can't use the already used Inventory");
            errorCount ++;
        }
        console.log(':::::::::: error count:'+errorCount);
        console.log(inventoryId);
		console.log(listRecs);
        var removedPart = JSON.stringify(Recs);
        
        if(errorCount < 1){
        	var action 	= 	component.get('c.insertRemovedPartForSerializedInventory');
            action.setParams({
                "removedPart" : removedPart
            });
            action.setCallback(this, function(response) {
                console.log(':::: Response:');
                console.log(response.getReturnValue());
                var myEvent = $A.get("e.c:UpdateInstalledParts");
                myEvent.setParams({
                });
                myEvent.fire();

                var myEvent = $A.get("e.c:ModalCloseEvent");
                myEvent.setParams({
                    "isModalEnabled":false
                });
                myEvent.fire();

            });
            $A.enqueueAction(action);
        }


	},
	changeModalClose	: function(component, event, helper){
			event.preventDefault();
			var myEvent = $A.get("e.c:ModalCloseEvent");
			myEvent.setParams({
					"isModalEnabled":false
			});
			myEvent.fire();
	}
})