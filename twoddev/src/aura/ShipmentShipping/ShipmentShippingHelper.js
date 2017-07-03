({
    helperMethod : function() {
        
    },
    cancelURL : function (component, event, helper) {
        this.urlSwitcher (component, event, helper);   
    },
    updateURL : function (component, event, helper) {
        
        var self = this;
        var validationSuccess  = self.validationSuccesStatus(component,event);
        
        if(validationSuccess===true){
            
            var shipmentObject = component.get("v.shipmentObject");
            console.log(JSON.parse(JSON.stringify(shipmentObject)));
            
            if(shipmentObject['Shipper_Comments__c']===null || shipmentObject['Shipper_Comments__c']===undefined || shipmentObject['Shipper_Comments__c'] ==='' ){
                component.set("v.error.fieldError.description",$A.get("$Label.c.Shipper_Comment_Mandatory"));
            }
            else{
                component.set("v.error.fieldError.description","");    
            }
            if(shipmentObject['Shipment_Date__c']===null || shipmentObject['Shipment_Date__c']===undefined 
               || shipmentObject['Shipment_Date__c']==='' ){
                component.set("v.error.fieldError.shipDate",$A.get("$Label.c.Shipment_Date_Mandatory"));   
            }
            else{
                component.set("v.error.fieldError.shipDate",""); 
            }
            if((component.get("v.error.fieldError.shipDate")==='')&&  (component.get("v.error.fieldError.description")==='')){
                
                //set the spinner
                component.set('v.actionSpinner',true);
                helper.updateRaw(component, event, helper, shipmentObject, function(shipmentResponse){
                    
                    
                    
                    if(shipmentResponse!==null && shipmentResponse!==undefined){
                        // set error in updation alert
                        var errorException = shipmentResponse['exception'];
                        var errorArrays = shipmentResponse['errorList'];
                        if ((errorException != null && errorException != undefined) || (errorArrays != null && errorArrays != undefined && errorArrays.length != 0)) {
                            //hide spinner
                            component.set('v.actionSpinner',false);
                            var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                            console.log(errorMessagesFormattedInString);
                            var alertboxContent = {
                                message: errorMessagesFormattedInString,
                                heading: $A.get("$Label.c.Shipment_Ship_Update_H"),
                                class: 'slds-theme--error',
                                callableFunction: component.getReference('c.closeAlert'),
                                buttonHeading: $A.get("$Label.c.OK")
                            };
                            helper.showAlert(component, event, alertboxContent);
                        }
                        else  {
                            helper.urlSwitcher (component, event, helper);
                        }
                    }
                });
            }  
        }else{
            
            var alertBoxData = {
                message: 'Please review all error messages..',
                heading: 'Shipment page says..',
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            self.showAlert(component, event, alertBoxData);
            
        }   
        
    },
    
    urlSwitcher: function (component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var shipmentRecordID = component.get("v.shipmentId");
        if(urlEvent!==undefined && urlEvent!==null){
            urlEvent.setParams({
                "url": "'"+shipmentRecordID+"'"
            });
            urlEvent.fire();
        }else{
            var ProceedURL = ''; 
            var BaseUrl =component.get('v.BaseURL');     
            console.log("record"+shipmentRecordID+BaseUrl);
            if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined') {
                if(BaseUrl.indexOf('lightning') !=-1){
                    ProceedURL = "/ShipmentShippingApp/ShipmentShipping.app#/sObject/"+shipmentRecordID+'/view';
                }else{
                    ProceedURL = BaseUrl+"/"+shipmentRecordID;
                }                                
                window.location.href=ProceedURL;
            } 
        }
        
        
        
        
    },
    
    removeError : function (component, event, helper) {
        var id = event.getSource().getLocalId(); 
        
        
        
        if(id==='shipDate'){
            component.set("v.error.fieldError.shipDate","");    
        }
        else if(id==='shipComment'){
            component.set("v.error.fieldError.description",""); 
        }
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
    
    getErrorMessage: function(exceptionObject, errorArrayObject) {
        
        var returnableErrorString = '';
        
        if (errorArrayObject !== null && errorArrayObject !== undefined && errorArrayObject.length !== 0) {
            
            var errorMessages = errorArrayObject[0]['errorMesssages'];
            if (errorMessages !== null && errorMessages !== undefined && errorMessages.length !== 0) {
                
                var stringifyErrorMessages = errorMessages.join("\r\n");
                returnableErrorString = returnableErrorString + "\r\n" + stringifyErrorMessages;
                
            }
            
        }
        
        if (exceptionObject !== null && exceptionObject !== undefined && exceptionObject.length !== 0) {
            
            var errorMessages = exceptionObject[0]['message'];
            if (!Array.isArray(errorMessages)) {
                errorMessages = [errorMessages];
            }
            if (errorMessages !== null && errorMessages !== undefined && errorMessages.length !== 0) {
                
                var stringifyErrorMessages = errorMessages.join("\r\n");
                returnableErrorString = returnableErrorString + "\r\n" + stringifyErrorMessages;
                
            }
            
        }
        
        return returnableErrorString;
        
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
        if(component.get('v.error.fieldError.shipDate')!==''){
            temporaryStatusObject.shipmentDate = false;
            
        }else{
            
            var shipmentDate = component.get('v.shipmentDate');
            var todayDate = self.getTodayDate();
            if(shipmentDate!==null && shipmentDate!==undefined && shipmentDate!==''){
                if (new Date(shipmentDate) > new Date(todayDate)) {
                    component.set('v.error.fieldError.shipDate', $A.get("$Label.c.Shipment_Date_Error"));
                    temporaryStatusObject.shipmentDate = false;
                }else{
                    component.set('v.error.fieldError.shipDate', '');
                    component.set('v.shipmentObject.Shipment_Date__c',shipmentDate);
                    temporaryStatusObject.shipmentDate = true;
                }
            }else{
                component.set('v.error.fieldError.shipDate', $A.get("$Label.c.Shipment_Date_Error"));
                temporaryStatusObject.shipmentDate = false;
            }
            
        }
        
        if(component.get('v.error.fieldError.description')!==''){
            temporaryStatusObject.description = false;
        }else{
            
            var description = component.get('v.shipmentObject.Shipper_Comments__c');
            if(description!==null && description!==undefined && description!==''){
                component.set('v.error.fieldError.description','');
                temporaryStatusObject.description = true;
            }else{
                component.set('v.error.fieldError.description',$A.get("$Label.c.Shipper_Comment_Mandatory"));
                temporaryStatusObject.description = false;
            }
            
        }
        
        finalStatus = self.analyseTempValidation(temporaryStatusObject);
        return finalStatus;
        
    }
    
})