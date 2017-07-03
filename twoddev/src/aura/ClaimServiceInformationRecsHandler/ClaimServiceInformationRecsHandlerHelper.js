({
	deleteRecordsHelper : function(component, event) {
			component.set('v.isDelete',false);
            console.log('::::: Delete records:');
            console.log(component.get('v.deleteRecordNumbers'))
            var makeEmpty		=	[];
            //var deleteRecs		=	component.get('v.deleteRecordNumbers');
            var allRecords		=	component.get('v.claimServiceInfos');
            var deleteObj		=	[];
            console.log('::::: All Records:____________');
            console.log(allRecords);
        console.log('..................................'+allRecords.length);
            for(var i = 0; i < allRecords.length; i++) {
                console.log(':::: delete recs adding:');
                //console.log(deleteRecs[i]);
                deleteObj.push(allRecords[i]);
                //allRecords.splice(deleteRecs[i],1);
            }
            console.log(':::: delete objects:');
            console.log(deleteObj);
            var action 	= 	component.get('c.deleteSObject');
            action.setParams({
                "deleteRecords" : deleteObj
            });
            action.setCallback(this, function(response) {
                console.log(':::: Response:');
                console.log(response.getReturnValue());
                if(response.getState() == "SUCCESS") {
                    console.log('::::: all records:')
                    console.log(allRecords);
                    component.set('v.claimServiceInfos',allRecords);
                    component.set('v.deleteRecordNumbers',makeEmpty);
                    var myEvent = $A.get("e.c:ClaimServiceEvent");
                    myEvent.setParams({
                    });
                    myEvent.fire();

                } else {
                    console.log(':::: Errors while deleting');
                }
                component.set('v.isDeleteDisabled',false);

            });
            $A.enqueueAction(action);
	},

	deleteClaimServiceInfo : function(component, event, currentRecordNum){
			var allRecords		=	component.get('v.claimServiceInfos');
			var currentRecord	=	allRecords[currentRecordNum];
			console.log('::::: current record:');
			console.log(currentRecord);



			component.set('v.isDelete',false);
					console.log('::::: Delete records:');
					var allRecords		=	component.get('v.claimServiceInfos');
					var deleteObj		=	[];
					console.log('::::: All Records:');
					console.log(allRecords);
					//console.log('::::: Delete Recs:'+deleteRecs);
					deleteObj.push(currentRecord);
					console.log(':::: delete objects:');
					console.log(deleteObj);
					var action 	= 	component.get('c.deleteSObject');
					action.setParams({
							"deleteRecords" : deleteObj
					});
					action.setCallback(this, function(response) {
							console.log(':::: Response:');
							console.log(response.getReturnValue());
							if(response.getState() == "SUCCESS") {
									console.log('::::: all records:')
									console.log(allRecords);
									component.set('v.claimServiceInfos',allRecords);
									//component.set('v.deleteRecordNumbers',makeEmpty);
									var myEvent = $A.get("e.c:ClaimServiceEvent");
									myEvent.setParams({
									});
									myEvent.fire();

							} else {
									console.log(':::: Errors while deleting');
							}
                component.set('v.isDeleteDisabled',false);

					});
					$A.enqueueAction(action);
	}
})