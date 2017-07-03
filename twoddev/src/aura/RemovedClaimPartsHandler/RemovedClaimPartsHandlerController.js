({
    // Method acts as the constructor
	doInit : function(component, event, helper) {
        console.log(component.get('{!v.installedParts}'));
        console.log('::::: Enable modal:'+component.get('v.isEnableModal'));

	},


	deleteClaimPart : function(component, event,	helper){
		console.log(event);
		//console.log(event.target.value);
		/*
        var currentRecordNum	=	0;
		if(typeof(event.target.parentNode.parentElement.value) != "undefined"){
				currentRecordNum = event.target.parentNode.parentElement.value;
		}else{
				currentRecordNum = event.target.parentElement.value;
		}
        */
        
        var currentRecordNum =	0;
        console.log(event.target);
        console.log('::::: event.target.parentNode.parentElement.tabIndex');
        console.log(event.target.parentNode.parentElement.tabIndex);
        console.log('::::: event.target.parentElement.tabIndex:');
        console.log(event.target.parentElement.tabIndex);
        
        if(typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0){
            currentRecordNum = event.target.parentElement.tabIndex; 
        }else{
            currentRecordNum = event.target.parentNode.parentElement.tabIndex;
        }
        
        
		console.log('::::: current record number:'+currentRecordNum);
        helper.currentRecordNum = currentRecordNum;
            
        component.set('v.isDeleteClicked',true);
        component.set('v.isDeleteDisabled',true);
        component.get('v.isDeletable',false);
        component.set('v.typeOfDeletion','Single');
        console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
        console.log('--------------------------deletable -------------',component.get('v.isDeletable'));
       
	},

		// Used to deselect the selected installed parts
		removeSelectedItems : function(component, event, helper){
				component.set('v.deleteRecordNumbers',component.get('v.emptyNumber'));
		},

    // Code to handle the check box selection and deselect functionality
    handleClaimPartSelection : function(component, event, helper) {

        console.log(':::: entered here');
        console.log(event.getSource().elements[0].defaultValue);
        var recordNumber	=	event.getSource().elements[0].defaultValue;
        console.log(component.get('v.installedParts')[recordNumber]);

        var idValuesString	=	component.get("v.deleteRecordNumbers");
				if(typeof idValuesString == "undefined"){
						component.set("v.deleteRecordNumbers",[]);
						idValuesString	=	[];
				}
        console.log('idValuesString1'+idValuesString);
        var location		=	idValuesString.indexOf(recordNumber);
        console.log(':: location:'+location);
        if(location > -1) {
            idValuesString.splice(location, 1);
            component.set("v.deleteRecordNumbers",idValuesString);
        } else {
            idValuesString.push(recordNumber);
			component.set("v.deleteRecordNumbers",idValuesString);
        }
        console.log('::::: delete record numbers:'+component.get('v.deleteRecordNumbers'));

    },


    // Adding the new record whenever clicked on the Add row Button
    addNewRow : function(component, event, helper) {
				//component.set('v.deleteRecordNumbers',component.get('v.emptyNumber'));
		component.set('v.inventoryId',null);
        component.set('v.inventoryName',null);
        component.set('v.warrantyProductId',null);
        component.set('v.warrantyProductName',null);
        component.set('v.isNewRecord', true);
        component.set('v.isEnableModal',true);
        component.set('v.isDisabledWarranty',false);
        component.set('v.isDisabledInventory',false);


        console.log(':::::: New Row record:');
        console.log(component.get('v.installedPart'));
        console.log('::::: Enable modal:'+component.get('v.isEnableModal'));

    },



    // Delete records function to delete the selected records in installed claim parts table
    deleteRecords : function(component, event, helper) {
        console.log('::::: Delete records:');
        console.log(component.get('v.deleteRecordNumbers'))

        var deleteRecs		=	component.get('v.deleteRecordNumbers');
		
        console.log('--------------------------inside deleteRecords-----removed part--------');
        component.set('v.isDeleteClicked',true);
        component.set('v.isDeleteDisabled',true);
        component.get('v.isDeletable',false);
        component.set('v.typeOfDeletion','All');
        console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
        console.log('--------------------------deletable -------------',component.get('v.isDeletable'));

    },
	 deleteRecordsByResponse : function(component, event, helper) {
         console.log('--------------------------inside deleteRecordsByResponse------installed part-----------');
         var isDeletable = event.getParam('response');
        var isDeleteClicked = event.getParam('isPopup');
        
        console.log('--------------------------deletable -------------',isDeletable);
        console.log('--------------------------deletable -------------',isDeleteClicked);
        if(component.get('v.typeOfDeletion') == 'All'){
            if(isDeletable){
                helper.deleteRecordsHelper(component, event);
            }else{
                component.set('v.isDeleteDisabled',false); 
            }             

            var myEvent2 = $A.get("e.c:DeselectPartIds");
            myEvent2.setParams({
            });
            myEvent2.fire();
        }else if(component.get('v.typeOfDeletion') == 'Single'){
            if(isDeletable){
                helper.deleteIndividualRecords(component, event, helper.currentRecordNum);
            }else{
                component.set('v.isDeleteDisabled',false); 
            }  
        }
     },

    // After the modal hasbeen closed update the isEnableModal to false, so whenever we click on the Add new or edit, then popup will come again
    changeModalClose : function(component, event, helper) {
        component.set('v.isEnableModal',false);
        component.set('v.inventoryId', null);
        component.set('v.inventoryName', null);
        component.set('v.warrantyProductName', null);
        component.set('v.warrantyProductId', null);
    },

    // Edit the record whenever click on the edit button and pass the required values
    editClaimPart : function(component, event, helper) {
        console.log(event);
        console.log(event.target.parentNode.parentElement.value);
        console.log(event.target.parentElement.value);
				component.set('v.deleteRecordNumbers',component.get('v.emptyNumbers'));
        component.set('v.isEnableModal',false);
        component.set('v.inventoryId', null);
        component.set('v.inventoryName', null);
        component.set('v.warrantyProductName', null);
        component.set('v.warrantyProductId', null);
        component.set('v.isNewRecord',false);
        
        var currentRecordNum =	0;
        console.log(event.target);
        console.log('::::: event.target.parentNode.parentElement.tabIndex');
        console.log(event.target.parentNode.parentElement.tabIndex);
        console.log('::::: event.target.parentElement.tabIndex:');
        console.log(event.target.parentElement.tabIndex);
        
        if(typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0){
            currentRecordNum = event.target.parentElement.tabIndex; 
        }else{
            currentRecordNum = event.target.parentNode.parentElement.tabIndex;
        }
        
        
        console.log('::::: current record number:'+currentRecordNum);
        var allRecords		=	component.get('v.installedParts');
        var currentRecord	=	allRecords[currentRecordNum];
        console.log('::::: current record:');
        console.log(currentRecord);
        var currentRecordId		=	currentRecord.Id;

        // Action to retrieve the reocrd information
        var action 	= 	component.get('c.findSObjectsBySOQL');
        action.setParams({
            "query" : "SELECT Id, Name, RecordType.Name, Inventory__c, Inventory__r.Name, Claim__c, Warranty_Product__r.Name, Warranty_Product__c, Quantity__c FROM Removed_Claim_Part__c WHERE Id =" + '\''+currentRecordId +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: current installed part:');
            console.log(response.getReturnValue()[0]);
            component.set("v.installedPart",response.getReturnValue()[0]);
            currentRecord	=	component.get("v.installedPart");
            console.log(':::::::::::: current Record ' + currentRecord);
            console.log(':::::::::::: current Record Inv ' + currentRecord.Inventory__c);

            console.log(':::::::::::: current Warranty_Product__c :' + currentRecord.Warranty_Product__c);
            if(typeof currentRecord.Inventory__c != "undefined" && currentRecord.Inventory__c != null && currentRecord.Inventory__c != '') {
                component.set('v.isDisabledWarranty', true);
                console.log('::: current record inventory:'+currentRecord.Inventory__c);
                console.log('::: current inventory name:'+currentRecord.Inventory__r.Name);
                var invName	=	currentRecord.Inventory__r.Name;
                console.log(':::::: invName:'+invName);
                component.set('v.inventoryId',currentRecord.Inventory__c);
                component.set('v.inventoryName',invName);
								component.set('v.isInvSave',true);
								component.set('v.isWarrantySave',false);
                component.set('v.isEnableModal',true);

            }
            else
                if(typeof currentRecord.Warranty_Product__c != "undefined" && currentRecord.Warranty_Product__c != null && currentRecord.Warranty_Product__c != '') {
                    var productName	=	currentRecord.Warranty_Product__r.Name;
                    var productId	=	currentRecord.Warranty_Product__c;
                    component.set('v.warrantyProductId',  productId);
                    component.set('v.warrantyProductName', productName);
                    component.set('v.isDisabledInventory', true);
                    console.log('::::: Product name:'+currentRecord.Warranty_Product__r.Name);
                    console.log('::::: Warranty Product name:'+component.get('v.warrantyProductName'));
										component.set('v.isInvSave',false);
										component.set('v.isWarrantySave',true);
                    component.set('v.isEnableModal',true);
                }
								console.log('::: is inv save:'+component.get('v.isInvSave'));
								console.log('::: is isWarrantySave save:'+component.get('v.isWarrantySave'));
								var myEvent2 = $A.get("e.c:DeselectPartIds");
								myEvent2.setParams({
								});
								myEvent2.fire();

								var myEvent = $A.get("e.c:DeselectRemovedPartIds");
								myEvent.setParams({
								});
								myEvent.fire();

        });
        $A.enqueueAction(action);

    }

})