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
            component.set('v.alertBoxData',alertBoxData);
            
        } else {
            
            var query = "select Id,Serial_Number__c,Name,Account__c,Is_D2D_Approval_Needed__c,Install_Date__c,"+
                "Is_RMT_Approval_Needed__c,Is_ERT_Approval_Needed__c,Account__r.Name,Customer__c,"+
                "Customer__r.Name,Type__c,Item__c,Item__r.Name,Item__r.Units_of_Measure__c,"+
                "Units_Run__c from Inventory__c where Inventory__c.Id = '" + component.get("v.inventoryId") + "'";
            
            helper.readRaw(component, event, query, function(response) {
         
                component.set('v.inventory', response[0]);
                if (component.get('v.inventory.Item__r.Units_of_Measure__c') != null) {
                    component.set('v.isUnitRun', true);
       
                }
            });
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
        
        window.location.href=ProceedURL;
        
    },
    
    hideSuccessAlert: function(component, event, helper) {
        component.set("v.truthy", false);
    },
    
    inventoryTransfer: function(component, event, helper) {
        
        var validationSuccess  = helper.validationSuccesStatus(component,event);
        
        if(validationSuccess === true){ 
            
            
            if ((component.get("v.inventory.Item__r.Units_of_Measure__c") != null) && (component.get("v.unitsRun") == null || component.get("v.unitsRun") == 0 || isNaN(component.get("v.unitsRun")))) {
                component.set("v.resultMessage", $A.get("$Label.c.Units_Run_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.unitsRun") < component.get("v.inventory.Units_Run__c")) {
                component.set("v.resultMessage", 'Already Inventory Ran for ' + component.get("v.inventory.Units_Run__c") + ' ' + component.get("v.inventory.Item__r.Units_of_Measure__c") + $A.get("$Label.c.Check_Value_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.dealerId") == null || component.get("v.dealerId") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.New_Dealer_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.date") == null || component.get("v.date") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.Transfer_Date_Mandatory_Error"));
                component.set("v.truthy", true);
            } else {
            
                var Transaction = component.get("v.transaction");
                var Inventory = component.get("v.inventory");
                Transaction.From__c = component.get("v.inventory.Account__c");
                Transaction.To__c = component.get("v.dealerId");
                Transaction.Transfer_Date__c = component.get("v.date");
                Transaction.Comments__c = component.get("v.comments");
                Transaction.Units_Run__c = component.get("v.unitsRun");
                
                Transaction.Inventory__c = component.get("v.inventoryId");
                if (Inventory.Is_D2D_Approval_Needed__c == true) {
                    Transaction.Transaction_Type__c = "D2D Pending for Approval";
                    Inventory.Transfer_Initiated__c = "Initiated";
                } else {
                    Transaction.Transaction_Type__c = "D2D";
                    Inventory.Account__c = component.get("v.dealerId");
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
            }
            
        }else{
            var alertBoxData = {
                message: $A.get('$Label.c.Please_Review_All_Error_Messages'),
                heading: $A.get('$Label.c.Page_Says'),
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            helper.showAlert(component, event, alertBoxData);
        }
    },
    
    inventoryTransferRMT: function(component, event, helper) {
        
        var validationSuccess  = helper.validationSuccesStatus(component,event);
        
        if(validationSuccess === true){ 
            
            if ((component.get("v.inventory.Item__r.Units_of_Measure__c") != null) && (component.get("v.unitsRun") == null)) {
                component.set("v.resultMessage", $A.get("$Label.c.Units_Run_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.unitsRun") < component.get("v.inventory.Units_Run__c")) {
                component.set("v.resultMessage", 'Already Inventory Ran for ' + component.get("v.inventory.Units_Run__c") + ' ' 
                              + component.get("v.inventory.Item__r.Units_of_Measure__c") + $A.get("$Label.c.Check_Value_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.dealerId") == null || component.get("v.dealerId") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.New_Dealer_Mandatory_Error"));
                component.set("v.truthy", true);
            } else if (component.get("v.date") == null || component.get("v.date") == '') {
                component.set("v.resultMessage", $A.get("$Label.c.Transfer_Date_Mandatory_Error"));
                component.set("v.truthy", true);
            } else {
                var Transaction = component.get("v.transaction");
                var Inventory = component.get("v.inventory");
                Transaction.From__c = component.get("v.inventory.Account__c");
                Transaction.To__c = component.get("v.dealerId");
                Transaction.Transfer_Date__c = component.get("v.date");
                Transaction.Comments__c = component.get("v.comments");
                Transaction.Units_Run__c = component.get("v.unitsRun");
                
                Transaction.Inventory__c = component.get("v.inventoryId");
                if (Inventory.Is_RMT_Approval_Needed__c == true) {
                    Transaction.Transaction_Type__c = "RMT Pending for Approval";
                    Inventory.Transfer_Initiated__c = "RMT Initiated";
                } else {
                    Transaction.Transaction_Type__c = "RMT";
                    Inventory.Account__c = component.get("v.dealerId");
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
            }
        }else{
            
            var alertBoxData = {
                message: 'Please review all error messages..',
                heading: 'Warranty registration page says..',
                class: 'slds-theme--error',
                callableFunction: component.getReference('c.closeAlert'),
                buttonHeading: $A.get("$Label.c.OK")
            };
            helper.showAlert(component, event, alertBoxData);
            
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
        }        
    },
    
    transferDateHandeler : function(component,event,helper){
        
        var dateValue = component.get('v.date');
        var today = helper.getTodayDate(component,event);
        
        if(dateValue!==null && dateValue!==undefined && dateValue!==''){
            
            var transferDate = new Date(dateValue);
            if(transferDate=='Invalid Date'){
                
                component.set('v.error.fieldError.transferDate','Invalid Date');
                
            }else{
                
                today = new Date(today);
                if(transferDate > today ){
                    
                    component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Error'));
                    
                }else{
                    
                    var inventory = JSON.parse(JSON.stringify(component.get('v.inventory')));
                    var installedDate = inventory['Install_Date__c'];
                    
                    if(installedDate!==null && installedDate!==undefined && installedDate!==''){
                        
                        //case for RMT    
                        installedDate = new Date(installedDate);
                        if(transferDate<installedDate){
                            component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Error')
                                          + helper.getDateReadableFormat(installedDate));
                        }else{
                            
                            component.set('v.error.fieldError.transferDate','');
                        }
                        
                    }else{
                        
                        //other cases
                        component.set('v.error.fieldError.transferDate','');
                    }
                    
                }
                
            }
            
        }else{
            
            component.set('v.error.fieldError.transferDate',$A.get('$Label.c.Transfer_Date_Mandatory'));
            
        }
        
    },
    
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
})