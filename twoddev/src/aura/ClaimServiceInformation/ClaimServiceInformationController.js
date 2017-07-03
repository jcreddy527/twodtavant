({
    doInit : function(component, event, helper) {
        console.log('::::: Claim id:'+component.get('{!v.claimId}'));
        component.set('v.claimServiceInfo.Claim__c',component.get('{!v.claimId}'));
        var claimId	=	component.get('{!v.claimId}');
        //var claimServiceInfo	=	component.get('c.findSObjectsBySOQL');
        var action = component.get('c.findSObjectsBySOQL');
        action.setParams({
            "query" : "SELECT Id, Name, Warranty_Product_Pricebook__c, RecordType.Name, Inventory__c, Claim__c, Warranty_Product__c, Quantity__c, Custom_Part_Cost__c, Final_Parts_Cost__c, Total_Parts_Cost__c  FROM Claim_Part__c WHERE Claim__c =" + '\''+claimId +'\''
        });
        action.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            var recordValue	=	response.getReturnValue()[0];
        });
        $A.enqueueAction(action);

        var action2 = component.get('c.findSObjectsBySOQL');
        action2.setParams({
            "query" : "SELECT Id, Name, Claim__c,Inventory__c,Inspector_Comments__c,Return_Location__c,Shipment_Detail__c,Shipment_Due_Days__c,Quantity__c,Is_Inspected__c,Is_Approved__c,Dealer_Received_Parts__c,Payment_Condition__c FROM Removed_Claim_Part__c WHERE Claim__c =" + '\''+claimId +'\''
        });
        action2.setCallback(this, function(response) {
            console.log(':::: Response from server:');
            console.log(response.getReturnValue());
            var recordValue	=	response.getReturnValue()[0];
        });
        $A.enqueueAction(action2);

        console.log(component.get('{!v.claimServiceInfo}'));
    },

    changeModalClose	: function(component, event, helper){
  			event.preventDefault();
  			var myEvent = $A.get("e.c:ModalCloseEvent");
  			myEvent.setParams({
  					"isModalEnabled":false
  			});
  			myEvent.fire();
  	},

    removeSelectedItems : function(component, event, helper){

    },
    
    onJobcodeSelect : function(component, event, helper){
		
    },
    
    serviceJobHandler : function(component, event, helper){
        console.log('Coming on change');
        //var serviceJobId	= component.get('v.serviceJobId');
        var serviceJobId	= component.find('JobCode').get('v.value');
        console.log(':::Selected job code');
        console.log(serviceJobId);
        component.set("v.serviceJobId",serviceJobId);
        var listOfRecs		=	[];
  
        if(serviceJobId != null && serviceJobId != '' && typeof serviceJobId != "undefined"){
            var action 	= 	component.get('c.findSObjectsBySOQL');
            action.setParams({
                "query" : "SELECT Id, Name, Description__c, Standard_Labor_Hour__c, Selectable__c, Warranty_Product__c, Warranty_Product__r.Name FROM Warranty_Code__c WHERE Id ="+ '\''+serviceJobId +'\''
            });
            action.setCallback(this, function(response) {
                listOfRecs	=	response.getReturnValue();
                console.log(':::: list of Recs:'+listOfRecs);
                component.set('v.standardHours',response.getReturnValue()[0].Standard_Labor_Hour__c);
                component.set('v.jobCodeDescription',response.getReturnValue()[0].Description__c);
                component.set('v.serviceJobRec',response.getReturnValue()[0]);
                component.set('v.showStandardHours',true);
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.showStandardHours',false);
        }
    },


    /* Save Claim Service Information */
	saveClaimServiceInfo : function(component, event, helper) {
        /* Entered Record */
        var serviceJobId	= component.get('v.serviceJobId');
        console.log(component.get('v.claimServiceInfo'));
        var sObject			= component.get('v.claimServiceInfo');
        //var serviceName 	= component.find("serviceName");
        //var name   			= serviceName.get("v.value");
        var errorCount		=	0;
        sObject.Service_Job_Code__c = serviceJobId;
        component.set('v.claimServiceInfo.Service_Job_Code__c',serviceJobId);
        component.set('v.claimServiceInfo.Claim__c',component.get('v.claimId'));
        //console.log(name);
        if(component.get('v.isNewRecord')){
            component.set('v.claimServiceInfo.Name','s');
        }
        console.log(':::: Claim service Info:'+component.get('v.claimServiceInfo.Claim__c'));

		/* Job code error */
        if (component.get('v.claimServiceInfo.Service_Job_Code__c') == '' || component.get('v.claimServiceInfo.Service_Job_Code__c') == null || typeof component.get('v.claimServiceInfo.Service_Job_Code__c') == "undefined"){
            console.log('::::: job code empty');
            component.set("v.jobCodeError", "Please select a job code");
            errorCount++;
        } else {
            component.set("v.jobCodeError", "");
        }
        console.log(':::: Error count:'+errorCount);

        var additionalLabourHour = component.find("additionalLaborHour");
        var value = additionalLabourHour.get("v.value");

        if(value != null && value != '' && typeof value != "undefined"){
          // Is input numeric?
          if (isNaN(value)) {
              errorCount++;
              additionalLabourHour.set("v.errors", [{message:"Additional Labor Hour should be number, Input not a number: " + value}]);
          } else {
              additionalLabourHour.set("v.errors", null);
          }
          var reasonAdditionalLabourHour = component.find("reasonForAdditionalHours");
          var reasonValue = reasonAdditionalLabourHour.get("v.value");
          if(reasonValue == null || reasonValue == '' || typeof reasonValue == "undefined"){
              errorCount++;
              reasonAdditionalLabourHour.set("v.errors",[{message:"Please enter Reason Additional Labor Hour"}]);
          }else {
              reasonAdditionalLabourHour.set("v.errors", null);
          }
        }

        console.log(sObject);
        if(errorCount == 0) {

            var listRecs	=	[];
            listRecs.push(sObject);
            console.log(':::: is New record:'+component.get('v.isNewRecord'));
            var action 	= 	component.get('c.InsertSObjectServiceInfo');
            if(component.get('v.isNewRecord') == false) {
                action 	= 	component.get('c.UpdateSObjects');
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

					if (response.error[0].fieldErrors) {
						for (var key in response.error[0].fieldErrors) {
                            console.log('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        	dmlErrors.push('Field Name ' + key + ' -The Message : ' + response.error[0].fieldErrors[key][0].message);
                        }
                    }

                } else if(state == "SUCCESS"){
                    component.set('v.currentTab',3);
                    component.set('v.NextTab',4);

                    console.log(response.getReturnValue());

                    if (response.getReturnValue()[0].errorCodeList) {
                            for  (var key in response.getReturnValue()[0].errorCodeList) {
                                console.log(response.getReturnValue()[0].errorCodeList[key]);
                                dmlErrors.push(response.getReturnValue()[0].errorCodeList[key]);
                            }
                        }
                    var saveResult = response.getReturnValue()[0];
                    if(saveResult.success == Boolean(1)){
                        component.set("v.claimServiceInfo.Id",saveResult.sObjID);
                        component.set('v.isEdit', Boolean(0));
                        component.set('v.claimServiceInfo',component.get('v.tempClaimServiceInfo'));
                    } else {
                       //
                    }

                    var myEvent = $A.get("e.c:ModalCloseEvent");
                    myEvent.setParams({

                    });
                    myEvent.fire();


                    console.log(':::: Firing Claim Service event');
                    var updateClaimSeriveEvent = $A.get("e.c:ClaimServiceEvent");
                    updateClaimSeriveEvent.setParams({

                    });
                    updateClaimSeriveEvent.fire();

                }
                component.set("v.dmlErrors",dmlErrors);

            });
            $A.enqueueAction(action);

        }

	}
})