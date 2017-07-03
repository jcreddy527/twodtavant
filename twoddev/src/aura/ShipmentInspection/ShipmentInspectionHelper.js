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
            var self = this;
            
            if((component.get("v.error.fieldError.inspectionDate")==='')){
                
                var claimShipmentPartList = JSON.parse(JSON.stringify(component.get('v.claimShipmentPartList')));
          
                var commentsValidated = self.validateCommentsInParts(claimShipmentPartList);	
                if(commentsValidated){
                    
                    //show spinner
                    component.set('v.actionSpinner',true);
                    helper.updateRaw(component, event, helper, shipmentObject, function(shipmentResponse){
                        
                        
                        if(shipmentResponse!==null && shipmentResponse!==undefined){
                            if (shipmentResponse['sobjectsAndStatus'] != undefined && shipmentResponse['sobjectsAndStatus'] != null &&
                                shipmentResponse['sobjectsAndStatus'].length != 0) {
                                var isSuccessfulUpdate = shipmentResponse['sobjectsAndStatus'][0]['status'];
                                if (isSuccessfulUpdate == 'successful') {
                                    helper.updateRaw(component, event, helper, claimShipmentPartList, function(claimPartUpdateResponse){
                                        helper.urlSwitcher (component, event, helper);
                              
                                    });
                                }else{
                                    //hide spinner
                                    component.set('v.actionSpinner',false);
                                    // set error in updation alert
                                    var errorException = shipmentResponse['exception'];
                                    var errorArrays = shipmentResponse['errorList'];
                                    if ((errorException != null && errorException != undefined) || (errorArrays != null && errorArrays != undefined && errorArrays.length != 0)) {
                                        var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Shipment_Received_Update_H"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }); 
                    
                    
                }else{
                    var alertboxContent = {
                        message: 'All comments fields are mandatory, kindly fill them..',
                        heading: 'Comments not populated...',
                        class: 'slds-theme--error',
                        callableFunction: component.getReference('c.closeAlert'),
                        buttonHeading: $A.get("$Label.c.OK")
                    };
                    self.showAlert(component, event, alertboxContent);
                    
                    
                }	
            }  
            
        }else{
            
            var alertBoxData = {
                message: 'Please review all error messages..',
                heading: 'Inspect shipment page says..',
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
       
            if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined') {
                if(BaseUrl.indexOf('lightning') !=-1){
                    ProceedURL = "/ShipmentInspectionApp/ShipmentInspection.app#/sObject/"+shipmentRecordID+'/view';
                }else{
                    ProceedURL = BaseUrl+"/"+shipmentRecordID;
                }                                
                window.location.href=ProceedURL;
            } 
        }
    },
    
    removeError : function (component, event, helper) {
        var id = event.getSource().getLocalId(); 
        
        if(id==='inspectionDate'){
            component.set("v.error.fieldError.inspectionDate","");    
        }
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
    
    validateCommentsInParts : function(claimShipmentPartList){
        
        var validationSuccessful = true;
        var self = this;
        if(!self.isListNullEmpty(claimShipmentPartList)){
            
            for(var i=0,len=claimShipmentPartList.length;i<len;i++){
                
                if(self.isNullUndefined(claimShipmentPartList[i]['Inspection_Comments__c']))	{
                    validationSuccessful = false;
                    break;
                }
            }
        }
        
        return validationSuccessful;
        
    },
    
    isListNullEmpty: function(givenList) {
        
        if (givenList !== undefined && givenList !== null && Array.isArray(givenList) && givenList.length !== 0) {
            return false;
        } else {
            return true;
        }
        
    },
    isNullUndefined: function(givenObject) {
        
        var returnStatus = true;
        
        if (givenObject !== undefined && givenObject !== null && givenObject !== '') {
            returnStatus = false;
        }
        
        return returnStatus;
        
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
        if(component.get('v.error.fieldError.inspectionDate')!==''){
            temporaryStatusObject.inspectionDate = false;
            
        }else{
            
            var inspectionDate = component.get('v.shipmentInspectionDate');
            var todayDate = self.getTodayDate();
            var receivedDate = self.getDateReadableFormat(component.get('v.shipmentObject.Shipment_Received_Date__c'));
            
            if(inspectionDate!==null && inspectionDate!==undefined && inspectionDate!==''){
                if (new Date(inspectionDate) > new Date(todayDate)) {
                    component.set('v.error.fieldError.inspectionDate', $A.get("$Label.c.Shipment_Inspection_Date_Error"));
                    temporaryStatusObject.inspectionDate = false;
                }else{
                       
                if(new Date(inspectionDate) < new Date(receivedDate)){
                    component.set('v.error.fieldError.inspectionDate',  $A.get("$Label.c.Shipment_Inspection_Date_Error"));
                    temporaryStatusObject.inspectionDate = false;
                }else{
                    component.set('v.error.fieldError.inspectionDate', '');
                    component.set('v.shipmentObject.Inspection_Date__c',inspectionDate);
                    temporaryStatusObject.inspectionDate = true;
                }
                    
                }
            }else{
                component.set('v.error.fieldError.inspectionDate', $A.get("$Label.c.Shipment_Inspection_Date_Error"));
                temporaryStatusObject.inspectionDate = false;
            }
            
        }
        
        finalStatus = self.analyseTempValidation(temporaryStatusObject);
        return finalStatus;
        
    }
    
    
})