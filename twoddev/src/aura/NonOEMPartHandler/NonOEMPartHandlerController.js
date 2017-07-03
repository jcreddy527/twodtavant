({
    doInit		: function(component, event, helper){
		component.set('v.showSpinner',false);
    },

	saveRecord : function(component, event, helper) {
        event.preventDefault();
        var errorCount	=	0;
        component.set('v.showSpinner',true);
        // part name
		var partName 		= component.find("partName");
        var name 			= partName.get("v.value");
        console.log(':::: part name:'+name);
		if(name == null || name == '' || typeof name == "undefined"){
            errorCount ++;
            partName.set("v.errors", [{message: $A.get("$Label.c.Non_OEM_Part_Empty_Error") }]);   
        }else{
             partName.set("v.errors", null);
        }

        // Description
        var description 		= component.find("description");
        var desc 			= description.get("v.value");
        console.log(':::: description name:'+desc);
		if(desc == null || desc == '' || typeof desc == "undefined"){
            errorCount ++;
            description.set("v.errors", [{message: $A.get("$Label.c.Part_Description_Empty_Error") }]);    

        }else{
             description.set("v.errors", null);
        }

        // Price
        var price 		= component.find("price");
        var amt 		= price.get("v.value");
        console.log(':::: amt:'+amt);
        if(amt != null && amt != '' && typeof amt != "undefined"){
            if (isNaN(amt) || amt < 0){
                errorCount ++;
                price.set("v.errors", [{message:"Custom Part Cost should be a number with positive sign"}]);
            }else{
                price.set("v.errors", null);
            }
        }else if(amt == null || amt == '' || typeof amt == "undefined") {
            errorCount ++;
            price.set("v.errors", [{message: $A.get("$Label.c.Custom_Part_Cost_Empty_Error") }]);     
        } else {
            price.set("v.errors", null);
        }


        // Quantity
        var Quantity 	= component.find("quantity");
        var quant 		= Quantity.get("v.value");
        console.log(':::: quant:'+quant);
        if(quant != null && quant != '' && typeof quant != "undefined"){
            if (isNaN(quant) || quant < 0){
                errorCount ++;
                Quantity.set("v.errors", [{message:"Quantity should be a number with positive sign"}]);
            }else
  					if(quant % 1 != 0){
  							errorCount ++;
  							Quantity.set("v.errors", [{message:"Quantity shouldn't have decimal places"}]);
  					}else{
                Quantity.set("v.errors", null);
            }
        }else if(quant == null || quant == '' || typeof quant == "undefined") {
            errorCount ++;
            Quantity.set("v.errors", [{message: $A.get("$Label.c.Price_Value_Empty_Error") }]);    
        } else {
            Quantity.set("v.errors", null);
        }

        if(errorCount == 0){
            var listRecs	=	[];
            listRecs.push(component.get('v.nonOEMPart'));
            console.log(':::::: Record type id for Miscellenious:'+component.get('v.recordTypeId'));
            var action 	= 	component.get('c.UpdateSObjects');
            if(component.get('v.isNewRecord')) {
                action 	= 	component.get('c.InsertSObjects');
            }
            action.setParams({
                "inputSObjectList" : listRecs
            });
            action.setCallback(this, function(response) {
                component.set('v.showSpinner',false);
                var isNew	=	component.get('v.isNewRecord');
                var dmlErrors = [];
                var state	=	response.getState();
                if(state === "ERROR"){
                    if (response.error[0].fieldErrors) {
                        for (var key in response.error[0].fieldErrors) {
                            console.log('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        	dmlErrors.push('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                            component.set('v.dmlErrors',dmlErrors);
                        }
                    }
                } else if(state == "SUCCESS"){
                    console.log(response.getReturnValue());
                    if(isNew){
                        var removedPartId	=	response.getReturnValue()[0].sObjID;
                        console.log(':::: removed part id:'+removedPartId);
                    }

                    component.set('v.isNewRecord',false);
                    if (response.getReturnValue()[0].errorCodeList) {
                        for(var key in response.getReturnValue()[0].errorCodeList) {
                            console.log(response.getReturnValue()[0].errorCodeList[key]);
                            dmlErrors.push(response.getReturnValue()[0].errorCodeList[key]);
                            component.set('v.dmlErrors',dmlErrors);
                        }
                    }
                    var saveResult = response.getReturnValue()[0];
                    if(saveResult.success == Boolean(1)){

                    }
                    var myEvent1 = $A.get("e.c:ModalCloseEvent");
                    myEvent1.setParams({
                        "isModalEnabled":false
                    });
                    myEvent1.fire();
                    var myEvent = $A.get("e.c:UpdateInstalledParts");
                    myEvent.setParams({
                    });
                    myEvent.fire();

                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.showSpinner',false);
        }


	},

    changeModalClose	: function(component, event, helper){
        event.preventDefault();
        var myEvent = $A.get("e.c:ModalCloseEvent");
        myEvent.setParams({
            "isModalEnabled":false
        });
        myEvent.fire();
    }
})