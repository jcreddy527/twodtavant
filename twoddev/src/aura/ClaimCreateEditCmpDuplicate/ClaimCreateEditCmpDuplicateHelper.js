({
    /*** constant array of months ***/
    MONTH_ARRAY: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],

    /*** modal helper methods**/
    showModal: function(component, modalBool) {
        component.set(modalBool, true);
    },
    closeModal: function(component, modalBool) {
        component.set(modalBool, false);
    },

    /***whether accordion should open validation method***/
    validateAccordionOpen: function(component, event, accordionId) {

        var validationSuccess = false;
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var self = this;

        switch (accordionId) {

            case "accordion-c-1-save":
                {

                    var product = component.get('v.product');
                    var inventory = component.get('v.inventory');
                    var temporaryValidationObject = {};

                    if (claimCustomRecordTypeName !== 'Claim Template') {

                        // dealer account validation in claim
                        if (currentClaim['Account__c'] == '' || currentClaim['Account__c'] == undefined ||
                            currentClaim['Account__c'] == null) {
                            component.set('v.error.accordion1.fieldError.dealer', $A.get("$Label.c.Dealer_Entry_Not_Correct"));
                            temporaryValidationObject.dealer = false;
                        }
                        if (component.get('v.error.accordion1.fieldError.dealer') !== '') {
                            temporaryValidationObject.dealer = false;
                        }

                        // date validations
                        var failureDate = component.get('v.failureDate');

                        // failure date validation
                        if (failureDate === '' || failureDate === undefined || failureDate === null) {
                            component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Failure_Date_Not_Filled"));
                            temporaryValidationObject.failureDate = false;
                        }
                        if (component.get('v.error.accordion1.fieldError.failureDate') !== '') {
                            temporaryValidationObject.failureDate = false;
                        }

                        // repair date validation
                        var repairDate = component.get('v.repairDate');
                        if (repairDate == '' || repairDate == undefined || repairDate == null) {
                            component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Repair_Date_Not_Filled"));
                            temporaryValidationObject.repairDate = false;
                        }
                        if (component.get('v.error.accordion1.fieldError.repairDate') !== '') {
                            temporaryValidationObject.repairDate = false;
                        }

                        // purchase date validation
                        if (claimCustomRecordTypeName === 'Non-Serialized') {
                            var purchaseDate = component.get('v.purchaseDate');
                            if (purchaseDate == '' || purchaseDate == undefined || purchaseDate == null) {
                                component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Purchase_Date_Not_Filled"));
                                temporaryValidationObject.purchaseDate = false;
                            }
                            if (component.get('v.error.accordion1.fieldError.purchaseDate') !== '') {
                                temporaryValidationObject.purchaseDate = false;
                            }
                        } else {
                            temporaryValidationObject.purchaseDate = true;
                        }

                        // unit usage validation

                        var unitType = component.get('v.unitType');

                        var unitUsage = currentClaim['Units_Run__c'];

                        if (unitUsage === '' || unitUsage === undefined || unitUsage === null) {

                            if (unitType !== 'Not Specified') {
                                component.set('v.error.accordion1.fieldError.unitsUsage', $A.get("$Label.c.Units_Usage_Empty"));
                                temporaryValidationObject.unitsUsage = false;
                            } else {
                                component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                temporaryValidationObject.unitsUsage = true;
                            }

                        } else if (parseFloat(unitUsage) < 0) {

                            component.set('v.error.accordion1.fieldError.unitsUsage', $A.get("$Label.c.Units_Run_Negative"));
                            temporaryValidationObject.unitsUsage = false;

                        } else if (parseFloat(unitUsage) > 0) {

                            if (claimCustomRecordTypeName == 'Serialized' || claimCustomRecordTypeName == 'Field Modification') {
                                var inventory = component.get('v.inventory');

                                if (inventory !== null && inventory !== undefined) {

                                    var unitsRun = parseFloat(inventory['Units_Run__c']);
                                    if (unitsRun > parseFloat(unitUsage)) {

                                        component.set('v.error.accordion1.fieldError.unitsUsage',
                                            $A.get("$Label.c.Units_Run_Less_Than_Inventory") + unitsRun);
                                        temporaryValidationObject.unitsUsage = false;

                                    } else {

                                        component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                        temporaryValidationObject.unitsUsage = true;
                                    }

                                } else {

                                    component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                    temporaryValidationObject.unitsUsage = true;

                                }

                            }

                        }
                        if (component.get('v.error.accordion1.fieldError.unitsUsage') !== '') {
                            temporaryValidationObject.unitsUsage = false;

                        }


                        // reason for delay validation
                        var isDateDiffBig = component.get('v.failureRepairDateDiffBig');
                        if (isDateDiffBig === true) {

                            var reasonForDelay = component.get('v.currentClaim.Delay_Reason__c');
                            if (reasonForDelay === '' || reasonForDelay === undefined || reasonForDelay === null) {
                                component.set('v.error.accordion1.fieldError.reasonForDelay', $A.get("$Label.c.Reason_For_Delay_Not_Filled"));
                                temporaryValidationObject.reasonForDelay = false;
                            } else {
                                component.set('v.error.accordion1.fieldError.reasonForDelay', '');
                                temporaryValidationObject.reasonForDelay = true;
                            }

                        }
                        if (component.get('v.error.accordion1.fieldError.reasonForDelay') !== '') {
                            temporaryValidationObject.reasonForDelay = false;
                        }

                        //inventory validation in claim
                        if (claimCustomRecordTypeName == 'Serialized' || claimCustomRecordTypeName == 'Field Modification') {


                            if (currentClaim['Inventory__c'] === undefined || currentClaim['Inventory__c'] === null ||
                                currentClaim['Inventory__c'] === '') {

                                component.set('v.error.accordion1.fieldError.inventory', $A.get("$Label.c.Inventory_Not_Correct"));
                                temporaryValidationObject.inventory = false;

                            }
                            if (component.get('v.error.accordion1.fieldError.inventory') !== '') {
                                temporaryValidationObject.inventory = false;
                            }


                        } else if (claimCustomRecordTypeName === 'Non-Serialized') {

                            // product validation in claim
                            if (currentClaim['Warranty_Product__c'] == undefined || currentClaim['Warranty_Product__c'] === null ||
                                currentClaim['Warranty_Product__c'] === '') {

                                component.set('v.error.accordion1.fieldError.product', $A.get("$Label.c.Product_Not_correct"));
                                temporaryValidationObject.product = false;

                            }
                            if (component.get('v.error.accordion1.fieldError.inventory') !== '') {
                                temporaryValidationObject.product = false;
                            }

                        } else {

                            // claim template validation
                            temporaryValidationObject.inventory = true;
                            temporaryValidationObject.product = true;
                        }

                        //analyse the temp validation Variable and send status
                        validationSuccess = self.analyseTempValidation(temporaryValidationObject);

                    } else {

                        validationSuccess = true;

                    }

                    //if all previous validations are complete , go further
                    if (validationSuccess === true) {

                        //continue to check for the next phase error checking which is independent of record type

                        /** causal part validation**/
                        if (currentClaim['Causal_Part_Number__c'] === undefined || currentClaim['Causal_Part_Number__c'] === null ||
                            currentClaim['Causal_Part_Number__c'] === '') {

                            component.set('v.error.accordion1.fieldError.causalPart', $A.get("$Label.c.Causal_Part_Not_Correct"));
                            temporaryValidationObject.causalPart = false;

                        }
                        if (component.get('v.error.accordion1.fieldError.causalPart') !== '') {
                            temporaryValidationObject.causalPart = false;
                        }

                        /** fault code validation**/
                        if (currentClaim['Fault_Code__c'] === undefined || currentClaim['Fault_Code__c'] === null ||
                            currentClaim['Fault_Code__c'] === '') {

                            component.set('v.error.accordion1.fieldError.faultCode', $A.get("$Label.c.Fault_Code_Not_Selected"));
                            temporaryValidationObject.faultCode = false;

                        }
                        if (component.get('v.error.accordion1.fieldError.faultCode') !== '') {
                            temporaryValidationObject.faultCode = false;
                        } else {
                            temporaryValidationObject.faultCode = true;
                        }

                        /***analyse the temp validation Variable and send status***/

                        validationSuccess = self.analyseTempValidation(temporaryValidationObject);
                    }


                    component.set('v.accordionValidationIndicator.accordion1', validationSuccess);

                    break;
                }

            case "accordion-c-3":
                {

                    var accordionValidationIndicator = JSON.parse(JSON.stringify(component.get('v.accordionValidationIndicator')));
                    var temporaryValidationObject = {};

                    if (accordionValidationIndicator.accordion1 === true) {


                        /** causal part validation**/
                        if (currentClaim['Causal_Part_Number__c'] === undefined || currentClaim['Causal_Part_Number__c'] === null ||
                            currentClaim['Causal_Part_Number__c'] === '') {

                            component.set('v.error.accordion1.fieldError.causalPart', $A.get("$Label.c.Causal_Part_Not_Correct"));
                            temporaryValidationObject.causalPart = false;

                        }
                        if (component.get('v.error.accordion1.fieldError.causalPart') !== '') {
                            temporaryValidationObject.causalPart = false;
                        }

                        /** fault code validation**/
                        if (currentClaim['Fault_Code__c'] === undefined || currentClaim['Fault_Code__c'] === null ||
                            currentClaim['Fault_Code__c'] === '') {

                            component.set('v.error.accordion1.fieldError.faultCode', $A.get("$Label.c.Fault_Code_Not_Selected"));
                            temporaryValidationObject.faultCode = false;

                        }
                        if (component.get('v.error.accordion1.fieldError.faultCode') !== '') {
                            temporaryValidationObject.faultCode = false;
                        } else {
                            temporaryValidationObject.faultCode = true;
                        }

                        /***analyse the temp validation Variable and send status***/

                        validationSuccess = self.analyseTempValidation(temporaryValidationObject);

                    } else {

                        // straightaway return false as first tab itself is not validated
                        validationSuccess = false;

                    }

                    break;
                }

            case "accordion-c-6":
                {

                    var faultFoundComment = currentClaim['Fault_Code_Comment__c'];
                    var causalPartComment = currentClaim['CasualPart_Comments__c'];
                    var workPerformedComment = currentClaim['work_Performed_comments__c'];

                    var temporaryValidationObject = {};


                    if (faultFoundComment === '' || faultFoundComment === null || faultFoundComment === undefined) {
                        component.set('v.error.accordion5.fieldError.faultFoundComment', $A.get("$Label.c.Fault_Found_Comments_Empty"));
                        temporaryValidationObject.faultFoundComment = false;
                    }

                    if (component.get('v.error.accordion5.fieldError.faultFoundComment') !== '') {
                        temporaryValidationObject.faultFoundComment = false;
                    }

                    if (causalPartComment === '' || causalPartComment === null || causalPartComment === undefined) {
                        component.set('v.error.accordion5.fieldError.causalPartComment', $A.get("$Label.c.Cause_Comments_Empty"));
                        temporaryValidationObject.causalPartComment = false;
                    }

                    if (component.get('v.error.accordion5.fieldError.causalPartComment') !== '') {
                        temporaryValidationObject.causalPartComment = false;
                    }

                    if (workPerformedComment === '' || workPerformedComment === null || workPerformedComment === undefined) {
                        component.set('v.error.accordion5.fieldError.workPerformedComment', $A.get("$Label.c.Work_Performed_Comments_Empty"));
                        temporaryValidationObject.workPerformedComment = false;
                    }

                    if (component.get('v.error.accordion5.fieldError.workPerformedComment') !== '') {
                        temporaryValidationObject.workPerformedComment = false;
                    }

                    /***analyse the temp validation Variable and send status***/
                    validationSuccess = self.analyseTempValidation(temporaryValidationObject);

                    /***check if the first accordion is validated***/
                    var checkForAccordion1Validation = true;

                    //if both validated then send true else false
                    if (validationSuccess && checkForAccordion1Validation) {
                        component.set('v.accordionValidationIndicator.accordion5', true);
                        validationSuccess = true;
                    } else {
                        component.set('v.accordionValidationIndicator.accordion5', false);
                        validationSuccess = false;
                    }


                    break;
                }

        }

        return validationSuccess;

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

    /***misceleneous helper method***/
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

    /***tab helper methods***/
    closeTabForceFully: function(component, event, tabname) {

        var faultCodeContainer = component.find(tabname);

        // close the fault code tab as the error is in basic info tab
        if ($A.util.hasClass(faultCodeContainer, 'tab-open')) {
            $A.util.removeClass(faultCodeContainer, 'tab-open');
            $A.util.addClass(faultCodeContainer, 'tab-close');
        }

    },
    bulkCloseOrOpenAccordion: function(component, accordionListToOpen, accordionListToClose) {

        if (accordionListToOpen !== null && accordionListToOpen !== undefined && accordionListToOpen.length !== 0) {

            accordionListToOpen.map(function(a) {

                if ($A.util.hasClass(a, 'tab-close')) {
                    $A.util.removeClass(a, 'tab-close');
                    $A.util.addClass(a, 'tab-open');
                    return a;
                }


            });

        }
        if (accordionListToClose !== null && accordionListToClose !== undefined && accordionListToClose.length !== 0) {

            accordionListToClose.map(function(a) {

                if ($A.util.hasClass(a, 'tab-open')) {
                    $A.util.removeClass(a, 'tab-open');
                    $A.util.addClass(a, 'tab-close');
                    return a;
                }

            });

        }

    },

    /***miscellenous helper methods***/
    getTodayDate: function(component, event) {

        var todayDate = new Date();
        var timezone = $A.get("$Locale.timezone");
        var langLocale = $A.get("$Locale.langLocale");
        var todayDateString = '';
        var self = this;

        //for browsers other than internet explorer
        if (navigator.appVersion.indexOf('Trident') === -1) {

            $A.localizationService.getDateStringBasedOnTimezone(timezone, todayDate, function(today) {
                todayDateString = today;
                todayDateString = self.getDateReadableFormat(todayDateString);
                return todayDateString;
            });

        } else {

            $A.localizationService.getDateStringBasedOnTimezone(timezone, todayDate, function(today) {
                todayDateString = today;
                var dateComponentList = todayDateString.split("-");
                //add 0 to date
                if (dateComponentList[1].length == 1) {
                    dateComponentList[1] = '0' + dateComponentList[1];
                }
                //add 0 to month
                if (dateComponentList[2].length == 1) {
                    dateComponentList[2] = '0' + dateComponentList[2];
                }

                todayDateString = dateComponentList.join('-');
                todayDateString = self.getDateReadableFormat(todayDateString);

                return todayDateString;
            });

        }
        return todayDateString;
    },
    getErrorMessage: function(exceptionObject, errorArrayObject) {

        var returnableErrorString = '';

        if (errorArrayObject !== null && errorArrayObject !== undefined && errorArrayObject.length !== 0) {

            var errorMessages = errorArrayObject[0]['errorMessages'];
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
    findIndexWithProperty: function(array, attr, value) {

        for (var i = 0; i < array.length; i += 1) {
            if (array[i][attr] === value) {
                return i;
            }
        }
        return -1;
    },
    intersectionByProperty: function(givenListA, givenListB) {

        var returnableIntersectionList = [];

        if (Array.isArray(givenListA) && givenListA.length !== 0 &&
            Array.isArray(givenListB) && givenListB.length !== 0) {

            var iterableList = (givenListA.length > givenListB.length) ? givenListB : givenListA;
            var toComparedList = (givenListA.length > givenListB.length) ? givenListA : givenListB;

            for (var i = 0, len = iterableList.length; i < len; i++) {

                var filterElement = toComparedList.filter(function(a) {
                    if (a['Id'] === iterableList[i]['Id']) {
                        return a;
                    }
                });
                if (filterElement !== null && filterElement !== undefined && filterElement.length !== 0) {
                    returnableIntersectionList.push(filterElement[0]);
                }

            }


        }


        return returnableIntersectionList;
    },
    
    /* added by Dharmil to get Unique Union of 2 arrays */
    arrayUnique: function (array) {
    var a = array.concat();
    for(var i=0; i<a.length; ++i) {
        for(var j=i+1; j<a.length; ++j) {
            if(a[i] === a[j])
                a.splice(j--, 1);
        }
    }

    return a;
},
    /*unionByProperty: function(givenListA, givenListB) {
    	
        var returnableUnionList = [];
        
        for (var i = 0, len = givenListB.length; i < len; i++) {
        	returnableUnionList.push(givenListA);
        	var filterElement = givenListA.filter(function(a) {
                    if (a['Id'] === givenListB[i]['Id']) {
                        return a;
                    }
                });
                if (filterElement !== null && filterElement !== undefined && filterElement.length !== 0) {
                    returnableUnionList.push(filterElement[0]);
                }
        }
        
        return returnableUnionList;
    },*/
    
    
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
    disableEnableComponentsWithAuraId: function(component, auraIdList, doDisable) {
        if (Array.isArray(auraIdList) && auraIdList.length !== 0) {
            auraIdList.map(function(a) {
                var targetComponent = component.find(a);
                if (targetComponent !== null && targetComponent !== undefined && typeof(targetComponent.set) === 'function') {
                    if (doDisable) {
                        targetComponent.set('v.disabled', true);
                    } else {
                        targetComponent.set('v.disabled', false);
                    }
                }
            });

        }
    },

    /***picklist values setters***/
    initializePickListValue: function(component, event) {

        var isEdit = component.get('v.isEdit');
        var pickListCollection = JSON.parse(JSON.stringify(component.get('v.claimPicklist')));

        if (!isEdit) {

            var noneOption = {
                label: '--None--',
                value: '',
                selected: false
            };

            //faultFound  picklist
            var faultFoundList = pickListCollection[4]['val'];
            var faultFoundOptions = [];
            faultFoundOptions = faultFoundList.map(function(a) {
                var option = {
                    label: a['label'],
                    value: a['value'],
                    selected: false
                }
                return option;
            });
            faultFoundOptions.unshift(noneOption);
            faultFoundOptions[0]['selected'] = true;
            if (typeof(component.find('faultFound').set) === 'function') {
                component.find('faultFound').set('v.options', faultFoundOptions);
            }


            //causedBy  picklist
            var causedByList = pickListCollection[5]['val'];
            var causedByOptions = [];
            causedByOptions = causedByList.map(function(a) {
                var option = {
                    label: a['label'],
                    value: a['value'],
                    selected: false
                }
                return option;
            });
            causedByOptions.unshift(noneOption);
            causedByOptions[0]['selected'] = true;
            if (typeof(component.find('causedBy').set) === 'function') {
                component.find('causedBy').set('v.options', causedByOptions);
            }

        } else {

            var noneOption = {
                label: '--None--',
                value: '',
                selected: false
            };

            //faultFound  picklist
            var faultFoundList = pickListCollection[4]['val'];
            var faultFoundOptions = [];
            faultFoundOptions = faultFoundList.map(function(a) {
                var option = {
                    label: a['label'],
                    value: a['value'],
                    selected: false
                }
                return option;
            });
            faultFoundOptions.unshift(noneOption);

            var currentClaimFaultFound = component.get('v.currentClaim.Fault_found__c');
            currentClaimFaultFound = (currentClaimFaultFound === undefined || currentClaimFaultFound === null || currentClaimFaultFound === '') ? '' : currentClaimFaultFound;
            var indexOfOption = this.findIndexWithProperty(faultFoundOptions, 'value', currentClaimFaultFound);


            if (indexOfOption > -1) {
                faultFoundOptions[indexOfOption]['selected'] = true;
            }

            if (typeof(component.find('faultFound').set) === 'function') {
                component.find('faultFound').set('v.options', faultFoundOptions);
            }

            //causedBy  picklist
            var causedByList = pickListCollection[5]['val'];
            var causedByOptions = [];
            causedByOptions = causedByList.map(function(a) {
                var option = {
                    label: a['label'],
                    value: a['value'],
                    selected: false
                }
                return option;
            });
            causedByOptions.unshift(noneOption);

            var currentClaimCausedBy = component.get('v.currentClaim.Caused_by__c');
            currentClaimFaultFound = (currentClaimCausedBy === undefined || currentClaimCausedBy === null || currentClaimCausedBy === '') ? '' : currentClaimCausedBy;
            indexOfOption = this.findIndexWithProperty(causedByOptions, 'value', currentClaimCausedBy);

            if (indexOfOption > -1) {
                causedByOptions[indexOfOption]['selected'] = true;
            }

            if (typeof(component.find('causedBy').set) === 'function') {
                component.find('causedBy').set('v.options', causedByOptions);
            }

            //hostnonhost picklist
            var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
            if (claimCustomRecordTypeName === 'Non-Serialized') {

                //set the host-nonhost picklist
                var pickListCollection = JSON.parse(JSON.stringify(component.get('v.claimPicklist')));
                var hostNonHostList = pickListCollection[2]['val'];
                var hostNonHostOptions = [];
                var hostNonHostOptions = hostNonHostList.map(function(a) {
                    var option = {
                        label: a['label'],
                        value: a['value'],
                        selected: false
                    }
                    return option;
                });

                var currentClaimHostNonHost = component.get('v.currentClaim.Host_NonHost__c');
                currentClaimHostNonHost = (currentClaimHostNonHost === undefined || currentClaimHostNonHost === null || currentClaimHostNonHost === '') ? '' : currentClaimHostNonHost;
                indexOfOption = this.findIndexWithProperty(hostNonHostOptions, 'value', currentClaimHostNonHost);

                if (indexOfOption > -1) {
                    hostNonHostOptions[indexOfOption]['selected'] = true;
                }

                if (typeof(component.find('hostNonHost').set) === 'function') {
                    component.find('hostNonHost').set('v.options', hostNonHostOptions);
                }

                if (component.find('hostNonHost') !== undefined && component.find('hostNonHost') !== null) {
                    if (typeof(component.find('hostNonHost').set) === 'function') {
                        component.find('hostNonHost').set('v.options', hostNonHostOptions);
                    }
                }


            }

            //smr reason picklist
            if (claimCustomRecordTypeName !== 'Claim Template') {

                var isPreAuthNeeded = component.get('v.currentClaim.Request_SMR__c');

                if (isPreAuthNeeded) {

                    var smrReasonList = pickListCollection[3]['val'];
                    var smrReasonOptions = [];
                    var smrReasonOptions = smrReasonList.map(function(a) {
                        var option = {
                            label: a['label'],
                            value: a['value'],
                            selected: false
                        }
                        return option;
                    });

                    var currentClaimSMRReason = component.get('v.currentClaim.SMR_Reason__c');
                    currentClaimSMRReason = (currentClaimSMRReason === undefined || currentClaimSMRReason === null || currentClaimSMRReason === '') ? '' : currentClaimSMRReason;
                    indexOfOption = this.findIndexWithProperty(smrReasonOptions, 'value', currentClaimSMRReason);

                    if (indexOfOption > -1) {
                        smrReasonOptions[indexOfOption]['selected'] = true;
                    }

                    if (typeof(component.find('reasonsForPreAuth').set) === 'function') {
                        component.find('reasonsForPreAuth').set('v.options', smrReasonOptions);
                    }

                }



            }


        }



    },
    fillPickListValuesInClaim: function(component, currentClaim) {

        var hostNonHost = '';
        if (component.find('hostNonHost') !== undefined && component.find('hostNonHost') !== null) {

            if (typeof(component.find('hostNonHost').get) === "function") {

                hostNonHost = component.find('hostNonHost').get('v.value');

            }

        }

        var faultFound = '';
        if (component.find('faultFound') !== undefined && component.find('faultFound') !== null) {

            if (typeof(component.find('faultFound').get) === "function") {

                faultFound = component.find('faultFound').get('v.value');

            }

        }

        var causedBy = '';
        if (component.find('causedBy') !== undefined && component.find('causedBy') !== null) {

            if (typeof(component.find('causedBy').get) === "function") {

                causedBy = component.find('causedBy').get('v.value');

            }

        }

        var smrReason = '';
        if (component.find('reasonsForPreAuth') !== undefined && component.find('reasonsForPreAuth') !== null) {

            if (typeof(component.find('reasonsForPreAuth').get) === "function") {

                smrReason = component.find('reasonsForPreAuth').get('v.value');

            }

        }


        currentClaim['Host_NonHost__c'] = hostNonHost;
        currentClaim['Fault_found__c'] = faultFound;
        currentClaim['Caused_by__c'] = causedBy;
        currentClaim['SMR_Reason__c'] = smrReason;

        return currentClaim;

    },

    /***functional helper***/
    setAdditionalInformationByTemplate: function(component, event, claimTemplate) {

        var travelByHours = (claimTemplate['TravelByHours__c'] === '' || claimTemplate['TravelByHours__c'] === null ||
                claimTemplate['TravelByHours__c'] === undefined || isNaN(parseFloat(claimTemplate['TravelByHours__c']))) ?
            0 : parseFloat(claimTemplate['TravelByHours__c']);

        var travelDistance = (claimTemplate['TravelByDistance__c'] === '' || claimTemplate['TravelByDistance__c'] === null ||
                claimTemplate['TravelByDistance__c'] === undefined || isNaN(parseFloat(claimTemplate['TravelByDistance__c']))) ?
            0 : parseFloat(claimTemplate['TravelByDistance__c']);

        var travelLocation = (claimTemplate['TravelByLocation__c'] === '' || claimTemplate['TravelByLocation__c'] === null ||
            claimTemplate['TravelByLocation__c'] === undefined) ? '' : claimTemplate['TravelByLocation__c'];

        var freightCharges = (claimTemplate['Total_Category1_Cost__c'] === '' || claimTemplate['Total_Category1_Cost__c'] === null ||
                claimTemplate['Total_Category1_Cost__c'] === undefined || isNaN(parseFloat(claimTemplate['Total_Category1_Cost__c']))) ?
            0 : parseFloat(claimTemplate['Total_Category1_Cost__c']);

        var miscellaneousCost = (claimTemplate['Total_Category2_Cost__c'] === '' || claimTemplate['Total_Category2_Cost__c'] === null ||
                claimTemplate['Total_Category2_Cost__c'] === undefined || isNaN(parseFloat(claimTemplate['Total_Category2_Cost__c']))) ?
            0 : parseFloat(claimTemplate['Total_Category2_Cost__c']);

        var totalMealsCost = (claimTemplate['Total_Meals_Cost__c'] === '' || claimTemplate['Total_Meals_Cost__c'] === null ||
                claimTemplate['Total_Meals_Cost__c'] === undefined || isNaN(parseFloat(claimTemplate['Total_Meals_Cost__c']))) ?
            0 : parseFloat(claimTemplate['Total_Meals_Cost__c']);

        var totalParkingCost = (claimTemplate['Total_Parking_Cost__c'] === '' || claimTemplate['Total_Parking_Cost__c'] === null ||
                claimTemplate['Total_Parking_Cost__c'] === undefined || isNaN(parseFloat(claimTemplate['Total_Parking_Cost__c']))) ?
            0 : parseFloat(claimTemplate['Total_Parking_Cost__c']);

        var faultFoundComments = (claimTemplate['Fault_Code_Comment__c'] === '' || claimTemplate['Fault_Code_Comment__c'] === null ||
            claimTemplate['Fault_Code_Comment__c'] === undefined) ? '' : claimTemplate['Fault_Code_Comment__c'];

        var causeComments = (claimTemplate['CasualPart_Comments__c'] === '' || claimTemplate['CasualPart_Comments__c'] === null ||
            claimTemplate['CasualPart_Comments__c'] === undefined) ? '' : claimTemplate['CasualPart_Comments__c'];

        var workPerformedComments = (claimTemplate['work_Performed_comments__c'] === '' || claimTemplate['work_Performed_comments__c'] === null ||
            claimTemplate['work_Performed_comments__c'] === undefined) ? '' : claimTemplate['work_Performed_comments__c'];

        var description = (claimTemplate['Description__c'] === '' || claimTemplate['Description__c'] === null ||
            claimTemplate['Description__c'] === undefined) ? '' : claimTemplate['Description__c'];

        var rate = (claimTemplate['Rate__c'] === '' || claimTemplate['Rate__c'] === null ||
            claimTemplate['Rate__c'] === undefined) ? '' : claimTemplate['Rate__c'];

        //set the additional info
        component.set('v.currentClaim.TravelByHours__c', travelByHours);
        component.set('v.currentClaim.TravelByDistance__c', travelDistance);
        component.set('v.currentClaim.TravelByLocation__c', travelLocation);
        component.set('v.currentClaim.Total_Category1_Cost__c', freightCharges);
        component.set('v.currentClaim.Total_Category2_Cost__c', miscellaneousCost);
        component.set('v.currentClaim.Total_Meals_Cost__c', totalMealsCost);
        component.set('v.currentClaim.Total_Parking_Cost__c', totalParkingCost);
        component.set('v.currentClaim.Fault_Code_Comment__c', faultFoundComments);
        component.set('v.currentClaim.CasualPart_Comments__c', causeComments);
        component.set('v.currentClaim.work_Performed_comments__c', workPerformedComments);
        component.set('v.currentClaim.Description__c', description);
        component.set('v.currentClaim.Rate__c', rate);

    },
    initializeFaultCodeListForEditMode: function(component, faultCodeMapperList) {

        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var currentInventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
        var causalPart = currentClaim['Causal_Part_Number__r'];
        var modelId = null;
        var modelParentId = null;
        var modelFaultCodeList = [];
        var modelParentFaultCodeList = [];
        var causalPartFaultCodeList = [];
        var self = this;
        var indexOfClaimFaultCodeInList = -1;
        var modelFaultCodeMapperList = [];
        var modelParentFaultCodeMapperList = [];
        var causalPartFaultCodeMapperList = [];
        var claimCustomRecordTypeName = currentClaim['Claim_Record_Type__c'];
        var finalFaultCodeList = [];


        if (claimCustomRecordTypeName === 'Serialized' || claimCustomRecordTypeName === 'Field Modification') {

            if (currentInventory !== null && currentInventory !== undefined) {
                var item = currentInventory['Item__r'];

                if (item !== null && item !== undefined) {

                    var model = currentInventory['Item__r']['Parent_Product__r'];
                    var modelParent = currentInventory['Item__r']['Parent_Product__r']['Parent_Product__r'];
                    
                    if (model !== null && model !== undefined) {

                        modelId = currentInventory['Item__r']['Parent_Product__r']['Id'];
                        //seperate model faultcode mapper and causal part faultcode mapper
                        modelFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                            if (a['Warranty_Product__c'] == modelId) {
                                return a;
                            }
                        });

                    }
                    if (modelParent !== null && modelParent !== undefined) {
                    	
                        modelParentId = currentInventory['Item__r']['Parent_Product__r']['Parent_Product__r']['Id'];
                        
                        //seperate model faultcode mapper and causal part faultcode mapper
                        modelParentFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                            if (a['Warranty_Product__c'] == modelParentId) {
                                return a;
                            }
                        });

                    }
                
                }

            }

            causalPartFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                if (a['Warranty_Product__c'] == causalPart['Id']) {
                    return a;
                }
            });


            //seperate model and causal part fault codes
            if (modelId !== null) {
                modelFaultCodeList = modelFaultCodeMapperList.map(function(a) {
                    return a['Fault_Code__r'];
                });
            }
            if (modelParentId !== null) {
                modelParentFaultCodeList = modelParentFaultCodeMapperList.map(function(a) {
                    return a['Fault_Code__r'];
                });
            }

            causalPartFaultCodeList = causalPartFaultCodeMapperList.map(function(a) {
                return a['Fault_Code__r'];
            });
           
            var unionFaultCodeList = self.arrayUnique(modelFaultCodeList.concat(modelParentFaultCodeList));
            
            var intersectedFaultCodeList = self.intersectionByProperty(unionFaultCodeList, causalPartFaultCodeList);

            //intersection returned nothing
            if (intersectedFaultCodeList.length == 0) {

                //set the fault code list as model fault code list as it cannot be empty
                if (unionFaultCodeList !== undefined && unionFaultCodeList !== null && unionFaultCodeList.length !== 0) {
                    component.set('v.faultCodeList', unionFaultCodeList);
                } else {
                    component.set('v.faultCodeList', []);
                }

            } else {
                //set the faultcode list as intersection list
                component.set('v.faultCodeList', intersectedFaultCodeList);
            }

        } else {

            //only causal part fault code list is present
            causalPartFaultCodeList = faultCodeMapperList.map(function(a) {
                return a['Fault_Code__r'];
            });

            //set the faultcode list as causal part fault code list
            component.set('v.faultCodeList', causalPartFaultCodeList);

        }

        //set the faultcode option list and set the default value
        var finalFaultCodeList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
        if (finalFaultCodeList !== undefined && finalFaultCodeList !== null && finalFaultCodeList.length !== 0) {
            indexOfClaimFaultCodeInList = self.findIndexWithProperty(finalFaultCodeList, 'Id', currentClaim['Fault_Code__c']);
            if (indexOfClaimFaultCodeInList !== -1) {
                self.setFaultCodePicklistOptions(component, finalFaultCodeList, indexOfClaimFaultCodeInList);
            } else {
                self.setFaultCodePicklistOptions(component, finalFaultCodeList, 0);
            }

        } else {
            self.setFaultCodePicklistOptions(component, [], -1);
        }



    },
    setFaultCodePicklistOptions: function(component, faultCodeList, defaultIndex) {

        var faultCodeComponent = component.find('faultCode');
        if (faultCodeList !== undefined && faultCodeList !== null && faultCodeList.length !== 0) {

            var optionList = faultCodeList.map(function(a) {

                var option = {
                    label: a['Name'],
                    value: a['Id'],
                    selected: false
                };
                return option;

            });

            if (optionList !== undefined && optionList !== null && optionList.length !== 0 && defaultIndex !== -1) {
                optionList[defaultIndex]['selected'] = true;
            }

            if (optionList !== undefined && optionList !== null && optionList.length !== 0) {
                faultCodeComponent.set('v.options', optionList);
            } else {
                faultCodeComponent.set('v.options', []);
            }

        } else {

            faultCodeComponent.set('v.options', []);

        }
        //set the fault code list
        component.set('v.faultCodeList', faultCodeList);

    },

    /***related list insert, reset and delete helper methods***/
    resetClaimRelatedListModalData: function(component, event, relatedListName) {

        var self = this;

        switch (relatedListName) {

            case "claimServiceInfo":
                {

                    // show the claim service info create modal
                    self.showModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');

                    //clear all the errors
                    component.set('v.error.accordion3.fieldError.jobCode', '');
                    component.set('v.error.accordion3.fieldError.additionalLabourHours', '');
                    component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');

                    //unset all boolean values
                    component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', false);

                    //set the modal data for create
                    component.set('v.modalData.claimServiceInfo.mode', 'Create');
                    component.set('v.modalData.title', $A.get('$Label.c.Create_Claim_Service_Info_Heading'));

                    //set the selected jobcode as null
                    component.set('v.selectedJobCode', null);

                    //unset the lookup field
                    var jobCodeLookupComponent = component.find('jobCode');
                    if (jobCodeLookupComponent !== null && jobCodeLookupComponent !== undefined && typeof(jobCodeLookupComponent.set) == 'function') {
                        jobCodeLookupComponent.set('v.objectName', '');
                    }

                    //unset the reason for additional hours
                    var additionalLabourHoursComponent = component.find('additionalLabourHours');
                    if (additionalLabourHoursComponent !== null && additionalLabourHoursComponent !== undefined &&
                        typeof(additionalLabourHoursComponent.set) == 'function') {
                        additionalLabourHoursComponent.set('v.value', '');
                    }

                    //unset the reason for additional hours
                    var reasonForAdditionalLabourHoursComponent = component.find('reasonForAdditionalHours');
                    if (reasonForAdditionalLabourHoursComponent !== null && reasonForAdditionalLabourHoursComponent !== undefined &&
                        typeof(reasonForAdditionalLabourHoursComponent.set) == 'function') {
                        reasonForAdditionalLabourHoursComponent.set('v.value', '');
                    }

                    break;
                }

            case "installedPart":
                {

                    // show the installed parts create modal
                    self.showModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');

                    //clear all the errors
                    component.set('v.error.accordion4.fieldError.nonSerializedInstalledPart', '');
                    component.set('v.error.accordion4.fieldError.serializedInstalledPart', '');
                    component.set('v.error.accordion4.fieldError.customCost', '');
                    component.set('v.error.accordion4.fieldError.quantity', '');
                    component.set('v.error.accordion4.fieldError.commonError', '');

                    //unset all the previous selected variables
                    component.set('v.selectedSerializedInstalledPart', null);
                    component.set('v.selectedNonSerializedInstalledPart', null);

                    //set the modal data for create
                    component.set('v.modalData.installedParts.mode', 'Create');
                    component.set('v.modalData.installedParts.title', $A.get('$Label.c.Add_Installed_Part_Heading'));

                    //unset the Non Serialized Part lookup
                    var nonSerializedPartLookupComponent = component.find('nonSerializedInstalledPart');
                    if (nonSerializedPartLookupComponent !== null && nonSerializedPartLookupComponent !== undefined &&
                        typeof(nonSerializedPartLookupComponent.set) == 'function') {
                        nonSerializedPartLookupComponent.set('v.objectName', '');
                        nonSerializedPartLookupComponent.set('v.disabled', false);
                    }

                    //unset the serialized Part lookup
                    var serializedPartLookupComponent = component.find('serializedInstalledPart');
                    if (serializedPartLookupComponent !== null && serializedPartLookupComponent !== undefined &&
                        typeof(serializedPartLookupComponent.set) == 'function') {
                        serializedPartLookupComponent.set('v.objectName', '');
                        serializedPartLookupComponent.set('v.disabled', false);
                    }

                    //unset the quantity
                    var quantityComponent = component.find('quantity');
                    if (quantityComponent !== null && quantityComponent !== undefined &&
                        typeof(quantityComponent.set) == 'function') {
                        quantityComponent.set('v.value', '');
                        quantityComponent.set('v.disabled', false);
                    }

                    //unset the customCost
                    var customCostComponent = component.find('customCost');
                    if (customCostComponent !== null && customCostComponent !== undefined &&
                        typeof(customCostComponent.set) == 'function') {
                        customCostComponent.set('v.value', '');
                    }

                    break;
                }

            case "removedPart":
                {

                    // show the installed parts create modal
                    self.showModal(component, 'v.modalAndElementDisplayBool.removedPartModal');

                    //clear all the errors
                    component.set('v.error.accordion4.fieldError.nonSerializedRemovedPart', '');
                    component.set('v.error.accordion4.fieldError.serializedRemovedPart', '');
                    component.set('v.error.accordion4.fieldError.removedPartQuantity', '');
                    component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', '');

                    //unset the values of selected serialized and non serialized removed parts
                    component.set('v.selectedSerializedRemovedPart', null);
                    component.set('v.selectedNonSerializedRemovedPart', null);

                    //set the modal data for create
                    component.set('v.modalData.removedParts.mode', 'Create');
                    component.set('v.modalData.removedParts.title', $A.get('$Label.c.Add_Removed_Part_Heading'));

                    //unset the Non Serialized Part lookup
                    var nonSerializedRemovedPartLookupComponent = component.find('nonSerializedRemovedPart');
                    if (nonSerializedRemovedPartLookupComponent !== null && nonSerializedRemovedPartLookupComponent !== undefined &&
                        typeof(nonSerializedRemovedPartLookupComponent.set) == 'function') {
                        nonSerializedRemovedPartLookupComponent.set('v.objectName', '');
                        nonSerializedRemovedPartLookupComponent.set('v.disabled', false);
                    }

                    //unset the serialized Part lookup
                    var serializedRemovedPartLookupComponent = component.find('serializedRemovedPart');
                    if (serializedRemovedPartLookupComponent !== null && serializedRemovedPartLookupComponent !== undefined &&
                        typeof(serializedRemovedPartLookupComponent.set) == 'function') {
                        serializedRemovedPartLookupComponent.set('v.objectName', '');
                        serializedRemovedPartLookupComponent.set('v.disabled', false);
                    }

                    //unset the quantity
                    var removedPartQuantityComponent = component.find('removedPartQuantity');
                    if (removedPartQuantityComponent !== null && removedPartQuantityComponent !== undefined &&
                        typeof(removedPartQuantityComponent.set) == 'function') {
                        removedPartQuantityComponent.set('v.value', '');
                        removedPartQuantityComponent.set('v.disabled', false);
                    }


                    break;
                }

            case "miscellenousPart":
                {

                    // show the non-OEM parts create modal
                    self.showModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');

                    //clear all the errors
                    component.set('v.error.accordion4.fieldError.nonOEMPartName', '');
                    component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', '');
                    component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', '');
                    component.set('v.error.accordion4.fieldError.nonOEMPartDescription', '');

                    //unset all the previous selected variables
                    component.set('v.selectedNONOEMPart', null);

                    //set the modal data for create
                    component.set('v.modalData.nonOEMParts.mode', 'Create');
                    component.set('v.modalData.nonOEMParts.title', $A.get('$Label.c.Add_Miscellaneous_Part_Heading'));


                    //unset the part name
                    var nonOEMPartNameComponent = component.find('nonOEMPartName');
                    if (nonOEMPartNameComponent !== null && nonOEMPartNameComponent !== undefined &&
                        typeof(nonOEMPartNameComponent.set) == 'function') {
                        nonOEMPartNameComponent.set('v.value', '');
                    }

                    //unset the description
                    var nonOEMPartDescription = component.find('nonOEMPartDescription');
                    if (nonOEMPartDescription !== null && nonOEMPartDescription !== undefined &&
                        typeof(nonOEMPartDescription.set) == 'function') {
                        nonOEMPartDescription.set('v.value', '');
                    }

                    //unset the quantity
                    var nonOEMPartQuantityComponent = component.find('nonOEMPartQuantity');
                    if (nonOEMPartQuantityComponent !== null && nonOEMPartQuantityComponent !== undefined &&
                        typeof(nonOEMPartQuantityComponent.set) == 'function') {
                        nonOEMPartQuantityComponent.set('v.value', 1);
                    }

                    //unset the customCost
                    var nonOEMPartCustomCostComponent = component.find('nonOEMPartCustomCost');
                    if (nonOEMPartCustomCostComponent !== null && nonOEMPartCustomCostComponent !== undefined &&
                        typeof(nonOEMPartCustomCostComponent.set) == 'function') {
                        nonOEMPartCustomCostComponent.set('v.value', 0);
                    }

                    //unset the invoice number
                    var invoiceNumberComponent = component.find('Invoice Number');
                    if (invoiceNumberComponent !== null && invoiceNumberComponent !== undefined &&
                        typeof(invoiceNumberComponent.set) == 'function') {
                        invoiceNumberComponent.set('v.value', '');
                    }

                    //unset the invoice date
                    var invoiceDateComponent = component.find('Invoice Date');
                    if (invoiceDateComponent !== null && invoiceDateComponent !== undefined &&
                        typeof(invoiceDateComponent.set) == 'function') {
                        invoiceDateComponent.set('v.value', '');
                    }

                    break;
                }

        }


    },
    saveClaimRelatedList: function(component, event, relatedListName, isSaveAndNext) {

        var self = this;

        switch (relatedListName) {

            case "claimServiceInfo":
                {

                    //get all the required info from form
                    var buttonIdList = ['saveClaimServiceInfoButton', 'cancelClaimServiceInfoButton',
                        'saveNextClaimServiceInfoButton'
                    ];
                    var jobCode = JSON.parse(JSON.stringify(component.get('v.selectedJobCode')));
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    var claimServiceInfoAlreadyExist = false;

                    if (jobCode != null && jobCode != undefined) {

                        var currentClaimServiceInfoList = JSON.parse(JSON.stringify(component.get('v.claimServiceInfoList')));
                        var claimServiceInfoWithSelectedJobcode = currentClaimServiceInfoList.filter(function(a) {
                            if (a['Service_Job_Code__c'] == jobCode['Id']) {
                                return a;
                            }
                        });
                        claimServiceInfoAlreadyExist = (claimServiceInfoWithSelectedJobcode.length == 0) ? false : true;

                        if (claimServiceInfoAlreadyExist == false) {

                            var additionalLabourHours = component.find('additionalLabourHours').get('v.value');
                            var reasonForAdditionalHours = '';
                            if (additionalLabourHours >= 0) {

                                //unset the error for additional labour hours
                                component.set('v.error.accordion3.fieldError.additionalLabourHours', '');

                                //get the value of reason for additional labour hours
                                if (additionalLabourHours > 0) {
                                    reasonForAdditionalHours = component.find('reasonForAdditionalHours').get('v.value');
                                } else {
                                    reasonForAdditionalHours = '';
                                }


                                //if empty then set the error
                                if ((reasonForAdditionalHours == '' || reasonForAdditionalHours == undefined ||
                                        reasonForAdditionalHours == null) && additionalLabourHours > 0) {

                                    component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded',
                                        $A.get("$Label.c.Reason_For_Additional_Labour_Hours_Not_Filled"));

                                } else {

                                    //unset the error
                                    component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');

                                    //make javascript object of claim service info
                                    var claimServiceInfo = {
                                        sobjectType: 'Claim_Service_Information__c',
                                        Service_Job_Code__c: jobCode['Id'],
                                        Additional_Labor_Hour__c: additionalLabourHours,
                                        Reason_Additional_Labor_hour__c: reasonForAdditionalHours,
                                        Standard_Labor_Hour__c: jobCode['Standard_Labor_Hour__c'],
                                        Claim__c: currentClaim['Id']
                                    };


                                    //unset all the jobcode errors
                                    component.set('v.error.accordion3.fieldError.jobCode', '');

                                    //disable modal buttons
                                    self.disableEnableComponentsWithAuraId(component, buttonIdList, true);


                                    //insert the claim service info
                                    self.insertRaw(component, event, self, claimServiceInfo, function(claimServiceInfoInsert) {

                                        //enable modal buttons
                                        self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                        if (claimServiceInfoInsert['sobjectsAndStatus'] != undefined && claimServiceInfoInsert['sobjectsAndStatus'] != null &&
                                            claimServiceInfoInsert['sobjectsAndStatus'].length != 0) {

                                            var isSuccessfulInsert = claimServiceInfoInsert['sobjectsAndStatus'][0]['status'];
                                            if (isSuccessfulInsert == 'successful') {

                                                var claimserviceInfoWithId = claimServiceInfoInsert['sobjectsAndStatus'][0]['sObject'];

                                                // add some additional fields
                                                claimserviceInfoWithId['Service_Job_Code__r'] = {};
                                                claimserviceInfoWithId['Service_Job_Code__r']['Name'] = jobCode['Name'];
                                                claimserviceInfoWithId['Service_Job_Code__r']['Description__c'] = jobCode['Description__c'];
                                                claimserviceInfoWithId['Service_Job_Code__r']['Standard_Labor_Hour__c'] = jobCode['Standard_Labor_Hour__c'];

                                                //unset the selected jobcode
                                                component.set('v.selectedJobCode', null);

                                                //add this to claim service info list of current page
                                                var claimServiceInfoList = JSON.parse(JSON.stringify(component.get('v.claimServiceInfoList')));
                                                claimServiceInfoList.push(claimserviceInfoWithId);
                                                component.set('v.claimServiceInfoList', claimServiceInfoList);


                                                if (isSaveAndNext == false) {

                                                    //close modal
                                                    self.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');

                                                } else {

                                                    //reset the modal with other row
                                                    self.resetClaimRelatedListModalData(component, event, 'claimServiceInfo');

                                                }

                                                //clear all the errors
                                                component.set('v.error.accordion3.fieldError.jobCode', '');

                                            } else {


                                                //close the modal
                                                self.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');

                                                // set error in insertion alert
                                                var errorException = claimServiceInfoInsert['exception'];
                                                var errorArrays = claimServiceInfoInsert['errorArrays'];

                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                        errorArrays != undefined && errorArrays.length != 0)) {

                                                    var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.Service_Info_Not_Saved_H"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    self.showAlert(component, event, alertboxContent);

                                                }

                                            }

                                        }

                                    });


                                }

                            } else if (additionalLabourHours < 0) {

                                component.set('v.error.accordion3.fieldError.additionalLabourHours', $A.get("$Label.c.Negative_Labour_Hour"));

                            }

                        } else {

                            //duplicate jobcode case

                            //close the modal
                            self.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');

                            var alertboxContent = {
                                message: 'Cannot add claim service info with duplicate job code..',
                                heading: 'Duplicate job code',
                                class: 'slds-theme--error',
                                callableFunction: component.getReference('c.closeAlert'),
                                buttonHeading: $A.get("$Label.c.OK")
                            };
                            self.showAlert(component, event, alertboxContent);

                        }

                    } else {

                        //set jobcode not selected error
                        component.set('v.error.accordion3.fieldError.jobCode', $A.get("$Label.c.Jobcode_Not_Correct"));
                    }


                    break;
                }

            case "installedPart":
                {

                    //get all the required info from form
                    var serializedInstalledPart = JSON.parse(JSON.stringify(component.get('v.selectedSerializedInstalledPart')));
                    var nonSerializedInstalledPart = JSON.parse(JSON.stringify(component.get('v.selectedNonSerializedInstalledPart')));
                    var buttonIdList = ['saveInstalledPartButton', 'saveNextInstalledPartButton', 'cancelInstalledPart'];

                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));

                    if ((serializedInstalledPart != null && serializedInstalledPart != undefined) ||
                        (nonSerializedInstalledPart != null && nonSerializedInstalledPart != undefined)) {

                        // check custom cost validation
                        var customCost = parseFloat(component.find('customCost').get('v.value'));

                        if (customCost < 0 || isNaN(customCost)) {
                            component.set('v.error.accordion4.fieldError.customCost', $A.get("$Label.c.Negative_Custom_Cost"));
                        } else {

                            // check quantity validation

                            //unset the cost error
                            component.set('v.error.accordion4.fieldError.customCost', '');
                            var quantity = parseFloat(component.find('quantity').get('v.value'));

                            if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {
                                component.set('v.error.accordion4.fieldError.quantity', $A.get("$Label.c.Quantity_Error"));
                            } else {

                                //filter NaN
                                if (isNaN(customCost)) {
                                    customCost = null;
                                }

                                //unset the error
                                component.set('v.error.accordion4.fieldError.customCost', '');
                                component.set('v.error.accordion4.fieldError.quantity', '');

                                //create empty installed part
                                var installedClaimPart = {

                                    sobjectType: 'Claim_Part__c',
                                    Claim__c: currentClaim['Id'],
                                    /******Aditya Integration*************/
                                    //Custom_Part_Cost__c: customCost,
                                    Price__c: customCost,
                                    Part_Price_Not_Found__c: component.get('v.partPriceNotFound'),
                                    /*************************************/
                                    Quantity__c: quantity,
                                    RecordTypeId: "",
                                    Warranty_Product__c: "",
                                    Inventory__c: ""

                                };

                                var recordTypeList = JSON.parse(JSON.stringify(component.get('v.installedPartRecordTypeList')));
                                var recordTypeId = "";
                                var isSerialized = false;

                                //find if it is serialised or non serialized and deside
                                if (serializedInstalledPart != null && serializedInstalledPart != undefined) {

                                    recordTypeId = recordTypeList.filter(function(a) {

                                        if (a['DeveloperName'] == 'Serialized_Part') {
                                            return a;
                                        }

                                    })[0]['Id'];

                                    installedClaimPart['Inventory__c'] = serializedInstalledPart['Id'];
                                    isSerialized = true;

                                } else {

                                    recordTypeId = recordTypeList.filter(function(a) {

                                        if (a['DeveloperName'] == 'Non_Serialized_Part') {
                                            return a;
                                        }

                                    })[0]['Id'];

                                    installedClaimPart['Warranty_Product__c'] = nonSerializedInstalledPart['Id']
                                }

                                installedClaimPart['RecordTypeId'] = recordTypeId;


                                //check for installed part already exist
                                var installedpartAlreadyExist = false;
                                var currentInstalledPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                                var installedPartWithSameInventoryOrWarrantyProduct = currentInstalledPartList.filter(function(a) {

                                    if (a !== null && a !== undefined) {

                                        if (isSerialized == false) {

                                            if (a['Warranty_Product__c'] === installedClaimPart['Warranty_Product__c']) {

                                                return a;

                                            }

                                        } else {

                                            if (a['Inventory__c'] === installedClaimPart['Inventory__c']) {

                                                return a;

                                            }

                                        }

                                    }

                                });
                                installedpartAlreadyExist = installedPartWithSameInventoryOrWarrantyProduct.length == 0 ? false : true;

                                if (installedpartAlreadyExist == false) {

                                    //insert the installed part

                                    //disable modal buttons
                                    self.disableEnableComponentsWithAuraId(component, buttonIdList, true);

                                    self.insertRaw(component, event, self, installedClaimPart, function(claimPartInsertResponse) {

                                        if (claimPartInsertResponse['sobjectsAndStatus'] != undefined &&
                                            claimPartInsertResponse['sobjectsAndStatus'] != null &&
                                            claimPartInsertResponse['sobjectsAndStatus'].length != 0) {

                                            var isSuccessfulInsert = claimPartInsertResponse['sobjectsAndStatus'][0]['status'];
                                            if (isSuccessfulInsert == 'successful') {

                                                var insertedInstalledClaimPart = claimPartInsertResponse['sobjectsAndStatus'][0]['sObject'];

                                                //fill some values to show on ui
                                                if (!isSerialized) {
                                                    insertedInstalledClaimPart['Warranty_Product__r'] = {};
                                                    insertedInstalledClaimPart['Warranty_Product__r']['Name'] = nonSerializedInstalledPart['Name'];
                                                } else {
                                                    insertedInstalledClaimPart['Inventory__r'] = {};
                                                    insertedInstalledClaimPart['Inventory__r']['Name'] = serializedInstalledPart['Name'];
                                                }

                                                //add into the list of installed parts
                                                var currentInstalledPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                                                currentInstalledPartList.push(insertedInstalledClaimPart);
                                                component.set('v.installedPartList', currentInstalledPartList);

												console.log('-=----isSerialized-----'+isSerialized);
                                                if (!isSerialized) {

                                                    // get whether to add removed part automatically
                                                    var autoAddRemovedPart = component.get('v.customSettingManager.Auto_Add_Removed_Part');
													console.log('-=----autoAddRemovedPart-----'+autoAddRemovedPart);
                                                    if (autoAddRemovedPart) {

                                                        var removedClaimPartRecordTypeList = component.get('v.removedPartRecordTypeList');
                                                        var recordTypeIdOfremovedClaimPart = removedClaimPartRecordTypeList.filter(function(a) {

                                                            if (a['DeveloperName'] === 'Non_Serialized_Part') {
																console.log('-----a-----'+a);
                                                                return a;

                                                            }

                                                        })[0]['Id'];


                                                        //insert the removed part with same details
                                                        var removedClaimPart = {

                                                            sobjectType: 'Removed_Claim_Part__c',
                                                            Claim__c: currentClaim['Id'],
                                                            Quantity__c: quantity,
                                                            RecordTypeId: recordTypeIdOfremovedClaimPart,
                                                            Warranty_Product__c: insertedInstalledClaimPart['Warranty_Product__c'],
                                                            Inventory__c: "",
                                                            relatedInstalledPart__r: insertedInstalledClaimPart['Id']
                                                        };

                                                        var isRemovedPartAlreadyExist = false;
                                                        var currentRemovedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));

                                                        var removedPartWithSamePartIdOrInventoryId = currentRemovedPartList.filter(function(a) {

                                                            if (a !== null && a !== undefined) {

                                                                if (isSerialized == false) {

                                                                    if (a['Warranty_Product__c'] === removedClaimPart['Warranty_Product__c']) {

                                                                        return a;

                                                                    }

                                                                } else {

                                                                    if (a['Inventory__c'] === removedClaimPart['Inventory__c']) {

                                                                        return a;

                                                                    }

                                                                }

                                                            }

                                                        });
                                                        isRemovedPartAlreadyExist = removedPartWithSamePartIdOrInventoryId.length === 0 ? false : true;

                                                        if (isRemovedPartAlreadyExist === false) {


                                                            //insert the removed claim part
                                                            self.insertRaw(component, event, self, removedClaimPart,
                                                                function(removedClaimPartInsertResponse) {

                                                                    //enable modal buttons
                                                                    self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                                                    //close the modal
                                                                    if (isSaveAndNext == false) {
                                                                        self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                                    } else {
                                                                        self.resetClaimRelatedListModalData(component, event, 'installedPart');
                                                                    }


                                                                    var isSuccessfulInsert = removedClaimPartInsertResponse['sobjectsAndStatus'][0]['status'];
                                                                    console.log('-----isSuccessfulInsert-----'+isSuccessfulInsert);
                                                                    if (isSuccessfulInsert == 'successful') {

                                                                        var insertedRemovedClaimPart = removedClaimPartInsertResponse['sobjectsAndStatus'][0]['sObject'];

                                                                        //insert some values to show on ui
                                                                        insertedRemovedClaimPart['Warranty_Product__r'] = {};
                                                                        insertedRemovedClaimPart['Warranty_Product__r']['Name'] =
                                                                            nonSerializedInstalledPart['Name'];

                                                                        //add into the list of removed parts
                                                                        var currentRemovedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                                                                        currentRemovedPartList.push(insertedRemovedClaimPart);
                                                                        component.set('v.removedPartList', currentRemovedPartList);


                                                                    } else {


                                                                        //close the modal
                                                                        self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');

                                                                        // set error in insertion alert
                                                                        var errorException = claimPartInsertResponse['exception'];
                                                                        var errorArrays = claimPartInsertResponse['errorArrays'];

                                                                        if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                errorArrays != undefined && errorArrays.length != 0)) {

                                                                            var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                                            var alertboxContent = {
                                                                                message: errorMessagesFormattedInString,
                                                                                heading: $A.get("$Label.c.Removed_Part_Not_Added_H"),
                                                                                class: 'slds-theme--error',
                                                                                callableFunction: component.getReference('c.closeAlert'),
                                                                                buttonHeading: $A.get("$Label.c.OK")
                                                                            };
                                                                            self.showAlert(component, event, alertboxContent);

                                                                        }
                                                                    }
                                                                });

                                                        } else {

                                                            //enable modal buttons
                                                            self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                                            if (isSaveAndNext == false) {
                                                                //close the modal
                                                                self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                            } else {
                                                                self.resetClaimRelatedListModalData(component, event, 'installedPart');
                                                            }

                                                        }

                                                    } else {

                                                        //enable modal buttons
                                                        self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                                        if (isSaveAndNext == false) {
                                                            //close the modal
                                                            self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                        } else {
                                                            self.resetClaimRelatedListModalData(component, event, 'installedPart');
                                                        }


                                                    }

                                                } else {


                                                    //enable modal buttons
                                                    self.disableEnableComponentsWithAuraId(component, buttonIdList, false);
                                                    if (isSaveAndNext == false) {
                                                        //close the modal
                                                        self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                    } else {
                                                        self.resetClaimRelatedListModalData(component, event, 'installedPart');
                                                    }

                                                }


                                            } else {


                                                //close the modal
                                                self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');

                                                // set error in insertion alert
                                                var errorException = claimPartInsertResponse['exception'];
                                                var errorArrays = claimPartInsertResponse['errorArrays'];

                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                        errorArrays != undefined && errorArrays.length != 0)) {

                                                    var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.Installed_Part_Not_Added_H"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    self.showAlert(component, event, alertboxContent);

                                                }


                                            }
                                        }
                                    });

                                } else {

                                    //duplicate installed part

                                    //close the modal
                                    self.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                    var alertboxContent = {
                                        message: 'This installed part is already present in claim.',
                                        heading: 'Duplicate installed part',
                                        class: 'slds-theme--error',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    self.showAlert(component, event, alertboxContent);

                                }

                            }
                        }



                    } else {

                        //set jobcode not selected error
                        component.set('v.error.accordion4.fieldError.commonError', $A.get("$Label.c.Fill_Serialized_Non_Serialized_Part"));

                    }


                    break;
                }

            case "removedPart":
                {
                    //get all the required info from form
                    var buttonIdList = ['saveRemovedPartButton', 'saveNextRemovedPartButton', 'cancelRemovedPart'];
                    var serializedRemovedPart = JSON.parse(JSON.stringify(component.get('v.selectedSerializedRemovedPart')));
                    var nonSerializedRemovedPart = JSON.parse(JSON.stringify(component.get('v.selectedNonSerializedRemovedPart')));

                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));

                    if ((serializedRemovedPart != null && serializedRemovedPart != undefined) ||
                        (nonSerializedRemovedPart != null && nonSerializedRemovedPart != undefined)) {


                        // check quantity validation
                        var quantity = parseFloat(component.find('removedPartQuantity').get('v.value'));
                        if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {
                            component.set('v.error.accordion4.fieldError.removedPartQuantity', $A.get("$Label.c.Quantity_Error"));
                        } else {

                            //unset the error
                            component.set('v.error.accordion4.fieldError.removedPartQuantity', '');


                            //create empty installed part
                            var removedClaimPart = {

                                sobjectType: 'Removed_Claim_Part__c',
                                Claim__c: currentClaim['Id'],
                                Quantity__c: quantity,
                                RecordTypeId: "",
                                Warranty_Product__c: "",
                                Inventory__c: ""

                            };

                            var recordTypeList = JSON.parse(JSON.stringify(component.get('v.removedPartRecordTypeList')));
                            var recordTypeId = "";
                            var isSerialized = false;

                            //find if it is serialized or non serialized and deside
                            if (serializedRemovedPart != null && serializedRemovedPart != undefined) {

                                recordTypeId = recordTypeList.filter(function(a) {

                                    if (a['DeveloperName'] == 'Serialized_Part') {
                                        return a;
                                    }

                                })[0]['Id'];

                                removedClaimPart['Inventory__c'] = serializedRemovedPart['Id'];
                                isSerialized = true;

                            } else {

                                recordTypeId = recordTypeList.filter(function(a) {

                                    if (a['DeveloperName'] == 'Non_Serialized_Part') {
                                        return a;
                                    }

                                })[0]['Id'];

                                removedClaimPart['Warranty_Product__c'] = nonSerializedRemovedPart['Id']
                            }

                            removedClaimPart['RecordTypeId'] = recordTypeId;

                            //insert the removed part

                            //disable buttons
                            self.disableEnableComponentsWithAuraId(component, buttonIdList, true);

                            var isRemovedPartAlreadyExist = false;
                            var currentRemovedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));

                            var removedPartWithSamePartIdOrInventoryId = currentRemovedPartList.filter(function(a) {

                                if (a !== null && a !== undefined) {

                                    if (isSerialized == false) {

                                        if (a['Warranty_Product__c'] === removedClaimPart['Warranty_Product__c']) {

                                            return a;

                                        }

                                    } else {

                                        if (a['Inventory__c'] === removedClaimPart['Inventory__c']) {

                                            return a;

                                        }

                                    }

                                }

                            });
                            isRemovedPartAlreadyExist = removedPartWithSamePartIdOrInventoryId.length === 0 ? false : true;

                            if (isRemovedPartAlreadyExist === false) {


                                self.insertRaw(component, event, self, removedClaimPart, function(removedClaimPartInsertResponse) {

                                    if (removedClaimPartInsertResponse['sobjectsAndStatus'] != undefined &&
                                        removedClaimPartInsertResponse['sobjectsAndStatus'] != null &&
                                        removedClaimPartInsertResponse['sobjectsAndStatus'].length != 0) {

                                        var isSuccessfulInsert = removedClaimPartInsertResponse['sobjectsAndStatus'][0]['status'];
                                        if (isSuccessfulInsert == 'successful') {

                                            var insertedRemovedClaimPart = removedClaimPartInsertResponse['sobjectsAndStatus'][0]['sObject'];

                                            //fill some values to show on ui
                                            if (!isSerialized) {
                                                insertedRemovedClaimPart['Warranty_Product__r'] = {};
                                                insertedRemovedClaimPart['Warranty_Product__r']['Name'] = nonSerializedRemovedPart['Name'];
                                            } else {
                                                insertedRemovedClaimPart['Inventory__r'] = {};
                                                insertedRemovedClaimPart['Inventory__r']['Name'] = serializedRemovedPart['Name'];
                                            }

                                            //add into the list of removed parts
                                            var currentRemovedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                                            currentRemovedPartList.push(insertedRemovedClaimPart);
                                            component.set('v.removedPartList', currentRemovedPartList);

                                            //enable buttons
                                            self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                            if (isSaveAndNext == false) {
                                                self.closeModal(component, "v.modalAndElementDisplayBool.removedPartModal");
                                            } else {
                                                self.resetClaimRelatedListModalData(component, event, 'removedPart');
                                            }


                                        } else {

                                            //close the modal
                                            self.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');

                                            // set error in insertion alert
                                            var errorException = removedClaimPartInsertResponse['exception'];
                                            var errorArrays = removedClaimPartInsertResponse['errorArrays'];

                                            if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                    errorArrays != undefined && errorArrays.length != 0)) {

                                                var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                var alertboxContent = {
                                                    message: errorMessagesFormattedInString,
                                                    heading: $A.get("$Label.c.Removed_Part_Not_Added_H"),
                                                    class: 'slds-theme--error',
                                                    callableFunction: component.getReference('c.closeAlert'),
                                                    buttonHeading: $A.get("$Label.c.OK")
                                                };
                                                self.showAlert(component, event, alertboxContent);

                                            }


                                        }


                                    } else {


                                        //close the modal
                                        self.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');

                                        // set error in insertion alert
                                        var errorException = removedClaimPartInsertResponse['exception'];
                                        var errorArrays = removedClaimPartInsertResponse['errorArrays'];

                                        if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                errorArrays != undefined && errorArrays.length != 0)) {

                                            var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                            var alertboxContent = {
                                                message: errorMessagesFormattedInString,
                                                heading: $A.get("$Label.c.Removed_Part_Not_Added_H"),
                                                class: 'slds-theme--error',
                                                callableFunction: component.getReference('c.closeAlert'),
                                                buttonHeading: $A.get("$Label.c.OK")
                                            };
                                            self.showAlert(component, event, alertboxContent);

                                        }
                                    }
                                });

                            } else {

                                //duplicate removed part error
                                //close the modal
                                self.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');

                                var alertboxContent = {
                                    message: "This removed part is already present..",
                                    heading: "Duplicate removed part",
                                    class: 'slds-theme--error',
                                    callableFunction: component.getReference('c.closeAlert'),
                                    buttonHeading: $A.get("$Label.c.OK")
                                };
                                self.showAlert(component, event, alertboxContent);


                            }
                        }
                    } else {

                        //set jobcode not selected error
                        component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', $A.get("$Label.c.Fill_Serialized_Non_Serialized_Part"));

                    }

                    break;
                }

            case "miscellenousPart":
                {

                    //get all the required info from form
                    var buttonIdList = ['saveNONOEMButton', 'saveNextNONOEMButton', 'cancelNONOEMPart'];

                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));

                    //non OEM part name
                    var nonOEMPartName = component.find('nonOEMPartName').get('v.value');
                    if (nonOEMPartName === undefined || nonOEMPartName === null || nonOEMPartName === '') {

                        //set the error
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', $A.get("$Label.c.Part_Name_Empty"));

                    } else {

                        //unset part empty error
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', '');

                        var quantity = parseFloat(component.find('nonOEMPartQuantity').get('v.value'));
                        var customCost = parseFloat(component.find('nonOEMPartCustomCost').get('v.value'));
                        var description = component.find('nonOEMPartDescription').get('v.value');

                        if (customCost < 0 || isNaN(customCost)) {

                            component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', $A.get("$Label.c.Non_OEM_Custom_Cost_Negative_Empty"));

                        } else {

                            if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {

                                component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', $A.get("$Label.c.Quantity_Error"));

                            } else {

                                if (description === null || description === undefined || description === '') {

                                    component.set('v.error.accordion4.fieldError.nonOEMPartDescription', $A.get("$Label.c.Non_OEM_Part_Description_Error"));

                                } else {

                                    var invoiceDate = component.find('Invoice Date').get('v.value');

                                    if (new Date(invoiceDate) == 'Invalid Date' && invoiceDate !== '') {

                                        component.set('v.error.accordion4.fieldError.invoiceDate', 'Invalid Date');

                                    } else {

                                        //No error, unset all the error values
                                        component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', '');
                                        component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', '');
                                        component.set('v.error.accordion4.fieldError.nonOEMPartName', '');
                                        component.set('v.error.accordion4.fieldError.nonOEMPartDescription', '');
                                        component.set('v.error.accordion4.fieldError.invoiceDate', '');


                                        //invoice date and number fill
                                        var invoiceDate = component.find('Invoice Date').get('v.value');
                                        var invoiceNumber = component.find('Invoice Number').get('v.value');

                                        if (invoiceNumber == '' || invoiceNumber == undefined || invoiceNumber == null) {
                                            invoiceNumber = null;
                                        }

                                        if (invoiceDate == '' || invoiceDate == undefined || invoiceDate == null) {
                                            invoiceDate = null;
                                        } else {

                                            invoiceDate = new Date(invoiceDate);
                                            invoiceDate = self.getDateReadableFormat(invoiceDate);

                                        }


                                        //create empty Non-OEM part
                                        var nonOEMPart = {

                                            sobjectType: 'Claim_Part__c',
                                            Claim__c: currentClaim['Id'],
                                            Custom_Part_Cost__c: customCost,
                                            Quantity__c: quantity,
                                            RecordTypeId: "",
                                            Miscellaneous_Part_Name__c: nonOEMPartName,
                                            Miscellaneous_Part_Description__c: description,
                                            Name: nonOEMPartName,
                                            Invoice_Date__c: invoiceDate,
                                            Invoice_Number__c: invoiceNumber
                                        };

                                        //fill record type Id
                                        var recordTypeList = JSON.parse(JSON.stringify(component.get('v.installedPartRecordTypeList')));
                                        var recordTypeId = recordTypeList.filter(function(a) {

                                            if (a['DeveloperName'] == 'Miscellaneous_Part') {
                                                return a;
                                            }

                                        })[0]['Id'];
                                        nonOEMPart['RecordTypeId'] = recordTypeId;

                                        //insert the NON-OEM part

                                        //disable buttons
                                        self.disableEnableComponentsWithAuraId(component, buttonIdList, true);

                                        self.insertRaw(component, event, self, nonOEMPart, function(nonOEMPartInsertResponse) {

                                            //enable buttons
                                            self.disableEnableComponentsWithAuraId(component, buttonIdList, false);

                                            if (nonOEMPartInsertResponse['sobjectsAndStatus'] != undefined &&
                                                nonOEMPartInsertResponse['sobjectsAndStatus'] != null &&
                                                nonOEMPartInsertResponse['sobjectsAndStatus'].length != 0) {

                                                var isSuccessfulInsert = nonOEMPartInsertResponse['sobjectsAndStatus'][0]['status'];
                                                if (isSuccessfulInsert == 'successful') {

                                                    var insertedNONOEMpart = nonOEMPartInsertResponse['sobjectsAndStatus'][0]['sObject'];

                                                    //add into the list of NON-OEM parts
                                                    var nonOEMPartList = JSON.parse(JSON.stringify(component.get('v.nonOEMPartList')));
                                                    nonOEMPartList.push(insertedNONOEMpart);
                                                    component.set('v.nonOEMPartList', nonOEMPartList);


                                                    if (isSaveAndNext == false) {
                                                        //close the modal
                                                        self.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                                                    } else {
                                                        self.resetClaimRelatedListModalData(component, event, 'miscellenousPart');
                                                    }


                                                } else {

                                                    //close the modal
                                                    self.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');

                                                    // set error in insertion alert
                                                    var errorException = nonOEMPartInsertResponse['exception'];
                                                    var errorArrays = nonOEMPartInsertResponse['errorArrays'];

                                                    if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                            errorArrays != undefined && errorArrays.length != 0)) {

                                                        var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                        var alertboxContent = {
                                                            message: errorMessagesFormattedInString,
                                                            heading: $A.get("$Label.c.NON_OEM_Part_Not_Added"),
                                                            class: 'slds-theme--error',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        self.showAlert(component, event, alertboxContent);

                                                    }

                                                }

                                            } else {

                                                //close the modal
                                                self.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');

                                                // set error in insertion alert
                                                var errorException = nonOEMPartInsertResponse['exception'];
                                                var errorArrays = nonOEMPartInsertResponse['errorArrays'];

                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                        errorArrays != undefined && errorArrays.length != 0)) {

                                                    var errorMessagesFormattedInString = self.getErrorMessage(errorException, errorArrays);

                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.NON_OEM_Part_Not_Added"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    self.showAlert(component, event, alertboxContent);

                                                }

                                            }


                                        });
                                    }

                                }




                            }

                        }



                    }



                    break;
                }

        }

    },
    deleteJobCodeList: function(component, event) {

        var self = this;
        var claimServiceInfoList = JSON.parse(JSON.stringify(component.get('v.claimServiceInfoList')));

        if (claimServiceInfoList.length != 0) {

            //get the ids of all the claim service info
            var claimServiceInfoIDList = claimServiceInfoList.map(function(a) {
                if (a !== null && a !== undefined && a['Id'] !== null && a['Id'] !== undefined) {
                    return a['Id'];
                }
            });

            //make a delete call
            component.set('v.spinnerBool.pageSpinner', true);
            self.deleteRaw(component, event, self, claimServiceInfoIDList, function(claimServiceInfoDeleteResponse) {

                //hide the spinner
                component.set('v.spinnerBool.pageSpinner', false);

                var statusArray = claimServiceInfoDeleteResponse['statusArray'];
                if (statusArray !== null && statusArray !== undefined && statusArray.length != 0) {

                    //reset the claimservice info list
                    claimServiceInfoList = [];
                    component.set('v.claimServiceInfoList', claimServiceInfoList);

                }

            });

        }

    },
    getCampaignMembers: function(component, event, inventoryId) {

        var self = this;
        var failureDate = component.get('v.currentClaim.Date_of_Failure__c');
        var inventoryId = component.get('v.currentClaim.Inventory__c');

        failureDate = $A.localizationService.formatDate(new Date(failureDate), "yyyy-MM-dd", $A.get("$Locale.timezone"));

        if (inventoryId !== null && inventoryId !== undefined && inventoryId !== undefined &&
            failureDate !== null && failureDate !== undefined) {

            //get all the campaigns from campaign members where this inventory is found
            var query = "Select Id,Name,Serial_Number__c,Service_Campaign__r.Id,Service_Campaign__r.Name," +
                "Service_Campaign__r.Claim_Template__c,Service_Campaign__r.Claim_Template__r.Id, Service_Campaign__r.Claim_Template__r.Name," +
                "Service_Campaign__r.Claim_Template__r.Causal_Part_Number__r.Id, Service_Campaign__r.Claim_Template__r.Causal_Part_Number__r.Name," +
                "Service_Campaign__r.Claim_Template__r.Causal_Part_Number__r.Description__c,Service_Campaign__r.Start_Date__c,Service_Campaign__r.End_Date__c," +
                "Service_Campaign__r.Claim_Template__r.Fault_Code__r.Id, Service_Campaign__r.Claim_Template__r.Fault_Code__r.Name," +
                "Service_Campaign__r.Claim_Template__r.Fault_found__c,Service_Campaign__r.Claim_Template__r.Caused_by__c," +
                "Service_Campaign__r.Claim_Template__r.TravelByHours__c,Service_Campaign__r.Claim_Template__r.TravelByDistance__c," +
                "Service_Campaign__r.Claim_Template__r.TravelByLocation__c,Service_Campaign__r.Claim_Template__r.Total_Category1_Cost__c," +
                "Service_Campaign__r.Claim_Template__r.Total_Meals_Cost__c,Service_Campaign__r.Claim_Template__r.Total_Parking_Cost__c," +
                "Service_Campaign__r.Claim_Template__r.Rate__c,Service_Campaign__r.Claim_Template__r.Total_Category2_Cost__c," +
                "Service_Campaign__r.Claim_Template__r.Fault_Code_Comment__c,Service_Campaign__r.Claim_Template__r.CasualPart_Comments__c," +
                "Service_Campaign__r.Claim_Template__r.Description__c,Service_Campaign__r.Claim_Template__r.work_Performed_comments__c " +
                "from Campaign_Members__c where Status__c='Campaign Member Uploaded' AND Service_Campaign__r.Status__c='Active' " +
                "AND Service_Campaign__r.Claim_Template__c!=null AND Inventory__c='" + inventoryId + "' AND " +
                "Service_Campaign__r.End_Date__c>=" + failureDate + " AND Service_Campaign__r.Start_Date__c<=" + failureDate;

            //show spinner
            component.set('v.spinnerBool.pageSpinner', true);
            self.readRaw(component, event, self, query, function(campaignMemberResponse) {

                //show spinner
                component.set('v.spinnerBool.pageSpinner', false);

                if (campaignMemberResponse['sObjectList'] !== undefined && campaignMemberResponse['sObjectList'] !== null &&
                    campaignMemberResponse['sObjectList'].length !== 0) {

                    var campaignMemberList = campaignMemberResponse['sObjectList'];

                    //set the campaign picklist on dom
                    var campaignMemberOptions = [];
                    campaignMemberOptions = campaignMemberList.map(function(a) {

                        var option = {
                            label: a['Service_Campaign__r']['Name'],
                            value: JSON.stringify(a),
                            selected: false
                        }
                        return option;
                    });
                    campaignMemberOptions[0]['selected'] = true;

                    if (typeof(component.find('campaignMember').set) == 'function') {
                        component.find('campaignMember').set('v.options', campaignMemberOptions);
                    }

                    //set the default campaign member as first one
                    component.set('v.currentClaim.Campaign_Members__c', campaignMemberList[0]['Id']);

                    component.set('v.campaignMember', campaignMemberList[0]);

                    var claimTemplate = campaignMemberList[0]['Service_Campaign__r']['Claim_Template__r'];

                    //set the causal part and faultcode from the first campaign
                    var causalPart = campaignMemberList[0]['Service_Campaign__r']['Claim_Template__r']
                        ['Causal_Part_Number__r'];

                    if (causalPart != undefined && causalPart != null) {

                        //set the causal part details wherever necesary
                        if (typeof(component.find('causalPart').set) === 'function') {
                            component.find('causalPart').set('v.objectName', causalPart['Name']);
                        }
                        component.set('v.causalPart', causalPart);
                        if (typeof(component.find('causalPartDescription').set) === 'function') {
                            component.find('causalPartDescription').set('v.value', causalPart['Description__c']);
                        }

                        component.set('v.currentClaim.Causal_Part_Number__c', causalPart['Id']);
                        component.set('v.error.accordion1.causalPart', '');

                        //set the fault code details wherever necessary
                        var faultCode = campaignMemberList[0]['Service_Campaign__r']['Claim_Template__r']
                            ['Fault_Code__r'];

                        if (faultCode != undefined && faultCode != null) {

                            //set the causal part details wherever necesary
                            self.setFaultCodePicklistOptions(component, [faultCode], 0);

                            component.set('v.currentClaim.Fault_Code__c', faultCode['Id']);
                            component.set('v.error.accordion1.faultCode', '');

                        }
                    }

                    //set the picklist values

                    var pickListCollection = JSON.parse(JSON.stringify(component.get('v.claimPicklist')));
                    var noneOption = {
                        label: '--None--',
                        value: '',
                        selected: false
                    };
                    //fill fault found and caused by
                    var faultFound = campaignMemberList[0]["Service_Campaign__r"]["Claim_Template__r"]["Fault_found__c"];
                    faultFound = (faultFound == null || faultFound == undefined || faultFound == '' ? '' : faultFound);
                    var faultFoundList = pickListCollection[4]['val'];
                    var faultFoundOptions = [];
                    var faultFoundOptions = faultFoundList.map(function(a) {
                        var option = {
                            label: a['label'],
                            value: a['value'],
                            selected: false
                        }
                        return option;
                    });
                    faultFoundOptions.unshift(noneOption);
                    var indexOfOption = self.findIndexWithProperty(faultFoundOptions, 'value', faultFound);
                    if (indexOfOption > -1) {
                        faultFoundOptions[indexOfOption]['selected'] = true;
                    }
                    if (typeof(component.find('faultFound').set) == 'function') {
                        component.find('faultFound').set('v.options', faultFoundOptions);
                    }


                    //set the caused by value on dom
                    var causedBy = campaignMemberList[0]["Service_Campaign__r"]["Claim_Template__r"]["Caused_by__c"];
                    causedBy = (causedBy == null || causedBy == undefined || causedBy == '' ? '' : causedBy);
                    var causedByList = pickListCollection[5]['val'];
                    var causedByOptions = [];
                    var causedByOptions = causedByList.map(function(a) {
                        var option = {
                            label: a['label'],
                            value: a['value'],
                            selected: false
                        }
                        return option;
                    });
                    causedByOptions.unshift(noneOption);
                    indexOfOption = self.findIndexWithProperty(causedByOptions, 'value', causedBy);
                    if (indexOfOption > -1) {
                        causedByOptions[indexOfOption]['selected'] = true;
                    }
                    if (typeof(component.find('causedBy').set) == 'function') {
                        component.find('causedBy').set('v.options', causedByOptions);
                    }

                    //set the additional information by template
                    self.setAdditionalInformationByTemplate(component, event, claimTemplate);


                } else {

                    // show the error message of service campaign found
                    var alertboxContent = {
                        message: $A.get("$Label.c.Service_Campaign_Not_Found_M"),
                        heading: $A.get("$Label.c.Service_Campaign_Not_Found_H"),
                        class: 'slds-theme--info',
                        callableFunction: component.getReference('c.closeAlert'),
                        buttonHeading: $A.get("$Label.c.OK")
                    };
                    self.showAlert(component, event, alertboxContent);

                    // unset the inventory page and dom variables
                    component.set('v.inventory', null);
                    component.find('inventory').set('v.objectName', '');
                    component.set('v.currentClaim.Inventory__c', '');
                    if (typeof(component.find('campaignMember').set) == 'function') {
                        component.find('campaignMember').set('v.options', [{}]);
                    }
                }

            });

        }

    },

    /*********Integration*********************************/
    /****Aditya integration****/
    getPartSettings: function(component, event, helper) {
        var action = component.get("c.getPartByPartSettings");
        var nonSerializedInstalledPart = event.getParam('selectedObject');
        console.log(JSON.stringify(nonSerializedInstalledPart) + '####');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS' && component.isValid()) {
                //component.set("v.partpriceSettings",response.getReturnValue());
                if (response.getReturnValue()) {
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    var getUnitPartPriceAction = component.get('c.getIndividualPartPrice');
                    component.set('v.spinnerBool.pageSpinner', true);

                    var partCode = '';

                    if (nonSerializedInstalledPart['Item__r'] !== undefined && nonSerializedInstalledPart['Item__r'] !== null &&
                        nonSerializedInstalledPart['Item__r']['Name'] != null && nonSerializedInstalledPart['Item__r']['Name'] != undefined) {
                        partCode = nonSerializedInstalledPart['Item__r']['Name'];

                    } else {
                        partCode = nonSerializedInstalledPart['Name'];
                    }

                    getUnitPartPriceAction.setParams({
                        ClaimId: currentClaim['Id'],
                        PartNumber: partCode
                    });

                    getUnitPartPriceAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS" && component.isValid()) {
                            component.set('v.partPriceException', false);
                            var returnedvalue = response.getReturnValue();
                            var response = [];
                            response = JSON.parse(returnedvalue);
                            component.find('customCost').set('v.value', response[0]['ttPriceVal'].toFixed(2));
                            component.set('v.spinnerBool.pageSpinner', false);
                            component.set('v.partPriceNotFound', false);
                            if (response[0]['ttResultVal'] != 'success') {
                                component.set('v.partPriceNotFound', true);
                                component.set('v.partPriceErrorMsg', response[0]['ttMessageVal']);
                                component.set('v.partPriceException', true);
                            }
                        }
                    });
                    $A.enqueueAction(getUnitPartPriceAction);
                }
            } else {
                console.log('FAIL');
            }

        });
        $A.enqueueAction(action);

    },
    /*************************/
    
    getmodelParentJobCodeCustomSetting: function(component, event, helper) {
        var action = component.get("c.isModelParentJobCodeList");
        action.setCallback(this, function(response) {
        	var returnedvalue = response.getReturnValue();
        	component.set("v.isModelParentJobCodeCustomSetting",returnedvalue);
        	console.log(returnedvalue);
        });
        $A.enqueueAction(action);
    },
    
    getInventoryUpcomingSchedule: function(component, memberList, defaultIndex) {

        var memberListComponent = component.find('upcomingScheduler');
        if (memberList !== undefined && memberList !== null && memberList.length !== 0) {

            var optionList = memberList.map(function(a) {

                var option = {
                    label: a['Name'],
                    value: a['Id'],
                    selected: false
                };
                return option;

            });

            if (optionList !== undefined && optionList !== null && optionList.length !== 0 && defaultIndex !== -1) {
                optionList[defaultIndex]['selected'] = true;
            }

            if (optionList !== undefined && optionList !== null && optionList.length !== 0) {
                memberListComponent.set('v.options', optionList);
            } else {
                memberListComponent.set('v.options', []);
            }

        } else {

            memberListComponent.set('v.options', []);

        }
        //set the fault code list
        //component.set('v.faultCodeList', faultCodeList);

    },
    


})