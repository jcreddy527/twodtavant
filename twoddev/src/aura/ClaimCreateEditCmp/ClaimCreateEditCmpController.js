({
    /*** init method for component initialization ****/
    
    doInit: function(component, event, helper) {
        
        //added by Dharmil for getting custom setting value for job code logic.
        helper.getmodelParentJobCodeCustomSetting(component, event, helper);     
        
        // essential initialization for alert box
        helper.showAlert(component, event, {});
        component.set('v.userLangId', $A.get("$Locale.langLocale"));
        
        // javascript objects to initialize page variables
        var isEdit = component.get('v.isEdit');
        
        var spinnerBool = {
            pageSpinner: false,
            claimServiceInfoSpinner: false,
            summarySpinner: true
        };
        var modalAndElementDisplayBool = {
            claimServiceInfoModal: false,
            installedPartsModal: false,
            removedPartsModal: false,
            nonOEMPartModal: false,
            reasonForAdditionalHoursNeeded: false,
        };
        var modalData = {
            claimServiceInfo: {
                mode: 'Create',
                title: $A.get('$Label.c.Create_Claim_Service_Info_Heading'),
                selectedClaimServiceInfo: {}
            },
            installedParts: {
                mode: 'Create',
                title: $A.get('$Label.c.Add_Installed_Part_Heading'),
                selectedInstalledPart: {}
            },
            removedParts: {
                mode: 'Create',
                title: $A.get('$Label.c.Add_Removed_Part_Heading'),
                selectedRemovedPart: {}
            },
            nonOEMParts: {
                mode: 'Create',
                title: $A.get('$Label.c.Add_Miscellaneous_Part_Heading'),
                selectedNONOEMPart: {}
            }
        };
        var todayDateString = helper.getTodayDate(component, event);
        
        
        /*****get all picklist values of claim in JSON ****/
        
        var pickListCollection = JSON.parse(JSON.stringify(component.get('v.claimPicklist')));
        
        /***** set all settable picklist values and related list values ******/
        if (pickListCollection != undefined && pickListCollection != null && pickListCollection.length != 0) {
            
            // add record type list
            //18-NOV-2016
            if (pickListCollection[0]['val'] != null) {
                var recordTypeList = pickListCollection[0]['val'];
                //if dealer or distributer login
                var site = component.get('v.site');
                if (site !== '') {
                    recordTypeList = recordTypeList.filter(function(a) {
                        if (a['label'] !== 'Claim Template') {
                            return a;
                        }
                    });
                }
                
                component.set('v.claimRecordTypeList', recordTypeList);
                
            } else {
                component.set('v.claimRecordTypeList', []);
            }
            //--18-NOV-2016
            
            //installed part recordType list
            if (pickListCollection[6]['val'] != null) {
                component.set('v.installedPartRecordTypeList', pickListCollection[6]['val']);
            } else {
                component.set('v.installedPartRecordTypeList', []);
            }
            
            //removed part recordType list
            if (pickListCollection[7]['val'] != null) {
                component.set('v.removedPartRecordTypeList', pickListCollection[7]['val']);
            } else {
                component.set('v.removedPartRecordTypeList', []);
            }
            
        }
        
        // if it is create claim case
        if (isEdit != undefined && isEdit == false) {
            
            //variables initializations for claim create
            var accordionValidationIndicator = {
                accordion1: false,
                accordion3: false,
                accordion4: false,
                accordion5: false,
                accordion6: false
            };
            var error = {
                accordion1: {
                    fieldError: {
                        dealer: "",
                        inventory: "",
                        product: "",
                        purchaseDate: "",
                        failureDate: "",
                        repairDate: "",
                        reasonForDelay: "",
                        unitsUsage: "",
                        causalPart: "",
                        faultCode: ""
                    }
                },
                accordion3: {
                    fieldError: {
                        jobCode: "",
                        additionalLabourHours: "",
                        reasonForAdditionalHours: ""
                    }
                },
                accordion4: {
                    fieldError: {
                        nonSerializedInstalledPart: "",
                        serializedInstalledPart: "",
                        quantity: "",
                        customCost: "",
                        commonError: "",
                        removedPartQuantity: "",
                        commonErrorForRemovedPart: "",
                        nonOEMPartName: "",
                        nonOEMPartCustomCost: "",
                        nonOEMPartQuantity: "",
                        nonOEMPartDescription: "",
                        invoiceDate: ""
                    }
                },
                accordion5: {
                    fieldError: {
                        faultFoundComment: "",
                        causalPartComment: "",
                        workPerformedComment: ""
                    }
                }
            };
            
            // page and component variables initializations
            component.set('v.spinnerBool', spinnerBool);
            component.set('v.error', error);
            component.set('v.modalAndElementDisplayBool', modalAndElementDisplayBool);
            
            // set default record type page variable
            component.set('v.claimCustomRecordTypeName', pickListCollection[0]['val'][0]['value']);
            
            
            var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
            if (claimCustomRecordTypeName != null && claimCustomRecordTypeName != undefined) {
                
                var recordTypeList = JSON.parse(JSON.stringify(component.get('v.claimRecordTypeList')));
                
                //make causal part disabled for serialized and field mod claim
                if (claimCustomRecordTypeName == 'Serialized' || claimCustomRecordTypeName == 'Field Modification') {
                    
                    var causalPartComponent = component.find('causalPart');
                    if (causalPartComponent !== null && causalPartComponent !== undefined && typeof(causalPartComponent.set) == 'function') {
                        causalPartComponent.set('v.disabled', true);
                    }
                    
                    helper.setFaultCodePicklistOptions(component, [], -1);
                    
                    
                }
                
            }
            
            
            //set all the picklist values in claim
            helper.initializePickListValue(component, event);
            
            /***** initialize page variables for new claim ****/
            currentClaim = {
                sobjectType: 'Claim__c',
                Claim_Record_Type__c: claimCustomRecordTypeName,
                Claim_Type__c: '',
                Account__c: '',
                Inventory__c: '',
                Warranty_Product__c: '',
                Units_Run__c: 0,
                Date_of_Failure__c: todayDateString,
                Date_of_Repair__c: todayDateString,
                Date_Of_Purchase__c: todayDateString,
                Request_SMR__c: false,
                Work_order__c: '',
                Service_Ticket__c: '',
                Delay_Reason__c: '',
                Causal_Part_Number__c: '',
                Fault_Code__c: '',
                Fault_Code_Comment__c: '',
                Fault_found__c: '',
                Caused_by__c: '',
                CasualPart_Comments__c: '',
                work_Performed_comments__c: '',
                Description__c: '',
                TravelByHours__c: 0,
                TravelByDistance__c: 0,
                TravelByLocation__c: '',
                Total_Meals_Cost__c: 0,
                Total_Parking_Cost__c: 0,
                Total_Category1_Cost__c: 0,
                Total_Category2_Cost__c: 0,
                Campaign_Members__c: '',
                Rate__c: '',
                Claim_Template_Payment_Definition__c: ''
            };
            
            //set the claim with initial values
            component.set('v.currentClaim', currentClaim);
            
            //set the lookups
            component.set('v.inventory', null);
            component.set('v.product', null);
            component.set('v.causalPart', null);
            
            component.set('v.faultCode', "");
            
            //add the dealer lookup automatically for community user
            var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
            if (dealer != null && dealer != undefined) {
                component.find('dealer').set('v.objectName', dealer['Name']);
                component.find('dealer').set('v.disabled', true);
                component.set('v.currentClaim.Account__c', dealer['Id']);
                component.set('v.isDealerEditable', false); ///18-NOV-2016///
            }
            
            
            //set all related list variables
            component.set('v.claimServiceInfoList', []);
            component.set('v.installedPartList', []);
            component.set('v.removedPartList', []);
            component.set('v.nonOEMPartList', []);
            component.set('v.partsToBeShippedList', []);
            
            component.set('v.accordionValidationIndicator', accordionValidationIndicator);
            
            component.set('v.purchaseDate', null);
            component.set('v.repairDate', todayDateString);
            component.set('v.failureDate', todayDateString);
            component.set('v.accordionValidationIndicator', accordionValidationIndicator);
            
            component.set('v.modalData', modalData);
            
            
        } else if (isEdit != undefined && isEdit == true) {
            
            
            //variables initializations for claim edit
            var accordionValidationIndicator = {
                accordion1: true,
                accordion3: true,
                accordion4: true,
                accordion5: true,
                accordion6: true
            };
            var error = {
                accordion1: {
                    fieldError: {
                        dealer: "",
                        inventory: "",
                        product: "",
                        purchaseDate: "",
                        failureDate: "",
                        repairDate: "",
                        reasonForDelay: "",
                        unitsUsage: "",
                        causalPart: "",
                        faultCode: ""
                    }
                },
                accordion3: {
                    fieldError: {
                        jobCode: "",
                        additionalLabourHours: "",
                        reasonForAdditionalHours: ""
                    }
                },
                accordion4: {
                    fieldError: {
                        nonSerializedInstalledPart: "",
                        serializedInstalledPart: "",
                        quantity: "",
                        customCost: "",
                        commonError: "",
                        removedPartQuantity: "",
                        commonErrorForRemovedPart: "",
                        nonOEMPartName: "",
                        nonOEMPartCustomCost: "",
                        nonOEMPartQuantity: "",
                        nonOEMPartDescription: "",
                        invoiceDate: ""
                    }
                },
                accordion5: {
                    fieldError: {
                        faultFoundComment: "",
                        causalPartComment: "",
                        workPerformedComment: ""
                    }
                }
            };
            component.set('v.accordionValidationIndicator', accordionValidationIndicator);
            
            // page and component variables initializations
            component.set('v.spinnerBool', spinnerBool);
            component.set('v.error', error);
            component.set('v.modalAndElementDisplayBool', modalAndElementDisplayBool);
            
            //set the editibility of dealer
            if (component.find('dealer') != undefined && component.find('dealer') != null) {
                if (typeof(component.find('dealer').set) == "function") {
                    component.set('v.isDealerEditable', false);
                }
            }
            
            
            // set claim heading as claim edit and do every thing after claim get
            component.set('v.claimPageHeading', $A.get("$Label.c.Claim_Edit_Heading"));
            
            var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
            
            // set default record type page variable
            var claimCustomRecordTypeName = currentClaim['Claim_Record_Type__c'];
            var recordTypePickList = JSON.parse(JSON.stringify(component.get('v.claimRecordTypeList')));
            var currentClaimRecordTypeObject = recordTypePickList.filter(function(a) {
                
                if (a !== undefined && a !== null && a['value'] !== undefined && a['value'] == claimCustomRecordTypeName) {
                    return a;
                }
                
            })[0];
            
            if (currentClaimRecordTypeObject !== null && currentClaimRecordTypeObject !== undefined && currentClaimRecordTypeObject['value'] !== null && currentClaimRecordTypeObject['value'] !== undefined) {
                component.set('v.claimCustomRecordTypeName', currentClaimRecordTypeObject['value']);
            }
            
            
            //set all the picklist values in claim
            helper.initializePickListValue(component, event);
            
            
            var claimCustomRecordTypeName = JSON.parse(JSON.stringify(component.get('v.claimCustomRecordTypeName')));
            
            switch (claimCustomRecordTypeName) {
                    
                case 'Field Modification':
                    {
                        //fill the campaign-member picklist
                        var campaignMember = currentClaim['Campaign_Members__r'];
                        var campaign = currentClaim['Campaign_Members__r']['Service_Campaign__r'];
                        
                        //set the campaign picklist on dom
                        var campaignMemberOptions = [{
                            label: campaign['Name'],
                            value: campaign,
                            selected: true
                        }];
                        
                        if (typeof(component.find('campaignMember').set) == 'function') {
                            component.find('campaignMember').set('v.options', campaignMemberOptions);
                        }
                        
                        //set the default campaign member as first one
                        component.set('v.currentClaim.Campaign_Members__c', campaignMember['Id']);
                        
                        component.set('v.campaignMember', campaignMember);
                        component.set('v.fieldModInitEditBoolean', true);
                        
                    }
                    
                case "Preventive Maintenance":
                    {	
                     var currentClaimId = currentClaim['Id'];
                     helper.fetchUpcomingScheduleForClaim(component,currentClaimId);
                     
                     component.set('v.claimType', currentClaim['Claim_Type__c']);
                     component.set('v.inventory', currentClaim['Inventory__r']);
                     component.set('v.causalPart', currentClaim['Causal_Part_Number__r']);
                     component.set('v.dealer', currentClaim['Account__r']);
                     
                     //var currentClaimId = currentClaim['Id'];
                     //helper.fetchUpcomingScheduleForClaim(component,currentClaimId);
                     
                     // initialize dates with the dates of editable claim
                     var dateOfFailure = helper.getDateReadableFormat(currentClaim['Date_of_Failure__c']);
                     var dateOfRepair = helper.getDateReadableFormat(currentClaim['Date_of_Repair__c']);
                     var dateOfPurchase = helper.getDateReadableFormat(currentClaim['Date_Of_Purchase__c']);
                     var getInventorySchedule = component.get('c.updateInventorySchedule');
                     //set the dates
                     component.set('v.repairDate', dateOfRepair);
                     component.set('v.failureDate', dateOfFailure);
                     component.set('v.purchaseDate', dateOfPurchase);
                     
                     //check for date difference in failure and repair date
                     if (component.get('v.failureRepairDateDiffBig')) {
                         component.find('reasonForDelay').set('v.value', currentClaim['Delay_Reason__c']);
                     }
                     
                     //add fault code
                     var faultCode = currentClaim['Fault_Code__r'];
                     var faultCodeMapperList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                     helper.initializeFaultCodeListForEditMode(component, faultCodeMapperList);
                     
                     break;
                    }
                    
                case "Serialized":
                    {
                        
                        component.set('v.claimType', currentClaim['Claim_Type__c']);
                        component.set('v.inventory', currentClaim['Inventory__r']);
                        component.set('v.causalPart', currentClaim['Causal_Part_Number__r']);
                        component.set('v.dealer', currentClaim['Account__r']);
                        
                        // initialize dates with the dates of editable claim
                        var dateOfFailure = helper.getDateReadableFormat(currentClaim['Date_of_Failure__c']);
                        var dateOfRepair = helper.getDateReadableFormat(currentClaim['Date_of_Repair__c']);
                        var dateOfPurchase = helper.getDateReadableFormat(currentClaim['Date_Of_Purchase__c']);
                        
                        //set the dates
                        component.set('v.repairDate', dateOfRepair);
                        component.set('v.failureDate', dateOfFailure);
                        component.set('v.purchaseDate', dateOfPurchase);
                        
                        //check for date difference in failure and repair date
                        if (component.get('v.failureRepairDateDiffBig')) {
                            component.find('reasonForDelay').set('v.value', currentClaim['Delay_Reason__c']);
                        }
                        
                        //add fault code
                        var faultCode = currentClaim['Fault_Code__r'];
                        var faultCodeMapperList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                        helper.initializeFaultCodeListForEditMode(component, faultCodeMapperList);
                        
                        break;
                    }
                    
                case "Non-Serialized":
                    {
                        
                        component.set('v.claimType', currentClaim['Claim_Type__c']);
                        component.set('v.product', currentClaim['Warranty_Product__r']);
                        component.set('v.causalPart', currentClaim['Causal_Part_Number__r']);
                        component.set('v.dealer', currentClaim['Account__r']);
                        
                        // initialize dates with the dates of editable claim
                        var dateOfFailure = helper.getDateReadableFormat(currentClaim['Date_of_Failure__c']);
                        var dateOfRepair = helper.getDateReadableFormat(currentClaim['Date_of_Repair__c']);
                        var dateOfPurchase = helper.getDateReadableFormat(currentClaim['Date_Of_Purchase__c']);
                        
                        //set the dates
                        component.set('v.repairDate', dateOfRepair);
                        component.set('v.failureDate', dateOfFailure);
                        component.set('v.purchaseDate', dateOfPurchase);
                        
                        
                        //check for date difference in failure and repair date
                        if (component.get('v.failureRepairDateDiffBig')) {
                            component.find('reasonForDelay').set('v.value', currentClaim['Delay_Reason__c']);
                        }
                        
                        
                        //add fault code
                        var faultCode = currentClaim['Fault_Code__r'];
                        var faultCodeMapperList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                        helper.initializeFaultCodeListForEditMode(component, faultCodeMapperList);
                        
                        component.find('faultFound').set('v.value', currentClaim['Fault_found__c']);
                        component.find('causedBy').set('v.value', currentClaim['Caused_by__c']);
                        
                        break;
                    }
                    
                case "Claim Template":
                    {
                        component.set('v.claimType', currentClaim['Claim_Type__c']);
                        component.set('v.causalPart', currentClaim['Causal_Part_Number__r']);
                        
                        //add fault code
                        var faultCode = currentClaim['Fault_Code__r'];
                        var faultCodeMapperList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                        helper.initializeFaultCodeListForEditMode(component, faultCodeMapperList);
                        
                        break;
                    }
                    
            }
            
            component.set('v.faultCode', currentClaim['Fault_Code__c']);
            
            //set the related list
            var relatedListData = JSON.parse(JSON.stringify(component.get('v.relatedListData')));
            
            var claimServiceInfoList = relatedListData['Claim Service Infos'];
            var installedPartList = relatedListData['Installed Parts'];
            var removedPartList = relatedListData['Removed Parts'];
            var nonOEMPartList = relatedListData['Non-OEM parts'];
            
            
            
            
            
            component.set('v.claimServiceInfoList', claimServiceInfoList);
            component.set('v.installedPartList', installedPartList);
            component.set('v.removedPartList', removedPartList);
            component.set('v.nonOEMPartList', nonOEMPartList);
            
            
            //add the parts to be shipped by removed parts which in which shipment detail is not null and not empty
            if (removedPartList != null && removedPartList != undefined && removedPartList.length != 0) {
                var partToBeShippedList = removedPartList.filter(function(a) {
                    if (a['Return_Location__c'] != undefined && a['Return_Location__c'] != null) {
                        return a;
                    }
                });
                component.set('v.partsToBeShippedList', partToBeShippedList);
            } else {
                component.set('v.partsToBeShippedList', []);
            }
            
            
            
            
            component.set('v.modalData', modalData);
            
        }
        
    },
    
    /*** accordion form event catcher methods ******/
    basicInfoHandeler: function(component, event, helper) {
        
        
        var componentId = event.getSource().getLocalId();
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var recordTypeList = JSON.parse(JSON.stringify(component.get('v.claimRecordTypeList')));
        var todayDateString = helper.getTodayDate(component, event);
        
        var staticLabel = $A.get("$Label.c.Date_of_Failure");
        
        if(claimCustomRecordTypeName == 'Preventive Maintenance'){
            component.set('v.DOF','Date Of Service');
        }
        else{
            component.set('v.DOF',staticLabel);
        }
        
        switch (componentId) {
                
            case "claimCustomRecordTypeName":
                {
                    var textValue = event.getSource().get('v.value');
                    
                    // remove unnecessary fields according to recordType
                    switch (textValue) {
                            
                            //empty field modification case specifies that it is handeled as per the serialized part type of claim,
                            //please do not delete this as this empty case is necessary for flow of code
                        case 'Field Modification':
                            {
                                
                            }
                            
                            
                            
                        case 'Serialized':
                            {
                                //set the claim page variable values
                                /***** initialize page variables for new claim ****/
                                var todayDateString = helper.getTodayDate(component, event);
                                
                                currentClaim = {
                                    sobjectType: 'Claim__c',
                                    Claim_Record_Type__c: textValue,
                                    Claim_Type__c: '',
                                    Account__c: '',
                                    Inventory__c: '',
                                    Warranty_Product__c: '',
                                    Units_Run__c: 0,
                                    Date_of_Failure__c: todayDateString,
                                    Date_of_Repair__c: todayDateString,
                                    Date_Of_Purchase__c: null,
                                    Request_SMR__c: false,
                                    Work_order__c: '',
                                    Service_Ticket__c: '',
                                    Delay_Reason__c: '',
                                    Causal_Part_Number__c: '',
                                    Fault_Code__c: '',
                                    Fault_found__c: '',
                                    Caused_by__c: '',
                                    Fault_Code_Comment__c: '',
                                    CasualPart_Comments__c: '',
                                    work_Performed_comments__c: '',
                                    Description__c: '',
                                    TravelByHours__c: 0,
                                    TravelByDistance__c: 0,
                                    TravelByLocation__c: '',
                                    Total_Meals_Cost__c: 0,
                                    Total_Parking_Cost__c: 0,
                                    Total_Category1_Cost__c: 0,
                                    Total_Category2_Cost__c: 0,
                                    Campaign_Members__c: '',
                                    Rate__c: '',
                                    Claim_Template_Payment_Definition__c: ''
                                };
                                
                                // set the claim
                                component.set('v.currentClaim', currentClaim);
                                
                                var accordionValidationIndicator = {
                                    accordion1: false,
                                    accordion3: false,
                                    accordion4: false,
                                    accordion5: false,
                                    accordion6: false
                                };
                                var error = {
                                    accordion1: {
                                        fieldError: {
                                            dealer: "",
                                            inventory: "",
                                            product: "",
                                            purchaseDate: "",
                                            failureDate: "",
                                            repairDate: "",
                                            reasonForDelay: "",
                                            unitsUsage: "",
                                            causalPart: "",
                                            faultCode: ""
                                        }
                                    },
                                    accordion3: {
                                        fieldError: {
                                            jobCode: "",
                                            additionalLabourHours: "",
                                            reasonForAdditionalHours: ""
                                        }
                                    },
                                    accordion4: {
                                        fieldError: {
                                            nonSerializedInstalledPart: "",
                                            serializedInstalledPart: "",
                                            quantity: "",
                                            customCost: "",
                                            commonError: "",
                                            removedPartQuantity: "",
                                            commonErrorForRemovedPart: "",
                                            nonOEMPartName: "",
                                            nonOEMPartCustomCost: "",
                                            nonOEMPartQuantity: "",
                                            nonOEMPartDescription: "",
                                            invoiceDate: ""
                                        }
                                    },
                                    accordion5: {
                                        fieldError: {
                                            faultFoundComment: "",
                                            causalPartComment: "",
                                            workPerformedComment: ""
                                        }
                                    }
                                };
                                
                                component.set('v.error', error);
                                component.set('v.accordionValidationIndicator', accordionValidationIndicator);
                                
                                //set the page variables
                                component.set('v.claimType', '');
                                component.set('v.currentClaim.Units_Run__c', 0);
                                component.set('v.inventory', null);
                                component.set('v.unitType', '');
                                component.set('v.purchaseDate', null);
                                
                                
                                //18-NOV-2016
                                if (component.get('v.isDealerEditable')) {
                                    component.set('v.dealer', null);
                                }
                                //--18-NOV-2016
                                
                                component.set('v.product', null);
                                
                                //make unit usage unrequired
                                //var unitUsageComponent = component.find('unitsUsage');
                                //if (!$A.util.hasClass(unitUsageComponent, 'required')) {
                                //$A.util.removeClass(unitUsageComponent, 'required');
                                //}
                                
                                //unset the lookups name
                                if (component.find('product') !== null && component.find('product') !== undefined) {
                                    
                                    if (typeof(component.find('product').set) == "function") {
                                        component.find('product').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                if (component.find('inventory') !== null && component.find('inventory') !== undefined) {
                                    
                                    if (typeof(component.find('inventory').set) == "function") {
                                        component.find('inventory').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                
                                if (component.find('dealer') !== null && component.find('dealer') !== undefined) {
                                    
                                    if (typeof(component.find('dealer').set) == "function") {
                                        
                                        //18-NOV-2016
                                        if (component.get('v.isDealerEditable')) {
                                            component.find('dealer').set('v.objectName', '');
                                        }
                                        
                                        //site case
                                        var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
                                        if (component.get('v.site') !== '' && dealer !== null && dealer !== undefined) {
                                            
                                            component.find('dealer').set('v.objectName', dealer['Name']);
                                            component.set('v.currentClaim.Account__c', dealer['Id']);
                                            
                                        }
                                        
                                        //--18-NOV-2016
                                    }
                                    
                                }
                                
                                
                                //set the accordion 2 variables as empty
                                if (component.find('causalPart') !== undefined && component.find('causalPart') !== null && typeof(component.find('causalPart').set) === 'function') {
                                    component.find('causalPart').set('v.objectName', '');
                                    component.find('causalPart').set('v.disabled', true);
                                }
                                component.set('v.causalPart', null);
                                
                                helper.setFaultCodePicklistOptions(component, [], -1);
                                
                                
                                //forcefully close the accordion 2
                                
                                break;
                            }
                            
                            case 'Preventive Maintenance':
                            {
                                //set the claim page variable values
                                /***** initialize page variables for new claim ****/
                                var todayDateString = helper.getTodayDate(component, event);
                                
                                currentClaim = {
                                    sobjectType: 'Claim__c',
                                    Claim_Record_Type__c: textValue,
                                    Claim_Type__c: '',
                                    Account__c: '',
                                    Inventory__c: '',
                                    Warranty_Product__c: '',
                                    Units_Run__c: 0,
                                    Date_of_Failure__c: todayDateString,
                                    Date_of_Repair__c: todayDateString,
                                    Date_Of_Purchase__c: null,
                                    Request_SMR__c: false,
                                    Work_order__c: '',
                                    Service_Ticket__c: '',
                                    Delay_Reason__c: '',
                                    Causal_Part_Number__c: '',
                                    Fault_Code__c: '',
                                    Fault_found__c: '',
                                    Caused_by__c: '',
                                    Fault_Code_Comment__c: '',
                                    CasualPart_Comments__c: '',
                                    work_Performed_comments__c: '',
                                    Description__c: '',
                                    TravelByHours__c: 0,
                                    TravelByDistance__c: 0,
                                    TravelByLocation__c: '',
                                    Total_Meals_Cost__c: 0,
                                    Total_Parking_Cost__c: 0,
                                    Total_Category1_Cost__c: 0,
                                    Total_Category2_Cost__c: 0,
                                    Campaign_Members__c: '',
                                    Rate__c: '',
                                    Claim_Template_Payment_Definition__c: ''
                                };
                                
                                // set the claim
                                component.set('v.currentClaim', currentClaim);
                                
                                var accordionValidationIndicator = {
                                    accordion1: false,
                                    accordion3: false,
                                    accordion4: false,
                                    accordion5: false,
                                    accordion6: false
                                };
                                var error = {
                                    accordion1: {
                                        fieldError: {
                                            dealer: "",
                                            inventory: "",
                                            product: "",
                                            purchaseDate: "",
                                            failureDate: "",
                                            repairDate: "",
                                            reasonForDelay: "",
                                            unitsUsage: "",
                                            causalPart: "",
                                            faultCode: ""
                                        }
                                    },
                                    accordion3: {
                                        fieldError: {
                                            jobCode: "",
                                            additionalLabourHours: "",
                                            reasonForAdditionalHours: ""
                                        }
                                    },
                                    accordion4: {
                                        fieldError: {
                                            nonSerializedInstalledPart: "",
                                            serializedInstalledPart: "",
                                            quantity: "",
                                            customCost: "",
                                            commonError: "",
                                            removedPartQuantity: "",
                                            commonErrorForRemovedPart: "",
                                            nonOEMPartName: "",
                                            nonOEMPartCustomCost: "",
                                            nonOEMPartQuantity: "",
                                            nonOEMPartDescription: "",
                                            invoiceDate: ""
                                        }
                                    },
                                    accordion5: {
                                        fieldError: {
                                            faultFoundComment: "",
                                            causalPartComment: "",
                                            workPerformedComment: ""
                                        }
                                    }
                                };
                                
                                component.set('v.error', error);
                                component.set('v.accordionValidationIndicator', accordionValidationIndicator);
                                
                                //set the page variables
                                component.set('v.claimType', '');
                                component.set('v.currentClaim.Units_Run__c', 0);
                                component.set('v.inventory', null);
                                component.set('v.unitType', '');
                                component.set('v.purchaseDate', null);
                                
                                
                                //18-NOV-2016
                                if (component.get('v.isDealerEditable')) {
                                    component.set('v.dealer', null);
                                }
                                //--18-NOV-2016
                                
                                component.set('v.product', null);
                                
                                //make unit usage unrequired
                                //var unitUsageComponent = component.find('unitsUsage');
                                //if (!$A.util.hasClass(unitUsageComponent, 'required')) {
                                //$A.util.removeClass(unitUsageComponent, 'required');
                                //}
                                
                                //unset the lookups name
                                if (component.find('product') !== null && component.find('product') !== undefined) {
                                    
                                    if (typeof(component.find('product').set) == "function") {
                                        component.find('product').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                if (component.find('inventory') !== null && component.find('inventory') !== undefined) {
                                    
                                    if (typeof(component.find('inventory').set) == "function") {
                                        component.find('inventory').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                
                                if (component.find('dealer') !== null && component.find('dealer') !== undefined) {
                                    
                                    if (typeof(component.find('dealer').set) == "function") {
                                        
                                        //18-NOV-2016
                                        if (component.get('v.isDealerEditable')) {
                                            component.find('dealer').set('v.objectName', '');
                                        }
                                        
                                        //site case
                                        var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
                                        if (component.get('v.site') !== '' && dealer !== null && dealer !== undefined) {
                                            
                                            component.find('dealer').set('v.objectName', dealer['Name']);
                                            component.set('v.currentClaim.Account__c', dealer['Id']);
                                            
                                        }
                                        
                                        //--18-NOV-2016
                                    }
                                    
                                }
                                
                                
                                //set the accordion 2 variables as empty
                                if (component.find('causalPart') !== undefined && component.find('causalPart') !== null && typeof(component.find('causalPart').set) === 'function') {
                                    component.find('causalPart').set('v.objectName', '');
                                    component.find('causalPart').set('v.disabled', true);
                                }
                                component.set('v.causalPart', null);
                                
                                helper.setFaultCodePicklistOptions(component, [], -1);
                                
                                
                                //forcefully close the accordion 2
                                
                                break;
                                
                            }
                            
                        case 'Non-Serialized':
                            {
                                //set the claim page variable values
                                /***** initialize page variables for new claim ****/
                                var todayDateString = helper.getTodayDate(component, event);
                                
                                currentClaim = {
                                    sobjectType: 'Claim__c',
                                    Claim_Record_Type__c: textValue,
                                    Claim_Type__c: '',
                                    Account__c: '',
                                    Inventory__c: '',
                                    Warranty_Product__c: '',
                                    Units_Run__c: 0,
                                    Date_of_Failure__c: todayDateString,
                                    Date_of_Repair__c: todayDateString,
                                    Date_Of_Purchase__c: todayDateString,
                                    Request_SMR__c: false,
                                    Work_order__c: '',
                                    Service_Ticket__c: '',
                                    Delay_Reason__c: '',
                                    Causal_Part_Number__c: '',
                                    Fault_Code__c: '',
                                    Fault_Code_Comment__c: '',
                                    CasualPart_Comments__c: '',
                                    work_Performed_comments__c: '',
                                    Description__c: '',
                                    TravelByHours__c: 0,
                                    TravelByDistance__c: 0,
                                    TravelByLocation__c: '',
                                    Total_Meals_Cost__c: 0,
                                    Total_Parking_Cost__c: 0,
                                    Total_Category1_Cost__c: 0,
                                    Total_Category2_Cost__c: 0,
                                    Campaign_Members__c: '',
                                    Rate__c: '',
                                    Claim_Template_Payment_Definition__c: ''
                                };
                                
                                // set the claim
                                component.set('v.currentClaim', currentClaim);
                                
                                //set the page variables
                                component.set('v.claimType', '');
                                component.set('v.currentClaim.Units_Run__c', 0);
                                component.set('v.unitType', '');
                                component.set('v.inventory', null);
                                //18-NOV-2016
                                if (component.get('v.isDealerEditable')) {
                                    component.set('v.dealer', null);
                                }
                                //--18-NOV-2016
                                component.set('v.product', null);
                                
                                //make unit usage unrequired
                                //var unitUsageComponent = component.find('unitsUsage');
                                //if ($A.util.hasClass(unitUsageComponent, 'required')) {
                                //$A.util.removeClass(unitUsageComponent, 'required');
                                //}
                                
                                
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
                                hostNonHostOptions[0]['selected'] = true;
                                if (component.find('causedBy') !== undefined && component.find('causedBy') !== null) {
                                    if (typeof(component.find('causedBy').set) === 'function') {
                                        component.find('hostNonHost').set('v.options', hostNonHostOptions);
                                    }
                                }
                                
                                
                                //unset the lookups name
                                if (component.find('product') !== null && component.find('product') !== undefined) {
                                    
                                    if (typeof(component.find('product').set) === "function") {
                                        component.find('product').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                if (component.find('inventory') !== null && component.find('inventory') !== undefined) {
                                    
                                    if (typeof(component.find('inventory').set) === "function") {
                                        component.find('inventory').set('v.objectName', '')
                                    }
                                    
                                }
                                
                                
                                if (component.find('dealer') !== null && component.find('dealer') !== undefined) {
                                    
                                    if (typeof(component.find('dealer').set) === "function") {
                                        //18-NOV-2016
                                        if (component.get('v.isDealerEditable')) {
                                            component.find('dealer').set('v.objectName', '');
                                        }
                                        
                                        //site case
                                        var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
                                        if (component.get('v.site') !== '' && dealer !== null && dealer !== undefined) {
                                            component.find('dealer').set('v.objectName', dealer['Name']);
                                            component.set('v.currentClaim.Account__c', dealer['Id']);
                                        }
                                        //--18-NOV-2016
                                    }
                                    
                                }
                                
                                var accordionValidationIndicator = {
                                    accordion1: false,
                                    accordion3: false,
                                    accordion4: false,
                                    accordion5: false,
                                    accordion6: false
                                };
                                var error = {
                                    accordion1: {
                                        fieldError: {
                                            dealer: "",
                                            inventory: "",
                                            product: "",
                                            purchaseDate: "",
                                            failureDate: "",
                                            repairDate: "",
                                            reasonForDelay: "",
                                            unitsUsage: "",
                                            causalPart: "",
                                            faultCode: ""
                                        }
                                    },
                                    accordion3: {
                                        fieldError: {
                                            jobCode: "",
                                            additionalLabourHours: "",
                                            reasonForAdditionalHours: ""
                                        }
                                    },
                                    accordion4: {
                                        fieldError: {
                                            nonSerializedInstalledPart: "",
                                            serializedInstalledPart: "",
                                            quantity: "",
                                            customCost: "",
                                            commonError: "",
                                            removedPartQuantity: "",
                                            commonErrorForRemovedPart: "",
                                            nonOEMPartName: "",
                                            nonOEMPartCustomCost: "",
                                            nonOEMPartQuantity: "",
                                            nonOEMPartDescription: "",
                                            invoiceDate: ""
                                        }
                                    },
                                    accordion5: {
                                        fieldError: {
                                            faultFoundComment: "",
                                            causalPartComment: "",
                                            workPerformedComment: ""
                                        }
                                    }
                                };
                                component.set('v.error', error);
                                component.set('v.accordionValidationIndicator', accordionValidationIndicator);
                                component.set('v.purchaseDate', todayDateString);
                                
                                
                                //set the accordion 2 variables as empty
                                if (component.find('causalPart') !== undefined && typeof(component.find('causalPart').set) === 'function') {
                                    component.find('causalPart').set('v.objectName', '');
                                    component.find('causalPart').set('v.disabled', false);
                                }
                                component.set('v.causalPart', null);
                                
                                helper.setFaultCodePicklistOptions(component, [], -1);
                                
                                
                                //forcefully close the accordion 2
                                
                                break;
                            }
                            
                        case 'Claim Template':
                            {
                                
                                // empty the values set in claim and set only record type Id
                                currentClaim = {
                                    sobjectType: 'Claim__c',
                                    Claim_Record_Type__c: textValue,
                                    Claim_Type__c: 'Claim Template',
                                    Account__c: '',
                                    Inventory__c: '',
                                    Warranty_Product__c: '',
                                    Units_Run__c: null,
                                    Date_of_Failure__c: null,
                                    Date_of_Repair__c: null,
                                    Date_Of_Purchase__c: null,
                                    Request_SMR__c: false,
                                    Work_order__c: null,
                                    Service_Ticket__c: null,
                                    Delay_Reason__c: null,
                                    Causal_Part_Number__c: '',
                                    Fault_Code__c: '',
                                    Fault_Code_Comment__c: '',
                                    CasualPart_Comments__c: '',
                                    work_Performed_comments__c: '',
                                    Description__c: '',
                                    TravelByHours__c: 0,
                                    TravelByDistance__c: 0,
                                    TravelByLocation__c: '',
                                    Total_Meals_Cost__c: 0,
                                    Total_Parking_Cost__c: 0,
                                    Total_Category1_Cost__c: 0,
                                    Total_Category2_Cost__c: 0,
                                    Campaign_Members__c: '',
                                    Rate__c: '',
                                    Claim_Template_Payment_Definition__c: ''
                                };
                                
                                //18-NOV-2016
                                if (component.get('v.isDealerEditable') == false && component.get('v.site') !== '') {
                                    
                                    var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
                                    if (dealer !== null && dealer !== undefined) {
                                        currentClaim['Account__c'] = dealer['Id'];
                                    }
                                    
                                }
                                //--18-NOV-2016
                                
                                component.set('v.currentClaim', currentClaim);
                                
                                //unset the errors
                                var accordionValidationIndicator = {
                                    accordion1: false,
                                    accordion3: false,
                                    accordion4: false,
                                    accordion5: false,
                                    accordion6: false
                                };
                                var error = {
                                    accordion1: {
                                        fieldError: {
                                            dealer: "",
                                            inventory: "",
                                            product: "",
                                            purchaseDate: "",
                                            failureDate: "",
                                            repairDate: "",
                                            reasonForDelay: "",
                                            unitsUsage: "",
                                            causalPart: "",
                                            faultCode: ""
                                        }
                                    },
                                    accordion3: {
                                        fieldError: {
                                            jobCode: "",
                                            additionalLabourHours: "",
                                            reasonForAdditionalHours: ""
                                        }
                                    },
                                    accordion4: {
                                        fieldError: {
                                            nonSerializedInstalledPart: "",
                                            serializedInstalledPart: "",
                                            quantity: "",
                                            customCost: "",
                                            commonError: "",
                                            removedPartQuantity: "",
                                            commonErrorForRemovedPart: "",
                                            nonOEMPartName: "",
                                            nonOEMPartCustomCost: "",
                                            nonOEMPartQuantity: "",
                                            nonOEMPartDescription: "",
                                            invoiceDate: ""
                                        }
                                    },
                                    accordion5: {
                                        fieldError: {
                                            faultFoundComment: "",
                                            causalPartComment: "",
                                            workPerformedComment: ""
                                        }
                                    }
                                };
                                component.set('v.error', error);
                                component.set('v.accordionValidationIndicator', accordionValidationIndicator);
                                
                                
                                // the dom values to empty in first and second accordion
                                //accordion 1 variables
                                component.set('v.claimType', null);
                                component.set('v.product', null);
                                component.set('v.inventory', null);
                                component.set('v.purchaseDate', null);
                                component.set('v.failureDate', helper.getTodayDate());
                                component.set('v.repairDate', helper.getTodayDate());
                                
                                //accordion 2 variables
                                if (component.find('causalPart') !== undefined && typeof(component.find('causalPart').set) === 'function') {
                                    if (typeof(component.find('causalPart').set) == "function") {
                                        component.find('causalPart').set('v.objectName', '');
                                        component.find('causalPart').set('v.disabled', false);
                                    }
                                }
                                
                                component.set('v.causalPart', null);
                                
                                helper.setFaultCodePicklistOptions(component, [], -1);
                                
                                
                                //forcefully close the accordion 2
                                
                                break;
                            }
                            
                    }
                    
                    
                    break;
                }
                
            case "dealer":
                {
                    var dealer = event.getParam('selectedObject');
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    
                    component.set('v.dealer', dealer);
                    currentClaim['Account__c'] = dealer['Id'];
                    component.set('v.currentClaim', currentClaim);
                    
                    //unset error of dealer
                    component.set('v.error.accordion1.fieldError.dealer', '');
                    
                    break;
                }
                
            case "rate":
                {
                    var rate = event.getParam('selectedObject');
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    
                    component.set('v.rate', rate);
                    currentClaim['Rate__c'] = rate['Id'];
                    component.set('v.currentClaim', currentClaim);
                    
                    break;
                }
                
            case "paymentDefinition":
                {
                    var paymentDefinition = event.getParam('selectedObject');
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    
                    component.set('v.paymentDefinition', paymentDefinition);
                    currentClaim['Claim_Template_Payment_Definition__c'] = paymentDefinition['Id'];
                    component.set('v.currentClaim', currentClaim);
                    
                    break;
                }
                
            case "inventory":
                {
                    
                    var inventory = JSON.parse(JSON.stringify(event.getParam('selectedObject')));
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                    
                    //set page variables
                    component.set('v.inventory', inventory);
                    
                    //show unit usage mandatory on dom level by adding css of required
                    var unitType = inventory['Item__r']['Units_of_Measure__c'];
                    if (unitType != undefined && unitType != null && unitType !== '') {
                        component.set('v.unitType', "(" + unitType + ")");
                        var unitUsage = component.find('unitsUsage');
                        $A.util.addClass(unitUsage, 'required');
                        
                    } else {
                        component.set('v.unitType', "");
                        var unitUsage = component.find('unitsUsage');
                        if ($A.util.hasClass(unitUsage, 'required')) {
                            $A.util.removeClass(unitUsage, 'required');
                        }
                    }
                    
                    //enable causal part component
                    var causalPartComponent = component.find('causalPart');
                    if (causalPartComponent !== null && causalPartComponent !== undefined && typeof(causalPartComponent.set) == 'function') {
                        causalPartComponent.set('v.disabled', false);
                    }
                    
                    // set claim variables
                    currentClaim['Date_Of_Purchase__c'] = (inventory['Install_Date__c'] == undefined || inventory['Install_Date__c'] ==
                                                           '' || inventory['Install_Date__c'] == null ? helper.getTodayDate(component, event) : inventory['Install_Date__c']);
                    
                    currentClaim['Units_Run__c'] = (inventory['Units_Run__c'] === undefined || inventory['Units_Run__c'] ===
                                                    null || inventory['Units_Run__c'] === 0 || inventory['Units_Run__c'] === '' ? 0 : inventory['Units_Run__c']);
                    component.set('v.error.accordion1.fieldError.unitsUsage', '');
                    
                    currentClaim['Inventory__c'] = inventory['Id'];
                    
                    component.set("v.currentClaim", currentClaim);
                    
                    // unset inventory error
                    component.set('v.error.accordion1.fieldError.inventory', '');
                    
                    // fill claim type
                    var claimType;
                    if (claimCustomRecordTypeName === 'Field Modification') {
                        
                        claimType = 'Field Modification';
                        
                        /**********field modification data fetch**********/
                        //nothing can be written inside this block after this line
                        helper.getCampaignMembers(component, event, inventory['Id']);
                        
                    } else {
                        claimType = inventory['Item__r']['Item_Type__c'];
                    }
                    
                    component.set('v.claimType', claimType);
                    component.set('v.currentClaim.Claim_Type__c', claimType);
                    
                    if(claimCustomRecordTypeName === 'Preventive Maintenance'){
                        /*helper.fetchGracePeriodCustomSettingRecord(component, event, helper,function(Response) {
                            var gracePeriod = component.get('v.gracePeriod');
                            var dateOfFailure = currentClaim['Date_of_Failure__c'];
                            console.log(dateOfFailure);
                            console.log('gracePeriod-->');
                            console.log(gracePeriod);
                            
                            var dateAfterGracePeriod = helper.addDays(dateOfFailure,gracePeriod);
                            console.log('dateAfterGracePeriod-->');
                            console.log(dateAfterGracePeriod);
                            var formattedDate = dateAfterGracePeriod.toISOString().slice(0, 10);
                            console.log('formattedDate');
                            console.log(formattedDate);
                            
                        });*/
                        /*Date newDate;
                        if(gracePeriod != null && gracePeriod != ''){
                            newDate = currentClaim['Date_of_Failure__c'].addDays(gracePeriod);
                        }
                        system.debug(newDate);*/
                        //var inventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                        
                        	var inventoryId = inventory['Id'];
	                        var self = this;
	                        var faultCodeComponent;
	                        
                        if (inventoryId !== null && inventoryId !== undefined && inventoryId !== undefined ) {
	                            
	                            //get all the campaigns from campaign members where this inventory is found
	                            var query = "Select Id,Name,Description__c,Order__c,Claim_Template__c,Preventative_Maintenance_Date__c,Completed__c,Expected_Procuct_Usage__c" +
	                                " from Upcoming_Completed__c where Completed__c=false AND Inventory__c='" + inventoryId+"\' ORDER BY Order__c";
	                            helper.readRaw(component, event, helper, query, function(campaignMemberResponse) {
	                                console.log(campaignMemberResponse.sObjectList);
	                                var campaignMemberList = campaignMemberResponse.sObjectList;
	                                helper.finalSchedule(component,campaignMemberList, function(response){
	                                	var schedulerList = component.get('v.finalScehdule');
	                                	
	                                	//helper.getInventoryUpcomingSchedule(component, campaignMemberList, 0);
	                                	//component.set('v.inventoryScheduleList',campaignMemberList);
	                                	helper.getInventoryUpcomingSchedule(component, schedulerList, 0);	                                	
	                                	component.set('v.inventoryScheduleList',schedulerList);
	                                	console.log('inv ss-->');
	                                	console.log(schedulerList);
	                                	helper.fetchClaimTemplate(component, event, helper);
	                                	
	                                });
	                                
	                           });
	                            
	                        }
                        
                    }
                    break;
                }
                
            case "product":
                {
                    
                    var product = JSON.parse(JSON.stringify(event.getParam('selectedObject')));
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    
                    //set page variables
                    component.set('v.product', product);
                    var unitType = product['Units_of_Measure__c'];
                    if (unitType != undefined && unitType != null && unitType !== '') {
                        component.set('v.unitType', "(" + unitType + ")");
                        var unitUsage = component.find('unitsUsage');
                        $A.util.addClass(unitUsage, 'required');
                        
                    } else {
                        component.set('v.unitType', "");
                        var unitUsage = component.find('unitsUsage');
                        if ($A.util.hasClass(unitUsage, 'required')) {
                            $A.util.removeClass(unitUsage, 'required');
                        }
                    }
                    
                    
                    //set claim variable
                    currentClaim['Warranty_Product__c'] = product['Id'];
                    component.set('v.currentClaim', currentClaim);
                    
                    // unset product error
                    component.set('v.error.accordion1.fieldError.product', '');
                    
                    // fill claim type
                    var claimType = (product['Item_Type__c'] === null || product['Item_Type__c'] === undefined ||
                                     product['Item_Type__c'] === '' ? '' : product['Item_Type__c']);
                    component.set('v.claimType', claimType);
                    component.set('v.currentClaim.Claim_Type__c', claimType);
                    
                    break;
                }
                
            case "preAuthorization":
                {
                    
                    var isPreAuthTrue = event.getSource().get('v.value');
                    
                    if (isPreAuthTrue) {
                        
                        var preAuthReason = component.find('reasonsForPreAuth').get('v.value');
                        
                        //set smr reason picklist
                        var pickListCollection = JSON.parse(JSON.stringify(component.get('v.claimPicklist')));
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
                        smrReasonOptions[0]['selected'] = true;
                        if (typeof(component.find('reasonsForPreAuth').set) == 'function') {
                            component.find('reasonsForPreAuth').set('v.options', smrReasonOptions);
                        }
                        
                    }
                    
                    break;
                }
                
            case "reasonsForPreAuth":
                {
                    
                    var preAuthReason = event.getSource().get('v.value');
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    currentClaim['SMR_Reason__c'] = preAuthReason;
                    component.set('v.currentClaim', currentClaim);
                    
                    break;
                }
                
            case "campaignMember":
                {
                    
                    var selectedCampaignMember = JSON.parse(event.getSource().get('v.value'));
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    
                    component.set('v.currentClaim.Campaign_Members__c', selectedCampaignMember['Id']);
                    component.set('v.campaignMember', selectedCampaignMember);
                    
                    //get the claim template
                    var claimTemplate = selectedCampaignMember['Service_Campaign__r']['Claim_Template__r'];
                    
                    //set the causal part and faultcode from the first campaign
                    var causalPart = claimTemplate['Causal_Part_Number__r'];
                    
                    if (causalPart != undefined && causalPart != null) {
                        
                        //set the causal part details wherever necesary
                        if (typeof(component.find('causalPart').set) === 'function') {
                            component.find('causalPart').set('v.objectName', causalPart['Name']);
                        }
                        component.set('v.causalPart', causalPart);
                        component.set('v.currentClaim.Causal_Part_Number__c', causalPart['Id']);
                        component.set('v.error.accordion1.causalPart', '');
                        
                        //set the fault code details wherever necessary
                        var faultCode = claimTemplate['Fault_Code__r'];
                        
                        if (faultCode != undefined && faultCode != null) {
                            
                            //set the causal part details wherever necesary
                            helper.setFaultCodePicklistOptions(component, [faultCode], 0);
                            
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
                    var faultFound = claimTemplate["Fault_found__c"];
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
                    var indexOfOption = helper.findIndexWithProperty(faultFoundOptions, 'value', faultFound);
                    if (indexOfOption > -1) {
                        faultFoundOptions[indexOfOption]['selected'] = true;
                    }
                    if (typeof(component.find('faultFound').set) == 'function') {
                        component.find('faultFound').set('v.options', faultFoundOptions);
                    }
                    
                    
                    //set the caused by value on dom
                    var causedBy = claimTemplate["Caused_by__c"];
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
                    indexOfOption = helper.findIndexWithProperty(causedByOptions, 'value', causedBy);
                    if (indexOfOption > -1) {
                        causedByOptions[indexOfOption]['selected'] = true;
                    }
                    if (typeof(component.find('causedBy').set) == 'function') {
                        component.find('causedBy').set('v.options', causedByOptions);
                    }
                    
                    //set the additional information by template
                    helper.setAdditionalInformationByTemplate(component, event, claimTemplate);
                    
                    
                    
                    break;
                }
                
            
        }
        
    },
    
    
    
    fetchSchedule: function(component, event, helper) {
        
        var sourceId = event.getSource().getLocalId();
        var inventory = component.get('v.inventory');
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        switch (sourceId) {
        	case 'failureDate' :{
        		if(claimCustomRecordTypeName == 'Preventive Maintenance'){
        			var inventoryId = inventory['Id'];
                    var self = this;
                    
                if (inventoryId !== null && inventoryId !== undefined && inventoryId !== undefined ) {
                        
                        //get all the campaigns from campaign members where this inventory is found
                        // Modified by Mahesh (2/24/17) - Added Expected_Procuct_Usage__c in the query.
                        var query = "Select Id,Name,Description__c,Order__c,Claim_Template__c,Preventative_Maintenance_Date__c,Expected_Procuct_Usage__c,Completed__c" +
                            " from Upcoming_Completed__c where Completed__c=false AND Inventory__c='" + inventoryId+"\' ORDER BY Order__c";
                        helper.readRaw(component, event, helper, query, function(campaignMemberResponse) {
                            var campaignMemberList = campaignMemberResponse.sObjectList;
                            console.log('campaignMemberList');
                            console.log(campaignMemberList);
                            helper.finalSchedule(component,campaignMemberList, function(response){
                            	var schedulerList = component.get('v.finalScehdule');
                            	//helper.getInventoryUpcomingSchedule(component, campaignMemberList, 0);
                            	//component.set('v.inventoryScheduleList',campaignMemberList);
                            	helper.getInventoryUpcomingSchedule(component, schedulerList, 0);
                            	component.set('v.inventoryScheduleList',schedulerList);
                            	console.log('ss-->');
                            	console.log(schedulerList);
                            	helper.fetchClaimTemplate(component, event, helper);
                            });
                            
                       });
                        
                    }
        		}
        		break;
        	}
        	case 'unitsUsage' :{
	        	if(claimCustomRecordTypeName == 'Preventive Maintenance'){
	        			var inventoryId = inventory['Id'];
	                    var self = this;
	                    
	                if (inventoryId !== null && inventoryId !== undefined && inventoryId !== undefined ) {
	                        
	                        //get all the campaigns from campaign members where this inventory is found
	                        // Modified by Mahesh (2/24/17) - Added Expected_Procuct_Usage__c in the query.
	                        var query = "Select Id,Name,Description__c,Order__c,Claim_Template__c,Preventative_Maintenance_Date__c,Expected_Procuct_Usage__c,Completed__c" +
	                            " from Upcoming_Completed__c where Completed__c=false AND Inventory__c='" + inventoryId+"\' ORDER BY Order__c";
	                        helper.readRaw(component, event, helper, query, function(campaignMemberResponse) {
	                            var campaignMemberList = campaignMemberResponse.sObjectList;
	                            console.log('campaignMemberList');
	                            console.log(campaignMemberList);
	                            helper.finalSchedule(component,campaignMemberList, function(response){
	                            	var schedulerList = component.get('v.finalScehdule');
	                            	//helper.getInventoryUpcomingSchedule(component, campaignMemberList, 0);
	                            	//component.set('v.inventoryScheduleList',campaignMemberList);
	                            	helper.getInventoryUpcomingSchedule(component, schedulerList, 0);
	                            	component.set('v.inventoryScheduleList',schedulerList);
	                            	console.log('ss-->');
	                            	console.log(schedulerList);
	                            	helper.fetchClaimTemplate(component, event, helper);
	                            });
	                            
	                       });
	                        
	                    }
	        		}
	        		break;
	        	}
	        }
        },
    
    
    
    faultCodeAccHandeler: function(component, event, helper) {
        
        var componentId = event.getSource().getLocalId();
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        switch (componentId) {
                
            case "causalPart":
                {
                    
                    var causalPart = event.getParam('selectedObject');
                    var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                    var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                    var userLangId = component.get('v.userLangId');
                    
                    //fetch fault codes on the basis of record types
                    switch (claimCustomRecordTypeName) {
                            
                        case "Field Modification":
                            {
                                
                                
                                
                            }
                            
                        case "Serialized":
                            {
                                
                                var currentInventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                                var modelId = currentInventory['Item__r']['Parent_Product__r']['Id'];
                                var modelFaultCodeList = [];
                                var causalPartFaultCodeList = [];
                                
                                //added by Dharmil for Fault code & Job Code Logic
                                var modelParentId = currentInventory['Item__r']['Parent_Product__r']['Parent_Product__r']['Id'];
                                var modelParentFaultCodeList = [];
                                
                                
                                //query for getting fault codes from model and causal part
                                var query = "select Id,Name,Warranty_Product__c,Fault_Code__r.Id,Fault_Code__r.Name " +
                                    "from FaultCode_Mapper__c where Status__c=true AND Warranty_Product__c IN('" + modelId + "','" + causalPart['Id'] + "','"+ modelParentId +"') " +
                                    "AND Fault_Code__r.Lang_Id__c='" + userLangId + "' AND Fault_Code__r.Selectable__c=true";
                                
                                //show spinner
                                component.set('v.spinnerBool.pageSpinner', true);
                                //get the model of the inventory and get all the faultcodes of model
                                helper.readRaw(component, event, helper, query, function(allFaultCodeResponse) {
                                    
                                    //show spinner
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    
                                    //get faultcodes from model and causal part of inventory
                                    var faultCodeMapperList = allFaultCodeResponse['sObjectList'];
                                    if (faultCodeMapperList != undefined && faultCodeMapperList != null && faultCodeMapperList.length != 0) {
                                        
                                        //seperate model faultcode mapper and causal part faultcode mapper
                                        var modelFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == modelId) {
                                                return a;
                                            }
                                        });
                                        
                                        //added by Dharmil for Fault code & Job Code Logic
                                        var modelParentFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == modelParentId) {
                                                return a;
                                            }
                                        });
                                        
                                        var causalPartFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == causalPart['Id']) {
                                                return a;
                                            }
                                        });
                                        
                                        //seperate model and causal part fault codes
                                        modelFaultCodeList = modelFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        //added by Dharmil for Fault code & Job Code Logic
                                        modelParentFaultCodeList = modelParentFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        causalPartFaultCodeList = causalPartFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        
                                    }
                                    //added by Dharmil for Fault code & Job Code Logic
                                    var unionFaultCodeList = helper.arrayUnique(modelFaultCodeList.concat(modelParentFaultCodeList));
                                    var intersectedFaultCodeList = helper.intersectionByProperty(unionFaultCodeList, causalPartFaultCodeList);
                                    
                                    var stringUnionFaultCodeList=[]	;
                                    var stringIntersectedFaultCodeList=[];
                                    
                                    for(var i = 0; i<unionFaultCodeList.length ; i++){
                                        if(unionFaultCodeList !== undefined && unionFaultCodeList !== null && unionFaultCodeList.length != 0){
                                            stringUnionFaultCodeList.push('\''+unionFaultCodeList[i]['Id']+'\'');
                                        }
                                    }
                                    
                                    for(var i = 0; i<intersectedFaultCodeList.length ; i++){
                                        if(intersectedFaultCodeList !== undefined && intersectedFaultCodeList !== null && intersectedFaultCodeList.length != 0){
                                            stringIntersectedFaultCodeList.push('\''+intersectedFaultCodeList[i]['Id']+'\'');
                                        }
                                        
                                    }
                                    if(stringUnionFaultCodeList != null){
                                        component.set("v.faultCodeListForJobCode",stringUnionFaultCodeList);
                                    }
                                    
                                    //intersection returned nothing
                                    if (intersectedFaultCodeList.length == 0) {
                                        
                                        //set the fault code list as model fault code list as it cannot be empty
                                        if (unionFaultCodeList !== undefined && unionFaultCodeList !== null && unionFaultCodeList.length != 0) {
                                            helper.setFaultCodePicklistOptions(component, unionFaultCodeList, 0);
                                            //component.set("v.faultCodeListForJobCode",stringUnionFaultCodeList);
                                            
                                        } else {
                                            helper.setFaultCodePicklistOptions(component, [], -1);
                                            
                                        }
                                        
                                    } else {
                                        
                                        //set the faultcode list as intersection list
                                        helper.setFaultCodePicklistOptions(component, intersectedFaultCodeList, 0);
                                        //component.set("v.faultCodeListForJobCode",stringIntersectedFaultCodeList);
                                        
                                    }
                                    
                                    
                                    var finalFaultCodeList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                                    
                                    if (finalFaultCodeList != undefined && finalFaultCodeList != null && finalFaultCodeList.length != 0) {
                                        
                                        // set the values based on causal part
                                        component.set('v.causalPart', causalPart);
                                        component.set('v.error.accordion1.causalPart', '');
                                        
                                        
                                        currentClaim['Causal_Part_Number__c'] = causalPart['Id'];
                                        currentClaim['Fault_Code__c'] = finalFaultCodeList[0]['Id'];
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        //unset the error values of fault code and causal part
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        component.set('v.error.accordion1.fieldError.faultCode', '');
                                        
                                    } else {
                                        
                                        // show the error message of no fault code found
                                        var alertboxContent = {
                                            message: $A.get("$Label.c.Fault_Code_Not_Found_M"),
                                            heading: $A.get("$Label.c.Fault_Code_Not_Found_H"),
                                            class: 'slds-theme--info',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        // unset all the values set by selecting causal part
                                        component.set('v.causalPart', null);
                                        currentClaim['Causal_Part_Number__c'] = '';
                                        currentClaim['Fault_Code__c'] = '';
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                        
                                        //unset causal part lookup value on dom element
                                        component.find('causalPart').set('v.objectName', '');
                                        
                                        //unset the error
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        
                                    }
                                    
                                });
                                
                                
                                break;
                            }
                            
                        case "Preventive Maintenance":
                            
                            {
                                
                                var currentInventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                                var modelId = currentInventory['Item__r']['Parent_Product__r']['Id'];
                                var modelFaultCodeList = [];
                                var causalPartFaultCodeList = [];
                                
                                //added by Dharmil for Fault code & Job Code Logic
                                var modelParentId = currentInventory['Item__r']['Parent_Product__r']['Parent_Product__r']['Id'];
                                var modelParentFaultCodeList = [];
                                
                                
                                //query for getting fault codes from model and causal part
                                var query = "select Id,Name,Warranty_Product__c,Fault_Code__r.Id,Fault_Code__r.Name " +
                                    "from FaultCode_Mapper__c where Status__c=true AND Warranty_Product__c IN('" + modelId + "','" + causalPart['Id'] + "','"+ modelParentId +"') " +
                                    "AND Fault_Code__r.Lang_Id__c='" + userLangId + "' AND Fault_Code__r.Selectable__c=true";
                                
                                //show spinner
                                component.set('v.spinnerBool.pageSpinner', true);
                                //get the model of the inventory and get all the faultcodes of model
                                helper.readRaw(component, event, helper, query, function(allFaultCodeResponse) {
                                    
                                    //show spinner
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    
                                    //get faultcodes from model and causal part of inventory
                                    var faultCodeMapperList = allFaultCodeResponse['sObjectList'];
                                    if (faultCodeMapperList != undefined && faultCodeMapperList != null && faultCodeMapperList.length != 0) {
                                        
                                        //seperate model faultcode mapper and causal part faultcode mapper
                                        var modelFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == modelId) {
                                                return a;
                                            }
                                        });
                                        
                                        //added by Dharmil for Fault code & Job Code Logic
                                        var modelParentFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == modelParentId) {
                                                return a;
                                            }
                                        });
                                        
                                        var causalPartFaultCodeMapperList = faultCodeMapperList.filter(function(a) {
                                            if (a['Warranty_Product__c'] == causalPart['Id']) {
                                                return a;
                                            }
                                        });
                                        
                                        //seperate model and causal part fault codes
                                        modelFaultCodeList = modelFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        //added by Dharmil for Fault code & Job Code Logic
                                        modelParentFaultCodeList = modelParentFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        causalPartFaultCodeList = causalPartFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                        
                                    }
                                    //added by Dharmil for Fault code & Job Code Logic
                                    var unionFaultCodeList = helper.arrayUnique(modelFaultCodeList.concat(modelParentFaultCodeList));
                                    var intersectedFaultCodeList = helper.intersectionByProperty(unionFaultCodeList, causalPartFaultCodeList);
                                    
                                    var stringUnionFaultCodeList=[]	;
                                    var stringIntersectedFaultCodeList=[];
                                    
                                    for(var i = 0; i<unionFaultCodeList.length ; i++){
                                        if(unionFaultCodeList !== undefined && unionFaultCodeList !== null && unionFaultCodeList.length != 0){
                                            stringUnionFaultCodeList.push('\''+unionFaultCodeList[i]['Id']+'\'');
                                        }
                                        
                                    } 
                                    
                                    
                                    for(var i = 0; i<intersectedFaultCodeList.length ; i++){
                                        if(intersectedFaultCodeList !== undefined && intersectedFaultCodeList !== null && intersectedFaultCodeList.length != 0){
                                            stringIntersectedFaultCodeList.push('\''+intersectedFaultCodeList[i]['Id']+'\'');
                                        }
                                        
                                    }
                                    if(stringUnionFaultCodeList != null){
                                        component.set("v.faultCodeListForJobCode",stringUnionFaultCodeList);
                                    }
                                    
                                    //intersection returned nothing
                                    if (intersectedFaultCodeList.length == 0) {
                                        
                                        //set the fault code list as model fault code list as it cannot be empty
                                        if (unionFaultCodeList !== undefined && unionFaultCodeList !== null && unionFaultCodeList.length != 0) {
                                            helper.setFaultCodePicklistOptions(component, unionFaultCodeList, 0);
                                            //component.set("v.faultCodeListForJobCode",stringUnionFaultCodeList);
                                            
                                        } else {
                                            helper.setFaultCodePicklistOptions(component, [], -1);
                                            
                                        }
                                        
                                    } else {
                                        
                                        //set the faultcode list as intersection list
                                        helper.setFaultCodePicklistOptions(component, intersectedFaultCodeList, 0);
                                        //component.set("v.faultCodeListForJobCode",stringIntersectedFaultCodeList);
                                        
                                    }
                                    
                                    
                                    var finalFaultCodeList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                                    
                                    if (finalFaultCodeList != undefined && finalFaultCodeList != null && finalFaultCodeList.length != 0) {
                                        
                                        // set the values based on causal part
                                        component.set('v.causalPart', causalPart);
                                        component.set('v.error.accordion1.causalPart', '');
                                        
                                        
                                        currentClaim['Causal_Part_Number__c'] = causalPart['Id'];
                                        currentClaim['Fault_Code__c'] = finalFaultCodeList[0]['Id'];
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        //unset the error values of fault code and causal part
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        component.set('v.error.accordion1.fieldError.faultCode', '');
                                        
                                    } else {
                                        
                                        // show the error message of no fault code found
                                        var alertboxContent = {
                                            message: $A.get("$Label.c.Fault_Code_Not_Found_M"),
                                            heading: $A.get("$Label.c.Fault_Code_Not_Found_H"),
                                            class: 'slds-theme--info',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        // unset all the values set by selecting causal part
                                        component.set('v.causalPart', null);
                                        currentClaim['Causal_Part_Number__c'] = '';
                                        currentClaim['Fault_Code__c'] = '';
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                        
                                        //unset causal part lookup value on dom element
                                        component.find('causalPart').set('v.objectName', '');
                                        
                                        //unset the error
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        
                                    }
                                    
                                });
                                
                                
                                break;
                            }
                            
                            
                            
                        case "Non-Serialized":
                            {
                                
                                var causalPartFaultCodeList = [];
                                var stringFaultCodeList=[]	;
                                
                                //query for getting fault codes from causal part
                                query = "select Id,Name,Warranty_Product__c,Fault_Code__r.Id,Fault_Code__r.Name " +
                                    "from FaultCode_Mapper__c where Status__c=true AND Warranty_Product__c='" + causalPart['Id'] + "' "
                                "AND Fault_Code__r.Lang_Id__c='" + userLangId + "' AND Fault_Code__r.Selectable__c=true";
                                
                                
                                //show spinner
                                component.set('v.spinnerBool.pageSpinner', true);
                                
                                // get all the fault codes from the causal part
                                helper.readRaw(component, event, helper, query, function(causalPartFCResponse) {
                                    
                                    //hide spinner
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    
                                    var causalPartFaultCodeMapperList = causalPartFCResponse['sObjectList'];
                                    
                                    if (causalPartFaultCodeMapperList != undefined && causalPartFaultCodeMapperList != null &&
                                        causalPartFaultCodeMapperList.length != 0) {
                                        
                                        //get all the faultCodes from the modelFaultCodeMapperList
                                        causalPartFaultCodeList = causalPartFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                    }
                                    for(var i = 0; i<causalPartFaultCodeList.length ; i++){
                                        if(causalPartFaultCodeList !== undefined && causalPartFaultCodeList !== null && causalPartFaultCodeList.length != 0){
                                            stringFaultCodeList.push('\''+causalPartFaultCodeList[i]['Id']+'\'');
                                        }
                                        
                                    }
                                    
                                    
                                    //set the faultcode list as intersection list
                                    helper.setFaultCodePicklistOptions(component, causalPartFaultCodeList, 0);
                                    if(stringFaultCodeList != null){
                                        component.set("v.faultCodeListForJobCode",stringFaultCodeList);
                                    }
                                    
                                    var finalFaultCodeList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                                    
                                    if (finalFaultCodeList != undefined && finalFaultCodeList != null && finalFaultCodeList.length != 0) {
                                        
                                        // set the values based on causal part
                                        component.set('v.causalPart', causalPart);
                                        component.set('v.error.accordion1.causalPart', '');
                                        currentClaim['Causal_Part_Number__c'] = causalPart['Id'];
                                        currentClaim['Fault_Code__c'] = finalFaultCodeList[0]['Id'];
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        
                                        
                                        //unset the error values of fault code and causal part
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        component.set('v.error.accordion1.fieldError.faultCode', '');
                                        
                                    } else {
                                        
                                        // show the error message of previous accordion not validated
                                        var alertboxContent = {
                                            message: $A.get("$Label.c.Fault_Code_Not_Found_M"),
                                            heading: $A.get("$Label.c.Fault_Code_Not_Found_H"),
                                            class: 'slds-theme--info',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        // unset all the values set by selecting causal part
                                        component.set('v.causalPart', null);
                                        currentClaim['Causal_Part_Number__c'] = '';
                                        currentClaim['Fault_Code__c'] = '';
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                        //unset causal part lookup value on dom element
                                        component.find('causalPart').set('v.objectName', '');
                                        
                                        //unset the error
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        
                                        
                                    }
                                    
                                });
                                
                                
                                break;
                            }
                            
                        case "Claim Template":
                            {
                                
                                var causalPartFaultCodeList = [];
                                var stringFaultCodeList=[];
                                
                                //query for getting fault codes from causal part
                                query = "select Id,Name,Warranty_Product__c,Fault_Code__r.Id,Fault_Code__r.Name " +
                                    "from FaultCode_Mapper__c where Status__c=true AND Warranty_Product__c='" + causalPart['Id'] + "' "
                                "AND Fault_Code__r.Lang_Id__c='" + userLangId + "' AND Fault_Code__r.Selectable__c=true";
                                
                                
                                //show spinner
                                component.set('v.spinnerBool.pageSpinner', true);
                                
                                // get all the fault codes from the causal part
                                helper.readRaw(component, event, helper, query, function(causalPartFCResponse) {
                                    
                                    //hide spinner
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    
                                    var causalPartFaultCodeMapperList = causalPartFCResponse['sObjectList'];
                                    
                                    if (causalPartFaultCodeMapperList != undefined && causalPartFaultCodeMapperList != null &&
                                        causalPartFaultCodeMapperList.length != 0) {
                                        
                                        //get all the faultCodes from the modelFaultCodeMapperList
                                        causalPartFaultCodeList = causalPartFaultCodeMapperList.map(function(a) {
                                            return a['Fault_Code__r'];
                                        });
                                        
                                    }
                                    for(var i = 0; i<causalPartFaultCodeList.length ; i++){
                                        if(causalPartFaultCodeList !== undefined && causalPartFaultCodeList !== null && causalPartFaultCodeList.length != 0){
                                            stringFaultCodeList.push('\''+causalPartFaultCodeList[i]['Id']+'\'');
                                        }
                                        
                                    }
                                    
                                    //set the faultcode list as intersection list
                                    helper.setFaultCodePicklistOptions(component, causalPartFaultCodeList, 0);
                                    if(stringFaultCodeList != null){
                                        component.set("v.faultCodeListForJobCode",stringFaultCodeList);
                                    }
                                    
                                    var finalFaultCodeList = JSON.parse(JSON.stringify(component.get('v.faultCodeList')));
                                    
                                    if (finalFaultCodeList != undefined && finalFaultCodeList != null && finalFaultCodeList.length != 0) {
                                        
                                        // set the values based on causal part
                                        component.set('v.causalPart', causalPart);
                                        component.set('v.error.accordion1.causalPart', '');
                                        currentClaim['Causal_Part_Number__c'] = causalPart['Id'];
                                        currentClaim['Fault_Code__c'] = finalFaultCodeList[0]['Id'];
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        //unset the error values of fault code and causal part
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        component.set('v.error.accordion1.fieldError.faultCode', '');
                                        
                                    } else {
                                        
                                        // show the error message of previous accordion not validated
                                        var alertboxContent = {
                                            message: $A.get("$Label.c.Fault_Code_Not_Found_M"),
                                            heading: $A.get("$Label.c.Fault_Code_Not_Found_H"),
                                            class: 'slds-theme--info',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        // unset all the values set by selecting causal part
                                        component.set('v.causalPart', null);
                                        currentClaim['Causal_Part_Number__c'] = '';
                                        currentClaim['Fault_Code__c'] = '';
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                        //unset causal part lookup value on dom element
                                        component.find('causalPart').set('v.objectName', '');
                                        
                                        //unset the error
                                        component.set('v.error.accordion1.fieldError.causalPart', '');
                                        
                                        
                                    }
                                    
                                });
                                
                                
                                break;
                            }
                            
                    }
                    
                    //delete the jobcode list
                    helper.deleteJobCodeList(component, event);
                    
                    break;
                }
                
            case "faultCode":
                {
                    helper.deleteJobCodeList(component, event);
                    break;
                }
                
        }
        
        
    },
    serviceInfoHandeler: function(component, event, helper) {
        
        //check if the event is thrown by checkbox or outputtext
        var isCheckBoxEvent = event.getSource().isInstanceOf('ui:inputCheckbox');
        var isTextEvent = event.getSource().isInstanceOf('ui:outputText');
        
        
        if (!isCheckBoxEvent && !isTextEvent) {
            
            var componentId = event.getSource().getLocalId();
            
            switch (componentId) {
                    
                case "addClaimServiceInfo":
                    {
                        helper.resetClaimRelatedListModalData(component, event, 'claimServiceInfo');
                        break;
                    }
                    
                case "cancelClaimServiceInfoButton":
                    {
                        //hide claim service create modal
                        helper.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');
                        
                        //clear all the errors
                        component.set('v.error.accordion3.fieldError.jobCode', '');
                        component.set('v.error.accordion3.fieldError.additionalLabourHours', '');
                        component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');
                        
                        //unset all boolean values
                        component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', false);
                        
                        
                        break;
                    }
                    
                case "jobCode":
                    {
                        
                        var jobCode = event.getParam('selectedObject');
                        component.set('v.selectedJobCode', jobCode);
                        
                        //unset any errors
                        component.set('v.error.accordion3.fieldError.jobCode', '');
                        
                        break;
                        
                    }
                    
                case "saveClaimServiceInfoButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'claimServiceInfo', false);
                        break;
                    }
                    
                case "saveNextClaimServiceInfoButton":
                    {
                        
                        helper.saveClaimRelatedList(component, event, 'claimServiceInfo', true);
                        break;
                        
                    }
                    
                case "editClaimServiceInfoButton":
                    {
                        var editClaimServiceInfoButton = event.getSource();
                        var targetClaimServiceInfo = JSON.parse(JSON.stringify(component.get('v.modalData.claimServiceInfo.selectedClaimServiceInfo')));
                        
                        //get jobcode of this targetClaimService Info
                        var jobCode = JSON.parse(JSON.stringify(component.get('v.selectedJobCode')));
                        
                        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                        
                        if (jobCode != null && jobCode != undefined) {
                            
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
                                
                                
                                //if reasonForAdditionalHours empty then set the error
                                if ((reasonForAdditionalHours == '' || reasonForAdditionalHours == undefined ||
                                     reasonForAdditionalHours == null) && additionalLabourHours > 0) {
                                    
                                    component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded',
                                                  $A.get("$Label.c.Reason_For_Additional_Labour_Hours_Not_Filled"));
                                    
                                } else {
                                    
                                    //unset the error
                                    component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');
                                    
                                    
                                    //make javascript object of claim service info
                                    var claimServiceInfo = {
                                        Id: targetClaimServiceInfo['Id'],
                                        Service_Job_Code__c: jobCode['Id'],
                                        Additional_Labor_Hour__c: additionalLabourHours,
                                        Reason_Additional_Labor_hour__c: reasonForAdditionalHours,
                                        Claim__c: currentClaim['Id']
                                    };
                                    
                                    //unset all the jobcode errors
                                    component.set('v.error.accordion3.fieldError.jobCode', '');
                                    
                                    //disable cancel and update button
                                    component.find('cancelClaimServiceInfoButton').set('v.disabled', true);
                                    editClaimServiceInfoButton.set('v.disabled', true);
                                    
                                    
                                    //update the claim service info
                                    helper.updateRaw(component, event, helper, claimServiceInfo, function(claimServiceInfoUpdate) {
                                        
                                        //enable the buttons
                                        component.find('cancelClaimServiceInfoButton').set('v.disabled', false);
                                        editClaimServiceInfoButton.set('v.disabled', false);
                                        
                                        
                                        if (claimServiceInfoUpdate['sobjectsAndStatus'] != undefined && claimServiceInfoUpdate['sobjectsAndStatus'] != null &&
                                            claimServiceInfoUpdate['sobjectsAndStatus'].length != 0) {
                                            
                                            var isSuccessfulUpdate = claimServiceInfoUpdate['sobjectsAndStatus'][0]['status'];
                                            if (isSuccessfulUpdate == 'successful') {
                                                
                                                var claimserviceInfoUpdated = claimServiceInfoUpdate['sobjectsAndStatus'][0]['sObject'];
                                                
                                                // update the fields on page variable
                                                claimserviceInfoUpdated['Service_Job_Code__r'] = {};
                                                claimserviceInfoUpdated['Service_Job_Code__r']['Name'] = jobCode['Name']
                                                claimserviceInfoUpdated['Service_Job_Code__r']['Description__c'] = jobCode['Description__c'];
                                                claimserviceInfoUpdated['Service_Job_Code__r']['Standard_Labor_Hour__c'] = jobCode['Standard_Labor_Hour__c'];
                                                
                                                //set the updated claim service info in claimServiceInfoList page variable
                                                var claimServiceInfoList = JSON.parse(JSON.stringify(component.get('v.claimServiceInfoList')));
                                                var indexOfOldClaimServiceInfo = helper.findIndexWithProperty(claimServiceInfoList,
                                                                                                              'Id', claimserviceInfoUpdated['Id']);
                                                
                                                //replace the updated claim service info in the claimServiceInfoList page variable
                                                if (indexOfOldClaimServiceInfo > -1) {
                                                    
                                                    claimServiceInfoList[indexOfOldClaimServiceInfo] = claimserviceInfoUpdated;
                                                    component.set('v.claimServiceInfoList', claimServiceInfoList);
                                                    
                                                }
                                                
                                                //unset the selected jobcode
                                                component.set('v.selectedJobCode', null);
                                                
                                                //close modal
                                                helper.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');
                                                
                                                //clear all the errors
                                                component.set('v.error.accordion3.fieldError.jobCode', '');
                                                
                                                //unset the modal to initial value
                                                //set the modal data for edit
                                                component.set('v.modalData.claimServiceInfo.mode', 'Create');
                                                component.set('v.modalData.claimServiceInfo.title', $A.get('$Label.c.Create_Claim_Service_Info_Heading'));
                                                
                                            } else {
                                                
                                                //close the modal
                                                helper.closeModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');
                                                
                                                // set error in updation alert
                                                var errorException = claimServiceInfoUpdate['exception'];
                                                var errorArrays = claimServiceInfoUpdate['errorList'];
                                                
                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                                errorArrays != undefined && errorArrays.length != 0)) {
                                                    
                                                    var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                                    
                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.Service_Info_Not_Updated_H"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    helper.showAlert(component, event, alertboxContent);
                                                    
                                                }
                                                
                                                //unset the modal to initial value
                                                //set the modal data for edit
                                                component.set('v.modalData.claimServiceInfo.mode', 'Create');
                                                component.set('v.modalData.claimServiceInfo.title', $A.get('$Label.c.Create_Claim_Service_Info_Heading'));
                                            }
                                            
                                        }
                                        //unset the modal data
                                        component.set('v.modalData.claimServiceInfo.mode', 'Create');
                                        component.set('v.modalData.claimServiceInfo.title', $A.get('$Label.c.Create_Claim_Service_Info_Heading'));
                                        
                                    });
                                    
                                    
                                }
                                
                            } else if (additionalLabourHours < 0) {
                                
                                component.set('v.error.accordion3.fieldError.additionalLabourHours', $A.get("$Label.c.Negative_Labour_Hour"));
                                
                            }
                            
                        } else {
                            
                            //set jobcode not selected error
                            component.set('v.error.accordion3.fieldError.jobCode', $A.get("$Label.c.Jobcode_Not_Correct"));
                        }
                        
                        break;
                    }
                    
                    
            }
            
        } else if (isTextEvent) {
            //event thrown by output text
            
            var claimServiceInfoId = event.getSource().get('v.title');
            var claimServiceInfoList = JSON.parse(JSON.stringify(component.get('v.claimServiceInfoList')));
            
            //find  target claim service info
            var targetClaimServiceInfo = claimServiceInfoList.filter(function(a) {
                if (a['Id'] == claimServiceInfoId) {
                    return a;
                }
            })[0];
            
            //check if the event is edit event for claimservice info
            var isEditEvent = (event.getSource().get('v.value') === 'Edit') ? true : false;
            
            // logic for editing the claim service info
            if (isEditEvent) {
                
                //set the modal data for edit
                component.set('v.modalData.claimServiceInfo.mode', 'Edit');
                component.set('v.modalData.claimServiceInfo.title', $A.get('$Label.c.Edit_Claim_Service_Info_Heading'));
                component.set('v.modalData.claimServiceInfo.selectedClaimServiceInfo', targetClaimServiceInfo);
                
                //set the jobcode to reference
                
                var jobcode = {
                    Id: targetClaimServiceInfo['Service_Job_Code__c'],
                    Name: targetClaimServiceInfo['Service_Job_Code__r']['Name'],
                    Description__c: targetClaimServiceInfo['Service_Job_Code__r']['Description__c'],
                    Standard_Labor_Hour__c: targetClaimServiceInfo['Service_Job_Code__r']['Standard_Labor_Hour__c']
                };
                component.set('v.selectedJobCode', jobcode);
                
                
                //disable the reasonForAdditionalHoursNeeded if additional hours are 0
                if (targetClaimServiceInfo['Additional_Labor_Hour__c'] == 0 || targetClaimServiceInfo['Additional_Labor_Hour__c'] == '') {
                    component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', false);
                }
                
                // show the claim service info create modal
                //this step is necessary to show the modal first as it is not on DOM
                helper.showModal(component, 'v.modalAndElementDisplayBool.claimServiceInfoModal');
                
                //initialize modal variables with the values of claim service info after dom displayed
                component.find('jobCode').set('v.objectName', targetClaimServiceInfo['Service_Job_Code__r']['Name']);
                var jobCodeComponent = component.find('jobCode');
                if (jobCodeComponent !== null && jobCodeComponent !== undefined && typeof(jobCodeComponent.set) == 'function') {
                    jobCodeComponent.set('v.disabled', true);
                }
                component.find('additionalLabourHours').set('v.value', targetClaimServiceInfo['Additional_Labor_Hour__c']);
                
                
                if (targetClaimServiceInfo['Additional_Labor_Hour__c'] > 0) {
                    
                    //show the reason text area
                    component.find('reasonForAdditionalHours').set('v.value', targetClaimServiceInfo['Reason_Additional_Labor_hour__c']);
                    component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', true);
                    
                }
                
            } else {
                
                // logic for deleting the claim service info
                
                //show the spinner
                component.set('v.spinnerBool.claimServiceInfoSpinner', true);
                
                helper.deleteRaw(component, event, helper, claimServiceInfoId, function(claimServiceDeleteResponse) {
                    
                    //hide the spinner
                    component.set('v.spinnerBool.claimServiceInfoSpinner', false);
                    if (claimServiceDeleteResponse['statusArray'] != null && claimServiceDeleteResponse['statusArray'] != undefined &&
                        claimServiceDeleteResponse['statusArray'].length != 0) {
                        
                        var isDeleted = claimServiceDeleteResponse['statusArray'][0];
                        
                        if (isDeleted == true) {
                            
                            /**remove the element from list**/
                            
                            //find element in list
                            var indexInCurrentClaimServiceInfoList = helper.findIndexWithProperty(claimServiceInfoList, 'Id', claimServiceInfoId);
                            if (indexInCurrentClaimServiceInfoList > -1) {
                                
                                //remove the element from list
                                claimServiceInfoList.splice(indexInCurrentClaimServiceInfoList, 1);
                                
                                //set the list to page variables
                                component.set('v.claimServiceInfoList', claimServiceInfoList);
                                
                            }
                            
                        } else {
                            
                            /**set the error**/
                            
                            var errorList = claimServiceDeleteResponse['errorList'];
                            var exception = [];
                            
                            if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                  errorList != undefined && errorList.length != 0)) {
                                
                                var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                
                                var alertboxContent = {
                                    message: errorMessagesFormattedInString,
                                    heading: $A.get("$Label.c.Delete_Failed"),
                                    class: 'slds-theme--error',
                                    callableFunction: component.getReference('c.closeAlert'),
                                    buttonHeading: $A.get("$Label.c.OK")
                                };
                                helper.showAlert(component, event, alertboxContent);
                                
                            }
                            
                            
                        }
                        
                    } else {
                        
                        /**set the error**/
                        
                        var errorList = [];
                        var exception = claimServiceDeleteResponse['exception'];
                        
                        if ((exception != null && exception != undefined) || (errorList != null &&
                                                                              errorList != undefined && errorList.length != 0)) {
                            
                            var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                            
                            var alertboxContent = {
                                message: errorMessagesFormattedInString,
                                heading: $A.get("$Label.c.Delete_Failed"),
                                class: 'slds-theme--error',
                                callableFunction: component.getReference('c.closeAlert'),
                                buttonHeading: $A.get("$Label.c.OK")
                            };
                            helper.showAlert(component, event, alertboxContent);
                            
                        }
                    }
                });
            }
        } else if (isCheckBoxEvent) {}
    },
    relatedPartListHandeler: function(component, event, helper) {
        
        //check if the event is thrown by checkbox or outputtext
        var isCheckBoxEvent = event.getSource().isInstanceOf('ui:inputCheckbox');
        var isTextEvent = event.getSource().isInstanceOf('ui:outputText');
        
        
        if (!isCheckBoxEvent && !isTextEvent) {
            
            var componentId = event.getSource().getLocalId();
            
            switch (componentId) {
                    
                case "addInstalledPart":
                    {
                        /****Aditya integration****/
                        component.set('v.partPriceException', false);
                        /*************************/
                        
                        helper.resetClaimRelatedListModalData(component, event, 'installedPart');
                        
                        break;
                        
                    }
                    
                case "cancelInstalledPart":
                    {
                        
                        //hide claim service create modal
                        helper.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonSerializedInstalledPart', '');
                        component.set('v.error.accordion4.fieldError.serializedInstalledPart', '');
                        component.set('v.error.accordion4.fieldError.customCost', '');
                        component.set('v.error.accordion4.fieldError.quantity', '');
                        component.set('v.error.accordion4.fieldError.commonError', '');
                        
                        
                        break;
                    }
                    
                case "nonSerializedInstalledPart":
                    {
                        
                        var textValue = event.getParam('textValue');
                        
                        if (textValue === "") {
                            
                            //unset the non-serialized part variables
                            component.find('nonSerializedInstalledPart').set('v.objectName', '');
                            component.set('v.selectedNonSerializedInstalledPart', null);
                            
                            //enable the serialized part lookup
                            var mode = component.get('v.modalData.installedParts.mode');
                            if (mode == 'Create') {
                                component.find('serializedInstalledPart').set('v.objectName', '');
                                component.find('serializedInstalledPart').set('v.disabled', false);
                            }
                            
                            
                        } else {
                            
                            var nonSerializedInstalledPart = event.getParam('selectedObject');
                            if (nonSerializedInstalledPart != null && nonSerializedInstalledPart != undefined) {
                                
                                component.set('v.selectedNonSerializedInstalledPart', nonSerializedInstalledPart);
                                
                                //disable the serialized part entry
                                component.find('serializedInstalledPart').set('v.objectName', '');
                                component.find('serializedInstalledPart').set('v.disabled', true);
                                
                                //unset the previously set serializedInstalledPart selected object
                                component.set('v.selectedSerializedInstalledPart', null);
                                
                                //unset any errors
                                component.set('v.error.accordion4.fieldError.nonSerializedInstalledPart', '');
                                component.set('v.error.accordion4.fieldError.commonError', '');
                                
                                /****Aditya integration****/
                                //helper.getPartSettings(component, event, helper);
                                /*************************/
                            }
                            
                        }
                        
                        break;
                        
                    }
                    
                case "serializedInstalledPart":
                    {
                        
                        var textValue = event.getParam('textValue');
                        
                        if (textValue === "") {
                            
                            //unset the serialized part variables
                            component.find('serializedInstalledPart').set('v.objectName', '');
                            component.set('v.selectedSerializedInstalledPart', null);
                            
                            //enable the non-serialized part lookup
                            var mode = component.get('v.modalData.installedParts.mode');
                            if (mode == 'Create') {
                                component.find('nonSerializedInstalledPart').set('v.objectName', '');
                                component.find('nonSerializedInstalledPart').set('v.disabled', false);
                                component.find('quantity').set('v.disabled', false);
                            }
                            
                            
                        } else {
                            var serializedInstalledPart = event.getParam('selectedObject');
                            
                            if (serializedInstalledPart != null && serializedInstalledPart != undefined) {
                                component.set('v.selectedSerializedInstalledPart', serializedInstalledPart);
                                
                                //disable the non-serialized part entry
                                component.find('nonSerializedInstalledPart').set('v.disabled', true);
                                component.find('nonSerializedInstalledPart').set('v.objectName', '');
                                component.find('quantity').set('v.value', 1);
                                component.find('quantity').set('v.disabled', true);
                                
                                
                                //unset the previously set non-serializedInstalledPart selected object
                                component.set('v.selectedNonSerializedInstalledPart', null);
                                
                                //unset any errors
                                component.set('v.error.accordion4.fieldError.serializedInstalledPart', '');
                                component.set('v.error.accordion4.fieldError.commonError', '');
                                
                                //Added By Aditya for getting individual partprice
                                // helper.getPartSettings(component, event, helper);
                            }
                        }
                        break;
                        
                    }
                    
                case "saveInstalledPartButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'installedPart', false);
                        break;
                    }
                    
                case "saveNextInstalledPartButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'installedPart', true);
                        break;
                    }
                    
                case "updateInstalledPartButton":
                    {
                        
                        //get all the required info from form
                        var updateInstalledPartButton = event.getSource();
                        var targetInstalledPart = JSON.parse(JSON.stringify(component.get('v.modalData.installedParts.selectedInstalledPart')));
                        
                        //if non serialized else serialized
                        if (targetInstalledPart['Warranty_Product__c'] !== null && targetInstalledPart['Warranty_Product__c'] !== undefined &&
                            targetInstalledPart['Warranty_Product__c'] !== '') {
                            
                            //get cost and quantity
                            // check custom cost validation
                            var customCost = parseFloat(component.find('customCost').get('v.value'));
                            
                            if (customCost <= 0 || isNaN(customCost)) {
                                component.set('v.error.accordion4.fieldError.customCost', $A.get("$Label.c.Negative_Unit_Price"));
                            } else {                                                 
                                
                                // check quantity validation
                                var quantity = parseFloat(component.find('quantity').get('v.value'));
                                if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {
                                    
                                    component.set('v.error.accordion4.fieldError.quantity', $A.get("$Label.c.Quantity_Error"));
                                    
                                } else {
                                    
                                    //unset the errors
                                    component.set('v.error.accordion4.fieldError.quantity', '');
                                    component.set('v.error.accordion4.fieldError.customCost', '');                                  
                                    
                                    //filter NaN
                                    if (isNaN(customCost)) {
                                        customCost = null;
                                    }
                                    
                                    //create updatable installed part object
                                    var updatableInstalledPart = {
                                        
                                        Id: targetInstalledPart['Id'],
                                        /****Aditya integration****/
                                        Price__c: customCost,
                                        //Custom_Part_Cost__c: customCost,
                                        /**************************/
                                        Quantity__c: quantity,
                                        
                                    };
                                    
                                    //disable the buttons
                                    updateInstalledPartButton.set('v.disabled', true);
                                    component.find('cancelInstalledPart').set('v.disabled', true);
                                    
                                    //update the installed part
                                    helper.updateRaw(component, event, helper, updatableInstalledPart, function(installedPartUpdateResponse) {
                                        
                                        //enable the buttons
                                        updateInstalledPartButton.set('v.disabled', false);
                                        component.find('cancelInstalledPart').set('v.disabled', false);
                                        
                                        if (installedPartUpdateResponse['sobjectsAndStatus'] != undefined && installedPartUpdateResponse['sobjectsAndStatus'] != null &&
                                            installedPartUpdateResponse['sobjectsAndStatus'].length != 0) {
                                            
                                            //if update successful
                                            var isSuccessfulUpdate = installedPartUpdateResponse['sobjectsAndStatus'][0]['status'];
                                            if (isSuccessfulUpdate == 'successful') {
                                                
                                                var updatedInstalledPart = installedPartUpdateResponse['sobjectsAndStatus'][0]['sObject'];
                                                
                                                // update the fields on page variable
                                                
                                                /****Aditya integration****/
                                                //targetInstalledPart['Custom_Part_Cost__c'] = updatedInstalledPart['Custom_Part_Cost__c'];
                                                targetInstalledPart['Price__c'] = updatedInstalledPart['Price__c'];
                                                /**************************/
                                                targetInstalledPart['Quantity__c'] = updatedInstalledPart['Quantity__c'];
                                                
                                                //set the updated installed part in installed part list page variable
                                                var installedPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                                                var indexOfOldInstalledPart = helper.findIndexWithProperty(installedPartList,
                                                                                                           'Id', updatedInstalledPart['Id']);
                                                
                                                
                                                //replace the updated installed part in the installed part list page variable
                                                if (indexOfOldInstalledPart > -1) {
                                                    
                                                    installedPartList[indexOfOldInstalledPart] = targetInstalledPart;
                                                    component.set('v.installedPartList', installedPartList);
                                                    
                                                }
                                                
                                                
                                                //close modal
                                                helper.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                
                                                
                                            } else {
                                                
                                                //close modal
                                                helper.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                                
                                                // set error in updation alert
                                                var errorException = claimServiceInfoUpdate['exception'];
                                                var errorArrays = claimServiceInfoUpdate['errorList'];
                                                
                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                                errorArrays != undefined && errorArrays.length != 0)) {
                                                    
                                                    var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                                    
                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.Installed_Part_Not_Updated_H"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    helper.showAlert(component, event, alertboxContent);
                                                    
                                                }
                                                
                                                
                                                
                                            }
                                            
                                        }
                                        
                                    });
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            
                            //get cost
                            var customCost = parseFloat(component.find('customCost').get('v.value'));
                            var quantity = parseFloat(component.find('quantity').get('v.value'));
                            
                            if (customCost <= 0 || isNaN(customCost)) {
                                component.set('v.error.accordion4.fieldError.customCost', $A.get("$Label.c.Negative_Unit_Price"));
                            } else {
                                
                                component.set('v.error.accordion4.fieldError.customCost', '');
                                
                                //create updatable installed part object
                                var updatableInstalledPart = {
                                    
                                    Id: targetInstalledPart['Id'],
                                    Custom_Part_Cost__c: customCost,
                                    Quantity__c: quantity,
                                    
                                };
                                
                                //disable the buttons
                                updateInstalledPartButton.set('v.disabled', true);
                                component.find('cancelInstalledPart').set('v.disabled', true);
                                
                                //update the installed part
                                helper.updateRaw(component, event, helper, updatableInstalledPart, function(installedPartUpdateResponse) {
                                    
                                    //enable the buttons
                                    updateInstalledPartButton.set('v.disabled', false);
                                    component.find('cancelInstalledPart').set('v.disabled', false);
                                    
                                    if (installedPartUpdateResponse['sobjectsAndStatus'] != undefined && installedPartUpdateResponse['sobjectsAndStatus'] != null &&
                                        installedPartUpdateResponse['sobjectsAndStatus'].length != 0) {
                                        
                                        //if update successful
                                        var isSuccessfulUpdate = installedPartUpdateResponse['sobjectsAndStatus'][0]['status'];
                                        if (isSuccessfulUpdate == 'successful') {
                                            
                                            var updatedInstalledPart = installedPartUpdateResponse['sobjectsAndStatus'][0]['sObject'];
                                            
                                            // update the fields on page variable
                                            targetInstalledPart['Custom_Part_Cost__c'] = updatedInstalledPart['Custom_Part_Cost__c'];
                                            targetInstalledPart['Quantity__c'] = updatedInstalledPart['Quantity__c'];
                                            
                                            //set the updated installed part in installed part list page variable
                                            var installedPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                                            var indexOfOldInstalledPart = helper.findIndexWithProperty(installedPartList,
                                                                                                       'Id', updatedInstalledPart['Id']);
                                            
                                            
                                            //replace the updated installed part in the installed part list page variable
                                            if (indexOfOldInstalledPart > -1) {
                                                
                                                installedPartList[indexOfOldInstalledPart] = targetInstalledPart;
                                                component.set('v.installedPartList', installedPartList);
                                                
                                            }
                                            
                                            
                                            //close modal
                                            helper.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                            
                                            
                                        } else {
                                            
                                            //close modal
                                            helper.closeModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                                            
                                            // set error in updation alert
                                            var errorException = claimServiceInfoUpdate['exception'];
                                            var errorArrays = claimServiceInfoUpdate['errorList'];
                                            
                                            if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                            errorArrays != undefined && errorArrays.length != 0)) {
                                                
                                                var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                                
                                                var alertboxContent = {
                                                    message: errorMessagesFormattedInString,
                                                    heading: $A.get("$Label.c.Installed_Part_Not_Updated_H"),
                                                    class: 'slds-theme--error',
                                                    callableFunction: component.getReference('c.closeAlert'),
                                                    buttonHeading: $A.get("$Label.c.OK")
                                                };
                                                helper.showAlert(component, event, alertboxContent);
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                });
                                
                            }
                            
                        }
                        
                        
                        break;
                    }
                    
                case "addRemovedPart":
                    {
                        
                        helper.resetClaimRelatedListModalData(component, event, 'removedPart');
                        
                        break;
                    }
                    
                case "cancelRemovedPart":
                    {
                        
                        //hide claim service create modal
                        helper.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonSerializedRemovedPart', '');
                        component.set('v.error.accordion4.fieldError.serializedRemovedPart', '');
                        component.set('v.error.accordion4.fieldError.removedPartQuantity', '');
                        component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', '');
                        
                        break;
                    }
                    
                case "nonSerializedRemovedPart":
                    {
                        
                        var textValue = event.getParam('textValue');
                        
                        if (textValue == "") {
                            
                            //unset the non-serialized part variables
                            component.find('nonSerializedRemovedPart').set('v.objectName', '');
                            
                            //unset the non-serialized part variables
                            component.set('v.selectedSerializedRemovedPart', null);
                            component.set('v.selectedNonSerializedRemovedPart', null);
                            
                            
                            //enable the serialized part lookup
                            var mode = component.get('v.modalData.removedParts.mode');
                            if (mode == 'Create') {
                                component.find('nonSerializedRemovedPart').set('v.objectName', '');
                                component.find('serializedRemovedPart').set('v.disabled', false);
                            }
                            
                            
                        } else {
                            
                            var nonSerializedRemovedPart = event.getParam('selectedObject');
                            
                            if (nonSerializedRemovedPart != null && nonSerializedRemovedPart != undefined) {
                                
                                component.set('v.selectedNonSerializedRemovedPart', nonSerializedRemovedPart);
                                
                                //disable the serialized part entry
                                component.find('serializedRemovedPart').set('v.objectName', '');
                                component.find('serializedRemovedPart').set('v.disabled', true);
                                
                                //unset the previously set serializedremovedpart selected object
                                component.set('v.selectedSerializedRemovedPart', null);
                                
                                //unset any errors
                                component.set('v.error.accordion4.fieldError.nonSerializedRemovedPart', '');
                                component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', '');
                                
                            }
                            
                        }
                        
                        break;
                        
                    }
                    
                case "serializedRemovedPart":
                    {
                        
                        var textValue = event.getParam('textValue');
                        
                        if (textValue == "") {
                            
                            //unset the serialized part variables
                            component.find('serializedRemovedPart').set('v.objectName', '');
                            
                            //unset the selected previously values
                            component.set('v.selectedSerializedRemovedPart', null);
                            component.set('v.selectedNonSerializedRemovedPart', null);
                            
                            
                            //enable the non-serialized part lookup
                            var mode = component.get('v.modalData.removedParts.mode');
                            if (mode == 'Create') {
                                component.find('nonSerializedRemovedPart').set('v.objectName', '');
                                component.find('nonSerializedRemovedPart').set('v.disabled', false);
                                component.find('removedPartQuantity').set('v.disabled', false);
                            }
                            
                            
                        } else {
                            var serializedRemovedPart = event.getParam('selectedObject');
                            
                            if (serializedRemovedPart != null && serializedRemovedPart != undefined) {
                                component.set('v.selectedSerializedRemovedPart', serializedRemovedPart);
                                
                                //disable the non-serialized part entry
                                component.find('nonSerializedRemovedPart').set('v.disabled', true);
                                component.find('nonSerializedRemovedPart').set('v.objectName', '');
                                component.find('removedPartQuantity').set('v.value', 1);
                                component.find('removedPartQuantity').set('v.disabled', true);
                                
                                //unset the previously set non-serializedRemovedPart selected object
                                component.set('v.selectedNonSerializedRemovedPart', null);
                                
                                //unset any errors
                                component.set('v.error.accordion4.fieldError.serializedRemovedPart', '');
                                component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', '');
                            }
                        }
                        break;
                        
                    }
                    
                case "saveRemovedPartButton":
                    {
                        
                        helper.saveClaimRelatedList(component, event, 'removedPart', false);
                        break;
                        
                    }
                    
                case "saveNextRemovedPartButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'removedPart', true);
                        break;
                    }
                    
                case "updateRemovedPartButton":
                    {
                        
                        //get all the required info from form
                        var updateRemovedPartButton = event.getSource();
                        var targetRemovedPart = JSON.parse(JSON.stringify(component.get('v.modalData.removedParts.selectedRemovedPart')));
                        
                        // check quantity validation
                        var quantity = parseFloat(component.find('removedPartQuantity').get('v.value'));
                        if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {
                            
                            component.set('v.error.accordion4.fieldError.removedPartQuantity', $A.get("$Label.c.Quantity_Error"));
                            
                        } else {
                            
                            //unset the errors
                            component.set('v.error.accordion4.fieldError.removedPartQuantity', '');
                            
                            //create updatable installed part object
                            var updatableRemovedPart = {
                                
                                Id: targetRemovedPart['Id'],
                                Quantity__c: quantity,
                                
                            };
                            
                            //disable the buttons
                            updateRemovedPartButton.set('v.disabled', true);
                            component.find('cancelRemovedPart').set('v.disabled', true);
                            
                            //update the installed part
                            helper.updateRaw(component, event, helper, updatableRemovedPart, function(removedPartUpdateResponse) {
                                
                                //enable the buttons
                                updateRemovedPartButton.set('v.disabled', false);
                                component.find('cancelRemovedPart').set('v.disabled', false);
                                
                                if (removedPartUpdateResponse['sobjectsAndStatus'] != undefined && removedPartUpdateResponse['sobjectsAndStatus'] != null &&
                                    removedPartUpdateResponse['sobjectsAndStatus'].length != 0) {
                                    
                                    //if update successful
                                    var isSuccessfulUpdate = removedPartUpdateResponse['sobjectsAndStatus'][0]['status'];
                                    if (isSuccessfulUpdate == 'successful') {
                                        
                                        var updatedRemovedPart = removedPartUpdateResponse['sobjectsAndStatus'][0]['sObject'];
                                        
                                        // update the fields on page variable
                                        targetRemovedPart['Quantity__c'] = updatedRemovedPart['Quantity__c'];
                                        
                                        //set the updated installed part in removed part list page variable
                                        var removedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                                        var indexOfOldRemovedPart = helper.findIndexWithProperty(removedPartList,
                                                                                                 'Id', updatedRemovedPart['Id']);
                                        
                                        
                                        //replace the updated removed part in the removed part list
                                        if (indexOfOldRemovedPart > -1) {
                                            
                                            removedPartList[indexOfOldRemovedPart] = targetRemovedPart;
                                            component.set('v.removedPartList', removedPartList);
                                            
                                            
                                        }
                                        
                                        
                                        //close modal
                                        helper.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');
                                        
                                        
                                    } else {
                                        
                                        //close modal
                                        helper.closeModal(component, 'v.modalAndElementDisplayBool.removedPartModal');
                                        
                                        // set error in updation alert
                                        var errorException = claimServiceInfoUpdate['exception'];
                                        var errorArrays = claimServiceInfoUpdate['errorList'];
                                        
                                        if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                        errorArrays != undefined && errorArrays.length != 0)) {
                                            
                                            var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                            
                                            var alertboxContent = {
                                                message: errorMessagesFormattedInString,
                                                heading: $A.get("$Label.c.Removed_Part_Not_Updated_H"),
                                                class: 'slds-theme--error',
                                                callableFunction: component.getReference('c.closeAlert'),
                                                buttonHeading: $A.get("$Label.c.OK")
                                            };
                                            helper.showAlert(component, event, alertboxContent);
                                            
                                        }
                                    }
                                    
                                }
                                
                            });
                        }
                        
                        break;
                    }
                    
                case "addNONOEMPart":
                    {
                        helper.resetClaimRelatedListModalData(component, event, 'miscellenousPart');
                        break;
                    }
                    
                case "cancelNONOEMPart":
                    {
                        
                        //hide claim service create modal
                        helper.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', '');
                        component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', '');
                        component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', '');
                        
                        break;
                    }
                    
                case "saveNONOEMButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'miscellenousPart', false);
                        break;
                    }
                    
                case "saveNextNONOEMButton":
                    {
                        helper.saveClaimRelatedList(component, event, 'miscellenousPart', true);
                        break;
                    }
                    
                case "updateNONOEMButton":
                    {
                        
                        //get all the required info from form
                        var updateNONOEMButton = event.getSource();
                        
                        var targetNONOEMPart = JSON.parse(JSON.stringify(component.get('v.modalData.nonOEMParts.selectedNONOEMPart')));
                        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                        
                        
                        var quantity = parseFloat(component.find('nonOEMPartQuantity').get('v.value'));
                        var customCost = parseFloat(component.find('nonOEMPartCustomCost').get('v.value'));
                        var description = component.find('nonOEMPartDescription').get('v.value');
                        
                        if (customCost <= 0 || isNaN(customCost)) {
                            component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', $A.get("$Label.c.Non_OEM_Custom_Cost_Negative_Empty"));
                        } else {
                            
                            if (quantity <= 0 || (quantity % 1 != 0) || isNaN(quantity)) {
                                component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', $A.get("$Label.c.Quantity_Error"));
                            } else {
                                
                                var invoiceDate = component.find('Invoice Date').get('v.value');
                                
                                if (new Date(invoiceDate) == 'Invalid Date' && invoiceDate !== '' && invoiceDate !== undefined) {
                                    
                                    component.set('v.error.accordion4.fieldError.invoiceDate', 'Invalid Date');
                                    
                                } else {
                                    
                                    if (description === null || description === undefined || description === '') {
                                        component.set('v.error.accordion4.fieldError.nonOEMPartDescription', $A.get("$Label.c.Non_OEM_Part_Description_Error"));
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
                                            invoiceDate = helper.getDateReadableFormat(invoiceDate);
                                            
                                        }
                                        
                                        
                                        //create empty Non-OEM part
                                        var updatableNonOEMPart = {
                                            
                                            Id: targetNONOEMPart['Id'],
                                            Custom_Part_Cost__c: customCost,
                                            Quantity__c: quantity,
                                            Invoice_Date__c: invoiceDate,
                                            Invoice_Number__c: invoiceNumber,
                                            Miscellaneous_Part_Description__c: description
                                        };
                                        
                                        
                                        //insert the NON-OEM part
                                        
                                        //disable buttons
                                        updateNONOEMButton.set('v.disabled', true);
                                        component.find('cancelNONOEMPart').set('v.disabled', true);
                                        
                                        helper.updateRaw(component, event, helper, updatableNonOEMPart, function(nonOEMPartUpdateResponse) {
                                            
                                            
                                            
                                            //enable buttons
                                            updateNONOEMButton.set('v.disabled', true);
                                            component.find('cancelNONOEMPart').set('v.disabled', true);
                                            
                                            if (nonOEMPartUpdateResponse['sobjectsAndStatus'] != undefined &&
                                                nonOEMPartUpdateResponse['sobjectsAndStatus'] != null &&
                                                nonOEMPartUpdateResponse['sobjectsAndStatus'].length != 0) {
                                                
                                                var isSuccessfulUpdate = nonOEMPartUpdateResponse['sobjectsAndStatus'][0]['status'];
                                                if (isSuccessfulUpdate == 'successful') {
                                                    
                                                    var updateedNONOEMpart = nonOEMPartUpdateResponse['sobjectsAndStatus'][0]['sObject'];
                                                    
                                                    //fill some values
                                                    updateedNONOEMpart['Name'] = targetNONOEMPart['Name'];
                                                    updateedNONOEMpart['Miscellaneous_Part_Name__c'] = targetNONOEMPart['Miscellaneous_Part_Name__c'];
                                                    
                                                    
                                                    //replace into the list of NON-OEM parts
                                                    var nonOEMPartList = JSON.parse(JSON.stringify(component.get('v.nonOEMPartList')));
                                                    
                                                    var indexOfOldNONOEMPart = helper.findIndexWithProperty(nonOEMPartList,
                                                                                                            'Id', updateedNONOEMpart['Id']);
                                                    
                                                    
                                                    //replace the updated non-OEM part in the non-OEM part list page variable
                                                    if (indexOfOldNONOEMPart > -1) {
                                                        
                                                        nonOEMPartList[indexOfOldNONOEMPart] = updateedNONOEMpart;
                                                        component.set('v.nonOEMPartList', nonOEMPartList);
                                                        
                                                    }
                                                    
                                                    //close the modal
                                                    helper.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                                                    
                                                } else {
                                                    
                                                    //close the modal
                                                    helper.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                                                    
                                                    // set error in insertion alert
                                                    var errorException = nonOEMPartUpdateResponse['exception'];
                                                    var errorArrays = nonOEMPartUpdateResponse['errorList'];
                                                    
                                                    if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                                    errorArrays != undefined && errorArrays.length != 0)) {
                                                        
                                                        var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                                        
                                                        var alertboxContent = {
                                                            message: errorMessagesFormattedInString,
                                                            heading: $A.get("$Label.c.NON_OEM_Part_Not_Updated_H"),
                                                            class: 'slds-theme--error',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        helper.showAlert(component, event, alertboxContent);
                                                        
                                                    }
                                                    
                                                }
                                                
                                            } else {
                                                
                                                //close the modal
                                                helper.closeModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                                                
                                                // set error in insertion alert
                                                var errorException = nonOEMPartUpdateResponse['exception'];
                                                var errorArrays = nonOEMPartUpdateResponse['errorList'];
                                                
                                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                                errorArrays != undefined && errorArrays.length != 0)) {
                                                    
                                                    var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                                    
                                                    var alertboxContent = {
                                                        message: errorMessagesFormattedInString,
                                                        heading: $A.get("$Label.c.NON_OEM_Part_Not_Updated_H"),
                                                        class: 'slds-theme--error',
                                                        callableFunction: component.getReference('c.closeAlert'),
                                                        buttonHeading: $A.get("$Label.c.OK")
                                                    };
                                                    helper.showAlert(component, event, alertboxContent);
                                                    
                                                }
                                                
                                            }
                                            
                                        });
                                        
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        break;
                    }
                    
                    /****Aditya integration****/
                case "partPriceGetterButton":
                    {
                        component.set('v.spinnerBool.pageSpinner', true);
                        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                        var getPartPriceAction = component.get('c.getPartPrice');
                        getPartPriceAction.setParams({
                            claimIdsList: [currentClaim['Id']]
                        });
                        getPartPriceAction.setCallback(this, function(getPartPriceResponse) {
                            
                            var state = getPartPriceResponse.getState();
                            
                            if (state === "SUCCESS" && component.isValid()) {
                                var returnedvalue = getPartPriceResponse.getReturnValue();
                                
                                var response = [];
                                response = JSON.parse(returnedvalue);
                                
                                var currentInstalledPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                                if (response !== null && response !== undefined) {
                                    
                                    if (response.includes('Read timed out')) {
                                        
                                        component.set('v.spinnerBool.pageSpinner', false);
                                        var alertboxContent = {
                                            message: $A.get("$Label.c.Server_Time_Out_Exception"),
                                            heading: 'Read timed out',
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        
                                    } else {
                                        
                                        for (var i = 0; i < response.length; i++) {
                                            currentInstalledPartList[i]['Price__c'] = response[i]['ttPriceVal'].toFixed(2);
                                            currentInstalledPartList[i]['Part_Price_Not_Found__c'] = false;
                                            if (response[i].ttResultVal !== 'success') {
                                                currentInstalledPartList[i]['Part_Price_Not_Found__c'] = true;
                                                
                                            }
                                        }
                                        helper.updateRaw(component, event, helper, currentInstalledPartList, function(installedPartUpdateResponse) {
                                            component.set('v.spinnerBool.pageSpinner', false);
                                            var updateStatusAndsObjectList = installedPartUpdateResponse['sobjectsAndStatus'];
                                            if (updateStatusAndsObjectList !== null && updateStatusAndsObjectList !== undefined && updateStatusAndsObjectList.length !== 0) {
                                                
                                                var updatedInstalledPartList = updateStatusAndsObjectList.map(function(a) {
                                                    return a['sObject'];
                                                });
                                                
                                                component.set('v.installedPartList', currentInstalledPartList);
                                            }
                                        });
                                        
                                    }
                                    
                                }
                                
                                
                            }
                        });
                        $A.enqueueAction(getPartPriceAction);
                        
                        break;
                    }
                    /*************************/
            }
            
        } else if (isTextEvent) {
            
            //get which event and for which claim part list
            var whichPartTypeWhichEvent = event.getSource().get('v.class');
            if (whichPartTypeWhichEvent.endsWith('EditInstalledPart')) {
                whichPartTypeWhichEvent = "EditInstalledPart";
            } else if (whichPartTypeWhichEvent.endsWith('DeleteInstalledPart')) {
                whichPartTypeWhichEvent = "DeleteInstalledPart";
            } else if (whichPartTypeWhichEvent.endsWith('DeleteRemovedPart')) {
                whichPartTypeWhichEvent = "DeleteRemovedPart";
            } else if (whichPartTypeWhichEvent.endsWith('EditRemovedPart')) {
                whichPartTypeWhichEvent = "EditRemovedPart";
            } else if (whichPartTypeWhichEvent.endsWith('EditNONOEMPart')) {
                whichPartTypeWhichEvent = "EditNONOEMPart";
            } else if (whichPartTypeWhichEvent.endsWith('DeleteNONOEMPart')) {
                whichPartTypeWhichEvent = "DeleteNONOEMPart";
            }
            
            
            switch (whichPartTypeWhichEvent) {
                    
                case "EditInstalledPart":
                    {
                        
                        var installedPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                        var targetInstalledPartId = event.getSource().get('v.title');
                        var targetInstalledPart = installedPartList.filter(function(a) {
                            if (a['Id'] === targetInstalledPartId) {
                                return a;
                            }
                        })[0];
                        
                        
                        // show the installed parts create modal
                        helper.showModal(component, 'v.modalAndElementDisplayBool.installedPartsModal');
                        
                        //if serialized part else for non serialized part
                        if (targetInstalledPart['Inventory__c'] != '' && targetInstalledPart['Inventory__c'] != null &&
                            targetInstalledPart['Inventory__c'] != undefined) {
                            
                            //set the dom values
                            /****Aditya integration****/
                            //component.find('customCost').set('v.value', targetInstalledPart['Custom_Part_Cost__c']);
                            component.find('customCost').set('v.value', targetInstalledPart['Price__c']);
                            /************************/
                            component.find('quantity').set('v.value', targetInstalledPart['Quantity__c']);
                            component.find('quantity').set('v.disabled', true);
                            component.find('nonSerializedInstalledPart').set('v.disabled', true);
                            component.find('serializedInstalledPart').set('v.disabled', true);
                            component.find('serializedInstalledPart').set('v.objectName', targetInstalledPart['Inventory__r']['Name']);
                            
                            
                        } else {
                            
                            //set the dom values
                            
                            
                            /****Aditya integration****/
                            //component.find('customCost').set('v.value', targetInstalledPart['Custom_Part_Cost__c']);
                            component.find('customCost').set('v.value', targetInstalledPart['Price__c']);
                            /************************/
                            component.find('quantity').set('v.value', targetInstalledPart['Quantity__c']);
                            component.find('nonSerializedInstalledPart').set('v.disabled', true);
                            component.find('serializedInstalledPart').set('v.disabled', true);
                            
                            /****Aditya integration****/
                            //component.find('customCost').set('v.disabled',true);
                            /************************/
                            
                            component.find('nonSerializedInstalledPart').set('v.objectName', targetInstalledPart['Warranty_Product__r']['Name']);
                            
                        }
                        
                        
                        
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonSerializedInstalledPart', '');
                        component.set('v.error.accordion4.fieldError.serializedInstalledPart', '');
                        component.set('v.error.accordion4.fieldError.customCost', '');
                        component.set('v.error.accordion4.fieldError.quantity', '');
                        component.set('v.error.accordion4.fieldError.commonError', '');
                        
                        //set the modal data for edit
                        component.set('v.modalData.installedParts.mode', 'Edit');
                        component.set('v.modalData.installedParts.title', $A.get('$Label.c.Edit_Installed_Part_Heading'));
                        component.set('v.modalData.installedParts.selectedInstalledPart', targetInstalledPart);
                        
                        break;
                    }
                    
                case "DeleteInstalledPart":
                    {
                        
                        var targetInstalledPartId = event.getSource().get('v.title');
                        var currentInstalledPartList = JSON.parse(JSON.stringify(component.get('v.installedPartList')));
                        
                        // logic for deleting the installed part
                        
                        //show the spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        //database delete
                        helper.deleteRaw(component, event, helper, targetInstalledPartId, function(installedPartDeleteResponse) {
                            
                            //hide the spinner
                            component.set('v.spinnerBool.pageSpinner', false);
                            
                            if (installedPartDeleteResponse['statusArray'] != null && installedPartDeleteResponse['statusArray'] != undefined &&
                                installedPartDeleteResponse['statusArray'].length != 0) {
                                
                                var isDeleted = installedPartDeleteResponse['statusArray'][0];
                                
                                if (isDeleted == true) {
                                    
                                    /**remove the element from list**/
                                    
                                    //find element in list
                                    var indexInCurrentInstalledPartList = helper.findIndexWithProperty(currentInstalledPartList, 'Id', targetInstalledPartId);
                                    if (indexInCurrentInstalledPartList > -1) {
                                        
                                        //remove the element from list
                                        currentInstalledPartList.splice(indexInCurrentInstalledPartList, 1);
                                        
                                        //set the list to page variables
                                        component.set('v.installedPartList', currentInstalledPartList);
                                        
                                    }
                                    
                                } else {
                                    
                                    /**set the error**/
                                    
                                    var errorList = installedPartDeleteResponse['errorList'];
                                    var exception = [];
                                    
                                    if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                          errorList != undefined && errorList.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Delete_Failed"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                    
                                }
                                
                            } else {
                                
                                
                                /**set the error**/
                                
                                var errorList = [];
                                var exception = installedPartDeleteResponse['exception'];
                                
                                if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                      errorList != undefined && errorList.length != 0)) {
                                    
                                    var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                    
                                    var alertboxContent = {
                                        message: errorMessagesFormattedInString,
                                        heading: $A.get("$Label.c.Delete_Failed"),
                                        class: 'slds-theme--error',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    helper.showAlert(component, event, alertboxContent);
                                    
                                }
                                
                                
                            }
                            
                            
                            
                        });
                        
                        
                        
                        
                        
                        break;
                    }
                    
                case "EditRemovedPart":
                    {
                        
                        var removedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                        var targetRemovedPartId = event.getSource().get('v.title');
                        var targetRemovedPart = removedPartList.filter(function(a) {
                            if (a['Id'] === targetRemovedPartId) {
                                return a;
                            }
                        })[0];
                        
                        
                        // show the removed parts create modal
                        helper.showModal(component, 'v.modalAndElementDisplayBool.removedPartModal');
                        
                        //if serialized part else for non serialized part
                        if (targetRemovedPart['Inventory__c'] != '' && targetRemovedPart['Inventory__c'] != null &&
                            targetRemovedPart['Inventory__c'] != undefined) {
                            
                            //set the dom values
                            component.find('removedPartQuantity').set('v.value', targetRemovedPart['Quantity__c']);
                            component.find('removedPartQuantity').set('v.disabled', true);
                            component.find('nonSerializedRemovedPart').set('v.disabled', true);
                            component.find('serializedRemovedPart').set('v.disabled', true);
                            component.find('serializedRemovedPart').set('v.objectName', targetRemovedPart['Inventory__r']['Name']);
                            
                            
                        } else {
                            
                            //set the dom values
                            component.find('removedPartQuantity').set('v.value', targetRemovedPart['Quantity__c']);
                            component.find('nonSerializedRemovedPart').set('v.disabled', true);
                            component.find('serializedRemovedPart').set('v.disabled', true);
                            component.find('nonSerializedRemovedPart').set('v.objectName', targetRemovedPart['Warranty_Product__r']['Name']);
                            
                        }
                        
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonSerializedRemovedPart', '');
                        component.set('v.error.accordion4.fieldError.serializedRemovedPart', '');
                        component.set('v.error.accordion4.fieldError.removedPartQuantity', '');
                        component.set('v.error.accordion4.fieldError.commonErrorForRemovedPart', '');
                        
                        //set the modal data for edit
                        component.set('v.modalData.removedParts.mode', 'Edit');
                        component.set('v.modalData.removedParts.title', $A.get('$Label.c.Edit_Removed_Part_Heading'));
                        component.set('v.modalData.removedParts.selectedRemovedPart', targetRemovedPart);
                        
                        
                        break;
                    }
                    
                case "DeleteRemovedPart":
                    {
                        
                        var targetRemovedPartId = event.getSource().get('v.title');
                        var currentRemovedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                        
                        // logic for deleting the removed part
                        
                        //show the spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        //database delete
                        helper.deleteRaw(component, event, helper, targetRemovedPartId, function(removedPartDeleteResponse) {
                            
                            //hide the spinner
                            component.set('v.spinnerBool.pageSpinner', false);
                            
                            if (removedPartDeleteResponse['statusArray'] != null && removedPartDeleteResponse['statusArray'] != undefined &&
                                removedPartDeleteResponse['statusArray'].length != 0) {
                                
                                var isDeleted = removedPartDeleteResponse['statusArray'][0];
                                
                                if (isDeleted == true) {
                                    
                                    /**remove the element from list**/
                                    
                                    //find element in list
                                    var indexInCurrentRemovedPartList = helper.findIndexWithProperty(currentRemovedPartList, 'Id', targetRemovedPartId);
                                    if (indexInCurrentRemovedPartList > -1) {
                                        
                                        //remove the element from list
                                        currentRemovedPartList.splice(indexInCurrentRemovedPartList, 1);
                                        
                                        //set the list to page variables
                                        component.set('v.removedPartList', currentRemovedPartList);
                                        
                                    }
                                    
                                } else {
                                    
                                    /**set the error**/
                                    
                                    var errorList = removedPartDeleteResponse['errorList'];
                                    var exception = [];
                                    
                                    if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                          errorList != undefined && errorList.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Delete_Failed"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                    
                                }
                                
                            } else {
                                
                                
                                /**set the error**/
                                
                                var errorList = [];
                                var exception = removedPartDeleteResponse['exception'];
                                
                                if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                      errorList != undefined && errorList.length != 0)) {
                                    
                                    var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                    
                                    var alertboxContent = {
                                        message: errorMessagesFormattedInString,
                                        heading: $A.get("$Label.c.Delete_Failed"),
                                        class: 'slds-theme--error',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    helper.showAlert(component, event, alertboxContent);
                                    
                                }
                                
                                
                            }
                            
                            
                            
                        });
                        
                        
                        
                        break;
                    }
                    
                case "EditNONOEMPart":
                    {
                        
                        var nonOEMPartList = JSON.parse(JSON.stringify(component.get('v.nonOEMPartList')));
                        var nonOEMPartId = event.getSource().get('v.title');
                        var targetNONOEMpart = nonOEMPartList.filter(function(a) {
                            if (a['Id'] === nonOEMPartId) {
                                return a;
                            }
                        })[0];
                        
                        
                        // show the nonOEM parts create modal
                        helper.showModal(component, 'v.modalAndElementDisplayBool.nonOEMPartModal');
                        
                        //set the dom values
                        component.find('nonOEMPartCustomCost').set('v.value', targetNONOEMpart['Custom_Part_Cost__c']);
                        component.find('nonOEMPartQuantity').set('v.value', targetNONOEMpart['Quantity__c']);
                        component.find('Invoice Number').set('v.value', targetNONOEMpart['Invoice_Number__c']);
                        component.find('Invoice Date').set('v.value', targetNONOEMpart['Invoice_Date__c']);
                        component.find('nonOEMPartName').set('v.value', targetNONOEMpart['Name']);
                        component.find('nonOEMPartDescription').set('v.value', targetNONOEMpart['Miscellaneous_Part_Description__c']);
                        
                        component.set('v.modalData.nonOEMParts.selectedNONOEMPart', targetNONOEMpart);
                        
                        component.find('nonOEMPartName').set('v.disabled', true);
                        
                        //clear all the errors
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', '');
                        component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', '');
                        component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', '');
                        component.set('v.error.accordion4.fieldError.nonOEMPartDescription', '');
                        
                        //set the modal data for edit
                        component.set('v.modalData.nonOEMParts.mode', 'Edit');
                        component.set('v.modalData.nonOEMParts.title', $A.get('$Label.c.Edit_Miscellaneous_Part_Heading'));
                        component.set('v.modalData.nonOEMParts.selectedNONOEMPart', targetNONOEMpart);
                        
                        
                        break;
                    }
                    
                case "DeleteNONOEMPart":
                    {
                        
                        var targetNONOEMpartId = event.getSource().get('v.title');
                        var currentNONOEMpartList = JSON.parse(JSON.stringify(component.get('v.nonOEMPartList')));
                        
                        //show the spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        //database delete
                        helper.deleteRaw(component, event, helper, targetNONOEMpartId, function(nonOEMPartDeleteResponse) {
                            
                            //hide the spinner
                            component.set('v.spinnerBool.pageSpinner', false);
                            
                            if (nonOEMPartDeleteResponse['statusArray'] != null && nonOEMPartDeleteResponse['statusArray'] != undefined &&
                                nonOEMPartDeleteResponse['statusArray'].length != 0) {
                                
                                var isDeleted = nonOEMPartDeleteResponse['statusArray'][0];
                                
                                if (isDeleted == true) {
                                    
                                    /**remove the element from list**/
                                    
                                    //find element in list
                                    var indexInCurrentNONOEMPartList = helper.findIndexWithProperty(currentNONOEMpartList, 'Id', targetNONOEMpartId);
                                    if (indexInCurrentNONOEMPartList > -1) {
                                        
                                        //remove the element from list
                                        currentNONOEMpartList.splice(indexInCurrentNONOEMPartList, 1);
                                        
                                        //set the list to page variables
                                        component.set('v.nonOEMPartList', currentNONOEMpartList);
                                        
                                    }
                                    
                                } else {
                                    
                                    /**set the error**/
                                    
                                    var errorList = nonOEMPartDeleteResponse['errorList'];
                                    var exception = [];
                                    
                                    if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                          errorList != undefined && errorList.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Delete_Failed"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                    
                                }
                                
                            } else {
                                
                                
                                /**set the error**/
                                var errorList = [];
                                var exception = nonOEMPartDeleteResponse['exception'];
                                
                                if ((exception != null && exception != undefined) || (errorList != null &&
                                                                                      errorList != undefined && errorList.length != 0)) {
                                    
                                    var errorMessagesFormattedInString = helper.getErrorMessage(exception, errorList);
                                    
                                    var alertboxContent = {
                                        message: errorMessagesFormattedInString,
                                        heading: $A.get("$Label.c.Delete_Failed"),
                                        class: 'slds-theme--error',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    helper.showAlert(component, event, alertboxContent);
                                    
                                }
                                
                                
                            }
                            
                            
                        });
                        
                        
                        break;
                    }
                    
            }
            
            
        }
        
        
    },
    additionalInfoHandeler: function(component, event, helper) {
        
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var componentId = event.getSource().getLocalId();
        
        switch (componentId) {
                
            case "updateCommentsAndCostButton":
                {
                    
                    // get this status from component error object
                    var accordionValidated = helper.validateAccordionOpen(component, event, 'accordion-c-6');
                    
                    // target accordion
                    var claimSummarytab = component.find("accordion-c-6-body");
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    var faultCodeandCausalPartTab = component.find('accordion-c-2-body');
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    var installedAndremovedPartsTab = component.find("accordion-c-4-body");
                    var additionalInfoTab = component.find("accordion-c-5-body");
                    
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Additional_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Additional_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        helper.closeTabForceFully(component, event, 'accordion-c-6-body');
                        helper.showAlert(component, event, alertboxContent);
                        
                        
                    } else {
                        
                        //set some variables
                        delete currentClaim['sobjectType'];
                        currentClaim['Date_Of_Purchase__c'] = component.get('v.purchaseDate');
                        
                        //fill picklist values in claim
                        currentClaim = helper.fillPickListValuesInClaim(component, currentClaim);
                        
                        //show the spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        //send only updatable fields
                        var claimToUpdate = {
                            Id: currentClaim['Id'],
                            TravelByHours__c: currentClaim['TravelByHours__c'],
                            TravelByDistance__c: currentClaim['TravelByDistance__c'],
                            TravelByLocation__c: currentClaim['TravelByLocation__c'],
                            Total_Category1_Cost__c: currentClaim['Total_Category1_Cost__c'],
                            Total_Category2_Cost__c: currentClaim['Total_Category2_Cost__c'],
                            Fault_Code_Comment__c: currentClaim['Fault_Code_Comment__c'],
                            CasualPart_Comments__c: currentClaim['CasualPart_Comments__c'],
                            work_Performed_comments__c: currentClaim['work_Performed_comments__c'],
                            Description__c: currentClaim['Description__c'],
                        };
                        
                        helper.updateRaw(component, event, helper, claimToUpdate, function(claimUpdateResponse) {
                            
                            //hide the spinner
                            component.set('v.spinnerBool.pageSpinner', false);
                            
                            if (claimUpdateResponse['sobjectsAndStatus'] != undefined && claimUpdateResponse['sobjectsAndStatus'] != null &&
                                claimUpdateResponse['sobjectsAndStatus'].length != 0) {
                                
                                // take status object
                                var statusObject = claimUpdateResponse['sobjectsAndStatus'][0];
                                if (statusObject['status'] == 'successful') {
                                    
                                    // show the error message of claim not updated
                                    var alertboxContent = {
                                        message: $A.get("$Label.c.Claim_Updated_With_Comments_M"),
                                        heading: $A.get("$Label.c.Claim_Updated_With_Comments_H"),
                                        class: 'slds-theme--success',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    helper.showAlert(component, event, alertboxContent);
                                    
                                    //set the current claim as that returned after this insert transaction
                                    currentClaim['TravelByHours__c'] = statusObject['sObject']['TravelByHours__c'];
                                    currentClaim['TravelByDistance__c'] = statusObject['sObject']['TravelByDistance__c'];
                                    currentClaim['Total_Category1_Cost__c'] = statusObject['sObject']['Total_Category1_Cost__c'];
                                    currentClaim['Total_Category2_Cost__c'] = statusObject['sObject']['Total_Category2_Cost__c'];
                                    currentClaim['Fault_Code_Comment__c'] = statusObject['sObject']['Fault_Code_Comment__c'];
                                    currentClaim['CasualPart_Comments__c'] = statusObject['sObject']['CasualPart_Comments__c'];
                                    currentClaim['work_Performed_comments__c'] = statusObject['sObject']['work_Performed_comments__c'];
                                    currentClaim['Description__c'] = statusObject['sObject']['Description__c'];
                                    
                                    component.set('v.currentClaim', currentClaim);
                                    
                                } else {
                                    
                                    // show the error message of claim not updated
                                    var errorException = claimUpdateResponse['exception'];
                                    var errorArrays = claimUpdateResponse['errorList'];
                                    
                                    if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                    errorArrays != undefined && errorArrays.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Claim_Cannot_Be_Updated_H"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                }
                                
                            } else {
                                
                                // show the error message of claim not updated
                                var errorException = claimUpdateResponse['exception'];
                                var errorArrays = claimUpdateResponse['errorList'];
                                
                                if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                errorArrays != undefined && errorArrays.length != 0)) {
                                    
                                    var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                    
                                    var alertboxContent = {
                                        message: errorMessagesFormattedInString,
                                        heading: $A.get("$Label.c.Claim_Cannot_Be_Updated_H"),
                                        class: 'slds-theme--error',
                                        callableFunction: component.getReference('c.closeAlert'),
                                        buttonHeading: $A.get("$Label.c.OK")
                                    };
                                    helper.showAlert(component, event, alertboxContent);
                                    
                                }
                                
                            }
                            
                            
                        });
                        
                        
                    }
                    
                    
                    
                    break;
                }
                
        }
        
    },
    claimSummaryHandeler: function(component, event, helper) {
        
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        var componentId = event.getSource().getLocalId();
        
        switch (componentId) {
                
            case "Validate":
                {
                    
                    var claimBasicInfoValidated = helper.validateAccordionOpen(component, event, 'accordion-c-1-save');
                    if (claimBasicInfoValidated) {
                        
                        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                        var removedPartList = component.get('v.removedPartList');
                        if (removedPartList.length != 0) {
                            
                            //get the return lication of all the removed parts
                            var query = "select Id,Name,Warranty_Product__r.Id,Warranty_Product__r.Name,Shipment_Due_Date__c," +
                                "Inventory__r.Id,Inventory__r.Name,Part_Return_Configuration__r.Days_Due_Within__c,Quantity__c,Return_Location__r.Name " +
                                "from Removed_Claim_Part__c " +
                                "where Claim__c='" + currentClaim['Id'] + "' AND Return_Location__c!=null";
                            
                            //show the spinner
                            component.set('v.spinnerBool.pageSpinner', true);
                            
                            helper.readRaw(component, event, helper, query, function(toBeShippedPartsResponse) {
                                
                                if (toBeShippedPartsResponse["sObjectList"] != null && toBeShippedPartsResponse["sObjectList"] != undefined &&
                                    toBeShippedPartsResponse["sObjectList"].length != 0) {
                                    
                                    component.set('v.partsToBeShippedList', toBeShippedPartsResponse["sObjectList"]);
                                    
                                } else {
                                    
                                    component.set('v.partsToBeShippedList', []);
                                    
                                }
                                
                                
                                //update the policy definition
                                var updatePolicyDefinitionAction = component.get('c.updatePolicyDefinition');
                                updatePolicyDefinitionAction.setParams({
                                    claimId: currentClaim['Id']
                                });
                                updatePolicyDefinitionAction.setCallback(this, function(a) {
                                    
                                    var query = "Select Id,Name,Applicable_Policy__r.Id,Applicable_Policy__r.Name," +
                                        "Final_Claim_Cost__c,Total_Labor_Cost__c,Total_TravelByDistance_Cost__c," +
                                        "Total_Parts_Cost__c,Total_Meals_Cost__c,Total_Parking_Cost__c,Final_Labor_Cost__c," +
                                        "Final_TravelByDistance_Cost__c,Final_TravelByHours_Cost__c,Final_Parts_Cost__c,Final_Meals_Cost__c," +
                                        "Total_Category1_Cost__c,Final_Category1_Cost__c,Total_Category2_Cost__c,Final_Category2_Cost__c," +
                                        "Final_Parking_Cost__c,Total_TravelByHours_Cost__c,Parts_Profit__c from Claim__c " +
                                        "where Id='" + currentClaim['Id'] + "'";
                                    
                                    helper.readRaw(component, event, helper, query, function(claimWithPolicyDefinitionResponse) {
                                        
                                        if (claimWithPolicyDefinitionResponse["sObjectList"] != null && claimWithPolicyDefinitionResponse["sObjectList"] != undefined &&
                                            claimWithPolicyDefinitionResponse["sObjectList"].length != 0) {
                                            
                                            var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                                            var receivedClaim = claimWithPolicyDefinitionResponse["sObjectList"][0];
                                            
                                            currentClaim['Name'] = receivedClaim['Name'];
                                            currentClaim['Applicable_Policy__r'] = {};
                                            
                                            
                                            if (receivedClaim['Applicable_Policy__r'] !== null && receivedClaim['Applicable_Policy__r'] !== undefined) {
                                                currentClaim['Applicable_Policy__r']['Id'] = receivedClaim['Applicable_Policy__r']['Id'];
                                                currentClaim['Applicable_Policy__r']['Name'] = receivedClaim['Applicable_Policy__r']['Name'];
                                            } else {
                                                currentClaim['Applicable_Policy__r'] = null;
                                            }
                                            
                                            currentClaim['Total_Labor_Cost__c'] = receivedClaim['Total_Labor_Cost__c'];
                                            currentClaim['Final_Labor_Cost__c'] = receivedClaim['Final_Labor_Cost__c'];
                                            
                                            currentClaim['Total_TravelByDistance_Cost__c'] = receivedClaim['Total_TravelByDistance_Cost__c'];
                                            currentClaim['Final_TravelByDistance_Cost__c'] = receivedClaim['Final_TravelByDistance_Cost__c'];
                                            
                                            currentClaim['Total_TravelByHours_Cost__c'] = receivedClaim['Total_TravelByHours_Cost__c'];
                                            currentClaim['Final_TravelByHours_Cost__c'] = receivedClaim['Final_TravelByHours_Cost__c'];
                                            
                                            currentClaim['Total_Parts_Cost__c'] = receivedClaim['Total_Parts_Cost__c'];
                                            currentClaim['Final_Parts_Cost__c'] = receivedClaim['Final_Parts_Cost__c'];
                                            currentClaim['Parts_Profit__c'] = receivedClaim['Parts_Profit__c'];
                                            
                                            currentClaim['Total_Meals_Cost__c'] = receivedClaim['Total_Meals_Cost__c'];
                                            currentClaim['Final_Meals_Cost__c'] = receivedClaim['Final_Meals_Cost__c'];
                                            
                                            currentClaim['Total_Category1_Cost__c'] = receivedClaim['Total_Category1_Cost__c'];
                                            currentClaim['Final_Category1_Cost__c'] = receivedClaim['Final_Category1_Cost__c'];
                                            currentClaim['Total_Category2_Cost__c'] = receivedClaim['Total_Category2_Cost__c'];
                                            currentClaim['Final_Category2_Cost__c'] = receivedClaim['Final_Category2_Cost__c'];
                                            
                                            currentClaim['Total_Parking_Cost__c'] = receivedClaim['Total_Parking_Cost__c'];
                                            currentClaim['Final_Parking_Cost__c'] = receivedClaim['Final_Parking_Cost__c'];
                                            
                                            currentClaim['Final_Claim_Cost__c'] = receivedClaim['Final_Claim_Cost__c'];
                                            
                                            
                                            //set the updated claim
                                            component.set('v.currentClaim', currentClaim);
                                            
                                            var policyDefinition = receivedClaim['Applicable_Policy__r'];
                                            if (policyDefinition != undefined && policyDefinition != null) {
                                                component.set('v.applicablePolicy', policyDefinition);
                                            } else {
                                                component.set('v.applicablePolicy', policyDefinition);
                                            }
                                            
                                        }
                                        
                                        //hide the spinner
                                        component.set('v.spinnerBool.pageSpinner', false);
                                        
                                    });
                                    
                                });
                                $A.enqueueAction(updatePolicyDefinitionAction);
                                
                            });
                            
                        } else {
                            
                            //show the spinner
                            component.set('v.spinnerBool.pageSpinner', true);
                            
                            //get the return lication of all the removed parts - Added by siva
                            var query = "select Id,Name,Warranty_Product__r.Id,Warranty_Product__r.Name,Shipment_Due_Date__c," +
                                "Inventory__r.Id,Inventory__r.Name,Part_Return_Configuration__r.Days_Due_Within__c,Quantity__c,Return_Location__r.Name " +
                                "from Removed_Claim_Part__c " +
                                "where Claim__c='" + currentClaim['Id'] + "' AND Return_Location__c!=null";
                            helper.readRaw(component, event, helper, query, function(toBeShippedPartsResponse) {
                                if (toBeShippedPartsResponse["sObjectList"] != null && toBeShippedPartsResponse["sObjectList"] != undefined &&
                                    toBeShippedPartsResponse["sObjectList"].length != 0) {
                                    
                                    component.set('v.partsToBeShippedList', toBeShippedPartsResponse["sObjectList"]);
                                    
                                } else {
                                    
                                    component.set('v.partsToBeShippedList', []);
                                    
                                }
                            });
                            
                            //update the policy definition
                            var updatePolicyDefinitionAction = component.get('c.updatePolicyDefinition');
                            updatePolicyDefinitionAction.setParams({
                                claimId: currentClaim['Id']
                            });
                            
                            
                            updatePolicyDefinitionAction.setCallback(this, function(a) {
                                
                                var query = "Select Id,Name,Applicable_Policy__r.Id,Applicable_Policy__r.Name," +
                                    "Final_Claim_Cost__c,Total_Labor_Cost__c,Total_TravelByDistance_Cost__c," +
                                    "Total_Parts_Cost__c,Total_Meals_Cost__c,Total_Parking_Cost__c,Final_Labor_Cost__c," +
                                    "Final_TravelByDistance_Cost__c,Final_TravelByHours_Cost__c,Final_Parts_Cost__c,Final_Meals_Cost__c," +
                                    "Total_Category1_Cost__c,Final_Category1_Cost__c,Total_Category2_Cost__c,Final_Category2_Cost__c," +
                                    "Final_Parking_Cost__c,Total_TravelByHours_Cost__c,Parts_Profit__c from Claim__c " +
                                    "where Id='" + currentClaim['Id'] + "'";
                                
                                helper.readRaw(component, event, helper, query, function(claimWithPolicyDefinitionResponse) {
                                    
                                    if (claimWithPolicyDefinitionResponse["sObjectList"] != null && claimWithPolicyDefinitionResponse["sObjectList"] != undefined &&
                                        claimWithPolicyDefinitionResponse["sObjectList"].length != 0) {
                                        
                                        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
                                        var receivedClaim = claimWithPolicyDefinitionResponse["sObjectList"][0];
                                        
                                        
                                        currentClaim['Name'] = receivedClaim['Name'];
                                        currentClaim['Applicable_Policy__r'] = {};
                                        
                                        if (receivedClaim['Applicable_Policy__r'] !== null && receivedClaim['Applicable_Policy__r'] !== undefined) {
                                            currentClaim['Applicable_Policy__r']['Id'] = receivedClaim['Applicable_Policy__r']['Id'];
                                            currentClaim['Applicable_Policy__r']['Name'] = receivedClaim['Applicable_Policy__r']['Name'];
                                        } else {
                                            currentClaim['Applicable_Policy__r'] = null;
                                        }
                                        
                                        currentClaim['Total_Labor_Cost__c'] = receivedClaim['Total_Labor_Cost__c'];
                                        currentClaim['Final_Labor_Cost__c'] = receivedClaim['Final_Labor_Cost__c'];
                                        
                                        currentClaim['Total_TravelByDistance_Cost__c'] = receivedClaim['Total_TravelByDistance_Cost__c'];
                                        currentClaim['Final_TravelByDistance_Cost__c'] = receivedClaim['Final_TravelByDistance_Cost__c'];
                                        
                                        currentClaim['Total_TravelByHours_Cost__c'] = receivedClaim['Total_TravelByHours_Cost__c'];
                                        currentClaim['Final_TravelByHours_Cost__c'] = receivedClaim['Final_TravelByHours_Cost__c'];
                                        
                                        currentClaim['Total_Parts_Cost__c'] = receivedClaim['Total_Parts_Cost__c'];
                                        currentClaim['Final_Parts_Cost__c'] = receivedClaim['Final_Parts_Cost__c'];
                                        currentClaim['Parts_Profit__c'] = receivedClaim['Parts_Profit__c'];
                                        
                                        
                                        currentClaim['Total_Meals_Cost__c'] = receivedClaim['Total_Meals_Cost__c'];
                                        currentClaim['Final_Meals_Cost__c'] = receivedClaim['Final_Meals_Cost__c'];
                                        
                                        
                                        currentClaim['Total_Parking_Cost__c'] = receivedClaim['Total_Parking_Cost__c'];
                                        currentClaim['Final_Parking_Cost__c'] = receivedClaim['Final_Parking_Cost__c'];
                                        
                                        currentClaim['Total_Category1_Cost__c'] = receivedClaim['Total_Category1_Cost__c'];
                                        currentClaim['Final_Category1_Cost__c'] = receivedClaim['Final_Category1_Cost__c'];
                                        currentClaim['Total_Category2_Cost__c'] = receivedClaim['Total_Category2_Cost__c'];
                                        currentClaim['Final_Category2_Cost__c'] = receivedClaim['Final_Category2_Cost__c'];
                                        
                                        
                                        currentClaim['Final_Claim_Cost__c'] = receivedClaim['Final_Claim_Cost__c'];
                                        
                                        //set the updated claim
                                        component.set('v.currentClaim', currentClaim);
                                        
                                        var policyDefinition = receivedClaim['Applicable_Policy__r'];
                                        if (policyDefinition != undefined && policyDefinition != null) {
                                            component.set('v.applicablePolicy', policyDefinition);
                                        } else {
                                            component.set('v.applicablePolicy', policyDefinition);
                                        }
                                        
                                    }
                                    
                                    //hide the spinner
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    
                                });
                                
                            });
                            $A.enqueueAction(updatePolicyDefinitionAction);
                            
                        }
                        
                        
                        
                    } else {
                        
                        //show the error messsage that claim not fit for validation
                        var alertboxContent = {
                            message: $A.get("$Label.c.Review_Error_Messages_M"),
                            heading: $A.get("$Label.c.Claim_Alert_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        helper.showAlert(component, event, alertboxContent);
                        
                    }
                    
                    
                    
                    
                    break;
                }
                
            case "Proceed":
                {
                    
                    var site = component.get('v.site');
                    var urlEvent = $A.get("e.force:navigateToURL");
                    var redirectUrl = '';
                    
                    if (urlEvent !== undefined && urlEvent !== null) {
                        
                        if (site !== '' && site !== null && site !== undefined) {
                            redirectUrl += site + '/' + currentClaim['Id']
                        } else {
                            redirectUrl += '/' + currentClaim['Id']
                        }
                        
                        urlEvent.setParams({
                            "url": redirectUrl
                        });
                        urlEvent.fire();
                        
                    } else {
                        ///added on 17-NOV-2016///
                        
                        if (site !== '' && site !== null && site !== undefined) {
                            redirectUrl += site + '/' + currentClaim['Id']
                        } else {
                            redirectUrl += '/' + currentClaim['Id']
                        }
                        window.location.href = redirectUrl;
                        ///--added on 17-NOV-2016///
                        
                    }
                    
                    
                    break;
                }
                
        }
        
    },
    
    /*** previous accordion validator methods ***/
    validateAccordionOpen: function(component, event, helper) {
        
        var currentClaim = JSON.parse(JSON.stringify(component.get('v.currentClaim')));
        
        var accordionId;
        
        // dom event or aura event
        if (event.target != undefined) {
            accordionId = event.target.id;
        } else {
            accordionId = event.getSource().getLocalId();
        }
        
        
        // process on the basis of acccordion
        switch (accordionId) {
                
            case "accordion-c-1":
                {
                    
                    // first accordion body
                    var claimInfotab = component.find('accordion-c-1-body');
                    
                    if ($A.util.hasClass(claimInfotab, 'tab-close')) {
                        
                        $A.util.removeClass(claimInfotab, 'tab-close');
                        $A.util.addClass(claimInfotab, 'tab-open');
                        
                    } else if ($A.util.hasClass(claimInfotab, 'tab-open')) {
                        
                        $A.util.removeClass(claimInfotab, 'tab-open');
                        $A.util.addClass(claimInfotab, 'tab-close');
                        
                    } else {
                        
                        // no case till now
                        
                    }
                    
                    
                    
                    break;
                }
                
            case "accordion-c-1-save":
                {
                    
                    // get this status from component error object
                    var accordionValidated = helper.validateAccordionOpen(component, event, accordionId);
                    
                    // target accordions
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    var installedAndremovedPartsTab = component.find('accordion-c-4-body');
                    var additionalInfoTab = component.find('accordion-c-5-body');
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    
                    var closeAccordionList = [claimBasicInfoTab];
                    var openAccordionList = [claimServiceInfoTab, installedAndremovedPartsTab, additionalInfoTab];
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        $A.util.addClass(claimServiceInfoTab, 'tab-close');
                        helper.showAlert(component, event, alertboxContent);
                        
                    } else {
                        
                        //fill picklist values in claim
                        currentClaim = helper.fillPickListValuesInClaim(component, currentClaim);
                        currentClaim['sobjectType'] = 'Claim__c';
                        
                        //show the page spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        
                        // find the duplicate recent claim
                        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                        var queryForDuplicateFinder;
                        
                        if (claimCustomRecordTypeName === 'Serialized' || claimCustomRecordTypeName === 'Field Modification') {
                            queryForDuplicateFinder = "select Id from Claim__c where Causal_Part_Number__c='" +
                                currentClaim['Causal_Part_Number__c'] + "' AND Inventory__c='" + currentClaim['Inventory__c'] + "' " +
                                "AND CreatedDate=LAST_N_DAYS:" + component.get('v.customSettingManager.Period_In_Days_For_Duplicate_Claim') + " " +
                                "AND Inventory__c!=null AND Causal_Part_Number__c!=null ORDER BY CreatedDate DESC LIMIT 1";
                        } else {
                            queryForDuplicateFinder = "select Id from Claim__c where Causal_Part_Number__c='" +
                                currentClaim['Causal_Part_Number__c'] + "' AND Warranty_Product__c='" + currentClaim['Warranty_Product__c'] + "' " +
                                "AND CreatedDate=LAST_N_DAYS:" + component.get('v.customSettingManager.Period_In_Days_For_Duplicate_Claim') + " " +
                                "AND Warranty_Product__c!=null AND Causal_Part_Number__c!=null ORDER BY CreatedDate DESC LIMIT 1";
                        }
                        
                        helper.readRaw(component, event, helper, queryForDuplicateFinder, function(duplicateClaimresponse) {
                            
                            var sobjectList = duplicateClaimresponse['sObjectList'];
                            if (sobjectList !== null && sobjectList !== undefined &&
                                Array.isArray(sobjectList) && sobjectList.length !== 0) {
                                currentClaim['Duplicate_Claim__c'] = sobjectList[0]['Id'];
                            } else {
                                currentClaim['Duplicate_Claim__c'] = '';
                            } 
                            if(claimCustomRecordTypeName === 'Preventive Maintenance'){
                                currentClaim['Date_of_Repair__c'] = currentClaim['Date_of_Failure__c'];
                                currentClaim['Claim_Record_Type__c'] = 'Preventive Maintenance';
                            }
                            // insert the claim
                            helper.insertRaw(component, event, helper, currentClaim, function(claimInsertResponse) {
                                
                                if (claimInsertResponse['sobjectsAndStatus'] != undefined && claimInsertResponse['sobjectsAndStatus'] != null &&
                                    claimInsertResponse['sobjectsAndStatus'].length != 0) {
                                    
                                    // take status object
                                    var statusObject = claimInsertResponse['sobjectsAndStatus'][0];
                                    
                                    if (statusObject['status'] == 'successful') {
                                        var insertedClaimId = statusObject['sObject']['Id'];
                                        
                                        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                                        
                                        
                                        if(claimCustomRecordTypeName == 'Preventive Maintenance'){
                                            var selectedPreventiveMaintainanceRule = component.find('upcomingScheduler').get('v.value');
                                            helper.upadteInventoryRuleSchedule(component,insertedClaimId,selectedPreventiveMaintainanceRule);   
                                            
                                            var currentClaimId = currentClaim['Id'];
                                            helper.fetchUpcomingScheduleForClaim(component,insertedClaimId);
                                            
                                            var claimTemplate = component.get('v.claimTemp');
                                            
                                            claimTemplate = claimTemplate == undefined || claimTemplate == null ? null : claimTemplate;
                                            
                                            if (claimTemplate != null) {
                                                
                                                var claimTemplateId = claimTemplate['Id'];
                                                var deepCloneAction = component.get('c.deepCloneTemplateToFieldMod');
                                                deepCloneAction.setParams({
                                                    claimTemplateId: claimTemplateId,
                                                    fieldModClaimId: statusObject['sObject']['Id']
                                                });
                                                
                                                deepCloneAction.setCallback(this, function(response) {
                                                    
                                                    //hide the page spinner
                                                    component.set('v.spinnerBool.pageSpinner', false);
                                                    
                                                    var state = response.getState();
                                                    
                                                    if (state === "SUCCESS") {
                                                        var returnedValue = response.getReturnValue();
                                                        var relatedObjectList = JSON.parse(returnedValue);
                                                        
                                                        //set the related list with values
                                                        component.set('v.installedPartList', relatedObjectList['Installed Parts']);
                                                        component.set('v.removedPartList', relatedObjectList['Removed Parts']);
                                                        component.set('v.nonOEMPartList', relatedObjectList['Non-OEM parts']);
                                                        component.set('v.claimServiceInfoList', relatedObjectList['Claim Service Infos']);
                                                        
                                                        
                                                        // show the message of claim successfully created
                                                        var alertboxContent = {
                                                            message: $A.get("$Label.c.Claim_Saved_M"),
                                                            heading: $A.get("$Label.c.Claim_Saved_H"),
                                                            class: 'slds-theme--success',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        helper.showAlert(component, event, alertboxContent);
                                                        
                                                        //set the isEdit as true because claim is saved at this point
                                                        component.set('v.isEdit', true);
                                                        
                                                        //set the current claim as that returned after this insert transaction
                                                        component.set('v.currentClaim', statusObject['sObject']);
                                                        
                                                        //disable the dealer
                                                        component.set('v.isDealerEditable', false);
                                                        
                                                        //set the accordion 2 validation to true
                                                        component.set('v.accordionValidationIndicator.accordion1', true);
                                                        
                                                        //disable the save button after this transaction
                                                        //component.find('accordion-c-1-save').set('v.disabled', true);
                                                        
                                                        helper.bulkCloseOrOpenAccordion(component, openAccordionList, closeAccordionList);
                                                        
                                                    } else {
                                                        
                                                        // show the message of claim successfully created
                                                        var alertboxContent = {
                                                            message: $A.get("$Label.c.Claim_Saved_M"),
                                                            heading: $A.get("$Label.c.Claim_Saved_H"),
                                                            class: 'slds-theme--success',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        helper.showAlert(component, event, alertboxContent);
                                                        
                                                        //set the isEdit as true because claim is saved at this point
                                                        component.set('v.isEdit', true);
                                                        
                                                        //set the current claim as that returned after this insert transaction
                                                        component.set('v.currentClaim', statusObject['sObject']);
                                                        
                                                        //set the accordion 2 validation to true
                                                        component.set('v.accordionValidationIndicator.accordion1', true);
                                                        
                                                        //disable the save button after this transaction
                                                        component.find('accordion-c-1-save').set('v.disabled', true);
                                                        
                                                        
                                                        helper.bulkCloseOrOpenAccordion(component, openAccordionList, closeAccordionList);
                                                        
                                                    }
                                                    
                                                });
                                                $A.enqueueAction(deepCloneAction);
                                            }
                                            
                                            //component.set('v.isInventoryScheduleEditable', false);
                                            /*var inventoryScheduleList = component.get('v.inventoryScheduleList');
                                            console.log(inventoryScheduleList);
                                            console.log(selectedPreventiveMaintainanceRule);
                                            //var selectedPreventiveMaintainanceRuleList = component.find('upcomingScheduler').get('v.value');
                                            for(var i=0;i<inventoryScheduleList.length;i++){
                                                console.log(inventoryScheduleList[i]['Name']);
                                                if(selectedPreventiveMaintainanceRule === inventoryScheduleList[i]['Id']){
                                                    console.log('in if');
                                                    component.set('v.selectedSchedule',inventoryScheduleList[i]['Name']);
                                                }
                                            }*/
                                            
                                            
                                        }
                                        
                                        
                                        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                                        if (claimCustomRecordTypeName == 'Field Modification') {
                                            
                                            //fetch all the related list from claim template and add to this claim
                                            var campaignMember = JSON.parse(JSON.stringify(component.get('v.campaignMember')));
                                            var claimTemplate = campaignMember["Service_Campaign__r"]["Claim_Template__r"];
                                            claimTemplate = claimTemplate == undefined || claimTemplate == null ? null : claimTemplate;
                                            
                                            if (claimTemplate != null) {
                                                
                                                var claimTemplateId = claimTemplate['Id'];
                                                var deepCloneAction = component.get('c.deepCloneTemplateToFieldMod');
                                                deepCloneAction.setParams({
                                                    claimTemplateId: claimTemplateId,
                                                    fieldModClaimId: statusObject['sObject']['Id']
                                                });
                                                
                                                deepCloneAction.setCallback(this, function(response) {
                                                    
                                                    //hide the page spinner
                                                    component.set('v.spinnerBool.pageSpinner', false);
                                                    
                                                    var state = response.getState();
                                                    
                                                    if (state === "SUCCESS") {
                                                        var returnedValue = response.getReturnValue();
                                                        var relatedObjectList = JSON.parse(returnedValue);
                                                        
                                                        //set the related list with values
                                                        component.set('v.installedPartList', relatedObjectList['Installed Parts']);
                                                        component.set('v.removedPartList', relatedObjectList['Removed Parts']);
                                                        component.set('v.nonOEMPartList', relatedObjectList['Non-OEM parts']);
                                                        component.set('v.claimServiceInfoList', relatedObjectList['Claim Service Infos']);
                                                        
                                                        
                                                        // show the message of claim successfully created
                                                        var alertboxContent = {
                                                            message: $A.get("$Label.c.Claim_Saved_M"),
                                                            heading: $A.get("$Label.c.Claim_Saved_H"),
                                                            class: 'slds-theme--success',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        helper.showAlert(component, event, alertboxContent);
                                                        
                                                        //set the isEdit as true because claim is saved at this point
                                                        component.set('v.isEdit', true);
                                                        
                                                        //set the current claim as that returned after this insert transaction
                                                        component.set('v.currentClaim', statusObject['sObject']);
                                                        
                                                        //disable the dealer
                                                        component.set('v.isDealerEditable', false);
                                                        
                                                        //set the accordion 2 validation to true
                                                        component.set('v.accordionValidationIndicator.accordion1', true);
                                                        
                                                        //disable the save button after this transaction
                                                        component.find('accordion-c-1-save').set('v.disabled', true);
                                                        
                                                        helper.bulkCloseOrOpenAccordion(component, openAccordionList, closeAccordionList);
                                                        
                                                    } else {
                                                        
                                                        // show the message of claim successfully created
                                                        var alertboxContent = {
                                                            message: $A.get("$Label.c.Claim_Saved_M"),
                                                            heading: $A.get("$Label.c.Claim_Saved_H"),
                                                            class: 'slds-theme--success',
                                                            callableFunction: component.getReference('c.closeAlert'),
                                                            buttonHeading: $A.get("$Label.c.OK")
                                                        };
                                                        helper.showAlert(component, event, alertboxContent);
                                                        
                                                        //set the isEdit as true because claim is saved at this point
                                                        component.set('v.isEdit', true);
                                                        
                                                        //set the current claim as that returned after this insert transaction
                                                        component.set('v.currentClaim', statusObject['sObject']);
                                                        
                                                        //set the accordion 2 validation to true
                                                        component.set('v.accordionValidationIndicator.accordion1', true);
                                                        
                                                        //disable the save button after this transaction
                                                        component.find('accordion-c-1-save').set('v.disabled', true);
                                                        
                                                        
                                                        helper.bulkCloseOrOpenAccordion(component, openAccordionList, closeAccordionList);
                                                        
                                                    }
                                                    
                                                });
                                                $A.enqueueAction(deepCloneAction);
                                            }
                                            
                                        } else {
                                            
                                            component.set('v.spinnerBool.pageSpinner', false);
                                            
                                            // show the message of claim successfully created
                                            /*var alertboxContent = {
                                                message: $A.get("$Label.c.Claim_Saved_M"),
                                                heading: $A.get("$Label.c.Claim_Saved_H"),
                                                class: 'slds-theme--success',
                                                callableFunction: component.getReference('c.closeAlert'),
                                                buttonHeading: $A.get("$Label.c.OK")
                                            };
                                            helper.showAlert(component, event, alertboxContent);
                                            */
                                            //set the isEdit as true because claim is saved at this point
                                            component.set('v.isEdit', true);
                                            
                                            //set the current claim as that returned after this insert transaction
                                            component.set('v.currentClaim', statusObject['sObject']);
                                            
                                            ///18-NOV-2016///
                                            //disable the dealer
                                            component.set('v.isDealerEditable', false);
                                            ///--18-NOV-2016///
                                            
                                            //set the accordion 2 validation to true
                                            component.set('v.accordionValidationIndicator.accordion1', true);
                                            
                                            //disable the save button after this transaction
                                            component.find('accordion-c-1-save').set('v.disabled', true);
                                            
                                            helper.bulkCloseOrOpenAccordion(component, openAccordionList, closeAccordionList);
                                            
                                            
                                        }
                                        
                                    } else {
                                        
                                        component.set('v.spinnerBool.pageSpinner', false);
                                        
                                        // show the error message of claim cannot be saved
                                        var errorException = claimInsertResponse['exception'];
                                        var errorArrays = claimInsertResponse['errorArrays'];
                                        
                                        if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                        errorArrays != undefined && errorArrays.length != 0)) {
                                            
                                            var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                            
                                            var alertboxContent = {
                                                message: errorMessagesFormattedInString,
                                                heading: $A.get("$Label.c.Claim_Not_Saved_H"),
                                                class: 'slds-theme--error',
                                                callableFunction: component.getReference('c.closeAlert'),
                                                buttonHeading: $A.get("$Label.c.OK")
                                            };
                                            helper.showAlert(component, event, alertboxContent);
                                            
                                            
                                            //set the isEdit as false because claim is saved at this point
                                            component.set('v.isEdit', false);
                                            
                                            //set the accordion 1 validation to false
                                            component.set('v.accordionValidationIndicator.accordion1', false);
                                            
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    // show the error message of claim cannot be saved
                                    var errorException = claimInsertResponse['exception'];
                                    var errorArrays = claimInsertResponse['errorArrays'];
                                    
                                    if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                    errorArrays != undefined && errorArrays.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Claim_Not_Saved_H"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                        
                                        //set the isEdit as false because claim is saved at this point
                                        component.set('v.isEdit', false);
                                        
                                        //set the accordion 1 validation to false
                                        component.set('v.accordionValidationIndicator.accordion1', false);
                                        
                                    }
                                    
                                }
                                
                            });
                            
                        });
                        
                    }
                    
                    
                    break;
                }
                
            case "accordion-c-1-update":
                {
                    
                    // get this status from component error object
                    var accordionValidated = helper.validateAccordionOpen(component, event, 'accordion-c-1-save');
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Info_Update_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        helper.showAlert(component, event, alertboxContent);
                        
                    } else {
                        
                        //set some variables
                        delete currentClaim['sobjectType'];
                        currentClaim['Date_Of_Purchase__c'] = component.get('v.purchaseDate');
                        //fill picklist values in claim
                        currentClaim = helper.fillPickListValuesInClaim(component, currentClaim);
                        
                        //show the page spinner
                        component.set('v.spinnerBool.pageSpinner', true);
                        
                        // find the duplicate recent claim
                        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                        var queryForDuplicateFinder;
                        
                        if (claimCustomRecordTypeName === 'Serialized' || claimCustomRecordTypeName === 'Field Modification') {
                            queryForDuplicateFinder = "select Id from Claim__c where Causal_Part_Number__c='" +
                                currentClaim['Causal_Part_Number__c'] + "' AND Inventory__c='" + currentClaim['Inventory__c'] + "' " +
                                "AND CreatedDate=LAST_N_DAYS:" + component.get('v.customSettingManager.Period_In_Days_For_Duplicate_Claim') + " " +
                                "AND Inventory__c!=null AND Causal_Part_Number__c!=null AND Id!='" + currentClaim['Id'] + "' ORDER BY CreatedDate DESC LIMIT 1";
                        } else {
                            queryForDuplicateFinder = "select Id from Claim__c where Causal_Part_Number__c='" +
                                currentClaim['Causal_Part_Number__c'] + "' AND Warranty_Product__c='" + currentClaim['Warranty_Product__c'] + "' " +
                                "AND CreatedDate=LAST_N_DAYS:" + component.get('v.customSettingManager.Period_In_Days_For_Duplicate_Claim') + " " +
                                "AND Warranty_Product__c!=null AND Causal_Part_Number__c!=null AND Id!='" + currentClaim['Id'] + "' ORDER BY CreatedDate DESC LIMIT 1";
                        }
                        
                        helper.readRaw(component, event, helper, queryForDuplicateFinder, function(duplicateClaimresponse) {
                            
                            var sobjectList = duplicateClaimresponse['sObjectList'];
                            if (sobjectList !== null && sobjectList !== undefined &&
                                Array.isArray(sobjectList) && sobjectList.length !== 0) {
                                currentClaim['Duplicate_Claim__c'] = sobjectList[0]['Id'];
                            } else {
                                currentClaim['Duplicate_Claim__c'] = '';
                            }
                            
                            //remove date of purchase
                            if (claimCustomRecordTypeName !== 'Non-Serialized') {
                                currentClaim['Date_Of_Purchase__c'] = null;
                            }
                            
                            helper.updateRaw(component, event, helper, currentClaim, function(claimUpdateResponse) {
                                
                                if (claimUpdateResponse['sobjectsAndStatus'] != undefined && claimUpdateResponse['sobjectsAndStatus'] != null &&
                                    claimUpdateResponse['sobjectsAndStatus'].length != 0) {
                                    
                                    // take status object
                                    var statusObject = claimUpdateResponse['sobjectsAndStatus'][0];
                                    if (statusObject['status'] == 'successful') {
                                        
                                        //update the policy definition
                                        var updatePolicyDefinitionAction = component.get('c.updatePolicyDefinition');
                                        updatePolicyDefinitionAction.setParams({
                                            claimId: currentClaim['Id']
                                        });
                                        updatePolicyDefinitionAction.setCallback(this, function(a) {
                                            
                                            var removedPartList = JSON.parse(JSON.stringify(component.get('v.removedPartList')));
                                            
                                            if (removedPartList !== null && removedPartList !== undefined && removedPartList.length !== 0) {
                                                
                                                //update the removed parts to fire PRC
                                                helper.updateRaw(component, event, helper, removedPartList,
                                                                 function(removedPartsUpdateresponse) {
                                                                     
                                                                     component.set('v.spinnerBool.pageSpinner', false);
                                                                     // show the alert of claim updated
                                                                     var alertboxContent = {
                                                                         message: $A.get("$Label.c.Claim_Updated_M"),
                                                                         heading: $A.get("$Label.c.Claim_Updated_H"),
                                                                         class: 'slds-theme--success',
                                                                         callableFunction: component.getReference('c.closeAlert'),
                                                                         buttonHeading: $A.get("$Label.c.OK")
                                                                     };
                                                                     helper.showAlert(component, event, alertboxContent);
                                                                     
                                                                     //set the current claim as that returned after this insert transaction
                                                                     component.set('v.currentClaim', statusObject['sObject']);
                                                                     
                                                                 });
                                                
                                            } else {
                                                
                                                component.set('v.spinnerBool.pageSpinner', false);
                                                // show the alert of claim updated
                                                var alertboxContent = {
                                                    message: $A.get("$Label.c.Claim_Updated_M"),
                                                    heading: $A.get("$Label.c.Claim_Updated_H"),
                                                    class: 'slds-theme--success',
                                                    callableFunction: component.getReference('c.closeAlert'),
                                                    buttonHeading: $A.get("$Label.c.OK")
                                                };
                                                helper.showAlert(component, event, alertboxContent);
                                                
                                                //set the current claim as that returned after this insert transaction
                                                component.set('v.currentClaim', statusObject['sObject']);
                                                
                                            }
                                            
                                        });
                                        $A.enqueueAction(updatePolicyDefinitionAction);
                                        
                                    } else {
                                        
                                        // show the alert of claim cannot be updated
                                        var errorException = claimUpdateResponse['exception'];
                                        var errorArrays = claimUpdateResponse['errorList'];
                                        component.set('v.spinnerBool.pageSpinner', false);
                                        if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                        errorArrays != undefined && errorArrays.length != 0)) {
                                            
                                            var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                            
                                            var alertboxContent = {
                                                message: errorMessagesFormattedInString,
                                                heading: $A.get("$Label.c.Claim_Cannot_Be_Updated_H"),
                                                class: 'slds-theme--error',
                                                callableFunction: component.getReference('c.closeAlert'),
                                                buttonHeading: $A.get("$Label.c.OK")
                                            };
                                            helper.showAlert(component, event, alertboxContent);
                                            
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    // show the alert of claim cannot be updated
                                    var errorException = claimUpdateResponse['exception'];
                                    var errorArrays = claimUpdateResponse['errorList'];
                                    component.set('v.spinnerBool.pageSpinner', false);
                                    if ((errorException != null && errorException != undefined) || (errorArrays != null &&
                                                                                                    errorArrays != undefined && errorArrays.length != 0)) {
                                        
                                        var errorMessagesFormattedInString = helper.getErrorMessage(errorException, errorArrays);
                                        
                                        var alertboxContent = {
                                            message: errorMessagesFormattedInString,
                                            heading: $A.get("$Label.c.Claim_Cannot_Be_Updated_H"),
                                            class: 'slds-theme--error',
                                            callableFunction: component.getReference('c.closeAlert'),
                                            buttonHeading: $A.get("$Label.c.OK")
                                        };
                                        helper.showAlert(component, event, alertboxContent);
                                        
                                    }
                                    
                                }
                                
                                
                            });
                            
                            
                        });
                    }
                    
                    
                    break;
                }
                
            case "accordion-c-3":
                {
                    
                    // get this status from component error object
                    var accordionValidated = component.get('v.accordionValidationIndicator.accordion1');
                    
                    // target accordion
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        $A.util.addClass(claimServiceInfoTab, 'tab-close');
                        helper.showAlert(component, event, alertboxContent);
                        
                    } else {
                        
                        // handle after insert
                        if ($A.util.hasClass(claimServiceInfoTab, 'tab-close')) {
                            
                            // open next accordion
                            $A.util.removeClass(claimServiceInfoTab, 'tab-close');
                            $A.util.addClass(claimServiceInfoTab, 'tab-open');
                            
                            // close all previous accordions
                            if ($A.util.hasClass(claimBasicInfoTab, 'tab-open')) {
                                $A.util.removeClass(claimBasicInfoTab, 'tab-open');
                                $A.util.addClass(claimBasicInfoTab, 'tab-close');
                            }
                            
                        } else if ($A.util.hasClass(claimServiceInfoTab, 'tab-open')) {
                            
                            // if already open,close
                            $A.util.removeClass(claimServiceInfoTab, 'tab-open');
                            $A.util.addClass(claimServiceInfoTab, 'tab-close');
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    break;
                }
                
            case "accordion-c-4":
                {
                    
                    // get this status from component error object
                    var accordionValidated = component.get('v.accordionValidationIndicator.accordion1');
                    
                    // target accordion
                    var installedAndremovedPartsTab = component.find('accordion-c-4-body');
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        $A.util.addClass(claimServiceInfoTab, 'tab-close');
                        helper.showAlert(component, event, alertboxContent);
                        
                    } else {
                        
                        if ($A.util.hasClass(installedAndremovedPartsTab, 'tab-close')) {
                            
                            $A.util.removeClass(installedAndremovedPartsTab, 'tab-close');
                            $A.util.addClass(installedAndremovedPartsTab, 'tab-open');
                            
                        } else if ($A.util.hasClass(installedAndremovedPartsTab, 'tab-open')) {
                            
                            $A.util.removeClass(installedAndremovedPartsTab, 'tab-open');
                            $A.util.addClass(installedAndremovedPartsTab, 'tab-close');
                            
                        } else {
                            
                            $A.util.addClass(installedAndremovedPartsTab, 'tab-open');
                            
                            // close all previous accordions
                            $A.util.addClass(claimServiceInfoTab, 'tab-close');
                            $A.util.addClass(claimBasicInfoTab, 'tab-close');
                            
                        }
                        
                    }
                    
                    break;
                    
                }
                
            case "accordion-c-5":
                {
                    
                    // get this status from component error object
                    var accordionValidated = component.get('v.accordionValidationIndicator.accordion1');
                    
                    // target accordion
                    var additionalInfoTab = component.find("accordion-c-5-body");
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    var installedAndremovedPartsTab = component.find('accordion-c-4-body');
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        $A.util.addClass(additionalInfoTab, 'tab-close');
                        helper.showAlert(component, event, alertboxContent);
                        
                        
                    } else {
                        
                        if ($A.util.hasClass(additionalInfoTab, 'tab-close')) {
                            
                            $A.util.removeClass(additionalInfoTab, 'tab-close');
                            $A.util.addClass(additionalInfoTab, 'tab-open');
                            
                        } else if ($A.util.hasClass(additionalInfoTab, 'tab-open')) {
                            
                            $A.util.removeClass(additionalInfoTab, 'tab-open');
                            $A.util.addClass(additionalInfoTab, 'tab-close');
                            
                        } else {
                            
                            $A.util.addClass(additionalInfoTab, 'tab-open');
                            
                            // close all previous accordions
                            $A.util.addClass(claimBasicInfoTab, 'tab-close');
                            $A.util.addClass(claimServiceInfoTab, 'tab-close');
                            $A.util.addClass(installedAndremovedPartsTab, 'tab-close');
                            
                        }
                        
                        
                    }
                    break;
                    
                }
                
            case "accordion-c-6":
                {
                    
                    // get this status from component error object
                    var accordionValidated = helper.validateAccordionOpen(component, event, accordionId);
                    
                    // target accordion
                    var claimSummarytab = component.find("accordion-c-6-body");
                    
                    // previous accordions
                    var claimBasicInfoTab = component.find('accordion-c-1-body');
                    var claimServiceInfoTab = component.find('accordion-c-3-body');
                    var installedAndremovedPartsTab = component.find("accordion-c-4-body");
                    var additionalInfoTab = component.find("accordion-c-5-body");
                    
                    
                    if (!accordionValidated) {
                        
                        // show the error message of previous accordion not validated
                        var alertboxContent = {
                            message: $A.get("$Label.c.Incomplete_Claim_Information_Save_M"),
                            heading: $A.get("$Label.c.Incomplete_Claim_Information_Save_H"),
                            class: 'slds-theme--error',
                            callableFunction: component.getReference('c.closeAlert'),
                            buttonHeading: $A.get("$Label.c.OK")
                        };
                        
                        $A.util.addClass(claimSummarytab, 'tab-close');
                        helper.showAlert(component, event, alertboxContent);
                        
                        
                    } else {
                        
                        if ($A.util.hasClass(claimSummarytab, 'tab-close')) {
                            
                            $A.util.removeClass(claimSummarytab, 'tab-close');
                            $A.util.addClass(claimSummarytab, 'tab-open');
                            
                        } else if ($A.util.hasClass(claimSummarytab, 'tab-open')) {
                            
                            $A.util.removeClass(claimSummarytab, 'tab-open');
                            $A.util.addClass(claimSummarytab, 'tab-close');
                            
                        } else {
                            
                            $A.util.addClass(claimSummarytab, 'tab-open');
                            
                            // close all previous accordions
                            $A.util.addClass(claimBasicInfoTab, 'tab-close');
                            $A.util.addClass(claimServiceInfoTab, 'tab-close');
                            $A.util.addClass(installedAndremovedPartsTab, 'tab-close');
                            $A.util.addClass(additionalInfoTab, 'tab-close');
                            
                        }
                        
                        
                    }
                    
                    break;
                }
                
        }
        
        
        
    },
    
    /*** alert message methods ***/
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
    
    /*** Error Filler ***/
    fillError: function(component, event, helper) {
        
        var sourceId = event.getSource().getLocalId();
        
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        switch (sourceId) {
                
            case 'dealer':
                {
                    
                    var textValue = event.getParam('textValue');
                    
                    if (claimCustomRecordTypeName != 'Claim Template') {
                        
                        if (textValue == '') {
                            component.set('v.error.accordion1.fieldError.dealer', $A.get("$Label.c.Dealer_Not_Selected"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                        } else {
                            
                            var dealer = JSON.parse(JSON.stringify(component.get('v.dealer')));
                            
                            if (dealer != null) {
                                
                                if (textValue !== dealer['Name']) {
                                    component.set('v.error.accordion1.fieldError.dealer', $A.get("$Label.c.Dealer_Entry_Not_Correct"));
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                } else {
                                    component.set('v.error.accordion1.fieldError.dealer', '');
                                }
                                
                            } else {
                                
                                //handle blur event
                                component.set('v.error.accordion1.fieldError.dealer', $A.get("$Label.c.Dealer_Entry_Not_Correct"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    break;
                }
            case 'upcomingScheduler':
                {
                    
                    var textValue = event.getSource().get('v.value');//sourceId.get('v.value');
                    
                    if (claimCustomRecordTypeName == 'Preventive Maintenance') {
                        
                        if (textValue == '') {
                            component.set('v.error.accordion1.fieldError.upcomingScheduler', $A.get("$Label.c.Upcoming_Scheduler_Entry_Not_Correct"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                        } else {
                            
                            //var dealer = JSON.parse(JSON.stringify(component.get('v.upcomingScheduler')));
                            var schedule = component.find('upcomingScheduler').get('v.value');
                            
                            if (schedule != null) {
                                
                                if (textValue !== schedule) {
                                    component.set('v.error.accordion1.fieldError.upcomingScheduler', $A.get("$Label.c.Upcoming_Scheduler_Entry_Not_Correct"));
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                } else {
                                    component.set('v.error.accordion1.fieldError.upcomingScheduler', '');
                                }
                                
                            } else {
                                
                                //handle blur event
                                component.set('v.error.accordion1.fieldError.upcomingScheduler', $A.get("$Label.c.Upcoming_Scheduler_Entry_Not_Correct"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    break;
                }
                
            case 'inventory':
                {
                    
                    var textValue = event.getParam('textValue');
                    
                    if (claimCustomRecordTypeName == 'Serialized' || claimCustomRecordTypeName == 'Field Modification') {
                        
                        if (textValue == '') {
                            component.set('v.error.accordion1.fieldError.inventory', $A.get("$Label.c.Inventory_Not_Selected"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                            // unset all the values filled by inventory
                            component.set('v.unitType', "");
                            component.set('v.currentClaim.Date_Of_Purchase__c', helper.getTodayDate(component, event));
                            component.set('v.currentClaim.Units_Run__c', 0);
                            component.set('v.inventory', null);
                            
                            //disable the causal part and fault code make it empty
                            var causalPartComponent = component.find('causalPart');
                            if (causalPartComponent !== null && causalPartComponent !== undefined) {
                                if (typeof(causalPartComponent.set) == 'function') {
                                    causalPartComponent.set('v.objectName', '');
                                    causalPartComponent.set('v.disabled', true);
                                    component.set('v.causalPart', null);
                                    component.set('v.currentClaim.Fault_Code__c', '');
                                    
                                    helper.setFaultCodePicklistOptions(component, [], -1);
                                    
                                }
                            }
                            
                        } else {
                            
                            var inventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                            
                            if (inventory != null) {
                                
                                if (textValue !== inventory['Name']) {
                                    component.set('v.error.accordion1.fieldError.inventory', $A.get("$Label.c.Inventory_Not_Correct"));
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                    
                                    // unset all the values filled by inventory
                                    component.set('v.unitType', "");
                                    component.set('v.currentClaim.Date_Of_Purchase__c', helper.getTodayDate(component, event));
                                    component.set('v.currentClaim.Units_Run__c', 0);
                                    component.set('v.inventory', null);
                                    
                                    //enable the causal part and fault code make it empty
                                    var causalPartComponent = component.find('causalPart');
                                    if (causalPartComponent !== null && causalPartComponent !== undefined) {
                                        if (typeof(causalPartComponent.set) == 'function') {
                                            causalPartComponent.set('v.objectName', '');
                                            causalPartComponent.set('v.disabled', false);
                                            component.set('v.causalPart', null);
                                            component.set('v.currentClaim.Fault_Code__c', '');
                                            
                                            helper.setFaultCodePicklistOptions(component, [], -1);
                                            
                                        }
                                    }
                                    
                                    
                                } else {
                                    component.set('v.error.accordion1.fieldError.inventory', '');
                                }
                                
                            } else {
                                
                                //handle blur event
                                component.set('v.error.accordion1.fieldError.inventory', $A.get("$Label.c.Inventory_Not_Correct"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                                //enable the causal part and fault code make it empty
                                var causalPartComponent = component.find('causalPart');
                                if (causalPartComponent !== null && causalPartComponent !== undefined) {
                                    if (typeof(causalPartComponent.set) == 'function') {
                                        causalPartComponent.set('v.objectName', '');
                                        causalPartComponent.set('v.disabled', false);
                                        component.set('v.causalPart', null);
                                        component.set('v.currentClaim.Fault_Code__c', '');
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                    }
                                }
                                
                                // unset all the values filled by inventory
                                component.set('v.unitType', "");
                                component.set('v.currentClaim.Date_Of_Purchase__c', helper.getTodayDate(component, event));
                                component.set('v.currentClaim.Units_Run__c', 0);
                                component.set('v.inventory', null);
                                
                                //disable the causal part and fault code make it empty
                                var causalPartComponent = component.find('causalPart');
                                if (causalPartComponent !== null && causalPartComponent !== undefined) {
                                    if (typeof(causalPartComponent.set) == 'function') {
                                        causalPartComponent.set('v.objectName', '');
                                        causalPartComponent.set('v.disabled', true);
                                        component.set('v.causalPart', null);
                                        component.set('v.currentClaim.Fault_Code__c', '');
                                        
                                        helper.setFaultCodePicklistOptions(component, [], -1);
                                        
                                    }
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    break;
                }
                
            case 'product':
                {
                    
                    var textValue = event.getParam('textValue');
                    
                    if (claimCustomRecordTypeName == 'Non-Serialized') {
                        
                        if (textValue == '') {
                            component.set('v.error.accordion1.fieldError.product', $A.get("$Label.c.Product_Not_Selected"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                            //unset all values filled by product
                            component.set('v.product', null);
                            component.set('v.unitType', "");
                            component.set('v.currentClaim.Warranty_Product__c', '');
                            
                        } else {
                            
                            var product = JSON.parse(JSON.stringify(component.get('v.product')));
                            
                            if (product != null) {
                                
                                if (textValue !== product['Name']) {
                                    
                                    component.set('v.error.accordion1.fieldError.product', $A.get("$Label.c.Product_Not_correct"));
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                    
                                    //unset all values filled by product
                                    component.set('v.product', null);
                                    component.set('v.unitType', "");
                                    component.set('v.currentClaim.Warranty_Product__c', '');
                                    
                                } else {
                                    component.set('v.error.accordion1.fieldError.product', '');
                                }
                                
                            } else {
                                
                                //handle blur event
                                component.set('v.error.accordion1.fieldError.product', $A.get("$Label.c.Product_Not_correct"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                                //unset all values filled by product
                                component.set('v.product', null);
                                component.set('v.unitType', "");
                                component.set('v.currentClaim.Warranty_Product__c', '');
                                
                            }
                            
                        }
                        
                    }
                    
                    break;
                }
                
            case 'reasonForDelay':
                {
                    
                    
                    if (claimCustomRecordTypeName != 'Claim Template') {
                        
                        var failureRepairDateDiffBig = component.get('v.failureRepairDateDiffBig');
                        var textValue = event.getSource().get('v.value');
                        if (failureRepairDateDiffBig && (textValue == '' || textValue == null || textValue == undefined)) {
                            component.set('v.error.accordion1.fieldError.reasonForDelay', $A.get("$Label.c.Reason_For_Delay_Not_Filled"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                        } else {
                            component.set('v.error.accordion1.fieldError.reasonForDelay', '');
                        }
                        
                    }
                    
                    break;
                }
                
            case 'unitsUsage':
                {
                    
                    var unitType = component.get('v.unitType');
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue !== '' && textValue !== undefined && textValue !== null) {
                        
                        // make units run float type
                        textValue = parseFloat(textValue);
                        
                        // check for negative
                        if (textValue < 0) {
                            component.set('v.error.accordion1.fieldError.unitsUsage', $A.get("$Label.c.Units_Run_Negative"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                        } else {
                            
                            // check for units run greater than or equals inventory units run
                            if (claimCustomRecordTypeName == 'Serialized' || claimCustomRecordTypeName == 'Field Modification') {
                                
                                var inventory = component.get('v.inventory');
                                if (inventory != null && inventory != undefined) {
                                    
                                    var unitsRun = parseFloat(inventory['Units_Run__c']);
                                    
                                    if (unitsRun > textValue) {
                                        
                                        component.set('v.error.accordion1.fieldError.unitsUsage',
                                                      $A.get("$Label.c.Units_Run_Less_Than_Inventory") + unitsRun);
                                        component.set('v.accordionValidationIndicator.accordion1', false);
                                        
                                    } else {
                                        
                                        component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                        
                                    }
                                    
                                } else {
                                    
                                    component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                    
                                }
                                
                            } else {
                                
                                component.set('v.error.accordion1.fieldError.unitsUsage', '');
                                
                            }
                            
                            
                        }
                        
                    } else {
                        
                        if (textValue !== '0') {
                            
                            if (unitType !== "") {
                                component.set('v.error.accordion1.fieldError.unitsUsage', $A.get("$Label.c.Units_Usage_Empty"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                            } else {
                                component.set('v.error.accordion1.fieldError.unitsUsage', '');
                            }
                            
                        } else {
                            component.set('v.error.accordion1.fieldError.unitsUsage', '');
                        }
                        
                        
                    }
                    
                    break;
                }
                
            case 'causalPart':
                {
                    
                    var textValue = event.getParam('textValue');
                    
                    if (textValue === '') {
                        
                        component.set('v.error.accordion1.fieldError.causalPart', $A.get("$Label.c.Causal_Part_Not_selected"));
                        component.set('v.accordionValidationIndicator.accordion1', false);
                        
                        //unset vall the values filled by causal part
                        component.set('v.causalPart', null);
                        component.set('v.currentClaim.Fault_Code__c', '');
                        
                        helper.setFaultCodePicklistOptions(component, [], -1);
                        
                    } else {
                        
                        var causalPart = JSON.parse(JSON.stringify(component.get('v.causalPart')));
                        
                        if (causalPart !== null) {
                            
                            if (textValue !== causalPart['Name']) {
                                
                                component.set('v.error.accordion1.fieldError.causalPart', $A.get("$Label.c.Causal_Part_Not_Correct"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                                //unset vall the values filled by causal part
                                component.set('v.causalPart', null);
                                component.set('v.currentClaim.Fault_Code__c', '');
                                
                                helper.setFaultCodePicklistOptions(component, [], -1);
                                
                            } else {
                                component.set('v.error.accordion1.fieldError.causalPart', '');
                            }
                            
                        } else {
                            
                            //handle blur event
                            component.set('v.error.accordion1.fieldError.causalPart', $A.get("$Label.c.Causal_Part_Not_Correct"));
                            component.set('v.accordionValidationIndicator.accordion1', false);
                            
                            //unset vall the values filled by causal part
                            component.set('v.causalPart', null);
                            component.set('v.currentClaim.Fault_Code__c', '');
                            
                            helper.setFaultCodePicklistOptions(component, [], -1);
                            
                        }
                        
                    }
                    
                    break;
                }
                
            case 'jobCode':
                {
                    
                    var textValue = event.getParam('textValue');
                    
                    if (textValue == '') {
                        component.set('v.error.accordion3.fieldError.jobCode', $A.get("$Label.c.Job_Code_Not_Selected"));
                        component.set('v.selectedJobCode', null);
                        
                    } else {
                        
                        var jobcode = JSON.parse(JSON.stringify(component.get('v.selectedJobCode')));
                        
                        if (jobcode != null) {
                            
                            if (textValue !== jobcode['Name']) {
                                component.set('v.error.accordion3.fieldError.jobCode', $A.get("$Label.c.Jobcode_Not_Correct"));
                                component.set('v.selectedJobCode', null);
                            } else {
                                component.set('v.error.accordion3.fieldError.jobCode', '');
                            }
                            
                        } else {
                            
                            //handle blur event
                            component.set('v.error.accordion3.fieldError.jobCode', $A.get("$Label.c.Jobcode_Not_Correct"));
                            component.set('v.selectedJobCode', null);
                            
                        }
                        
                        
                    }
                    
                    break;
                }
                
            case 'additionalLabourHours':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    //check for empty
                    if (textValue == '' || textValue == undefined || textValue == null) {
                        
                        //find dom element and fill with 0
                        component.find('additionalLabourHours').set('v.value', 0);
                        
                        //hide the reason for display textarea
                        component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', false);
                        
                        //unset the errors
                        component.set('v.error.accordion3.fieldError.additionalLabourHours', '');
                        component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');
                        
                    }
                    
                    //check for -ve value
                    if (textValue < 0) {
                        
                        component.set('v.error.accordion3.fieldError.additionalLabourHours', $A.get("$Label.c.Negative_Labour_Hour"));
                        
                    } else if (textValue > 0) {
                        
                        //display the reason for display textarea
                        component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', true);
                        
                        //unset the error of additional labour charges
                        component.set('v.error.accordion3.fieldError.additionalLabourHours', '');
                        
                    } else {
                        
                        //hide the reason for display textarea
                        component.set('v.modalAndElementDisplayBool.reasonForAdditionalHoursNeeded', false);
                    }
                    
                    break;
                }
                
            case 'reasonForAdditionalHours':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    //check for empty
                    if (textValue == '' || textValue == undefined || textValue == null) {
                        
                        //find dom element and fill with 0
                        component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', $A.get("$Label.c.Reason_For_Additional_Labour_Hours_Not_Filled"));
                        
                        
                    } else {
                        
                        //find dom element and fill with 0
                        component.set('v.error.accordion3.fieldError.reasonForAdditionalHoursNeeded', '');
                        
                    }
                    
                    break;
                }
                
            case 'customCost':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue !== '' && textValue !== undefined && textValue !== null) {
                        
                        // make units run float type
                        textValue = parseFloat(textValue);
                        
                        // check for negative
                        if (textValue <= 0 || isNaN(textValue)) {
                            component.set('v.error.accordion4.fieldError.customCost', $A.get("$Label.c.Negative_Unit_Price"));
                        } else {
                            component.set('v.error.accordion4.fieldError.customCost', '');
                        }
                        
                        
                    } else {
                        component.set('v.error.accordion4.fieldError.customCost', $A.get("$Label.c.Negative_Unit_Price"));
                    }
                    break;
                }
                
            case 'quantity':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    // make units run float type
                    textValue = parseFloat(textValue);
                    
                    // check for negative and zero and empty
                    if (textValue <= 0 || (textValue % 1 !== 0) || isNaN(textValue)) {
                        component.set('v.error.accordion4.fieldError.quantity', $A.get("$Label.c.Quantity_Error"));
                    } else {
                        component.set('v.error.accordion4.fieldError.quantity', '');
                    }
                    
                    break;
                }
                
            case 'removedPartQuantity':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    
                    // make units run float type
                    textValue = parseFloat(textValue);
                    
                    // check for negative and zero
                    if (textValue <= 0 || (textValue % 1 !== 0) || isNaN(textValue)) {
                        component.set('v.error.accordion4.fieldError.removedPartQuantity', $A.get("$Label.c.Quantity_Error"));
                    } else {
                        component.set('v.error.accordion4.fieldError.removedPartQuantity', '');
                    }
                    
                    
                    
                    break;
                }
                
            case 'causeComment':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue == '') {
                        component.set('v.error.accordion5.fieldError.causalPartComment', $A.get("$Label.c.Cause_Comments_Empty"));
                        helper.closeTabForceFully(component, event, 'accordion-c-6-body');
                    } else {
                        component.set('v.error.accordion5.fieldError.causalPartComment', '');
                    }
                    
                    
                    break;
                }
                
            case 'workPerformedComment':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue == '') {
                        component.set('v.error.accordion5.fieldError.workPerformedComment', $A.get("$Label.c.Work_Performed_Comments_Empty"));
                        helper.closeTabForceFully(component, event, 'accordion-c-6-body');
                        
                    } else {
                        component.set('v.error.accordion5.fieldError.workPerformedComment', '');
                    }
                    
                    break;
                }
                
            case 'faultFoundComment':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue == '') {
                        component.set('v.error.accordion5.fieldError.faultFoundComment', $A.get("$Label.c.Fault_Found_Comments_Empty"));
                        helper.closeTabForceFully(component, event, 'accordion-c-6-body');
                    } else {
                        component.set('v.error.accordion5.fieldError.faultFoundComment', '');
                    }
                    
                    break;
                }
                
            case 'nonOEMPartName':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue !== '' && textValue !== undefined && textValue !== null) {
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', '');
                    } else {
                        component.set('v.error.accordion4.fieldError.nonOEMPartName', $A.get("$Label.c.Part_Name_Empty"));
                    }
                    
                    break;
                }
                
            case 'Invoice Date':
                {
                    
                    var dateValue = event.getSource().get('v.value');
                    if (new Date(dateValue) == 'Invalid Date' && dateValue !== '') {
                        component.set('v.error.accordion4.fieldError.invoiceDate', 'Invalid Date');
                    } else {
                        component.set('v.error.accordion4.fieldError.invoiceDate', '');
                    }
                    
                    break;
                }
                
            case 'nonOEMPartDescription':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    if (textValue !== '' && textValue !== undefined && textValue !== null) {
                        component.set('v.error.accordion4.fieldError.nonOEMPartDescription', '');
                    } else {
                        component.set('v.error.accordion4.fieldError.nonOEMPartDescription', $A.get("$Label.c.Non_OEM_Part_Description_Error"));
                    }
                    
                    break;
                }
                
            case 'nonOEMPartCustomCost':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    // make units run float type
                    textValue = parseFloat(textValue);
                    
                    // check for negative
                    if (textValue <= 0 || isNaN(textValue)) {
                        component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', $A.get("$Label.c.Non_OEM_Custom_Cost_Negative_Empty"));
                    } else {
                        component.set('v.error.accordion4.fieldError.nonOEMPartCustomCost', '');
                    }
                    
                    break;
                }
                
            case 'nonOEMPartQuantity':
                {
                    
                    var textValue = event.getSource().get('v.value');
                    
                    // make units run float type
                    textValue = parseFloat(textValue);
                    
                    // check for negative and zero
                    if (textValue <= 0 || (textValue % 1 !== 0) || isNaN(textValue)) {
                        component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', $A.get("$Label.c.Quantity_Error"));
                    } else {
                        component.set('v.error.accordion4.fieldError.nonOEMPartQuantity', '');
                    }
                    
                    break;
                }
        }
        
    },
    
    /*** Date change Handelers ***/
    purchaseDateChangeHandeler: function(component, event, helper) {
        
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        if (claimCustomRecordTypeName == 'Non-Serialized') {
            var dateValue = event.getParam('value');
            
            
            //invalid date check
            if (new Date(dateValue) != 'Invalid Date') {
                // add empty error and  remove empty error
                if (dateValue == '' || dateValue == undefined || dateValue == null) {
                    component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Purchase_Date_Not_Filled"));
                    component.set('v.accordionValidationIndicator.accordion1', false);
                    
                } else {
                    
                    //18-NOV-2016
                    var purchaseDateFromPage = component.get('v.purchaseDate');
                    var todayDate = helper.getTodayDate();
                    var failureDate = component.get('v.failureDate');
                    var repairDate = component.get('v.repairDate');
                    
                    if (new Date(purchaseDateFromPage) > new Date(todayDate)) {
                        
                        component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Purchase_Date_Error"));
                        component.set('v.accordionValidationIndicator.accordion1', false);
                        
                    } else {
                        
                        if (failureDate !== null && failureDate !== undefined && failureDate !== '' && repairDate !== null &&
                            repairDate !== undefined && repairDate !== '') {
                            
                            if ((new Date(purchaseDateFromPage) > new Date(failureDate)) || (new Date(purchaseDateFromPage) > new Date(repairDate)) ||
                                (new Date(failureDate) > new Date(repairDate))) {
                                
                                //--18-NOV-2016
                                component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Common_Date_Error"));
                                component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Common_Date_Error"));
                                component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Common_Date_Error"));
                                
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                
                            } else {
                                
                                component.set('v.error.accordion1.fieldError.failureDate', '');
                                component.set('v.error.accordion1.fieldError.repairDate', '');
                                component.set('v.error.accordion1.fieldError.purchaseDate', '');
                                component.set('v.currentClaim.Date_Of_Purchase__c', purchaseDateFromPage);
                                component.set('v.currentClaim.Date_of_Failure__c', failureDate);
                                component.set('v.currentClaim.Date_of_Repair__c', repairDate);
                                
                            }
                            
                        } else {
                            
                            //unset the value
                            component.set('v.error.accordion1.fieldError.purchaseDate', '');
                            component.set('v.currentClaim.Date_Of_Purchase__c', purchaseDateFromPage);
                            
                        }
                        
                        
                    }
                    
                    //--18-NOV-2016
                    
                }
                
            } else {
                
                component.set('v.error.accordion1.fieldError.purchaseDate', 'Invalid date value');
                
            }
        }
        
    },
    failureDateChangeHandeler: function(component, event, helper) {
        
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        if (claimCustomRecordTypeName != 'Claim Template') {
            
            var dateValue = component.get('v.failureDate');
            
            //invalid date check
            if (new Date(dateValue) != 'Invalid Date') {
                
                // add empty error and  remove empty error
                if (dateValue === '' || dateValue === undefined || dateValue === null) {
                    
                    component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Failure_Date_Not_Filled"));
                    component.set('v.accordionValidationIndicator.accordion1', false);
                    
                } else {
                    var failureDateFromPage = component.get('v.failureDate');
                    var serviceEligibleOnwards = component.get('v.inventoryScheduleDate');
                    
                    var todayDate = helper.getTodayDate();
                    
                    //check if failure date is greater than today
                    if (new Date(failureDateFromPage) > new Date(todayDate)) {
                        
                        component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Failure_Date_After_Today"));
                        component.set('v.accordionValidationIndicator.accordion1', false);
                        helper.closeTabForceFully(component, event, 'accordion-c-2-body'); //18-NOV-2016
                        
                    }/*if(claimCustomRecordTypeName == 'Preventive Maintenance' && new Date(failureDateFromPage) < new Date(serviceEligibleOnwards)){
                        component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Service_Date_Before_Service_Date"));
                        component.set('v.accordionValidationIndicator.accordion1', false);
                    }*/
                    else {
                        
                        // check for the date of failure and repair difference
                        var repairDate = component.get('v.repairDate');
                        
                        if ((repairDate != '' && repairDate != null && repairDate != undefined)) {
                            
                            // check for failure date and repair date comparison error
                            if ((new Date(repairDate) < new Date(dateValue))) {
                                
                                //--18-NOV-2016
                                if(claimCustomRecordTypeName == 'Preventive Maintenance'){
                                    component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Failure_Date_Error_Preventive_Maintenance"));
                                }else{
                                    component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Failure_Date_Error"));
                                }
                                
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                component.set('v.error.accordion1.fieldError.repairDate', '');
                                component.set('v.currentClaim.Date_of_Repair__c', repairDate);
                                
                            } else {
                                
                                //unset failure date error
                                component.set('v.error.accordion1.fieldError.failureDate', '');
                                component.set('v.error.accordion1.fieldError.repairDate', '');
                                component.set('v.currentClaim.Date_of_Repair__c', repairDate);
                                component.set('v.currentClaim.Date_of_Failure__c', dateValue);
                                
                                
                                // check for the difference in dates condition
                                var differenceAllowed = parseFloat($A.get("$Label.c.Failure_Repair_Date_Diff"));
                                var timeDiff = Math.abs(new Date(repairDate) - new Date(dateValue));
                                var dateDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
                                
                                if (dateDiff > differenceAllowed) {
                                    component.set('v.failureRepairDateDiffBig', true);
                                } else {
                                    component.set('v.failureRepairDateDiffBig', false);
                                    component.set('v.currentClaim.Delay_Reason__c', '');
                                }
                                
                                //set failure date in claim
                                component.set('v.currentClaim.Date_of_Failure__c', dateValue);
                                
                                /**********field modification data fetch**********/
                                //nothing can be written inside this block after this line
                                var fieldModInitEditBoolean = component.get('v.fieldModInitEditBoolean');
                                var isEdit = component.get('v.isEdit');
                                if (fieldModInitEditBoolean == false && isEdit == false) {
                                    var inventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                                    var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
                                    if (claimCustomRecordTypeName === 'Field Modification' && inventory !== null &&
                                        inventory !== undefined && inventory['Id'] !== null && inventory['Id'] !== undefined) {
                                        helper.getCampaignMembers(component, event, inventory['Id']);
                                    }
                                    component.set('v.fieldModInitEditBoolean', false)
                                }
                                
                                
                            }
                            
                        }
                        
                        
                        //check the purchase date error
                        if (claimCustomRecordTypeName == 'Non-Serialized') {
                            //18-NOV-2016
                            var purchaseDate = component.get('v.purchaseDate');
                            
                            if ((purchaseDate != '' && purchaseDate != null && purchaseDate != undefined &&
                                 repairDate != '' && repairDate != null && repairDate != undefined
                                )) {
                                
                                if ((new Date(purchaseDate) > new Date(dateValue)) || (new Date(purchaseDate) > new Date(repairDate)) ||
                                    (new Date(dateValue) > new Date(repairDate))
                                   ) {
                                    
                                    component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Common_Date_Error"));
                                    component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Common_Date_Error"));
                                    component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Common_Date_Error"));
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                    
                                } else {
                                    
                                    //--18-NOV-2016
                                    component.set('v.error.accordion1.fieldError.failureDate', '');
                                    component.set('v.error.accordion1.fieldError.repairDate', '');
                                    component.set('v.error.accordion1.fieldError.purchaseDate', '');
                                    component.set('v.currentClaim.Date_Of_Purchase__c', purchaseDate);
                                    component.set('v.currentClaim.Date_of_Failure__c', dateValue);
                                    component.set('v.currentClaim.Date_of_Repair__c', repairDate);
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                component.set('v.error.accordion1.fieldError.failureDate', 'Invalid date value');
                
            }
            
        }
        
    },
    repairDateChangeHandeler: function(component, event, helper) {
        
        var claimCustomRecordTypeName = component.get('v.claimCustomRecordTypeName');
        
        if (claimCustomRecordTypeName != 'Claim Template') {
            
            var dateValue = component.get('v.repairDate');
            
            //invalid date check
            if (new Date(dateValue) != 'Invalid Date') {
                
                // add empty error and  remove empty error
                if (dateValue == '' || dateValue == undefined || dateValue == null) {
                    component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Repair_Date_Not_Filled"));
                    component.set('v.accordionValidationIndicator.accordion1', false);
                    
                } else {
                    
                    var repairDateFromPage = component.get('v.repairDate');
                    var todayDate = helper.getTodayDate();
                    
                    
                    //check if repair date is greater than today
                    if (new Date(repairDateFromPage) > new Date(todayDate)) {
                        
                        component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Repair_Date_After_Today"));
                        component.set('v.accordionValidationIndicator.accordion1', false);
                        helper.closeTabForceFully(component, event, 'accordion-c-2-body'); //18-NOV-2016
                        
                    } else {
                        
                        // unset repair date error
                        component.set('v.error.accordion1.fieldError.repairDate', '');
                        
                        //set repair date in claim
                        component.set('v.currentClaim.Date_of_Repair__c', dateValue);
                        
                        // check for the date of failure and repair difference
                        var failureDate = component.get('v.failureDate');
                        
                        if ((failureDate != '' && failureDate != null && failureDate != undefined)) {
                            
                            // check for failure date and repair date comparison error
                            
                            if ((new Date(dateValue) < new Date(failureDate))) {
                                component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Repair_Date_Error"));
                                component.set('v.accordionValidationIndicator.accordion1', false);
                                component.set('v.error.accordion1.fieldError.failureDate', '');
                                component.set('v.currentClaim.Date_of_Failure__c', failureDate);
                                
                            } else {
                                
                                // unset repair date error
                                component.set('v.error.accordion1.fieldError.repairDate', '');
                                component.set('v.error.accordion1.fieldError.failureDate', '');
                                
                                //--18-NOV-2016
                                //set repair date in claim
                                component.set('v.currentClaim.Date_of_Repair__c', dateValue);
                                component.set('v.currentClaim.Date_of_Failure__c', failureDate);
                                
                                // check for the difference in dates condition
                                var differenceAllowed = parseFloat($A.get("$Label.c.Failure_Repair_Date_Diff"));
                                var timeDiff = Math.abs(new Date(dateValue) - new Date(failureDate));
                                var dateDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
                                
                                if (dateDiff > differenceAllowed) {
                                    component.set('v.failureRepairDateDiffBig', true);
                                } else {
                                    component.set('v.failureRepairDateDiffBig', false);
                                    component.set('v.currentClaim.Delay_Reason__c', '');
                                }
                            }
                        }
                        
                        
                        //check the purchase date error
                        //18-NOV-2016
                        if (claimCustomRecordTypeName == 'Non-Serialized') {
                            
                            var purchaseDate = component.get('v.purchaseDate');
                            
                            if ((purchaseDate != '' && purchaseDate != null && purchaseDate != undefined &&
                                 failureDate != '' && failureDate != null && failureDate != undefined
                                )) {
                                
                                if ((new Date(purchaseDate) > new Date(dateValue)) || (new Date(purchaseDate) > new Date(failureDate)) ||
                                    (new Date(failureDate) > new Date(dateValue))
                                   ) {
                                    
                                    //--18-NOV-2016
                                    component.set('v.error.accordion1.fieldError.failureDate', $A.get("$Label.c.Common_Date_Error"));
                                    component.set('v.error.accordion1.fieldError.repairDate', $A.get("$Label.c.Common_Date_Error"));
                                    component.set('v.error.accordion1.fieldError.purchaseDate', $A.get("$Label.c.Common_Date_Error"));
                                    
                                    component.set('v.accordionValidationIndicator.accordion1', false);
                                    
                                } else {
                                    
                                    //--18-NOV-2016
                                    component.set('v.error.accordion1.fieldError.failureDate', '');
                                    component.set('v.error.accordion1.fieldError.repairDate', '');
                                    component.set('v.error.accordion1.fieldError.purchaseDate', '');
                                    
                                    component.set('v.currentClaim.Date_Of_Purchase__c', purchaseDate);
                                    component.set('v.currentClaim.Date_of_Failure__c', failureDate);
                                    component.set('v.currentClaim.Date_of_Repair__c', dateValue);
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
                
            } else {
                
                component.set('v.error.accordion1.fieldError.repairDate', 'Invalid date value');
                
            }
        }
        
    },
    
    fetchDetails: function (component, event, helper) {
        var tt = component.find('upcomingScheduler').get('v.value');
        component.set('v.scheduleSetValue',tt);
        var inventoryScheduleList = component.get('v.inventoryScheduleList');
        var selectedPreventiveMaintainanceRule = component.find('upcomingScheduler').get('v.value');
        for(var i=0;i<inventoryScheduleList.length;i++){
            if(selectedPreventiveMaintainanceRule === inventoryScheduleList[i]['Id']){
                component.set('v.inventoryScheduleDescription',inventoryScheduleList[i]['Description__c']);
                component.set('v.inventoryScheduleDate',inventoryScheduleList[i]['Preventative_Maintenance_Date__c']);
                //component.set('v.selectedSchedule',inventoryScheduleList[i]['Name']);
            }
        }
    },
    
    /*** clean claim data ***/
    handleAuraError: function(component, event, helper) {
        
        //if message is from output text, nullify this error
        var message = event.getParam('message');
        var pattern = "AttributeSet.get(): attribute 'disableDoubleClicks' of component 'markup://ui:outputText";
        
        if (message.includes(pattern)) {
            event.setParam('message', '');
        }
        
    },
    
    ///added on 17-NOV-2016///
    cancel: function(component, event, helper) {
        
        var navEvent = $A.get("e.force:navigateToList");
        if (navEvent !== null && navEvent !== undefined) {
            navEvent.setParams({
                "listViewId": component.get('v.claimListViewId'),
                "listViewName": null,
                "scope": "Claim__c"
            });
            navEvent.fire();
        } else {
            window.history.back();
        }
        
    },
    
    // ** Added on 23-Jan-2016 By Chethan **//
    validateNegativeNumber: function(component, event, helper) {
        //alert("hi");
        helper.validateNegativeNumber(component, event);
    },
    
})