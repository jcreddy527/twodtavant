({
    SHIPPMENT_QUERY : 'SELECT Id, Name, CreatedDate,Type_Of_Shipment__c,isShipped__c  FROM Shipment_Detail__c WHERE Id = ',
    
    AddpartToShipmentList : function(component,event,helper) {
        
        var PendingQuantity = component.get('v.RecoveryClaimLineItem.Pending_Shipment_Quantity__c');
        var ShippedQuanity = component.get('v.QuantitySelectedForShipment');
        var makeEmpty = [];
        var ShipmentRecordList = component.get('v.RecoveryLineItemShippedList');
        
        if(ShippedQuanity != "" && ShippedQuanity <= PendingQuantity && ShippedQuanity > 0 && (Math.round(ShippedQuanity) == ShippedQuanity) ){
            
            var total = PendingQuantity - ShippedQuanity;
            var ElementAlreadypresent;
            if(parseInt(total) >= 0){
                //Iterating over the Shipped list to find the already existing line items in the list
                if(ShipmentRecordList.length != undefined){
                    for(var i=0; i < ShipmentRecordList.length; i++){
                        //updating the already existing Shipped Line item
                        if(ShipmentRecordList[i].Supply_Recovery_Claim_Line_Item__c == component.get('v.RecoveryClaimLineItem.Id')){
                            var CurrentRecordQuantity = ShipmentRecordList[i].Quantity__c;
                            var updatedQuantity =  parseInt(CurrentRecordQuantity) + parseInt(ShippedQuanity);
                            ShipmentRecordList[i].Supply_Recovery_Claim_Line_Item__c =  component.get('v.RecoveryClaimLineItem.Id');
                            ShipmentRecordList[i].Shipment__c 						=  component.get('v.ShipmentRecordIdRowComp');
                            ShipmentRecordList[i].Quantity__c						=  updatedQuantity;
                            ElementAlreadypresent = 'True';
                            this.showSpinner(component);
                            helper.updateRaw(component, event,ShipmentRecordList[i],function(returnedValues) {
                                component.set('v.showSpinner' , 'No');
                                console.log(returnedValues);
                            });
                        }
                        
                    }
                }
                
                if(ElementAlreadypresent != 'True'){
                    //Creating the new record in the Items Shipped List
                    var ShipmentRecord	   = {sobjectType:'Recovery_Claim_Shipment__c', Id : null, Supply_Recovery_Claim_Line_Item__r : { Name : '' } };
                    console.log(component.get('v.RecoveryLineItemShipped'));
                    ShipmentRecord.Supply_Recovery_Claim_Line_Item__c = component.get('v.RecoveryClaimLineItem.Id');
                    ShipmentRecord.Supply_Recovery_Claim_Line_Item__r = {Name : ''};
                    ShipmentRecord.sobjectType  = 'Recovery_Claim_Shipment__c';
                    ShipmentRecord.Supply_Recovery_Claim_Line_Item__r.Name = component.get('v.RecoveryClaimLineItem.Name');
                    ShipmentRecord.Shipment__c 						  = component.get('v.ShipmentRecordIdRowComp');
                    ShipmentRecord.Quantity__c 						  = Math.round(component.get('v.QuantitySelectedForShipment'));
                    
                    //	var tmpShipmentRecord = helper.clone(ShipmentRecord);
                    //	delete tmpShipmentRecord["Supply_Recovery_Claim_Line_Item__r"];
                    this.showSpinner(component);
                    this.insertRaw(component, event,ShipmentRecord,function(returnedValues) {
                        //	console.log('--------------------------helper');
                        
                        component.set('v.showSpinner' , 'No');
                        
                        ShipmentRecord.Id = returnedValues.sobjectsAndStatus[0].sObject.Id;
                        
                        var tmpShipmentRecord = helper.clone(ShipmentRecord);
                        ShipmentRecordList.unshift(tmpShipmentRecord);
                        var myEvent = $A.get("e.c:AddRecordToshipEvent");
                        myEvent.setParams({
                            ShipmentRecordList: ShipmentRecordList
                        });
                        myEvent.fire();
                        
                    });
                }else {
                    var myEvent = $A.get("e.c:AddRecordToshipEvent");
                    myEvent.setParams({
                        ShipmentRecordList: ShipmentRecordList
                    });
                    myEvent.fire();
                }
                
                
                
                component.set('v.RecoveryClaimLineItem.Pending_Shipment_Quantity__c',total);
                component.set('v.QuantitySelectedForShipment','');
            }else{
                alert('Shipped Quantity Greater than the Pending Quantity');
                
            }
            
            if(component.get('v.RecoveryClaimLineItem.Pending_Shipment_Quantity__c') == 0){
                //component.set('v.LineItemComponentVisible',false);
                var spinnermp = component.find('LineitemComp');
                $A.util.addClass(spinnermp,'hidetr');
            }
            
            component.set('v.RecoveryLineItemShipped',makeEmpty);
        }else{
            alert('Please Enter Valid Shipped Quantity');
        }
        
        
    },
    showSpinner: function(component){
        component.set('v.showSpinner' , 'Yes');
    },
    hideSpinner: function(component){
        component.set('v.showSpinner' , 'No');
    },
})