({
    doInit: function(component, event, helper) {
        
        var isScrappedOrStolen = component.get('v.scrappedOrStolen');
        
        if(isScrappedOrStolen){
            
            var alertBoxData = {
                title: $A.get("$Label.c.Page_Blocker_Title"),
                message: $A.get("$Label.c.Page_Blocker_Message"),
                okayButtonTitle: $A.get("$Label.c.Okay")
            };
            component.set('v.alertBoxData',alertBoxData);
            
        }else{
            
            var lookupInventoryWhereClause = component.get('v.lookupInventoryWhereClause');
            var inventoryId = component.get('v.inventoryId');
            console.log('rgertfgrt');
            //usageTypeList
            
            var today = new Date();
            var todayDateString = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
            component.set('v.coverageEndDate', todayDateString);
            
            
            
            var action = component.get("c.usageTypeRetrun");
            action.setParams({});
            action.setCallback(this, function(a) {
                console.log('------ inside isMultipleWarrantyRegistration------');
                console.log(a.getReturnValue());
                component.set('v.usageTypeList', a.getReturnValue());
            });
            $A.enqueueAction(action);
            
            // list of  user type
            
            
            lookupInventoryWhereClause = ' Id !=' + '\'' + inventoryId + '\'' + ' AND ' + lookupInventoryWhereClause;
            console.log('=================' + lookupInventoryWhereClause);
            
            component.set('v.lookupInventoryWhereClause', lookupInventoryWhereClause);
            var action = component.get("c.isMultipleWarrantyRegistration");
            action.setParams({});
            action.setCallback(this, function(a) {
                console.log('------ inside isMultipleWarrantyRegistration------');
                console.log(a.getReturnValue());
                component.set('v.ismultipleWarrantyRegistration', a.getReturnValue());
            });
            $A.enqueueAction(action);
            
            /***********new account empty initialization***********/
            
            var formNewAccount = {
                sobjectType: 'Account',
                Name: null,
                ShippingState: null,
                ShippingStreet: null,
                ShippingCountry: null,
                ShippingPostalCode: null,
                Phone: null,
                Website: null,
                Warranty_Account_Type__c: 'Customer'
            };
            component.set('v.formNewAccount', formNewAccount);
            
            /******************************************************/
            console.log('==========usageType=======' + component.get("v.usageType"));
            
            helper.fetchInventory(component, event, helper);
            
            
        }
        
        
    },
    
    addselectedInventory: function(component, event, helper) {
        console.log('--------- inside add selected inv---------');
        console.log(component.get('v.selectedInventoryId'));
        helper.selectedInventoryId = component.get('v.selectedInventoryId');
        var isAddInvClicked = component.get('v.isAddInvClicked');
        if (component.get('v.selectedInventoryId') != null && component.get('v.selectedInventoryId') != '' && isAddInvClicked == false) {
            component.set('v.isAddInvClicked', true)
            component.set('v.isAddInventoryClicked', true);
            helper.constructMultipleInventoriesTable(component, event, helper);
        }
    },
    
    deleteInventoryBlock: function(component, event, helper) {
        console.log(event);
        console.log(event.target);
        var currentRecordNum = 0;
        if (typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0) {
            currentRecordNum = event.target.parentElement.tabIndex;
        } else {
            currentRecordNum = event.target.parentNode.parentElement.tabIndex;
        }
        console.log(currentRecordNum);
        
        if (currentRecordNum >= 0) {
            var deleteId = 'Id_' + currentRecordNum;
            console.log(deleteId);
            console.log(document.getElementById(deleteId));
            var row = document.getElementById(deleteId);
            console.log('inv id-----');
            console.log(row.lang);
            var InventoryId = row.lang;
            row.parentNode.removeChild(row);
            
            console.log("removed");
            
            var policyBlockInventory = document.getElementById('Id_' + InventoryId);
            console.log('inv----');
            console.log(policyBlockInventory);
            if (policyBlockInventory != null) {
                console.log(policyBlockInventory.parentNode);
                console.log(policyBlockInventory.parentNode.removeChild(policyBlockInventory));
                
                
            }
            
            var inventoryWithPolicies = helper.inventoryWithPolicies;
            var PolicyTableindex = inventoryWithPolicies.indexOf(InventoryId);
            console.log(PolicyTableindex);
            if (PolicyTableindex > -1) {
                inventoryWithPolicies.splice(PolicyTableindex, 1);
            }
            helper.inventoryWithPolicies = inventoryWithPolicies;
            
            var policiestodelete = component.get('v.mapInventoryPolicies')[InventoryId];
            console.log('policies-----');
            console.log(policiestodelete);
            
            if (typeof policiestodelete != 'undefined') {
                for (var i = 0; i < policiestodelete.length; i++) {
                    var policydeletionId = policiestodelete[i].ObjPolicyDefinition['Id'];
                    var policyrow = document.getElementById('Id_' + policydeletionId + '_' + InventoryId);
                    console.log(policyrow);
                    if (policyrow != null)
                        policyrow.parentNode.removeChild(policyrow);
                }
            }
            var lstSelectedInventories = component.get('v.lstSelectedInventories');
            console.log('--------before--lstSelectedInventories---');
            console.log(lstSelectedInventories);
            var index = lstSelectedInventories.indexOf(InventoryId);
            console.log(index);
            if (index > -1) {
                lstSelectedInventories.splice(index, 1);
            }
            console.log('--------after-----');
            console.log(lstSelectedInventories);
            component.set('v.lstSelectedInventories', lstSelectedInventories);
            var selectedInventories = component.get('v.selectedInventories');
            console.log('--------before--selectedInventories---');
            console.log(selectedInventories);
            var listIndex = -1;
            for (var i = 0; i < selectedInventories.length; i++) {
                if (selectedInventories[i].Id == InventoryId) {
                    listIndex = i;
                }
            }
            if (listIndex != -1) {
                console.log('--------------selected inventoryIndex----------' + listIndex);
                selectedInventories.splice(listIndex, 1);
            }
            console.log('--------after--selectedInventories---');
            console.log(selectedInventories);
            //component.policysearch(component, event, helper);
        }
    },
    
    searchPolicy: function(component, event, helper) {
        var isSearchPolicyExecuting = component.get('v.isSearchPolicyExecuting');
        if (isSearchPolicyExecuting == false) {
            console.log('inside search policy------------');
            var isError = helper.validateInputs(component, event, helper);
            
            console.log('is Error')
            
            if (isError == true) {
                component.set('v.isError', true);
            } else {
                component.set('v.isSearchPolicyExecuting', true);
                component.set('v.isRegisterDisabled', true);
                if (typeof document.getElementsByClassName('delete-Icon-E-D') != 'undefined') {
                    for (var i = 0; i < document.getElementsByClassName('delete-Icon-E-D').length; i++) {
                        document.getElementsByClassName('delete-Icon-E-D')[i].style.display = 'none';
                    }
                }
                component.set('v.isError', false);
                component.set('v.isRegistrationError', false);
                console.log('----searchPolicy-------');
                console.log('existing inventories in table---------');
                console.log('----selectedInventories-------');
                console.log(component.get('v.selectedInventories'));
                console.log(component.get('v.selectedInventories').length);
                if (component.get('v.selectedInventories').length > 0) {
                    helper.selectedInventoriesSize = component.get('v.selectedInventories').length;
                    helper.currentInventory = 0;
                    helper.addInventorywithpolicies(component, event, helper);
                }
            }
        }
    },
    
    UnitsRunChange: function(component, event, helper) {
        console.log(event.getSource());
        var eventSource = event.getSource();
        console.log(eventSource.get('v.value'));
        console.log(eventSource.get('v.class'));
        var unitValue = eventSource.get('v.value');
        var InvId = eventSource.get('v.class').split(' ')[1];
        console.log(unitValue);
        console.log(InvId);
        var selectedInventories = component.get('v.selectedInventories');
        for (var i = 0; i < selectedInventories.length; i++) {
            if (selectedInventories[i].Id == InvId) {
                selectedInventories[i].Units_Run__c = unitValue;
            }
        }
        component.set('v.selectedInventories', selectedInventories);
        
    },
    
    registerInv: function(component, event, helper) {
        component.set('v.isRegisterDisabled', true);
        var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
        console.log('-----------------inside register inventory---------');
        var selectedInventories = component.get('v.selectedInventories');
        /*if(typeof selectedInventories != 'undefined'){
            var atleastOneSelectedForInv = 'false';
            for(var i=0;i<selectedInventories.length;i++){
                var policydef = mapInventoryPolicies[selectedInventories[i].Id];
                if(policydef.length > 0 && typeof policydef != 'undefined'){
                    var isOneSelected = 'false';
                    for(var j=0;j<policydef.length;j++){
                        if(policydef[j].selected){
                            isOneSelected = 'true';
                        }
                    }
                }
                if(isOneSelected == 'false'){
                    atleastOneSelectedForInv = 'true';
                    //component.set('v.message','Registration can not be done without selecting any Policy');
                    //component.set('v.isError',true);
                    //break;
                }
                if(i == selectedInventories.length-1 && ){

                }
            }
            if(atleastOneSelectedForInv == 'false'){
                component.set('v.isError',false);
                helper.registerInventoriesSize = component.get('v.selectedInventories').length;
                helper.currentRegisterInventory = '0';
                helper.registerInventoryHelper(component,helper);
            }
        }*/
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
                component.set('v.isRegisterDisabled', false);
            } else if (isOneSelected > 0) {
                component.set('v.isRegistrationError', false);
                helper.registerInventoriesSize = component.get('v.selectedInventories').length;
                helper.currentRegisterInventory = '0';
                helper.registerInventoryHelper(component, helper);
            } else {
                component.set('v.registrationErrorMessage', 'Registration can not be done without selecting any Policy');
                component.set('v.isRegistrationError', true);
                component.set('v.isRegisterDisabled', false);
            }
        }
    },
    
    checkedPolicies: function(component, event, helper) {
        console.log('inside checkbox click');
        console.log(event);
        console.log(event.getSource());
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        console.log(checkbox.get("v.class"));
        
        var index_InventoryId = checkbox.get("v.class").split('_');
        var index = index_InventoryId[0];
        var InventoryId = index_InventoryId[1];
        var value = checkbox.get("v.value");
        
        if (index != 'undefined' && typeof index != 'undefined') {
            console.log('index is not null');
            var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
            var policydeflist = mapInventoryPolicies[InventoryId];
            console.log('--------------- policies before change------');
            console.log(component.get('v.mapInventoryPolicies'));
            console.log(policydeflist[index].selected);
            policydeflist[index].selected = value;
            component.set('v.mapInventoryPolicies', mapInventoryPolicies);
            console.log('--------------- policies after change------');
            console.log(component.get('v.mapInventoryPolicies'));
        }
        
    },
    
    cancelclick: function(component, event, helper) {
        var BaseUrl = component.get('v.BaseURL');
        var inventoryId = component.get('v.inventoryId');
        
        if (inventoryId != null && inventoryId != undefined && inventoryId!='') {
            if (BaseUrl.indexOf('lightning') != -1) {
                component.set('v.cancelUrl', '/one/one.app#/sObject/' + inventoryId + '/view');
            } else if (BaseUrl.indexOf('hustler') != -1) {
                component.set('v.cancelUrl', '/hustler/' + inventoryId);
            } else if (BaseUrl.indexOf('bigdog') != -1) {
                component.set('v.cancelUrl', '/bigdog/' + inventoryId);
            } else{
                component.set('v.cancelUrl', '/' + inventoryId);
            }
             
            
        }
        window.location.href=component.get('v.cancelUrl');
    },
    
    fetchselectedcustomerdata: function(component, event, helper) {
        console.log('-------------customer dataa');
        console.log(component.get('v.customer'));
        var customerId = component.get('v.customerId');
        if (customerId != null && typeof customerId != 'undefined') {
            var query = 'SELECT Id,Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM Account Where Id=' + '\'' + customerId + '\'';
            
            helper.readRaw(component, event, query, function(response) {
                
                
                console.log('----response customer--------');
                console.log(response);
                
                console.log(response[0]);
                component.set('v.customer', response[0]);
                console.log(component.get('v.customer'));
                console.log(component.get('v.customer.Name'));
            });
        }
    },
    
    continueMultipleInventoryPolicySelection: function(component, event, helper) {
        console.log(component.get('v.selectedInventories'));
    },
    
    setCreateCustomerModal: function(component, event, helper) {
        component.set('v.showCreateCustomerModal', true);
    },
    
    saveCustomer: function(component, event, helper) {
        
        /*** check for account name is not null or empty ***/
        var customer = JSON.parse(JSON.stringify(component.get('v.formNewAccount')));
        if (customer.Name != null && customer.Name != '') {
            
            // show spinner
            component.set('v.showSpinner', true);
            
            
            helper.insertRaw(component, event, customer, function(response) {                
                //hide spinner
                component.set('v.showSpinner', false);
                console.log(response);
                if (response.sobjectsAndStatus != null && response.sobjectsAndStatus != undefined &&
                    response.sobjectsAndStatus.length != 0 && response.sobjectsAndStatus[0].status == 'successful') {
                    
                    component.set('v.showCreateCustomerModal', false);
                    var idOfAccount = response.sobjectsAndStatus[0]['sObject']['Id'];
                    component.set('v.customer', response.sobjectsAndStatus[0]['sObject']);
                    component.set('v.customerId', idOfAccount);
                    
                } else {
                    console.log(response);
                }
            });            
        }        
    },
    
    cancelCustomermake: function(component, event, helper) {
        component.set('v.showCreateCustomerModal', false);
    },
    
    onChangeUsageType: function(component, event, helper) {
        component.set('v.isSearchPolicyClicked',false);
        component.set('v.isSearchPolicyExecuting',false);
        helper.inventoryWithPolicies = [];
    }    
})