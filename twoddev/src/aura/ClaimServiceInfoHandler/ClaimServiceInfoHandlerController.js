({
	doInit : function(component, event, helper) {
		var partId	=	component.get('v.partId');
        if(partId != null && partId != '') {
        	var queryString		=	'SELECT Id, Name, Additional_Labor_Hour__c, Service_Job_Code__c, Service_Job_Code__r.Name, Reason_Additional_Labor_hour__c, Total_Labor_hours__c, Claim__c FROM Claim_Service_Information__c WHERE Id =' + '\'' +partId + '\'';
        	console.log('::: Query String:' +queryString);    
            var action = component.get('c.findSObjectsBySOQL');
            action.setParams({ 
                "query" : queryString
            });
            action.setCallback(this, function(response) {
                console.log(':::: Response from server installed part handler:');
                console.log(response.getReturnValue());
                var recordValue	=	response.getReturnValue();
                component.set('v.clainServiceInfo', response.getReturnValue());
                var serviceInfoName	=	recordValue[0].Service_Job_Code__r.Name;
                component.set('v.serviceJobName',inventory);;
                console.log(':::: Inventory');
            });
            $A.enqueueAction(action);
        }
	},
    
    // To save the record
    saveRecord : function(component, event, helper) {
        event.preventDefault();
        var isNew		=	component.get('v.isNewRecord');
        var saveRecord	=	component.get('v.clainServiceInfo');
        saveRecord.Claim__c = component.get('v.claimId');
        console.log(':::: is new record:'+isNew);
        console.log('::::: save record value:');
        console.log(saveRecord);
        var hasErrors	=	'false';
        var partName					= 	component.find("partName");
        var partValue 					= 	partName.get("v.value");
        if(partValue == null || partValue == '' || typeof partValue == "undefined"){
            hasErrors	=	'true';
            partName.set("v.errors", [{message:"Please enter Name"}]);
        } else {
            hasErrors	=	'false';
            partName.set("v.errors", null);
        }
        console.log(':::: part value:');
        console.log(partValue);
        
        var inputCmp 					= 	component.find("warrantyProductId");
        var warrantyProductvalue 		= 	inputCmp.get("v.value");
		var isWarrantySave				=	component.get('v.isDisabledInventory');
        if (isWarrantySave) {
            if(warrantyProductvalue == null || warrantyProductvalue == '' || typeof warrantyProductvalue == "undefined"){
                hasErrors	=	'true';
                inputCmp.set("v.errors", [{message:"Please enter Warranty value"}]);
            } else {
                hasErrors	=	'false';
                component.set('v.installedPart.Warranty_Product__c',component.get('v.warrantyProductId'));
                saveRecord.Warranty_Product__c = component.get('v.warrantyProductId');
                inputCmp.set("v.errors",null);
            }
        }
        console.log('::: warranty product value:');
        console.log(warrantyProductvalue);
        
        var inputInvValue				= 	component.find("inventoryId");
        var invIdvalue 					= 	inputInvValue.get("v.value");
		var isInvSave					=	component.get('v.isDisabledWarranty');
        if (isInvSave) {
            if(invIdvalue == null || invIdvalue == '' || typeof invIdvalue == "undefined"){
                hasErrors	=	'true';
                inputInvValue.set("v.errors", [{message:"Please enter Inventory value"}]);
            }else {
                component.set('v.installedPart.Inventory__c',component.get('v.inventoryId'));
                saveRecord.Inventory__c = component.get('v.inventoryId');
                inputInvValue.set("v.errors", null);
            }
        }
        
        console.log('::::: is inv save:'+isInvSave);
        console.log('::::: is isWarrantySave:'+isWarrantySave);
        if(!isInvSave && !isWarrantySave ) {
            hasErrors	=	'true';
            inputInvValue.set("v.errors", [{message:"Please enter Inventory value"}]);
            inputCmp.set("v.errors", [{message:"Please enter Warranty value"}]);
        }
        
        console.log('::: inv value:');
        console.log(invIdvalue);
        console.log(':::: has errors:'+hasErrors);
        if(hasErrors == 'false') {
            console.log('::::: Entered inside of the execution');
            var listRecs	=	[];
            listRecs.push(saveRecord);
            var action 	= 	component.get('c.UpdateSObjects');
            if(isNew) {
                action 	= 	component.get('c.InsertSObjects')
            }
            action.setParams({ 
                "inputSObjectList" : listRecs
            });
            action.setCallback(this, function(response) {
                console.log('::::: Respose value:');
                console.log(response.getReturnValue());
                console.log(':::: Status:'+response.getState());
                var state = response.getState();
                var dmlErrors = [];
                if(state === "ERROR"){         
                    component.set('v.isNewRecord',false);
					if (response.error[0].fieldErrors) {
						for (var key in response.error[0].fieldErrors) {
                            console.log('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        	dmlErrors.push('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        }                    
                    }
               
                } else if(state == "SUCCESS"){
                    console.log(response.getReturnValue());
                    component.set('v.installedPart',component.get('v.tempInstalledPart'));
                    component.set('v.isNewRecord',false);
                    if (response.getReturnValue()[0].errorCodeList) {
                            for  (var key in response.getReturnValue()[0].errorCodeList) {
                                console.log(response.getReturnValue()[0].errorCodeList[key]);
                                dmlErrors.push(response.getReturnValue()[0].errorCodeList[key]);
                            }                    
                        }
                    var saveResult = response.getReturnValue()[0];
                    if(saveResult.success == Boolean(1)){
                        component.set("v.claimLaborDetail_SObj.Id",saveResult.sObjID);
                        component.set("v.sObjectList","");
                        console.log(component.get("v.claimLaborDetail_SObj"));
                        component.set('v.isEdit', Boolean(0));
                    } else {
                       //
                    }
                    var myEvent = $A.get("e.c:UpdateInstalledParts");
                        myEvent.setParams({
                        });
                        myEvent.fire();
                        
                        var myEvent = $A.get("e.c:ModalCloseEvent");
                        myEvent.setParams({
                            "isModalEnabled":false
                        });
                        myEvent.fire();
                }
                component.set("v.dmlErrors",dmlErrors);
                
            });
            $A.enqueueAction(action);
            
        }
        
    },
    
})