({
    doInit : function(component, event, helper) {
        helper.showAlert(component,event,{});
        var query = "select Id,Receiver_Comments__c,Shipment_Received_Date__c,Name"+
            ",Is_Inspected__c,Received__c,Tracking_Number__c,Return_Location__r.Name,Shipment_Date__c, (Select id,Inspection_Comments__c,Quantity__c,Shipment_Detail__c,Is_Received__c,Removed_Claim_Part__c,Removed_Claim_Part__r.Warranty_Product__r.Name,Removed_Claim_Part__r.Warranty_Product__r.Description__c,Removed_Claim_Part__r.Inventory__c,Removed_Claim_Part__r.Inventory__r.Item__c,Removed_Claim_Part__r.Inventory__r.Item__r.Name,Removed_Claim_Part__r.Inventory__r.Item__r.Description__c,Removed_Claim_Part__r.Inventory__r.Name from Claim_Shipments__r) from Shipment_Detail__c where Id = '" + component.get("v.shipmentId") + "'";	
        console.log(query);
        helper.readRaw(component, event, helper, query, function(shipmentResponse){
            
            component.set('v.isPageLoaded',true);
            
            if(shipmentResponse!==null && shipmentResponse!==undefined){
                if(shipmentResponse['sObjectList']!==null && 
                   shipmentResponse['sObjectList']!==undefined && 
                   shipmentResponse['sObjectList'].length!==0){				
                  
                    
                    component.set("v.shipmentObjectList",shipmentResponse['sObjectList']);
                    component.set("v.shipmentObject",shipmentResponse['sObjectList'][0]);
                    
                    var shipmentObject = component.get("v.shipmentObject");
                    //check if the received status is true then we will throw error.
                    
                    if(shipmentObject!=null){
                    
                        if(shipmentObject['Is_Inspected__c']!== null && 
                           shipmentObject['Is_Inspected__c']!==undefined){
                        
                            if(shipmentObject['Is_Inspected__c']==false){                                
                                
                                var shipmentObject = JSON.parse(JSON.stringify(component.get("v.shipmentObject")));
                                if(shipmentObject['Claim_Shipments__r']!==null && shipmentObject['Claim_Shipments__r']!==undefined){
                                    component.set("v.claimShipmentPartList",shipmentObject['Claim_Shipments__r'])    
                                }
                                
                                if(shipmentObject['Inspection_Date__c']===null || shipmentObject['Inspection_Date__c']===undefined || shipmentObject['Shipment_Received_Date__c']===''){
                                    shipmentObject['Inspection_Date__c'] = '';  
                                }
                                //AKR - 30-NOV-2016:- setting the flag before sending to server for save.
                                shipmentObject['Is_Inspected__c'] = true;  
                            }else{
                                
                                var alertboxContent = {
                                    message: $A.get("$Label.c.Shipment_Inspection_Already_Completed_H"),
                                    heading: $A.get("$Label.c.Shipment_Inspection_Already_Completed_H"),
                                    class: 'slds-theme--error',
                                    callableFunction: component.getReference('c.closeAlertandReturn'),
                                    buttonHeading: $A.get("$Label.c.OK")
                                };
                                helper.showAlert(component, event, alertboxContent);
                            }
                            component.set("v.shipmentObject",shipmentObject);
                        } //if closed.  
                    }
                } 
            }
        });
        
        //error handling 
        var error = {
            fieldError: {
                description:"",
                inspectionDate:"",
            }
        }
        component.set("v.error",error);
        helper.showAlert(component, event, {});
        component.set('v.shipmentInspectionDate',helper.getTodayDate(component, event));
        component.set('v.shipmentObject.Inspection_Date__c',helper.getTodayDate(component, event));    
        
    },
    CancelinspectShipment : function(component, event, helper) {
        helper.cancelURL(component, event, helper);
    },
    inspectShipment : function(component, event, helper) {
        
        helper.updateURL(component, event, helper);
    },
    hideError :function(component, event, helper) { 
        helper.removeError(component, event, helper);
    },
    shipmentInspectionDateChangeHandeler : function(component,event,helper){
        
        var inspectionDate = event.getParam('value'); 
        var todayDate = helper.getTodayDate();
        var receivedDate = helper.getDateReadableFormat(component.get('v.shipmentObject.Shipment_Received_Date__c'));
        
        if(inspectionDate!==null && inspectionDate!==undefined && inspectionDate!==''){
            if (new Date(inspectionDate) > new Date(todayDate)) {
                component.set('v.error.fieldError.inspectionDate', $A.get("$Label.c.Shipment_Inspection_Date_Error"));
            }else{
                
                if(new Date(inspectionDate) < new Date(receivedDate)){
                    component.set('v.error.fieldError.inspectionDate',  $A.get("$Label.c.Shipment_Inspection_Date_Error"));
                }else{
                    component.set('v.error.fieldError.inspectionDate', '');
                    component.set('v.shipmentObject.Inspection_Date__c',inspectionDate);
                }
                
            }
        }else{
            component.set('v.error.fieldError.inspectionDate', $A.get("$Label.c.Shipment_Inspection_Date_Error"));
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
    
    fillComments: function(component,event,helper){
        
        var index = event.getSource().get('v.labelClass');
        var value= event.getSource().get('v.value');
        var claimShipmentPartList = JSON.parse(JSON.stringify(component.get('v.claimShipmentPartList')));
        claimShipmentPartList[index]['Inspection_Comments__c'] = value;
        component.set('v.claimShipmentPartList',claimShipmentPartList);
        
        
    }
    
})