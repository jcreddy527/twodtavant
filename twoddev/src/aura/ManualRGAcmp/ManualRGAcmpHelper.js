({
	checkIfAllSuccessfullyUpdated : function(sobjectsAndStatusList) {

		var status = true;
		for(var i=0,len=sobjectsAndStatusList.length;i<len;i++){

			if(sobjectsAndStatusList[i]['status']!=='successful'){
				status = false;
				break;
			}

		}
		return status;
	},

	/***alert box helper method***/
	showAlert: function(component, event, alertboxContent) {

			// create dynamic alert box with some initializations
			var self = this;
			var test;
			$A.createComponent(
					"c:AlertboxCmp", {
							message: alertboxContent.message,
							heading: alertboxContent.heading,
							class: alertboxContent.class,
							onOkay: alertboxContent.callableFunction,
							onSecondaryOkay: alertboxContent.secondaryCallableFunction,
							buttonHeading: alertboxContent.buttonHeading,
							secondaryButtonHeading: alertboxContent.secondaryButtonHeading
					},
					function(alertbox) {


							if (alertbox != undefined && alertbox != null && alertbox.isValid()) {
									var body = [];
									body.push(alertbox);
									if (!alertbox.isInstanceOf("c:AlertboxCmp")) {
											component.set("v.body", []);
									} else {
											component.set("v.body", body);
									}

							}
					}

			);

	},

})