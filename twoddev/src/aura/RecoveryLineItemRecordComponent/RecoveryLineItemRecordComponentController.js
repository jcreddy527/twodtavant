({
    doInit : function(component, event, helper){
     component.set( "v.AddSymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#add"));
   //     component.set( "v.AddSymbolURL" ,helper.renderURL("resource/slds/assets/icons/utility-sprite/svg/symbols.svg#add"));
 //   component.set("v.SpinnerURL",$A.getContext().gg);
    component.set("v.AllowInput",false);

        //if the supplier recovery line item linked to the removed part 'Part payment condition is : Return Not applicable' - Do not allow to ship the part
        //if the supplier recovery line item linked to the removed part 'Part payment condition is : Return Not applicable' and IsApprovedStatus of the Removed part is 'False' - Do not allow to ship the part
        if(component.get("v.RecoveryClaimLineItem.Removed_Claim_Part__r.Payment_Condition__c") == 'Return Not Applicable' || (component.get("v.RecoveryClaimLineItem.Removed_Claim_Part__r.Payment_Condition__c") == 'Return Not Applicable' && component.get("v.RecoveryClaimLineItem.Removed_Claim_Part__r.Is_Approved__c") == false)){
            component.set("v.DonotAllowInput",true);
            component.set("v.bgcolor",'#A4A4A4');
        }    
    
	},
    
    AddPartsToShipment : function(component, event, helper) {
        var SHIPPMENTQUERY = helper.SHIPPMENT_QUERY + "'" + component.get("v.ShipmentRecordIdComp") + "'";
        console.log(SHIPPMENTQUERY);
        
        helper.readDom(component, event, SHIPPMENTQUERY, "v.IsShippedStatus", "v.dmlErrors", function(returnedValues) {
             	
            		component.set("v.shipmentURLcomp",helper.renderURL(component.get("v.baseURL"),returnedValues[0].Id));
            
            		//Check if the shipment Shipped status is True,If True redirect to the Shipment Detail page
            		if(returnedValues[0].isShipped__c == true){
                        alert('Shipment is Already Shipped, Cannot Add Parts to shipment');
                        
                        if($A.getContext().gg != 'undefined' && typeof $A.getContext().gg != 'undefined'){  
                            var ReturnUrl = window.location.origin +  $A.getContext().gg + '/' + returnedValues[0].Id;
                            window.location.href = ReturnUrl;  
                        }else{
                            var ReturnUrl = window.location.origin +  '/' + returnedValues[0].Id;
                            window.location.href = ReturnUrl; 
                        }
             
                    }else{
                        helper.AddpartToShipmentList(component, event,helper);
                    }
	    })
		
	},
    
    UpdLineItemAfterSippedItemDeletion : function(component, event, helper){

        var CompLineItemRec = component.get('v.RecoveryClaimLineItem');
        var EventTriggeredShipmentRec = event.getParam("ShipmentRecord");
        var ShipmentQuantAfterDel = EventTriggeredShipmentRec.Quantity__c;
        var LineQuantAfterDel = component.get('v.RecoveryClaimLineItem.Pending_Shipment_Quantity__c');
        var UpdatedTotalAfterDel = parseInt(ShipmentQuantAfterDel) + parseInt(LineQuantAfterDel);

        if(EventTriggeredShipmentRec.Supply_Recovery_Claim_Line_Item__c == CompLineItemRec.Id ){
          
            if(UpdatedTotalAfterDel > 0){
                component.set('v.RecoveryClaimLineItem.Pending_Shipment_Quantity__c',UpdatedTotalAfterDel);
           //     component.set('v.LineItemComponentVisible',true);
             	var spinnermp = component.find('LineitemComp');
                $A.util.removeClass(spinnermp,'hidetr');
                helper.deleteRaw(component, event, EventTriggeredShipmentRec, function(returnedValues) {
                    console.log(returnedValues);
                } );
            }else{
                alert('Pending Quantity cannot be Negative');
            }
        }
    }
})