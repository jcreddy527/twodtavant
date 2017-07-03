({
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
            
            var inventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
            var installedDate = inventory['Install_Date__c'];
            var transferDate = component.get('v.date');
            
            if(transferDate!==null && transferDate!==undefined && transferDate!==''){
                
                transferDate = new Date(transferDate);
                
                if(transferDate!=='Invalid Date'){
                    
                    if(installedDate!==null && installedDate!==undefined && installedDate!==''){
                        
                        //case for RMT    
                        installedDate = new Date(installedDate);
                        
                        if(transferDate<installedDate){
                                component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Error')
                                          + self.getDateReadableFormat(installedDate));
                            temporaryStatusObject.transferDate = false;
                        }else{
                            component.set('v.error.fieldError.transferDate','');
                            temporaryStatusObject.transferDate = true;
                        }
                    }else{
                        //other cases
                        component.set('v.error.fieldError.transferDate','');
                        temporaryStatusObject.transferDate = true;
                    }
                    
                }else{
                    component.set('v.error.fieldError.transferDate','Invalid Date');
                    temporaryStatusObject.transferDate = false;
                }    
                
            }else{
                
                component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Mandatory'));
                temporaryStatusObject.transferDate = false;
                
            }
            
        }
        
        finalStatus = self.analyseTempValidation(temporaryStatusObject);
        return finalStatus;
        
    }
    
})