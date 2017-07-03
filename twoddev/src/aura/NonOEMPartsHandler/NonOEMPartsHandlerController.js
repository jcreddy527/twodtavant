({
	editClaimPart : function(component, event, helper) {
        component.set('v.showSpinner',true);
		component.set('v.isModalEnable',false);
        component.set('v.isNewRecord',false);
        //component.set('v.context',$A.getContext().gg);
        var currentRecordNum =	0;
        var currentRecordId	=	'';

        console.log(':::::: current NON OEM record number:'+event.target.parentNode.parentElement.value);
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
        var allRecords		=	component.get('v.nonOEMParts');
        var currentRecord	=	allRecords[currentRecordNum];
        component.set('v.nonOEMPart',currentRecord);
        console.log('::: non oem part:');
        console.log(component.get('v.nonOEMPart'));
        component.set('v.isModalEnable',true);
        component.set('v.showSpinner',false);
        /*
        var action	=	component.get('c.findSObjectsBySOQL');
        action.setParams({
            "query" : "SELECT Id, Name, Miscellaneous_Part_Name__c, Price__c, Quantity__c FROM Claim_Part__c WHERE Id =" + '\''+currentRecordId +'\''
        });
        action.setCallback(this, function(response) {
        });
        $A.enqueueAction(action);
        */
	},

    deleteClaimPart : function(component, event, helper) {
        console.log('--------------------------inside deleteClaimPart-------------');
        
        var currentRecordNum =	0;
        var currentRecordId	=	'';
        
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
        component.set('v.isDeleteClicked',true);
        component.set('v.isDeleteDisabled',true);
        component.get('v.isDeletable',false);
        component.set('v.typeOfDeletion','Single');
        console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
        console.log('--------------------------deletable -------------',component.get('v.isDeletable'));
	},

    addNewRow		: function(component, event, helper){
        var objectName	=	'Claim_Part__c';
		component.set('v.showSpinner',true);
        component.set('v.isModalEnable',false);
        component.set('v.nonOEMPart',component.get('v.tempNonOEM'));
        var action2	=	component.get('c.findSObjectsBySOQL');
        action2.setParams({
            "query" : "SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = "+'\''+ objectName +'\''
        });
        action2.setCallback(this, function(response) {
            var result	=	response.getReturnValue();
            console.log('::::: Result value:');
            console.log(result);
			
            for(var i=0;i < result.length; i++){
                if(result[i].DeveloperName ==  'Miscellaneous_Part'){
                    //recordTypeId	=	result[i].Id;
                    console.log('::::: Developer name:'+result[i].DeveloperName);
                    console.log(result[i]);
                    component.set('v.recordTypeId',result[i].Id);

                    component.set('v.nonOEMPart',component.get('v.tempNonOEM'));
                    component.set('v.nonOEMPart.Claim__c',component.get('v.claimId'));
                    component.set('v.nonOEMPart.Name','');
                    component.set('v.nonOEMPart.Miscellaneous_Part_Name__c','');
                    component.set('v.nonOEMPart.Custom_Part_Cost__c','');
                    component.set('v.nonOEMPart.Quantity__c','');
                    component.set('v.nonOEMPart.RecordTypeId',result[i].Id);
                    component.set('v.isNewRecord',true);
                    component.set('v.isModalEnable',true);
					component.set('v.showSpinner',false);
                }
            }
        });
        $A.enqueueAction(action2);


    },

    deleteRecords	: function(component, event, helper){
        console.log('--------------------------inside deleteRecords-----NON OEM--------');
        component.set('v.isDeleteClicked',true);
        component.set('v.isDeleteDisabled',true);
        component.get('v.isDeletable',false);
        component.set('v.typeOfDeletion','All');
        console.log('--------------------------deletable -------------',component.get('v.isDeleteClicked'));
        console.log('--------------------------deletable -------------',component.get('v.isDeletable'));
        
       
    },
    deleteRecordsByResponse: function(component, event, helper){
        
        console.log('--------------------------inside deleteRecordsByResponse----NON OEM-------------');
         var isDeletable = event.getParam('response');
        var isDeleteClicked = event.getParam('isPopup');
        
        console.log('--------------------------deletable -------------',isDeletable);
        console.log('--------------------------deletable -------------',isDeleteClicked);
        
        if(component.get('v.typeOfDeletion') == 'All'){
            if(isDeletable){
                helper.deleteRecordsHelper(component,event);
                component.set('v.isDeleteClicked',isDeleteClicked);
            }else{
                 component.set('v.isDeleteClicked',isDeleteClicked);
                component.set('v.isDeleteDisabled',false);
            }
        }else if(component.get('v.typeOfDeletion') == 'Single'){
            if(isDeletable){
                helper.deleteIndividualRecords(component,event,helper.currentRecordNum);
            	component.set('v.isDeleteClicked',isDeleteClicked);
            }else{
                 component.set('v.isDeleteClicked',isDeleteClicked);
                 component.set('v.isDeleteDisabled',false);

            }

        }
    },

    changeModalClose : function(component, event, helper){
        component.set('v.isModalEnable',false);
    }
})