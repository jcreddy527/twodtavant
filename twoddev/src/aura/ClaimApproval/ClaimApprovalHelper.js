({
    unlockstatus:'',
    claimStatusApproveReject : function(component,helper,event)
    {
     /* if(component.get('v.claimRecord.Claim_Status__c') == 'Approved')
                {console.log('---------------------inside approved');
                     component.set('v.showApprove',false);
                     component.set('v.showReject',true);
                }
                else if(component.get('v.claimRecord.Claim_Status__c') == 'Rejected')
                {
                    component.set('v.showApprove',true);
                    component.set('v.showReject',false);
                }
        		else */
        if(component.get('v.claimRecord.Claim_Status__c') == 'Submitted')
                {
                    component.set('v.showApprove',true);
                    component.set('v.showReject',true);

                }  
    },
	recordUnLockHelper : function(component,helper,event,recordId,SobjectRecord,'Enter') {
        console.log('---------------inside unlock helllllllper');
        var action = component.get("c.recordUnlock");
            action.setParams({
                "recordId"	: recordId,
                "claimRecord":SobjectRecord
            });
            action.setCallback(this, function(a) {
                console.log(a.getReturnValue());
				helper.unlockstatus = a.getReturnValue();              
                console.log('---------------unlocked:'+a.getReturnValue());
            });
        $A.enqueueAction(action);
		
	},
    recordLockHelper : function(component,helper,event,SobjectRecord) {
        console.log('---------------inside lock helper');
        var action = component.get("c.recordLock");
            action.setParams({
                "claimRecord":SobjectRecord
            });
            action.setCallback(this, function(a) {
                console.log('---------------locked');
            });
        $A.enqueueAction(action);
		
	},
	updateClaimValidationforAdmin	: function(component, event, Elementid, errorCount){
		var inputCmp = component.find(Elementid);
		console.log('----------inputCmp----------'+Elementid);
		console.log(inputCmp);
		var value = inputCmp.get("v.value");
		console.log('================='+value);
		if (isNaN(value)) {
			errorCount++;
			inputCmp.set("v.errors", [{message:"Input not a number: " + value}]);
		} else {
			inputCmp.set("v.errors", null);
		}
		console.log('::: error count in helper:'+errorCount);
		return errorCount;
	},
	updateRelatedField: function(component,helper,onkeyUpId,updatedValue){
		if(onkeyUpId == 'percentLaborCost')
		{
			helper.ToValue(component,'approvedLaborCost',component.get('v.claimRecord.Final_Labor_Cost__c'),updatedValue);
		}
		else if(onkeyUpId == 'percentTravelByDistanceCost'){
			helper.ToValue(component,'approvedTravelByDistanceCost',component.get('v.claimRecord.Final_TravelByDistance_Cost__c'),updatedValue);
		}
		else if(onkeyUpId == 'percentTravelByHoursCost'){
			helper.ToValue(component,'approvedTravelByHoursCost',component.get('v.claimRecord.Final_TravelByHours_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'percentPartsCost'){
			helper.ToValue(component,'approvedPartsCost',component.get('v.claimRecord.Final_Parts_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'percentMealsCost'){
			helper.ToValue(component,'approvedMealsCost',component.get('v.claimRecord.Final_Meals_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'percentParkingCost'){
			helper.ToValue(component,'approvedParkingCost',component.get('v.claimRecord.Final_Parking_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedLaborCost'){
			helper.ToPercent(component,'percentLaborCost',component.get('v.claimRecord.Final_Labor_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedTravelByDistanceCost'){
			helper.ToPercent(component,'percentTravelByDistanceCost',component.get('v.claimRecord.Final_TravelByDistance_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedTravelByHoursCost'){
			helper.ToPercent(component,'percentTravelByHoursCost',component.get('v.claimRecord.Final_TravelByHours_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedPartsCost'){
			helper.ToPercent(component,'percentPartsCost',component.get('v.claimRecord.Final_Parts_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedMealsCost'){
			helper.ToPercent(component,'percentMealsCost',component.get('v.claimRecord.Final_Meals_Cost__c'),updatedValue);
			}
		else if(onkeyUpId == 'approvedParkingCost'){
			helper.ToPercent(component,'percentParkingCost',component.get('v.claimRecord.Final_Parking_Cost__c'),updatedValue);
			}

	},
	ToPercent : function(component,fieldToUpdate,mediationFieldsValue,updatedValue){
		var finalValue = (updatedValue * 100)/mediationFieldsValue;
		console.log(component.find(finalValue));
		component.find(fieldToUpdate).set('v.value',finalValue);
	},
	ToValue : function(component,fieldToUpdate,mediationFieldsValue,updatedValue){
		var finalValue = (updatedValue * mediationFieldsValue)/100;
		console.log(component.find(fieldToUpdate));
		component.find(fieldToUpdate).set('v.value',finalValue);

	},
	submitClaimRecord	: function(component, event){
		var ClaimId	=	component.get('v.claimId');
		window.open(component.get('v.BaseURL')+"/"+ClaimId,"_self");
	},
    ApproveClaim : function(component, event, helper){
        console.log('-----------------Inside----------- approve claim');       
        var action = component.get("c.LockUnlockBasedOnAction1");
            action.setParams({
                "recordId"	: component.get('v.claimId'),
                "fieldToModify":"Claim_Status__c",
                "valueToPut":"Approved"
            });
            action.setCallback(this, function(a) {
                console.log('-----------------Inside approve claim-----callback-----');
                helper.submitClaimRecord(component, event);
            });
        	$A.enqueueAction(action);
    },
    RejectClaim : function(component, event, helper){
       var action = component.get("c.LockUnlockBasedOnAction1");
            action.setParams({
                "recordId"	: component.get('v.claimId'),
                "fieldToModify":"Claim_Status__c",
                "valueToPut":"Rejected"
            });
            action.setCallback(this, function(a) {
                console.log('-----------------Inside reject claim----------'+a.getReturnValue());
                helper.submitClaimRecord(component, event);
            });
        	$A.enqueueAction(action);
    },
	setCurrentTabHelper: function(component, event, helper){
		var nextclicked =  component.get('v.isNextClicked');
		var prevclicked = component.get('v.isPrevClicked');
		var currentTab = component.get('v.currentTab');
		var tabCount = component.get("v.numRecords");
		console.log('------------------'+currentTab);
		var Errorcount = 0;
		//helper.updateClaimRecord(component, event);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentLaborCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedLaborCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentTravelByDistanceCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedTravelByDistanceCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentTravelByHoursCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedTravelByHoursCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentPartsCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedPartsCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentMealsCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedMealsCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'percentParkingCost',Errorcount);
		Errorcount = helper.updateClaimValidationforAdmin(component, event,'approvedParkingCost',Errorcount);

		if(Errorcount == 0)
		{
			if(nextclicked || prevclicked)
			{
				console.log('-------------------- next clicked');
				$A.util.removeClass(document.getElementById('litem-tab-' + currentTab), 'slds-active');
				$A.util.removeClass(document.getElementById('divitem-tab-' + currentTab), 'slds-show');
				$A.util.addClass(document.getElementById('divitem-tab-' + currentTab), 'slds-hide');
				if(nextclicked)
				{
					console.log('inside ----next clicked-------------',currentTab);
					var NextTab = parseInt(currentTab)+1;
					console.log("--------------NextTab: " + NextTab);
				}
				else if(prevclicked)
				{
					console.log('inside ----prev clicked-------------',currentTab);
					var NextTab = parseInt(currentTab)-1;
					console.log("--------------NextTab: " + NextTab);
				}
				var whichTab = 'tab-'+NextTab;
				console.log('-----whichTab----'+whichTab);
				var cmpTargetLi = document.getElementById('litem-' + whichTab);
				var cmpTargetDiv = document.getElementById('divitem-' + whichTab);
				$A.util.addClass(cmpTargetLi, 'slds-active');
				$A.util.removeClass(cmpTargetDiv, 'slds-hide');
				$A.util.addClass(cmpTargetDiv, 'slds-show');
				component.set('v.isNextClicked',false);
				component.set('v.isPrevClicked',false);
				console.log('---------v.currentTab--------'+NextTab);
				component.set('v.currentTab',NextTab);
			}
			else if(!nextclicked && !prevclicked)
			{
				console.log('---------not----------- next clicked');
				for (var i=1; i<= tabCount ; i++) {
					console.log('-----------inside for loop');
					$A.util.removeClass(document.getElementById('litem-tab-' + i), 'slds-active');
					$A.util.removeClass(document.getElementById('divitem-tab-' + i), 'slds-show');
					$A.util.addClass(document.getElementById('divitem-tab-' + i), 'slds-hide');
				}
				var whichTab ='tab-' + event.target.tabIndex;
				console.log('::::: current target value:'+event.target.tabIndex);
				var splittedtab = event.target.tabIndex;
                if(splittedtab == 1)
                    component.set('v.refreshSummary',false);
				console.log('-----whichTab----'+whichTab);

				var cmpTargetLi = document.getElementById('litem-' + whichTab);
				var cmpTargetDiv = document.getElementById('divitem-' + whichTab);
				$A.util.addClass(cmpTargetLi, 'slds-active');
				$A.util.removeClass(cmpTargetDiv, 'slds-hide');
				$A.util.addClass(cmpTargetDiv, 'slds-show');
				component.set('v.currentTab',splittedtab);
			}
		}
	},
	CLAIM_QUERY : 'Select Id, Name,Total_Parts_Cost__c,RecordTypeId,Claim_Status__c,RecordType.DeveloperName,Delay_Reason__c,Date_Of_Purchase__c,Invoice_Number__c, RecordType.Name,Service_Ticket__c,Work_order__c, Account__r.Name, Inventory__r.Name, Campaign_Members__r.Name, Warranty_Product__r.Name,Fault_Code__r.Name,Fault_Code__r.Description__c, Causal_Part_Number__r.Name,Causal_Part_Number__r.Description__c, Applicable_Policy__r.Name,Account__c,Inventory__c,Warranty_Product__c,Campaign_Members__c,Host_NonHost__c,Serial_Number__c,Date_of_Failure__c,Date_of_Repair__c,Applicable_Policy__c,Fault_Code__c,Causal_Part_Number__c,Request_SMR__c,Claim_Parts_Pending_Approval__c,SMR_Reason__c,Override_Policy__c,TravelByHours__c,TravelByDistance__c,Total_Labor_Cost__c,Final_Labor_Cost__c,Total_TravelByDistance_Cost__c,Final_TravelByDistance_Cost__c,Total_TravelByHours_Cost__c,Final_TravelByHours_Cost__c,Total_Meals_Cost__c,Final_Meals_Cost__c,Total_Parking_Cost__c,Final_Parking_Cost__c,Percent_Labor_Cost__c,Approved_Labor_Cost__c,Percent_TravelByDistance_Cost__c,Approved_TravelByDistance_Cost__c,Percent_TravelByHours_Cost__c,Approved_TravelByHours_Cost__c,Percent_Parts_Cost__c,Approved_Parts_Cost__c,Percent_Meals_Cost__c,Approved_Meals_Cost__c,Percent_Parking_Cost__c,Approved_Parking_Cost__c,Percent_Claim_Cost__c,Approved_Ignore_Sum__c,Final_Parts_Cost__c,Final_Claim_Cost__c,Approved_Claim_Cost__c,Description__c,TravelByLocation__c,Fault_Code_Comment__c,CasualPart_Comments__c,work_Performed_comments__c,(Select Id,Name,Shipment_Due_Days__c,Return_Location__r.Name from Removed_Claim_Parts__r) from Claim__c Where Id= ',

})