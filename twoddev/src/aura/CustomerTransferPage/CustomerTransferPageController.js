({
    doInit: function(component, event, helper) {
        var isScrappedOrStolen = component.get('v.scrappedOrStolen');
        var error = {
            fieldError:{
            	transferDate : '' 
        	}
            
        };
        component.set('v.error',error);
        helper.showAlert(component, event, {});
        if (isScrappedOrStolen) {
            var alertBoxData = {
                title: $A.get("$Label.c.Page_Blocker_Title"),
                message: $A.get("$Label.c.Page_Blocker_Message"),
                okayButtonTitle: $A.get("$Label.c.Okay")
            };
            component.set('v.alertBoxData', alertBoxData);

        } else {
            var query = "select Id,Serial_Number__c,Name,Units_Run__c,Account__c,Is_D2D_Approval_Needed__c,Is_ERT_Approval_Needed__c,Account__r.Name,Customer__c,Customer__r.Name,Type__c,Item__c,Item__r.Name,Item__r.Units_of_Measure__c from Inventory__c where Inventory__c.Id = '" + component.get("v.inventoryId") + "'";
           
            helper.readRaw(component, event, query, function(response) {
           
                component.set('v.inventory', response[0]);
              
                if (component.get('v.inventory.Item__r.Units_of_Measure__c') != null) {
                    component.set('v.isUnitRun', true);
              
                }
            });
            
            var query1 = "Select Is_Active__c,ERT_Selected__c,Policy_Definition__r.Name,Policy_Definition__r.Transferable__c,Policy_Definition__r.Transfer_Fee__c from Warranty_Coverages__c where Warranty_Registration__r.Inventory__c = '" + component.get("v.inventoryId") + "'and Is_Active__c=true";
        
            helper.readRaw(component, event, query1, function(response) {
                component.set('v.policy', response);
             
                component.set('v.isNoPolicies', component.get('v.policy').length);
               
                
                var Inventory = component.get("v.inventory");
               
                if (Inventory.Is_ERT_Approval_Needed__c == false) {
                    for (var i = 0; i < component.get('v.policy').length; i++) {
                        var policyInactive = component.get('v.policy')[i];
                        policyInactive.Is_Active__c = false;
                    }
                }
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
                Email__c: null,
                Website: null,
                Warranty_Account_Type__c: 'Customer'
            };
            component.set('v.formNewAccount', formNewAccount);
            /******************************************************/
            
            component.set('v.confirmBtnClicked', false);
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
        var check = event.srcElement.checked;
        var value = event.srcElement.value;
 
        for (var i = 0; i < component.get('v.policy').length; i++) {
            if (value == component.get('v.policy')[i].Id) {
                var policyInactive = component.get('v.policy')[i];
              
            }

        }
        var Inventory = component.get("v.inventory");
        if (Inventory.Is_ERT_Approval_Needed__c == true) {
            policyInactive.Is_Active__c = true;
            if (check == true) {
                policyInactive.ERT_Selected__c = true;
            }
            if (check == false) {
                policyInactive.ERT_Selected__c = false;
            }
        } else {
            if (check == true) {
                policyInactive.Is_Active__c = true;
            }
            if (check == false) {
                policyInactive.Is_Active__c = false;
            }
        }
  
    },

    inventoryTransfer: function(component, event, helper) {
        
         var validationSuccess  = helper.validationSuccesStatus(component,event);
        
        if(validationSuccess === true){ 
            if(!component.get('v.confirmBtnClicked')){
  
                
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
                    component.set('v.confirmBtnClicked', true);                
                    var confirmButton = component.find('confirmBtn');
                    $A.util.addClass(confirmButton, 'BtnCSS');
                 
                    
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
                            window.location.href = ProceedURL;
                        });
                    });
                    
                    var updatablepolicies = [];
             
                    for (var i = 0; i < component.get('v.policy').length; i++) {
                        var policy = {
                            Id: component.get('v.policy')[i].Id,
                            Is_Active__c: component.get('v.policy')[i].Is_Active__c,
                            ERT_Selected__c: component.get('v.policy')[i].ERT_Selected__c
                        };
                        if ((component.get('v.policy')[i].Policy_Definition__r.Transferable__c == false)) {
                            var policyInactive = component.get('v.policy')[i];
                            policy.ERT_Selected__c = false;
                        }
                        updatablepolicies.push(policy);
                    }
                    
               
                    
                    if (updatablepolicies.length != 0) {
                        helper.updateRaw(component, event, updatablepolicies, function(response) {});
                    }
                }
            }
            
        }else{
            
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
	
    transferDateHandeler : function(component,event,helper){
        
        var dateValue = component.get('v.date');
        var today = helper.getTodayDate(component,event);
        
        if(dateValue!==null && dateValue!==undefined){
            var transferDate = new Date(dateValue);
            today = new Date(today);
            if(transferDate > today ){
                component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Error'));
            }else{
            	component.set('v.error.fieldError.transferDate','');
            }
            
        }
        
    },
    
    setCreateCustomerModal: function(component, event, helper) {
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
        component.set('v.showCreateCustomerModal', true);
    },
    cancelCustomermake: function(component, event, helper) {
        component.set('v.showCreateCustomerModal', false);
    },
    saveCustomer: function(component, event, helper) {
        /*** check for account name is not null or empty ***/
        var customer = JSON.parse(JSON.stringify(component.get('v.formNewAccount')));
        if (customer.Name != null && customer.Name != '' && customer.Email__c != null && customer.Email__c != '') {
            // show spinner
            component.set('v.showSpinner', true);
            
            var errorInput = component.find('emailError');
            $A.util.removeClass(errorInput, 'errorCSS');
            
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
                  
                    component.set('v.showEmailError',true);
                    component.set('v.validationEError',response.errorArrays[0].errorMesssages[0]);                    
                    
                    $A.util.addClass(errorInput, 'errorCSS');
                }
            });
        }else{
            if(customer.Name == null && customer.Email__c == null){
                component.set('v.showCustomerNameError',true);
                component.set('v.validationCNError',$A.get('$Label.c.Customer_Name_Is_Mandatory'));
                component.set('v.showEmailError',true);
                component.set('v.validationEError',$A.get('$Label.c.CustomerEmail_Mandatory'));
            }
            
            if(customer.Name == null || customer.Name ==''){
              
                component.set('v.showCustomerNameError',true);
                component.set('v.validationCNError',$A.get('$Label.c.Customer_Name_Is_Mandatory'));
            }
            
            if(customer.Email__c == null || customer.Email__c == ''){
               
                component.set('v.showEmailError',true);
                component.set('v.validationEError',$A.get('$Label.c.CustomerEmail_Mandatory'));
            }
        }
    },
    validateAccordionOpen : function(component, event, helper) {
    
        var accordionId = event.target.id;
        
        switch(accordionId){
            case "accordion-c-1": {
                // first accordion body
                var tranferInfotab = component.find('accordion-c-1-body');
                
                if ($A.util.hasClass(tranferInfotab, 'tab-close')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-close');
                    $A.util.addClass(tranferInfotab, 'tab-open');
                    
                } else if ($A.util.hasClass(tranferInfotab, 'tab-open')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-open');
                    $A.util.addClass(tranferInfotab, 'tab-close');                    
                }
                break;
            }
            case "accordion-c-2": {
                // Second accordion body
                var tranferInfotab = component.find('accordion-c-2-body');
                
                if ($A.util.hasClass(tranferInfotab, 'tab-close')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-close');
                    $A.util.addClass(tranferInfotab, 'tab-open');
                    
                } else if ($A.util.hasClass(tranferInfotab, 'tab-open')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-open');
                    $A.util.addClass(tranferInfotab, 'tab-close');                    
                }
                break;
            }
                case "accordion-c-3": {
                // Third accordion body
                var tranferInfotab = component.find('accordion-c-3-body');
                
                if ($A.util.hasClass(tranferInfotab, 'tab-close')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-close');
                    $A.util.addClass(tranferInfotab, 'tab-open');
                    
                } else if ($A.util.hasClass(tranferInfotab, 'tab-open')) {
                    
                    $A.util.removeClass(tranferInfotab, 'tab-open');
                    $A.util.addClass(tranferInfotab, 'tab-close');                    
                }
                break;
            }
        }        
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
    
})