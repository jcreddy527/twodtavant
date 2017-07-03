({
    currentRecordNum : '',
	deleteRecordsHelper : function(component, event) {
		var makeEmpty		=	[];
        var deleteRecs		=	component.get('v.deleteRecordNumbers');
        var allRecords		=	component.get('v.installedParts');
        var deleteObj			=	[];
				var dmlErrors			=	[];
        console.log('::::: All Records:');
        console.log(allRecords);
        for(var i = 0; i < allRecords.length; i++) {
            console.log(':::: delete recs adding:');
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
                component.set('v.installedParts',allRecords);
                component.set('v.deleteRecordNumbers',makeEmpty);
								if(response.getReturnValue().indexOf('error') > -1){
										console.log('::::::: Response value:inside setting the errors');
										dmlErrors.push(': '+response.getReturnValue());
										component.set('v.dmlErrors',dmlErrors);
								}
								else{
										var myEvent = $A.get("e.c:UpdateInstalledParts");
										myEvent.setParams({
										});
										myEvent.fire();
								}
            } else {
								dmlErrors.push(': '+response.getReturnValue());
								component.set('v.dmlErrors',dmlErrors);
            }
            component.set('v.isDeleteDisabled',false);

        });
        $A.enqueueAction(action);

	},

	deleteIndividualRecords : function(component, event, currentRecordNum){
			var allRecords		=	component.get('v.installedParts');
			console.log('::::: All Records:');
			console.log(allRecords);
			console.log(currentRecordNum);
			var deleteRecord = allRecords[currentRecordNum];
			var deleteRecs 	 =	[];
			var dmlErrors			=	[];
			deleteRecs.push(deleteRecord);
			console.log(':::::: Delete Record:');
			console.log(deleteRecs);
			var action 	= 	component.get('c.deleteSObject');
			action.setParams({
					"deleteRecords" : deleteRecs
			});
			action.setCallback(this, function(response) {
					console.log(':::: Total Response:');
					console.log(response);
					console.log(':::: Response.getState:'+response.getState());
					console.log(':::: Response:');
					console.log(response.getReturnValue());
					if(response.getState() == "SUCCESS") {
							console.log('::::: all records:')
							console.log(allRecords);
							var errorsList = [];
							if(response.getReturnValue().indexOf('error') > -1){
									console.log('::::::: Response value:inside setting the errors');
									dmlErrors.push(': '+response.getReturnValue());
									component.set('v.dmlErrors',dmlErrors);
							}else{
								dmlErrors.push(errorsList);
								component.set('v.dmlErrors',null);
								//component.set('v.installedParts',allRecords);
								//component.set('v.deleteRecordNumbers',makeEmpty);
								var myEvent = $A.get("e.c:UpdateInstalledParts");
								myEvent.setParams({
								});
								myEvent.fire();
							}
					} else {
							console.log('::::: Responseeeeeeeeeeeeeeeeeeee:'+response.getReturnValue());
							dmlErrors.push(': '+response.getReturnValue());
							component.set('v.dmlErrors',dmlErrors);
					}
            component.set('v.isDeleteDisabled',false);

			});
			$A.enqueueAction(action);
	}


})