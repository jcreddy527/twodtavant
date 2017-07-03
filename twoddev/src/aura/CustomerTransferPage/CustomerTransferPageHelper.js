({
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
	getTodayDate: function(component, event) {
        //19-NOV-2016
        var todayDate = new Date();
        var todayDateString = '';
        var self = this;
        todayDateString = self.getDateReadableFormat(todayDate);
        return todayDateString;
        //--19-NOV-2016
    },
     
    analyseTempValidation: function(temporaryValidationObject) {

        var validationSuccess = true;

        for (var key in temporaryValidationObject) {
            if (temporaryValidationObject[key] === false) {
                validationSuccess = false;
                break;
            }
        }
        return validationSuccess;

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
    validationSuccesStatus : function(component,event){
    
    	var finalStatus = false;
        var temporaryStatusObject = {};
        var self= this;
        if(component.get('v.error.fieldError.transferDate')!==''){
            temporaryStatusObject.transferDate = false;
        }else{
            temporaryStatusObject.transferDate = true;
        }
        
        finalStatus = self.analyseTempValidation(temporaryStatusObject);
        return finalStatus;
    
	}
})