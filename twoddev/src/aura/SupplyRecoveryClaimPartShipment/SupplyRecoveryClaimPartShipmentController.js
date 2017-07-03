({   
    doInit : function(component, event, helper) {
        var ShipmentPartLocation;
        component.set( "v.RefreshSymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#refresh"));
        component.set( "v.DeleteSymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#delete"));
        var query = helper.SUPPLY_RECOVERY_SHIPPMENT_QUERY + "'" + component.get("v.ShipmentRecordID") + "'";
        helper.readDom(component, event, query, "v.shipmentDetail", "v.dmlErrors", function(returnedValues) {
            
            if(component.get("v.shipmentDetail").isShipped__c == true){
                alert('Shipment Already Created and Shipped');
                helper.DonotShowShipmentpage(component,component.get("v.ShipmentRecordID"));
            }else if(component.get("v.shipmentDetail").Type_Of_Shipment__c != 'OEM to Supplier'){
                alert('You have selected wrong Shipment  '+component.get("v.shipmentDetail").Type_Of_Shipment__c);
                helper.DonotShowShipmentpage(component,component.get("v.ShipmentRecordID"));
            }
            
            helper.readSupplyRecoveryClaimLineItem(component,event);
            if(typeof  component.get("v.shipmentDetail").Recovery_Claim_Shipments__r != 'undefined'){
                component.set("v.supplyRecoveryClaimShipmentArr",(component.get("v.shipmentDetail")).Recovery_Claim_Shipments__r);
                component.set("v.TableContainRecords",true); 
            }				
            component.set("v.shipmentURL",helper.renderURL(component.get("v.baseURL"),component.get("v.shipmentDetail").Id));
        });
        
        
    },
    
    RefreshRecoveryLineItems : function(component, event, helper){
       
        helper.readSupplyRecoveryClaimLineItem(component,event);
        
    },
    
    AddLineItemToShipment : function(component, event, helper){
        
        component.set("v.supplyRecoveryClaimShipmentArr", event.getParam("ShipmentRecordList"));
      
    },
    
    DeleteSelectedRecords : function(component, event, helper){
        
        var query1 = helper.SUPPLY_RECOVERY_SHIPPMENT_QUERY + "'" + component.get("v.ShipmentRecordID") + "'";
        helper.readDom(component, event, query1, "v.shipmentDetail", "v.dmlErrors", function(returnedValues) {
            //Check if the shipment Shipped status is True,If True redirect to the Shipment Detail page
            if(component.get("v.shipmentDetail").isShipped__c == true){
                alert('Shipment is Already Shipped, Cannot Delete Parts from the shipment');
                var ReturnUrl = component.get("v.baseURL") + '/' + returnedValues[0].Id;
                window.location.href = ReturnUrl;  

            }else{
                helper.DeleteSelRecordFunc(component,event,helper);
            }
        })  
 
    }
    
    
})