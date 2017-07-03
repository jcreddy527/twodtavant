({
    doInit : function(component, event, helper) {
        
        //error handling
        var error = {
            fieldError: {
                description:"",
                receiveDate:"",
            }
        }
        component.set("v.error",error);
        helper.showAlert(component, event, {});
        component.set('v.shipmentReceivedDate',helper.getTodayDate(component, event));
        
        var query = "select Id,Receiver_Comments__c,Shipment_Received_Date__c,Name"+
            ",Received__c,Tracking_Number__c,Return_Location__r.Name,Shipment_Date__c, (Select id,Quantity__c,Shipment_Detail__c,Is_Received__c,Removed_Claim_Part__c,Removed_Claim_Part__r.Warranty_Product__r.Name,Removed_Claim_Part__r.Warranty_Product__r.Description__c,Removed_Claim_Part__r.Inventory__c,Removed_Claim_Part__r.Inventory__r.Item__c,Removed_Claim_Part__r.Inventory__r.Item__r.Name,Removed_Claim_Part__r.Inventory__r.Item__r.Description__c,Removed_Claim_Part__r.Inventory__r.Name from Claim_Shipments__r) from Shipment_Detail__c where Id = '" + component.get("v.shipmentId") + "'";
        helper.readRaw(component, event, helper, query, function(shipmentResponse){
            component.set('v.isPageLoaded',true);
            if(shipmentResponse!==null && shipmentResponse!==undefined){
                if(shipmentResponse['sObjectList']!==null &&
                   shipmentResponse['sObjectList']!==undefined &&
                   shipmentResponse['sObjectList'].length!==0){
                    component.set("v.shipmentObjectList",shipmentResponse['sObjectList']);
                    component.set("v.shipmentObject",shipmentResponse['sObjectList'][0]);
                    component.set('v.shipmentObject.Shipment_Received_Date__c',helper.getTodayDate(component, event));
                    var shipmentObject = component.get("v.shipmentObject");
                    //check if the received status is true then we will throw error.
                    if(shipmentObject!=null){
                        if(shipmentObject['Received__c']!== null &&
                           shipmentObject['Received__c']!==undefined){
                            if(shipmentObject['Received__c']==false){
                                var shipmentObject = JSON.parse(JSON.stringify(component.get("v.shipmentObject")));
                                if(shipmentObject['Claim_Shipments__r']!==null && shipmentObject['Claim_Shipments__r']!==undefined){
                                    component.set("v.claimShipmentPartList",shipmentObject['Claim_Shipments__r'])
                                }
                                var shipmentObject = JSON.parse(JSON.stringify(component.get("v.shipmentObject")));
                                if(shipmentObject['Receiver_Comments__c']===null || shipmentObject['Receiver_Comments__c']===undefined || shipmentObject['Receiver_Comments__c']===''){
                                    shipmentObject['Receiver_Comments__c'] = '';
                                }
                                if(shipmentObject['Shipment_Received_Date__c']===null || shipmentObject['Shipment_Received_Date__c']===undefined || shipmentObject['Shipment_Received_Date__c']===''){
                                    shipmentObject['Shipment_Received_Date__c'] = '';
                                }
                                //AKR - 30-NOV-2016:- setting the flag before sending to server for save.
                                shipmentObject['Received__c'] = true;
                            }else{

                                var alertboxContent = {
                                    message: $A.get("$Label.c.Shipment_Received_Already_Completed_H"),
                                    heading: $A.get("$Label.c.Shipment_Received_Already_Completed_H"),
                                    class: 'slds-theme--error',
                                    callableFunction: component.getReference('c.closeAlertandReturn'),
                                    buttonHeading: $A.get("$Label.c.OK")
                                };
                                helper.showAlert(component, event, alertboxContent);
                            }
                            component.set("v.shipmentObject",shipmentObject);
                            component.set('v.shipmentObject.Shipment_Received_Date__c',helper.getTodayDate(component, event));
                        } //if closed.
                    }
                }
            }
        });

        
        
        

    },
    CancelreceiveShipment : function(component, event, helper) {
        helper.cancelURL(component, event, helper);
    },
    shipmentReceivedDateChangeHandeler : function(component,event,helper){

        var receiveDate = event.getParam('value');
        var todayDate = helper.getTodayDate(component, event);
        var shipmentDate = helper.getDateReadableFormat(component.get('v.shipmentObject.Shipment_Date__c'));

        if(receiveDate!==null && receiveDate!==undefined && receiveDate!==''){

          receiveDate = new Date(receiveDate);
          if(receiveDate!='Invalid Date'){

            if (receiveDate > new Date(todayDate)) {
                component.set('v.error.fieldError.receiveDate', $A.get("$Label.c.Shipment_Receive_Date_Error"));
            }else{
                if(receiveDate < new Date(shipmentDate)){
                    component.set('v.error.fieldError.receiveDate', $A.get("$Label.c.Shipment_Receive_Date_Error"));
                }else{
                    component.set('v.error.fieldError.receiveDate', '');
                    component.set('v.shipmentObject.Shipment_Received_Date__c',helper.getDateReadableFormat(receiveDate));
                }

            }

          }else{

            component.set('v.error.fieldError.receiveDate', 'Invalid Date');

          }
        }else{
            component.set('v.error.fieldError.receiveDate', $A.get("$Label.c.Shipment_Receive_Date_Error"));
        }

    },

    receiveShipment : function(component, event, helper) {

        helper.updateURL(component, event, helper);
    },
    hideError :function(component, event, helper) {
        helper.removeError(component, event, helper);
    },

    fillError  :function(component,event,helper){

        var componentId = event.getSource().getLocalId();

        switch(componentId){

            case "receiveComment" :
                {
                    var textvalue= event.getSource().get('v.value');
                    if(textvalue!==null && textvalue!==undefined && textvalue!==''){
                        component.set('v.error.fieldError.description','');
                    }else{
                        component.set('v.error.fieldError.description',$A.get("$Label.c.Shipment_Received_Comment_Mandatory"));
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