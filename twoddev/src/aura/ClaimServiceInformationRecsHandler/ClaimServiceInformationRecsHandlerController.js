({
    // Method acts as the constructor
	doInit : function(component, event, helper) {
        //console.log(component.get('{!v.installedParts}'));
        //console.log('::::: Enable modal:'+component.get('v.isEnableModal'));
	},



    // Code to handle the check box selection and deselect functionality
    handleClaimPartSelection : function(component, event, helper) {

        console.log(':::: entered here');
        console.log(event.getSource().elements[0].defaultValue);
        var recordNumber = event.getSource().elements[0].defaultValue;
        console.log(':::: Record number:'+recordNumber);
        console.log(component.get('v.claimServiceInfos')[recordNumber]);

        var idValuesString = component.get("v.deleteRecordNumbers");
        console.log('idValuesString1'+idValuesString);
        var location = idValuesString.indexOf(recordNumber);
        console.log('::location::'+location);
        if(location > -1) {
            idValuesString.splice(location, 1);
            component.set("v.deleteRecordNumbers",idValuesString);
        } else {
            idValuesString.push(recordNumber);
			component.set("v.deleteRecordNumbers",idValuesString);
        }
        console.log(':::::delete record numbers:::'+component.get('v.deleteRecordNumbers'));

    },


    // Adding the new record whenever clicked on the Add row Button
    addNewRow : function(component, event, helper) {

        component.set('v.serviceJobId',null);
        component.set('v.serviceJobName',null);
        component.set('v.isNewRecord', true);
        component.set('v.isEnableModal',true);

        console.log(':::::: New Row record:');
        console.log(component.get('v.claimServiceInfo'));
        console.log('::::: Enable modal:'+component.get('v.isEnableModal'));

    },


    // Delete records function to delete the selected records in installed claim parts table
    deleteRecords : function(component, event, helper) {
        event.preventDefault();
        console.log(':::: count'+component.get('v.deleteRecordNumbers').length);
        var deleteRecs		=	component.get('v.deleteRecordNumbers');
         console.log('--------------------------inside deleteRecords----claim service info -------');
        component.set('v.isDeleteClicked',true);
        component.set('v.isDeleteDisabled',true);

        component.get('v.isDeletable',false);
        component.set('v.typeOfDeletion','All');
        console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
        console.log('--------------------------deletable -------------',component.get('v.isDeletable'));
    },
     deleteRecordsByResponse : function(component, event, helper) {
         console.log('--------------------------inside deleteRecordsByResponse------claim service info -----------');
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
        }else if(component.get('v.typeOfDeletion') == 'Single'){
            if(isDeletable){
                helper.deleteClaimServiceInfo(component, event, helper.currentRecordNum);
            }else{
                component.set('v.isDeleteDisabled',false);
            }
        }
               
     },
		// delete claimServiceInfo
		deleteClaimServiceInfo : function(component, event, helper){
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
            
			helper.currentRecordNum = currentRecordNum;
            
            console.log('------------currentRecordNum'+currentRecordNum);
            
            component.set('v.isDeleteClicked',true);
            component.set('v.isDeleteDisabled',true);

            component.get('v.isDeletable',false);
            component.set('v.typeOfDeletion','Single');
            console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
            console.log('--------------------------deletable -------------',component.get('v.isDeletable'));
		},

    // After the modal hasbeen closed update the isEnableModal to false, so whenever we click on the Add new or edit, then popup will come again
    changeModalClose : function(component, event, helper) {
        component.set('v.isEnableModal',false);
        component.set('v.serviceJobId', null);
        component.set('v.serviceJobName', null);
    },

    // Edit the record whenever click on the edit button and pass the required values
    editClaimPart : function(component, event, helper) {
        console.log(event);
        
        console.log(event.target);
        console.log('::::: event.target.parentNode.parentElement.tabIndex');
        console.log(event.target.parentNode.parentElement.tabIndex);
        console.log('::::: event.target.parentElement.tabIndex:');
        console.log(event.target.parentElement.tabIndex);
        
        component.set('v.isEnableModal',false);
        component.set('v.serviceJobId', null);
        component.set('v.serviceJobName', null);
        component.set('v.isNewRecord',false);

        
        var currentRecordNum =	0;
        if(typeof(event.target.parentNode.parentElement.tabIndex) == "undefined" || event.target.parentNode.parentElement.tabIndex < 0){
            currentRecordNum = event.target.parentElement.tabIndex; 
        }else{
            currentRecordNum = event.target.parentNode.parentElement.tabIndex;
        }

        console.log('::::: current record number:'+currentRecordNum);
        var allRecords		=	component.get('v.claimServiceInfos');
        var currentRecord	=	allRecords[currentRecordNum];
        console.log('::::: current record:');
        console.log(currentRecord);
        var currentRecordId		=	currentRecord.Id;

        // Action to retrieve the reocrd information
        var action 	= 	component.get('c.findSObjectsBySOQL');
        action.setParams({
            "query" : "SELECT Id, Name, Service_Job_Code__r.Description__c, Additional_Labor_Hour__c, Service_Job_Code__c, Service_Job_Code__r.Name, Service_Job_Code__r.Standard_Labor_Hour__c, Reason_Additional_Labor_hour__c, Total_Labor_hours__c, Claim__c FROM Claim_Service_Information__c WHERE Id =" + '\''+currentRecordId +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: current installed part:');
            console.log(response.getReturnValue()[0]);
            component.set("v.claimServiceInfo",response.getReturnValue()[0]);
            currentRecord	=	component.get("v.claimServiceInfo");

            component.set('v.serviceJobId',currentRecord.Service_Job_Code__c);
            component.set('v.standardHours',currentRecord.Service_Job_Code__r.Standard_Labor_Hour__c);
						component.set('v.jobCodeDescription',currentRecord.Service_Job_Code__r.Description__c);
            console.log('::: Standard Hours:'+component.get('v.standardHours'));
            component.set('v.serviceJobName',currentRecord.Service_Job_Code__r.Name);
            console.log(':::::::::::: current Record ' + currentRecord);
            //console.log(':::::::::::: current Warranty name :' + currentRecord.Warranty_Product__r.Name);
            component.set('v.isNewRecord',false);
            component.set('v.showStandardHours',true);
            component.set('v.isEnableModal',true);

        });
        $A.enqueueAction(action);

    }

})