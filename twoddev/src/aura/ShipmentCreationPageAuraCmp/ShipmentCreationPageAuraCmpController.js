({
    doInit : function(component, event, helper) {
        
        component.set( "v.searchsymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#open"));
        component.set("v.RecoveryClaimURL",helper.renderURL(component.get("v.baseURL"),component.get("v.RecoveryClaimId")));
        component.set("v.ShowShipmentRecords",true);
        component.set("v.ShowStartingPage",true);
        component.set("v.CreateNewShipment",true);
        component.set("v.ShowAddpartsToShipmentComponent",false);
        component.set("v.ShowShipmentCreationPage",false);
        component.set("v.OpenSelectedShipment",false);
        var RecoveryClaimQuery = helper.Recovery_Claim +  "'" + component.get("v.RecoveryClaimId") + "'";
        //Fetch the returnlocation from the Recovery Claim
        helper.readDom(component, event, RecoveryClaimQuery, "v.SupplyRecoveryClaim", "v.dmlErrors", function(returnedValues) {
            console.log("helllo");
            console.log(returnedValues);
            
            //If the Recovery Claim is in Draft navigate back to the Recovery Claim Page
            if(component.get("v.SupplyRecoveryClaim.Status__c") == 'Draft'){
                alert('Shipment Cannot Be initiate on the Draft Claim'); 
                helper.NavigateToRecoveryClaimPage(component,component.get("v.SupplyRecoveryClaim.Id")); 
            } 
            
            component.set("v.ReturnLocation",component.get("v.SupplyRecoveryClaim.Supplier_Contract__r.Part_Return_Location__c"));
            var ShipmentQuery = helper.Shipment_Query   + "'" + component.get("v.ReturnLocation") + "'";
            
            //Fetch the Shipment Which are not shipped and matches the return Location on the Supply Recovery Claim
            helper.readDom(component, event, ShipmentQuery, "v.ShipmentRecordList", "v.dmlErrors", function(returnedValues) {
                
                component.set("v.ReturnLocation",component.get("v.ShipmentRecordList")[0].Return_Location__c);
                component.set("v.ReturnLocationName",component.get("v.ShipmentRecordList")[0].Return_Location__r.Name);
                
            });
            
        });    
        
    },
    
    onShipmentCheck : function(component, event, helper){
        var currentRecordNumClick;
        
        if(typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0){
            currentRecordNumClick = event.target.parentElement.tabIndex; 
        }else{
            currentRecordNumClick = event.target.parentNode.parentElement.tabIndex;
        }
        
        var allShipmentRecords = component.get("v.ShipmentRecordList");
        
        //Get the Shipment RecordID of the selected Shipment record
        component.set("v.ShipmentRecordId",component.get("v.ShipmentRecordList")[currentRecordNumClick].Id);
        if(component.get("v.ShipmentRecordId") != undefined){
            helper.NavigateToShipmentPage(component,component.get("v.ShipmentRecordId"));
        }
        
    },
    
    
    CreateNewShipmentRecord : function(component, event, helper){
        
        //Create the Shipment and redirect to the add parts to shipment page
        component.set("v.ShowShipmentCreationPage",true);
        //Hide the Starting Page
        component.set("v.ShowShipmentRecords",false);
        
    },
    
    CreateShipmentRecord : function(component, event, helper){
        
        component.set("v.PageError",'');
        //Populate the Shipment Fields
        if(component.get("v.NewShipmentNumber") != undefined){
            component.set("v.ShipmentRecord.Name",component.get("v.NewShipmentNumber"));
        }else{
            component.set("v.PageError",'The Shipment Number Cannot be empty');    
        }
        
        if(component.get("v.ShipmentDate") != undefined){
            component.set("v.ShipmentRecord.Shipment_Date__c",component.get("v.ShipmentDate"));
        }else{
            component.set("v.PageError",'The Shipment Date cannot be blank');        
        }   
        
        component.set("v.ShipmentRecord.Return_Location__c",component.get("v.ReturnLocation"));
        
        //Fetch the Type of shipment selected on the Ui page
        var selected = component.find("ShipmentType").get("v.value");
        if(selected == 'OEM to Supplier'){
            var RecordTypeName = 'OEM to Supplier Shipment';
            var ShipmentRecordtypeQuery = helper.RecordType_Query +  "'" + RecordTypeName + "'";  
            //Fetch the Shipment RecordTypeID when the Record type is - OEM to Supplier Shipment
            helper.readDom(component, event, ShipmentRecordtypeQuery,"v.ShipmentRecordType", "v.dmlErrors", function(returnedValues) {
                
                component.set("v.ShipmentRecord.RecordType.Id",component.get("v.ShipmentRecordType")[0].Id);
                //      component.set("v.ShipmentRecord.RecordTypeId",'01261000000iknO');
                component.set("v.ShipmentRecord.Type_Of_Shipment__c",selected);
                if(component.get("v.PageError").length == 0){
                    helper.insertRaw(component, event,component.get("v.ShipmentRecord"),function(returnedValues) {
                        
                        //Print the Message In Case of error during insert
                        if(returnedValues.errorArrays.length > 0){
                            component.set("v.PageError",returnedValues.errorArrays[0].errorMesssages[0]);
                        }
                        
                        
                        //If the Shipment Record is Successfully created , navigate to the Shipment Add parts VF page
                        if(returnedValues.sobjectsAndStatus[0].sObject.Id != undefined){
                            helper.NavigateToShipmentPage(component,returnedValues.sobjectsAndStatus[0].sObject.Id);
                        }
                    }); 
                }
            });
            
        }else{
            var RecordTypeName = 'Dealer To OEM Shipment';
            var ShipmentRecordtypeQuery = helper.RecordType_Query +  "'" + RecordTypeName + "'"; 
            //Fetch the Shipment RecordTypeID when the Record type is - Dealer To OEM Shipment
            helper.readDom(component, event, ShipmentRecordtypeQuery,"v.ShipmentRecordType", "v.dmlErrors", function(returnedValues) {
                
                component.set("v.ShipmentRecord.RecordTypeId",component.get("v.ShipmentRecordType")[0].Id);
                component.set("v.ShipmentRecord.Type_Of_Shipment__c",selected);
                if(component.get("v.PageError").length == 0){
                    helper.insertRaw(component, event,component.get("v.ShipmentRecord"),function(returnedValues) {                        
                        //Print the Message In Case of error during insert
                        if(returnedValues.errorArrays.length > 0){
                            component.set("v.PageError",returnedValues.errorArrays[0].errorMesssages[0]);
                        }
                        
                        
                        //If the Shipment Record is Successfully created , navigate to the Shipment Add parts VF page
                        if(returnedValues.sobjectsAndStatus[0].sObject.Id != undefined){
                            helper.NavigateToShipmentPage(component,returnedValues.sobjectsAndStatus[0].sObject.Id);
                        }
                    }); 
                }
            });
            
        }
    },
    
    GobackTotheCreateShipmentLightningPage : function(component, event, helper){
        
        var ReturnUrl = component.get("v.baseURL")  + '/c/ShipmentCreationPageAuraApp.app' ;
        window.location = ReturnUrl; 
        
    }
    
})