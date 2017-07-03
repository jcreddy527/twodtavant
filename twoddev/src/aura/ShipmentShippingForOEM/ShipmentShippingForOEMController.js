({
    doInit : function(component, event, helper) {
        
        //error handling 
        var error = {
            fieldError: {
                description:"",
                shipDate:"",
            }
        }
        helper.showAlert(component,event,{});
        component.set("v.error",error);
        component.set('v.shipmentDate',helper.getTodayDate(component, event));
        	
        var query = "select Id,Receiver_Comments__c,Shipment_Received_Date__c,Name"+
            ",Carrier__c,isShipped__c, isShipped_OEM__c, Shipper_Comments__c,Received__c,Tracking_Number__c,Return_Location__r.Name,Shipment_Date__c, (Select id,Quantity__c,Shipment_Detail__c,Is_Received__c,Removed_Claim_Part__c,Removed_Claim_Part__r.Warranty_Product__r.Name,Removed_Claim_Part__r.Warranty_Product__r.Description__c,Removed_Claim_Part__r.Inventory__c,Removed_Claim_Part__r.Inventory__r.Item__c,Removed_Claim_Part__r.Inventory__r.Item__r.Name,Removed_Claim_Part__r.Inventory__r.Item__r.Description__c,Removed_Claim_Part__r.Inventory__r.Name from Claim_Shipments__r) from Shipment_Detail__c where Id = '" + component.get("v.shipmentId") + "'";	
        helper.readRaw(component, event, helper, query, function(shipmentResponse){
            component.set('v.isPageLoaded',true);
            if(shipmentResponse!==null && shipmentResponse!==undefined){
                if(shipmentResponse['sObjectList']!==null && 
                   shipmentResponse['sObjectList']!==undefined && 
                   shipmentResponse['sObjectList'].length!==0){				
                    component.set("v.shipmentObjectList",shipmentResponse['sObjectList']);
                    component.set("v.shipmentObject",shipmentResponse['sObjectList'][0]);
                    component.set('v.shipmentObject.Shipment_Date__c',helper.getTodayDate(component, event));
                    var shipmentObject = component.get("v.shipmentObject");
                    //check if the received status is true then we will throw error.
                    if(shipmentObject!=null){
                        if(shipmentObject['isShipped_OEM__c']!== null && 
                           shipmentObject['isShipped_OEM__c']!==undefined){
                            if(shipmentObject['isShipped_OEM__c']==false){
                                
                                
                                var shipmentObject = JSON.parse(JSON.stringify(component.get("v.shipmentObject")));
                                if(shipmentObject['Claim_Shipments__r']!==null && shipmentObject['Claim_Shipments__r']!==undefined){
                                    component.set("v.claimShipmentPartList",shipmentObject['Claim_Shipments__r'])    
                                }
                                var shipmentObject = JSON.parse(JSON.stringify(component.get("v.shipmentObject")));
                                if(shipmentObject['Shipper_Comments__c']===null || shipmentObject['Shipper_Comments__c']===undefined || shipmentObject['Shipper_Comments__c']===''){
                                    shipmentObject['Shipper_Comments__c'] = '';  
                                }
                                if(shipmentObject['Shipment_Date__c']===null || shipmentObject['Shipment_Date__c']===undefined || shipmentObject['Shipment_Date__c']===''){
                                    shipmentObject['Shipment_Date__c'] = '';  
                                }
                                //AKR - 30-NOV-2016:- setting the flag before sending to server for save.
                                shipmentObject['isShipped_OEM__c'] = true;  
                            }else{
                                
                                var alertboxContent = {
                                    message: $A.get("$Label.c.Ship_Shipment_Already_Completed_H"),
                                    heading: $A.get("$Label.c.Ship_Shipment_Already_Completed_H"),
                                    class: 'slds-theme--error',
                                    callableFunction: component.getReference('c.closeAlertandReturn'),
                                    buttonHeading: $A.get("$Label.c.OK")
                                };
                                helper.showAlert(component, event, alertboxContent);
                            }
                            component.set("v.shipmentObject",shipmentObject);
                            component.set('v.shipmentObject.Shipment_Date__c',helper.getTodayDate(component, event));
                        } //if closed.  
                    }
                } 
            }
        });
        

        
        
    },
    CancelShipShipment : function(component, event, helper) {
        helper.cancelURL(component, event, helper);
    },
    
    shipShipment : function(component, event, helper) {
        
        helper.updateURL(component, event, helper);
    },
    hideError :function(component, event, helper) { 
        helper.removeError(component, event, helper);
    },
    
    shipmentDateChangeHandeler : function(component,event,helper){
      
        var shipmentDate = event.getParam('value'); 
        var todayDate = helper.getTodayDate();
        
        if(shipmentDate!==null && shipmentDate!==undefined && shipmentDate!==''){
            if (new Date(shipmentDate) > new Date(todayDate)) {
                component.set('v.error.fieldError.shipDate', $A.get("$Label.c.Shipment_Date_Error"));
            }else{
                component.set('v.error.fieldError.shipDate', '');
                component.set('v.shipmentObject.Shipment_Date__c',shipmentDate);
            }
        }else{
            component.set('v.error.fieldError.shipDate', $A.get("$Label.c.Shipment_Date_Error"));
        }
        
    },
    fillError  :function(component,event,helper){
      
        var componentId = event.getSource().getLocalId();
        
        switch(componentId){
                
            case "shipComment" : 
                {
                    var textvalue= event.getSource().get('v.value');
                    if(textvalue!==null && textvalue!==undefined && textvalue!==''){
                        component.set('v.error.fieldError.description','');
                    }else{
                        component.set('v.error.fieldError.description',$A.get("$Label.c.Shipper_Comment_Mandatory"));
                    }
                    
                    break;
                }
                
        }
        
        
        
    },	
    
    
    /*** alert message methods ***/
    closeAlert: function(component, event, helper) {
        component.set('v.body', []);
    },
    /*** alert message methods ***/
    closeAlertandReturn: function(component, event, helper) {
        component.set('v.body', []);
        helper.cancelURL(component, event, helper);
        
    },

})