({
    allInstalledPartIds	:[],
	updateValues : function(component, event) {
        
        var myEvent = $A.get("e.c:UpdateInstalledParts");
			myEvent.setParams({
			});
			myEvent.fire();

			var myEvent = $A.get("e.c:ModalCloseEvent");
	    myEvent.setParams({
	        "isModalEnabled":false
	    });
	    myEvent.fire();

	},

	 inventoryProductCost	: function(component, event, isInv){
			var action 		= 	component.get('c.receiveProductCostAndPriceBookId');
			//var isInv		=	component.get('v.isInvSave');
			var queryVal= 	''; //
			//component.set('v.showSpinner',true);
			console.log("Hey2");
			if(!isInv){
					queryVal	= 	"SELECT Id, Name  FROM Warranty_Product__c  WHERE Id ="+'\''+component.get('v.warrantyProductId')+'\'';
      } else {
      		queryVal	= 	"SELECT Id, Name, Item__c FROM Inventory__c  WHERE Id ="+'\''+component.get('v.inventoryId')+'\'';
      }
      console.log(':::: Query val:');
			console.log(queryVal);
			action.setParams({
				"query" : queryVal,
				"isInv" : isInv
			});
			action.setCallback(this, function(response) {
				console.log(':::: response cost value:');
				console.log(response.getReturnValue());
				if(response.getReturnValue().length > 0){
						component.set('v.costValue',response.getReturnValue()[0].Price__c);
						component.set('v.installedPart.Warranty_Product_Pricebook__c',response.getReturnValue()[0].Id);
						console.log('::::: installedPart information:');
						console.log(component.get('v.installedPart'));
						component.set('v.showSpinner',false);
				}else{
						component.set('v.costValue',0.00);
						component.set('v.installedPart.Warranty_Product_Pricebook__c','');
				}

			});
			$A.enqueueAction(action);
	}, 
})