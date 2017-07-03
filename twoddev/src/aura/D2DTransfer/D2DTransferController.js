({
    doInit: function(component, event, helper) {

        var isScrappedOrStolen = component.get('v.scrappedOrStolen');

        if (isScrappedOrStolen) {

            var alertBoxData = {
              title: $A.get("$Label.c.Page_Blocker_Title"),
              message: $A.get("$Label.c.Page_Blocker_Message"),
              okayButtonTitle: $A.get("$Label.c.Okay")
            };
            component.set('v.alertBoxData',alertBoxData);

        } else {

            var query = "select Id,Serial_Number__c,Name,Account__c,Is_D2D_Approval_Needed__c,Is_RMT_Approval_Needed__c,Is_ERT_Approval_Needed__c,Account__r.Name,Customer__c,Customer__r.Name,Type__c,Item__c,Item__r.Name,Item__r.Units_of_Measure__c,Units_Run__c from Inventory__c where Inventory__c.Id = '" + component.get("v.inventoryId") + "'";
            
            helper.readRaw(component, event, query, function(response) {
         
            	
                component.set('v.inventory', response[0]);
                
                if(component.get('v.inventory.Units_Run__c') != null){
                	var unitsRun = component.get('v.inventory.Units_Run__c');
                    component.set('v.unitsRun',unitsRun);
                }
                
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
    },

    inventoryTransferRMT: function(component, event, helper) {
        if ((component.get("v.inventory.Item__r.Units_of_Measure__c") != null) && (component.get("v.unitsRun") == null)) {
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
    },
})