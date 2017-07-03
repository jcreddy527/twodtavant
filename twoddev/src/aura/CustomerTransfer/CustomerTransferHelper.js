({
	findIndexWithProperty: function(array, attr, value) {

			for (var i = 0; i < array.length; i += 1) {
					if (array[i][attr] === value) {
							return i;
					}
			}
			return -1;
	},
    getTodayDate: function(component, event) {

        var todayDate = new Date();
        var timezone = $A.get("$Locale.timezone");
        var todayDateString = '';
        var self = this;

        $A.localizationService.getToday(timezone, function(today) {
            todayDateString = today;
            todayDateString = self.getDateReadableFormat(todayDateString);
            return todayDateString;
        });
        return todayDateString;

    },
    getDateReadableFormat: function(dateString) {

        var returnableDateString = "";
        var convertableDate = new Date(dateString);
        var dateString = convertableDate.getDate() + "";
        var monthString = (convertableDate.getMonth() + 1) + "";
        if (dateString.length === 1) {
            dateString = "0" + dateString;
        }
        if (monthString.length === 1) {
            monthString = "0" + monthString;
        }
        returnableDateString = convertableDate.getFullYear() + "-" + monthString + "-" + dateString;

        return returnableDateString;
    },
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


                if (alertbox !== undefined && alertbox !== null && alertbox.isValid()) {
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