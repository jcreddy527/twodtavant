({
    doInit: function(component, event, helper) {
        console.log('test');
        
        helper.showAlert(component, event, {});
        
        //initialize errors
        var error = {
            fieldError: {
                unitUsage: '',
                coverageEndDate: '',
                purchaseDate: '',
                emailError: ''
            }

        };
        component.set('v.error', error);


        var pageBlockerBooleanObject = JSON.parse(JSON.stringify(component.get('v.pageBlockerBooleanObject')));
        helper.getEnableExtended(component,pageBlockerBooleanObject);
        var registrationPageBlockerMessage = helper.registrableCheck(component, pageBlockerBooleanObject);   

        if (registrationPageBlockerMessage !== '') {           
            component.set('v.pageBlockerMessage', registrationPageBlockerMessage);
        } else {

            //get all the policy definition with the months covered
            var policyDefinitionWithMonthsCoveredAction = component.get('c.getMaxMonthsCovered');
            policyDefinitionWithMonthsCoveredAction.setParams({
                warrantyRegistrationId: component.get('v.wrExistingId')
            });

            policyDefinitionWithMonthsCoveredAction.setCallback(this, function(response) {

                var maxCoverageTillDate = response.getReturnValue();
                var allowedCoverage = parseFloat($A.get('$Label.c.Maximum_Months_For_Extension'));

                //set the maximum coverage till date and allowed coverage
                component.set('v.maximumCoverageTillDate', maxCoverageTillDate);
                component.set('v.allowedCoverage', allowedCoverage);

                /////////////////////////////continue forward///////////////////////

                var lookupInventoryWhereClause = component.get('v.lookupInventoryWhereClause');

                var todayDateString = helper.getTodayDate(component, event);
                component.set('v.coverageEndDate', todayDateString);

                helper.newAccountObject(component, helper);
                component.set('v.showSpinner', true);

                var invtId = component.get("v.inventoryId");

                lookupInventoryWhereClause = ' Id !=' + '\'' + invtId + '\'' + ' AND ' + lookupInventoryWhereClause;

                component.set('v.lookupInventoryWhereClause', lookupInventoryWhereClause);

                var action = component.get("c.getInitialData");
                action.setParams({
                    invId: invtId
                });
                action.setCallback(this, function(a) {

					console.log(a.getError());
                    
                    
                    var initData = JSON.parse(a.getReturnValue());

                    var invObj = initData.invObj;
                    var accObj = initData.accObj;
                    var usageTypeOptions = initData.usageTypeOptions;
                    var invFieldSetList = initData.invFieldSetList;
                    var policyFieldSetList = initData.policyFieldSetList;


                    component.set('v.inventoryForDate', invObj);

                    //set the unit usage for inventory in page variable
                    if (invObj !== null && invObj !== undefined && invObj['Units_Run__c'] !== undefined &&
                        invObj['Units_Run__c'] !== null && !isNaN(parseFloat(invObj['Units_Run__c']))) {

                        component.set('v.unitUsageOnPage', parseFloat(invObj['Units_Run__c']));

                    }


                    var inventories = component.get('v.selectedInventories');
                    inventories.push(invObj);
                    component.set('v.selectedInventories', inventories);
                    component.set('v.Inventory', inventories);

                    if (accObj != null && accObj != 'undefined') {
                        var customerObject = component.get('v.formNewAccount');

                        customerObject.Name = accObj.Name;
                        customerObject.ShippingState = accObj.ShippingState;
                        customerObject.ShippingStreet = accObj.ShippingStreet;
                        customerObject.ShippingCountry = accObj.ShippingCountry;
                        customerObject.ShippingPostalCode = accObj.ShippingPostalCode;
                        customerObject.Phone = accObj.Phone;
                        customerObject.Email__c = accObj.Email__c;
                        customerObject.Website = accObj.Website;

                        component.set('v.formNewAccount', customerObject);

                        component.set('v.customer', accObj);
                    }

                    var installdate = component.get('v.inventoryForDate.Install_Date__c');
                    component.set('v.inventoryInstallDate', installdate);

                    component.set('v.usageTypeList', usageTypeOptions);
                    component.set('v.usageType', usageTypeOptions[0]);
                    component.set('v.inventoryfieldset', invFieldSetList);
                    component.set('v.policyfieldset', policyFieldSetList);

                    // form string to query fieldset fields related to inventory
                    var fieldsfromFieldset = '';

                    if (component.get('v.inventoryfieldset').length - 1 > 0) {
                        for (var i = 0; i < component.get('v.inventoryfieldset').length; i++) {
                            // fieldsfromFieldset is to add into query and looping to display
                            if (i != component.get('v.inventoryfieldset').length - 1)
                                fieldsfromFieldset += component.get('v.inventoryfieldset')[i].apiName + ',';
                            else if (i == component.get('v.inventoryfieldset').length - 1)
                                fieldsfromFieldset += component.get('v.inventoryfieldset')[i].apiName;

                            // if field type is reference add field apiname and refrence name to map.
                            var refrencefieldstoQuery = '';
                            if (component.get('v.inventoryfieldset')[i].type == 'REFERENCE') {
                                var mapFieldApi_Reference = component.get("v.mapFieldApi_Reference");
                                mapFieldApi_Reference[component.get('v.inventoryfieldset')[i].apiName] = component.get('v.inventoryfieldset')[i].RelationShipName;
                                component.set('v.mapFieldApi_Reference', mapFieldApi_Reference);

                                // add relationship fields to query but not to display on screen

                                if (i != component.get('v.inventoryfieldset').length - 1)
                                    refrencefieldstoQuery += component.get('v.inventoryfieldset')[i].RelationShipName + ',';
                                else if (i == component.get('v.inventoryfieldset').length - 1)
                                    refrencefieldstoQuery += component.get('v.inventoryfieldset')[i].RelationShipName;
                            }
                        }
                        component.set('v.fieldArr', fieldsfromFieldset.split(','));
                    }

                    // query other inventory fields which are not to display but necessary
                    if (refrencefieldstoQuery == '')
                        var fields = component.get('v.additionalFields') + ',' + fieldsfromFieldset;
                    else
                        var fields = component.get('v.additionalFields') + ',' + fieldsfromFieldset + ',' + refrencefieldstoQuery;


                    component.set('v.allFieldsToQuery', fields);

                    // form string to query fieldset fields related to inventory
                    var policyfieldsfromFieldset = '';
                    if (component.get('v.policyfieldset').length - 1 > 0) {
                        for (var i = 0; i < component.get('v.policyfieldset').length; i++) {
                            // policyfieldsfromFieldset is to add into query and looping to display
                            if (i != component.get('v.policyfieldset').length - 1)
                                policyfieldsfromFieldset += component.get('v.policyfieldset')[i].apiName + ',';
                            else if (i == component.get('v.policyfieldset').length - 1)
                                policyfieldsfromFieldset += component.get('v.policyfieldset')[i].apiName;

                            // if field type is reference add field apiname and refrence name to map.
                            if (component.get('v.policyfieldset')[i].type == 'REFERENCE') {
                                var mapPolicyFieldApi_Reference = component.get("v.mapPolicyFieldApi_Reference");
                                mapPolicyFieldApi_Reference[component.get('v.policyfieldset')[i].apiName] = component.get('v.policyfieldset')[i].RelationShipName;
                                component.set('v.mapPolicyFieldApi_Reference', mapPolicyFieldApi_Reference);
                            }
                        }
                        component.set('v.policyFieldArr', policyfieldsfromFieldset.split(','));
                    }


                    component.set('v.showSpinner', false);
                });
                $A.enqueueAction(action);


            });
            $A.enqueueAction(policyDefinitionWithMonthsCoveredAction);

        }



    },
    
    fillError: function(component, event, helper) {

        var componentId = event.getSource().getLocalId();

        switch (componentId) {

            case "unitUsage":
                {

                    var unitUsageValue = parseFloat(event.getSource().get('v.value'));
                    var inventoryUnitsUsage = parseFloat(component.get('v.inventoryForDate.Units_Run__c'));

                    if (!isNaN(unitUsageValue) && !isNaN(inventoryUnitsUsage)) {
                        if (unitUsageValue < 0) {
                            component.set('v.error.fieldError.unitUsage', $A.get('$Label.c.Units_Run_Negative'));
                        } else {
                            if (unitUsageValue < inventoryUnitsUsage) {
                                component.set('v.error.fieldError.unitUsage', $A.get('$Label.c.Units_Run_Less_Than_Inventory') + inventoryUnitsUsage);
                            } else {
                                component.set('v.error.fieldError.unitUsage', '');
                            }
                        }
                    } else {

                        if (!isNaN(unitUsageValue) && unitUsageValue < 0) {
                            component.set('v.error.fieldError.unitUsage', $A.get('$Label.c.Units_Run_Negative'));
                        } else {
                            component.set('v.error.fieldError.unitUsage', '');
                        }

                    }

                    break;
                }

        }

    },

    coverageEndDateHandeler: function(component, event, helper) {
        var dateValue = component.get('v.coverageEndDate');
        var purchaseDate = component.get('v.inventoryInstallDate');
        var today = helper.getTodayDate(component, event);
        if (dateValue !== null && dateValue !== undefined && purchaseDate !== null && purchaseDate !== undefined) {

            var purchaseDate = new Date(purchaseDate);
            var coverageEndDate = new Date(dateValue);
            today = new Date(today);

            if (coverageEndDate < today) {
                component.set('v.error.fieldError.coverageEndDate', $A.get('$Label.c.Coverage_End_Date_Error'));
                component.set('v.isSearchPolicyClicked', false);
                component.set('v.isSearchPolicyExecuting', false);
                component.set("v.PolicyList", null);


            } else {
                if (purchaseDate > coverageEndDate) {
                    component.set('v.error.fieldError.coverageEndDate', $A.get('$Label.c.Coverage_End_Date_Error'));
                    component.set('v.isSearchPolicyClicked', false);
                    component.set('v.isSearchPolicyExecuting', false);
                    component.set("v.PolicyList", null);

                } else {
                    component.set('v.error.fieldError.coverageEndDate', '');
                    component.set('v.error.fieldError.purchaseDate', '');
                }
            }



        }

    },

    searchPolicy: function(component, event, helper) {

        var validationSuccess = helper.validationSuccesStatus(component, event);

        if (validationSuccess === true) {

            component.set('v.showPolicySpinner', true);
            var isSearchPolicyExecuting = component.get('v.isSearchPolicyExecuting');

            if (isSearchPolicyExecuting == false) {

                var isError = helper.validateInputs(component, event, helper);
                if (isError == true) {
                    component.set('v.isError', true);
                } else {
                    component.set('v.isSearchPolicyExecuting', true);

                    component.set('v.isError', false);
                    component.set('v.isRegistrationError', false);

                    if (component.get('v.selectedInventories').length > 0) {
                        helper.selectedInventoriesSize = component.get('v.selectedInventories').length;
                        helper.currentInventory = 0;
                        helper.addInventorywithpolicies(component, event, helper);
                    } else {
                        component.set('v.showPolicySpinner', false);
                    }
                }
            } else {
                component.set('v.showPolicySpinner', false);
            }


        } else {
            var alertBoxData = {
                message: $A.get('$Label.c.Please_Review_All_Error_Messages'),
                heading: $A.get('$Label.c.Warranty_Registration_Page_Says'),
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            helper.showAlert(component, event, alertBoxData);

        }




    },
    
    registerInv: function(component, event, helper) {


        var registerButton = component.find('registerBtn');
        var type = component.get("v.type");
        if (type === 'Extended') {
			
            ////////////////////////logic for maximum months that can be added in extended warranty registration/////////////////////
            var maxCoverageTillDate = component.get('v.maximumCoverageTillDate');
            var allowedCoverage = component.get('v.allowedCoverage');
            var allowedCoverageAfterDifference = allowedCoverage - maxCoverageTillDate;
            var mapInventoryPolicies = JSON.parse(JSON.stringify(component.get('v.mapInventoryPolicies')));
            var inventory = JSON.parse(JSON.stringify(component.get('v.Inventory')));
            if (Array.isArray(inventory)) {
                inventory = inventory[0];
            }
            mapInventoryPolicies = mapInventoryPolicies[inventory['Id']];

            var sumOfSelectedpoliciesMonthsCovered = 0;
            for (var i = 0, len = mapInventoryPolicies.length; i < len; i++) {
                if (mapInventoryPolicies[i]['selected'] === true) {
                    sumOfSelectedpoliciesMonthsCovered += mapInventoryPolicies[i]['ObjPolicyDefinition']['Months_Covered__c'];
                }
            }

            if (sumOfSelectedpoliciesMonthsCovered > allowedCoverageAfterDifference) {


                // show the error message of service campaign found
                var alertboxContent = {
                    message: $A.get('$Label.c.Months_Covered_Exceeded'),
                    heading: $A.get('$Label.c.Warranty_Registration_Page_Says'),
                    class: 'slds-theme--error',
                    callableFunction: component.getReference('c.closeAlert'),
                    buttonHeading: $A.get("$Label.c.OK")
                };
                helper.showAlert(component, event, alertboxContent);


            } else {

                //If there is a policy selected for the inventory from the list, then do the registration. Also restrict user to click multiple times.
                if (component.get('v.selectedPoliciesCount') > 0 && helper.isRegisterWR) {
                    helper.isRegisterWR = false;
                    $A.util.addClass(registerButton, 'BtnCSS');

                    var mapInventoryPolicies = component.get('v.mapInventoryPolicies');

                    var selectedInventories = component.get('v.selectedInventories');
                    var isOneSelected = 0;
                    var policyCount = 0;
                    if (typeof selectedInventories != 'undefined') {
                        for (var i = 0; i < selectedInventories.length; i++) {
                            var policydef = mapInventoryPolicies[selectedInventories[i].Id];
                            if (policydef.length > 0 && typeof policydef != 'undefined') {
                                policyCount++;
                                for (var j = 0; j < policydef.length; j++) {
                                    if (policydef[j].selected) {
                                        isOneSelected++;
                                    }
                                }
                            }
                        }

                        if (policyCount == 0) {
                            component.set('v.registrationErrorMessage', 'No Policies found');
                            component.set('v.isRegistrationError', true);
                        } else if (isOneSelected > 0) {
                            component.set('v.isRegistrationError', false);
                            helper.registerInventoriesSize = component.get('v.selectedInventories').length;
                            helper.currentRegisterInventory = '0';

                            helper.registerInventoryHelper(component, helper);
                        } else {
                            component.set('v.registrationErrorMessage', $A.get('$Label.c.Registration_Without_Policy_Error'));
                            component.set('v.isRegistrationError', true);
                        }
                    }
                }

            }







        } else {


            if (component.get('v.selectedPoliciesCount') > 0 && helper.isRegisterWR) {
                helper.isRegisterWR = false;
                $A.util.addClass(registerButton, 'BtnCSS');

                var mapInventoryPolicies = component.get('v.mapInventoryPolicies');

                var selectedInventories = component.get('v.selectedInventories');

                var isOneSelected = 0;
                var policyCount = 0;
                if (typeof selectedInventories != 'undefined') {
                    for (var i = 0; i < selectedInventories.length; i++) {
                        var policydef = mapInventoryPolicies[selectedInventories[i].Id];
                        if (policydef.length > 0 && typeof policydef != 'undefined') {
                            policyCount++;
                            for (var j = 0; j < policydef.length; j++) {
                                if (policydef[j].selected) {
                                    isOneSelected++;
                                }
                            }
                        }
                    }

                    if (policyCount == 0) {
                        component.set('v.registrationErrorMessage', $A.get('$Label.c.No_Policies_Found'));
                        component.set('v.isRegistrationError', true);
                    } else if (isOneSelected > 0) {
                        component.set('v.isRegistrationError', false);
                        helper.registerInventoriesSize = component.get('v.selectedInventories').length;
                        helper.currentRegisterInventory = '0';

                        helper.registerInventoryHelper(component, helper);
                    } else {
                        component.set('v.registrationErrorMessage', $A.get('$Label.c.Registration_Without_Policy_Error'));
                        component.set('v.isRegistrationError', true);
                    }
                }
            }
        }
    },

    setCustomerModal: function(component, event, helper) {

        helper.newAccountObject(component, helper);
        component.set('v.showCustomerNameError', false);
        component.set('v.showEmailError', false);

        component.set('v.showCreateCustomerModal', true);
    },

    setEditCustomerModal: function(component, event, helper) {
        component.set('v.showCreateCustomerModal', true);
    },

    cancelCustomerModel: function(component, event, helper) {
        component.set('v.showCreateCustomerModal', false);
        component.set('v.showSpinner', false);
    },

    saveCustomer: function(component, event, helper) {
        component.set('v.showCustomerNameError', false);
        component.set('v.showEmailError', false);

        /*** check for account name is not null or empty ***/
        var customer = JSON.parse(JSON.stringify(component.get('v.formNewAccount')));

        /* Check if customerId exists. If no, then do insert dml else do update dml*/
        var customerObj = component.get('v.customer');


        var errorInput = component.find('emailError');
        $A.util.removeClass(errorInput, 'errorCSS');

        if (customer.Name != null && customer.Name != '' && customer.Email__c != null && customer.Email__c != '') {

            if (customerObj == null || customerObj.Id == undefined) {
                helper.insertRaw(component, event, customer, function(response) {

                    if (response.sobjectsAndStatus != null && response.sobjectsAndStatus != undefined &&
                        response.sobjectsAndStatus.length != 0 && response.sobjectsAndStatus[0].status == 'successful') {
                        component.set('v.showCreateCustomerModal', false);
                        var idOfAccount = response.sobjectsAndStatus[0]['sObject']['Id'];
                        component.set('v.customerId', idOfAccount);
                        component.set('v.customerBackendErrorString', '');
                        component.set('v.customerBackendErrorModal', false);

                    } else {

                        component.set('v.showEmailError', true);
                        component.set('v.validationEError', response.errorArrays[0].errorMesssages[0]);
                        if (component.get('v.validationEError') !== null && component.get('v.validationEError') !== undefined &&
                            component.get('v.validationEError') !== '') {
                            //component.set('v.showCreateCustomerModal',false);
                            component.set('v.customerBackendErrorString', response.errorArrays[0].errorMesssages[0]);
                            component.set('v.customerBackendErrorModal', true);

                            //helper.showAlert(component,event,alertboxContent);
                        } else {
                            component.set('v.showCreateCustomerModal', true);
                        }



                        $A.util.addClass(errorInput, 'errorCSS');
                    }
                });
            } else {
                component.set('v.customerId', null);


                var formUpdateAccount = {
                    sobjectType: 'Account',
                    Id: customerObj.Id,
                    Name: customer.Name,
                    ShippingState: customer.ShippingState,
                    ShippingStreet: customer.ShippingStreet,
                    ShippingCountry: customer.ShippingCountry,
                    ShippingPostalCode: customer.ShippingPostalCode,
                    Phone: customer.Phone,
                    Email__c: customer.Email__c,
                    Website: customer.Website
                };

                formUpdateAccount = JSON.parse(JSON.stringify(formUpdateAccount));
                helper.updateRaw(component, event, formUpdateAccount, function(response) {

                    if (response.sobjectsAndStatus != null && response.sobjectsAndStatus != undefined &&
                        response.sobjectsAndStatus.length != 0 && response.sobjectsAndStatus[0].status == 'successful') {
                        component.set('v.showCreateCustomerModal', false);
                        var idOfAccount = response.sobjectsAndStatus[0]['sObject']['Id'];
                        component.set('v.customerId', idOfAccount);
                        component.set('v.customerBackendErrorString', '');
                        component.set('v.customerBackendErrorModal', false);

                    } else {

                        component.set('v.customerBackendErrorString', response.errorList[0].errorMesssages[0]);
                        component.set('v.customerBackendErrorModal', true);

                        component.set('v.validationEError', response.errorList[0].errorMesssages[0]);
                        $A.util.addClass(errorInput, 'errorCSS');
                    }
                });
            }
        } else {
            if (customer.Name == null && customer.Email__c == null) {
                component.set('v.showCustomerNameError', true);
                component.set('v.validationCNError', $A.get('$Label.c.CustomerName_Mandatory'));
                component.set('v.showEmailError', true);
                component.set('v.validationEError', $A.get('$Label.c.CustomerEmail_Mandatory'));
            }

            if (customer.Name == null || customer.Name == '') {

                component.set('v.showCustomerNameError', true);
                component.set('v.validationCNError', $A.get('$Label.c.CustomerName_Mandatory'));
            }

            if (customer.Email__c == null || customer.Email__c == '') {

                component.set('v.showEmailError', true);
                component.set('v.validationEError', $A.get('$Label.c.CustomerEmail_Mandatory'));
            }
        }
    },

    fetchselectedcustomerdata: function(component, event, helper) {

        var customerId = component.get('v.customerId');
        if (customerId != null && typeof customerId != 'undefined') {
            //var query = 'SELECT Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode FROM Account Where Id='+ '\'' + customerId + '\'';
            var query = 'SELECT Id,Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode,Phone,Website,Email__c FROM Account Where Id=' + '\'' + customerId + '\'';
            helper.readRaw(component, event, query, function(response) {


                component.set('v.customer', response[0]);

                // Fill formNewAccount object for further editting the customer when customer is selected via lookup.
                var customerObject = component.get('v.formNewAccount');
                var accObj = response[0];
                if (customerObject === null || customerObject === undefined) {
                    customerObject = {};
                }
                customerObject.Name = accObj.Name;
                customerObject.ShippingState = accObj.ShippingState;
                customerObject.ShippingStreet = accObj.ShippingStreet;
                customerObject.ShippingCountry = accObj.ShippingCountry;
                customerObject.ShippingPostalCode = accObj.ShippingPostalCode;
                customerObject.Phone = accObj.Phone;
                customerObject.Email__c = accObj.Email__c;
                customerObject.Website = accObj.Website;

                component.set('v.formNewAccount', customerObject);

                //hide spinner
                component.set('v.showSpinner', false);
            });
        }
    },

    validateAccordionOpen: function(component, event, helper) {

        var accordionId = event.target.id;

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
                    }
                    break;
                }
            case "accordion-c-2":
                {
                    // Second accordion body
                    var claimInfotab = component.find('accordion-c-2-body');

                    if ($A.util.hasClass(claimInfotab, 'tab-close')) {

                        $A.util.removeClass(claimInfotab, 'tab-close');
                        $A.util.addClass(claimInfotab, 'tab-open');

                    } else if ($A.util.hasClass(claimInfotab, 'tab-open')) {

                        $A.util.removeClass(claimInfotab, 'tab-open');
                        $A.util.addClass(claimInfotab, 'tab-close');
                    }
                    break;
                }
            case "accordion-c-3":
                {
                    // Third accordion body
                    var claimInfotab = component.find('accordion-c-3-body');

                    if ($A.util.hasClass(claimInfotab, 'tab-close')) {

                        $A.util.removeClass(claimInfotab, 'tab-close');
                        $A.util.addClass(claimInfotab, 'tab-open');

                    } else if ($A.util.hasClass(claimInfotab, 'tab-open')) {

                        $A.util.removeClass(claimInfotab, 'tab-open');
                        $A.util.addClass(claimInfotab, 'tab-close');
                    }
                    break;
                }
        }
    },

    onclickCheckbox: function(component, event, helper) {
        helper.onclickCheckboxHelper(component, helper);
    },

    cancelclick: function(component, event, helper) {
        var BaseUrl = component.get('v.BaseURL');
        var inventoryId = component.get('v.inventoryId');
        var sitePrefix = component.get('v.sitePrefix');
        var cancelUrl = "";

        if (sitePrefix == '' || sitePrefix == undefined || sitePrefix == null) {
            cancelUrl += "/";
        } else {
            cancelUrl += sitePrefix + "/";
        }
        cancelUrl += inventoryId;
        component.set('v.cancelUrl', cancelUrl);

        window.location.href = cancelUrl;
    },

    onChangeUsageType: function(component, event, helper) {
        var dateValue = component.get('v.inventoryInstallDate');
        var coverageEndDate = component.get('v.coverageEndDate');
        var today = helper.getTodayDate(component, event);



        if (dateValue !== null && dateValue !== undefined && coverageEndDate !== null && coverageEndDate !== undefined) {

            var coverageEndDate = new Date(helper.getDateReadableFormat(coverageEndDate));
            var purchaseDate = new Date(helper.getDateReadableFormat(dateValue));
            today = new Date(today);

            if (purchaseDate > today) {
                component.set('v.error.fieldError.purchaseDate', 'Purchase date cannot be after today.');
            } else {
                if (purchaseDate > coverageEndDate) {
                    component.set('v.error.fieldError.purchaseDate', 'Purchase date cannot be after coverage end date.');
                } else {
                    component.set('v.error.fieldError.coverageEndDate', '');
                    component.set('v.error.fieldError.purchaseDate', '');
                }

            }

        }


        component.set('v.isSearchPolicyClicked', false);
        component.set('v.isSearchPolicyExecuting', false);
        component.set("v.PolicyList", null);



    },

    resetCustomer: function(component, event, helper) {
        component.set('v.customer', null);
        var formNewAccount = {
            sobjectType: 'Account',
            Name: null,
            ShippingState: null,
            ShippingStreet: null,
            ShippingCountry: null,
            ShippingPostalCode: null,
            Phone: null,
            Email__c: null,
            Website: null,
            Warranty_Account_Type__c: 'Customer'
        };
        component.set('v.formNewAccount', formNewAccount);
        component.set('v.customerId', null);
    },

    hideErrorMessage: function(component, event, helper) {
        component.set("v.isError", false);
    },

    hideCNError: function(component, event, helper) {
        component.set("v.showCustomerNameError", false);
    },

    hideEError: function(component, event, helper) {
        component.set("v.showEmailError", false);
        var errorInput = component.find('emailError');
        $A.util.removeClass(errorInput, 'errorCSS');
    },
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
    deregisterWarentyRegistration: function(component, event, helper) {

        var policiesList = JSON.parse(JSON.stringify(component.get('v.PolicyList')));       
        var CurrentInv = JSON.parse(JSON.stringify(component.get('v.CurrentInventory')));        
        var getcoverages = component.get('c.getAllCoveragesRealtedtoInventory');
        getcoverages.setParams({
            "invId": CurrentInv[0].Id
        });

        getcoverages.setCallback(this, function(getCoveragesResponse) {           
            var state = getCoveragesResponse.getState();
            if (state === "SUCCESS" && component.isValid()) {
                var returnedvalue = getCoveragesResponse.getReturnValue();
                var response = [];
                var deRegistrationDate = CurrentInv[0].De_Registration_Date__c;
                var date1 = new Date();
                var date2 = new Date(deRegistrationDate);
                var timeDiff = Math.abs(date1.getTime() - date2.getTime());
                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));                
                response = JSON.parse(returnedvalue);
                if (response !== null && response !== undefined) {
                    for (var i = 0; i < policiesList.length; i++) {

                        for (var j = 0; j < response.length; j++) {

                            if (response[j]['Policy_Definition__r']['Name'] === policiesList[i].ObjPolicyDefinition.Name && policiesList[i].selected == true) {
                                var date3 = new Date(response[j]['Warranty_End_Date__c']);                                
                                response[j]['Is_Active__c'] = true;
                                var finalizedDate = new Date(date3.getTime() + diffDays * 24 * 60 * 60 * 1000);
                                var endDate = (finalizedDate.getMonth() + 1) + '/' + finalizedDate.getDate()+ '/' + finalizedDate.getFullYear();
								console.log('**************'+JSON.stringify(endDate));
                                response[j]['Warranty_End_Date__c'] = Date.parse(endDate);

                            }
                        }
                    }
                    var reponseJson = JSON.stringify(response);                    
                    helper.updateCoverages(component, event, helper, reponseJson);
                }

            }

        });
        $A.enqueueAction(getcoverages);

    },
    closeCustomerErrorModal: function(component, event, helper) {
        component.set('v.customerBackendErrorModal', false);
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

})