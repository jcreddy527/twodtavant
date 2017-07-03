({
    doInit: function(component, event, helper) {
        
        
        var isScrappedOrStolen = component.get('v.scrappedOrStolen');
        helper.showAlert(component, event, {});
        
        if (isScrappedOrStolen) {
            
            var alertBoxData = {
                title: $A.get("$Label.c.Page_Blocker_Title"),
                message: $A.get("$Label.c.Page_Blocker_Message"),
                okayButtonTitle: $A.get("$Label.c.Okay")
            };
            component.set('v.alertBoxData', alertBoxData);
            
        } else {
            
            component.set('v.date',helper.getTodayDate(component,event));
            var query = "select Id,Serial_Number__c,Name,Units_Run__c,Account__c,Is_D2D_Approval_Needed__c,Install_Date__c,"+
                "Is_ERT_Approval_Needed__c,Account__r.Name,Customer__c,Customer__r.Name,Type__c,"+
                "Item__c,Item__r.Name,Item__r.Units_of_Measure__c from Inventory__c "+
                "where Inventory__c.Id = '" + component.get("v.inventoryId") + "'";
            
            helper.readRaw(component, event, query, function(response) {
             
                component.set('v.inventory', response[0]);
                
                if(component.get('v.inventory.Units_Run__c') != null){
                	var unitsRun = component.get('v.inventory.Units_Run__c');
                    component.set('v.unitsRun',unitsRun);
                }
                    
            
                if (component.get('v.inventory.Item__r.Units_of_Measure__c') != null) {
                    component.set('v.isUnitRun', true);
                }
                
                
                /////////////////////////
                
                var query1 = "Select Is_Active__c,ERT_Selected__c,Policy_Definition__r.Name,"+
                    "Policy_Definition__r.Transferable__c,Policy_Definition__r.Transfer_Fee__c "+
                    "from Warranty_Coverages__c where Warranty_Registration__r.Inventory__c = '" +
                    component.get("v.inventoryId") + "'and Is_Active__c=true";
             
                helper.readRaw(component, event, query1, function(response) {
                    component.set('v.policy', response);
                    component.set('v.markedPolicyList', response);
                  
                    if (component.get('v.policy').length <= 0) {
                        component.set('v.isNoPolicies', true);
                    }
                    var Inventory = component.get("v.inventory");
                    if (Inventory.Is_ERT_Approval_Needed__c == false) {
                        for (var i = 0; i < component.get('v.policy').length; i++) {
                            var policyInactive = component.get('v.policy')[i];
                            policyInactive.Is_Active__c = false;
                            
                        }
                    }
                });
                
                
                /////////////////////////
                
                
                
                
            });
            
            
            
            
            
            
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
            
            
        }
        
    },
    
    Cancel: function(component, event, helper) {
        var ProceedURL = '';
        var BaseUrl = component.get('v.BaseURL');
        var inventoryId = component.get('v.inventoryId');
        
        if (BaseUrl != 'undefined' && typeof BaseUrl != 'undefined') {
            if (BaseUrl.indexOf('lightning') != -1)
                ProceedURL = "/one/one.app#/sObject/" + inventoryId + '/view';
            else
                ProceedURL = BaseUrl + "/" + inventoryId;
        } else {
            if (BaseUrl.indexOf('lightning') != -1)
                ProceedURL = "/one/one.app#/sObject/" + inventoryId + '/view';
            else
                ProceedURL = "/" + inventoryId;
        }
        component.set('v.ProceedURL', ProceedURL);
        window.location.href = ProceedURL;
    },
    
    hideSuccessAlert: function(component, event, helper) {
        component.set("v.truthy", false);
    },
    
    check: function(component, event, helper) {
        var check = event.getSource().get('v.value');
        var value = event.getSource().get('v.text');
        var policyList = JSON.parse(JSON.stringify(component.get('v.markedPolicyList')));
        var inventory = JSON.parse(JSON.stringify(component.get("v.inventory")));
        
        var index = helper.findIndexWithProperty(policyList,'Id',value);
        if(index>-1){
            
            if(inventory.Is_ERT_Approval_Needed__c == true){
                
                if (check == true) {
                    policyList[index]["ERT_Selected__c"] = true;
                }else{
                    policyList[index]["ERT_Selected__c"] = false;
                }
                
            }else{
                
                if (check == true) {
                    policyList[index]["Is_Active__c"] = true;
                }else{
                    policyList[index]["Is_Active__c"] = false;
                }
                
            }
            
        }
        
     
        component.set('v.markedPolicyList', policyList);
        
    },
    
    inventoryTransfer: function(component, event, helper) {
        
        var transferDate = component.get('v.date');
        var todayDate = helper.getTodayDate(component,event);
        var purchaseDate = helper.getDateReadableFormat(component.get('v.inventory.Install_Date__c'));
        var transferDateError = '';
        
        if(new Date(transferDate)=='Invalid Date' || new Date(transferDate) > new Date(todayDate)  || new Date(transferDate) < new Date(purchaseDate)){
            transferDateError = $A.get('$Label.c.Transfer_Date_Error') + ' '+ $A.localizationService.formatDate(new Date(purchaseDate),'DD/MMM/YYYY');
            component.set('v.isAcknowledged',false);
        }else{
            transferDate = '';
        }
        
        if(transferDate===''){
            
            if ((component.get("v.inventory.Item__r.Units_of_Measure__c") != null) && (component.get("v.unitsRun") == null)) {
                component.set("v.resultMessage", $A.get("$Label.c.Units_Run_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.unitsRun") < component.get("v.inventory.Units_Run__c")) {
                component.set("v.resultMessage", 'Already Inventory Ran for ' + component.get("v.inventory.Units_Run__c") + ' ' + component.get("v.inventory.Item__r.Units_of_Measure__c") + $A.get("$Label.c.Check_Value_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.dealerId") == null || component.get("v.dealerId") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.Customer_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.date") == null || component.get("v.date") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.Transfer_Date_Mandatory_Error"));
                component.set("v.truthy", true);
            } else {
                var Transaction = component.get("v.transaction");
                Transaction.From__c = component.get("v.inventory.Customer__c");
                var Inventory = component.get("v.inventory");
                Transaction.To__c = component.get("v.dealerId");
                Transaction.Transfer_Date__c = component.get("v.date");
                Transaction.Comments__c = component.get("v.comments");
                Transaction.Inventory__c = component.get("v.inventoryId");
                Transaction.Units_Run__c = component.get("v.unitsRun");
                
                if (Inventory.Is_ERT_Approval_Needed__c == true) {
                    Transaction.Transaction_Type__c = "ETR Pending for Approval";
                    Inventory.Transfer_Initiated__c = "Initiated";
                } else {
                    Transaction.Transaction_Type__c = "ETR";
                    Inventory.Customer__c = component.get("v.dealerId");
                    Inventory.Transfer_Initiated__c = "New";
                    Inventory.Units_Run__c = component.get("v.unitsRun");
                    
                }
                
                
                helper.insertRaw(component, event, Transaction, function(response) {
                    
                    Inventory.Latest_Transaction__c = response.sobjectsAndStatus[0].sObject.Id;
                    
                    helper.updateRaw(component, event, Inventory, function(response) {
                        var ProceedURL = '';
                        var BaseUrl = component.get('v.BaseURL');
                        var inventoryId = component.get('v.inventoryId');
                        if (BaseUrl != 'undefined' && typeof BaseUrl != 'undefined') {
                            if (BaseUrl.indexOf('lightning') != -1)
                                ProceedURL = "/one/one.app#/sObject/" + inventoryId + '/view';
                            else
                                ProceedURL = BaseUrl + "/" + inventoryId;
                        } else {
                            if (BaseUrl.indexOf('lightning') != -1)
                                ProceedURL = "/one/one.app#/sObject/" + inventoryId + '/view';
                            else
                                ProceedURL = "/" + inventoryId;
                        }
                        component.set('v.ProceedURL', ProceedURL);
                        
                        ///////////////////////////////////updation of policies////////////////////////
                        
                        var updatablepolicies = [];
                        var policyList = JSON.parse(JSON.stringify(component.get('v.markedPolicyList')));
                        
                        for (var i = 0, len = policyList.length; i < len; i++) {
                            
                            var ertSelected = (policyList[i]["Policy_Definition__r"]["Transferable__c"]===false ?false : policyList[i]["ERT_Selected__c"] );
                            
                            var policy = {
                                Id: policyList[i].Id,
                                Is_Active__c: policyList[i]["Is_Active__c"],
                                ERT_Selected__c: ertSelected
                            };
                            
                            updatablepolicies.push(policy);
                        }
                    
                        
                        if (updatablepolicies.length != 0) {
                            helper.updateRaw(component, event, updatablepolicies, function(response) {
                                window.location.href = ProceedURL;
                            });
                        }
                        
                        /////////////////////////////////////////////////////////////////////////////////////
                        
                    });
                    
                    
                });
                
            }
            
 
        }else{
            
            // show the error message of no fault code found
            var alertboxContent = {
                message: transferDateError,
                heading: $A.get('$Label.c.Transfer_Page_Says'),
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            helper.showAlert(component, event, alertboxContent);
            
            
        }
        
        
    },
    
    setCreateCustomerModal: function(component, event, helper) {
        
        component.set('v.showCreateCustomerModal', true);
        
    },
    cancelCustomermake: function(component, event, helper) {
        
        component.set('v.showCreateCustomerModal', false);
        
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
           
                if (response.sobjectsAndStatus != null && response.sobjectsAndStatus != undefined &&
                    response.sobjectsAndStatus.length != 0 && response.sobjectsAndStatus[0].status == 'successful') {
                    
                    component.set('v.showCreateCustomerModal', false);
                    var idOfDealer = response.sobjectsAndStatus[0]['sObject']['Id'];
                    var nameOfDealer = response.sobjectsAndStatus[0]['sObject']['Name'];
                    component.set('v.dealerId', idOfDealer);
                    component.set('v.dealerName', nameOfDealer);
                    component.find('dealer-lookup').set('v.selectedValue', nameOfDealer);
                    component.find('dealer-lookup').set('v.selectedId', idOfDealer);
                    component.find('dealer-lookup').set('v.selSobject', nameOfDealer);
                    
                    
                } else {
                    
                    //check response
                    console.log(response);
                
                }
            });
            
        }
        
        
    },
    
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
    
})