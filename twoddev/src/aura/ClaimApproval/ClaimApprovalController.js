({
	doInit : function(component, event, helper) {
        $A.util.addClass(document.getElementById('litem-tab-2'), 'slds-active');
        $A.util.addClass(document.getElementById('divitem-tab-2'), 'slds-show');
        $A.util.removeClass(document.getElementById('divitem-tab-2'), 'slds-hide');
        $A.util.addClass(document.getElementById('divitem-tab-1'), 'slds-hide');
        $A.util.removeClass(document.getElementById('divitem-tab-1'), 'slds-show');
        $A.util.removeClass(document.getElementById('litem-tab-1'), 'slds-active');
        
        //component.set('v.cancelUrl',document.referrer);
        
        var BaseUrl = component.get('v.BaseURL');
        var claimId = component.get('v.claimId');
        if(claimId != null  && claimId != '')
        {
                if(BaseUrl.indexOf('lightning') !=-1) 
                   component.set('v.cancelUrl',BaseUrl+'/one/one.app#/sObject/'+claimId+'/view');
                else
                    component.set('v.cancelUrl',BaseUrl+'/'+claimId);
        }
        else{
            console.log('getclaimprefix error here else');
             var action = component.get("c.getclaimPrefix");
            action.setParams({
                
            });
            action.setCallback(this, function(a) {
                console.log('---------------------------------return prefix'+a.getReturnValue());
                var claimPrefix = a.getReturnValue();
                if(BaseUrl.indexOf('lightning') !=-1)                           
                        component.set('v.cancelUrl',BaseUrl+'/one/one.app#/sObject/'+claimPrefix+'/home');      
                    else
                       component.set('v.cancelUrl',BaseUrl+'/'+claimPrefix+'/o'); 
            });
            $A.enqueueAction(action);
        }
        
        //component.set('v.context',$A.getContext().gg);
		console.log(':::: inside of the calim summary do init method');
        console.log(component.get('v.claimRecord'));    
        
		/*if(component.get('v.claimId') != null && typeof component.get('v.claimId') !='undefined' && component.get('v.claimId') != '' ){
			var query = helper.CLAIM_QUERY + '\'' + component.get('v.claimId') + '\'';
			helper.readDom(component, event, query, 'v.claimRecord', 'v.dmlErrors', function(response){
				console.log('read dom response -------------------------------');
			console.log(response);
                console.log('----111111111111--'+component.get('v.claimRecord.Claim_Status__c')+'------------');
                if(component.get('v.claimRecord.Claim_Status__c') == 'Approved')
                {console.log('---------------------inside approved');
                     component.set('v.showApprove',false);
                     component.set('v.showReject',true);
                }
                else if(component.get('v.claimRecord.Claim_Status__c') == 'Rejected')
                {
                    component.set('v.showApprove',true);
                    component.set('v.showReject',false);
                }
		 });
		}*/
        console.log('claim status-------'+component.get('v.claimRecord.Claim_Status__c'));
        helper.claimStatusApproveReject(component,helper,event);
	},
	populateRelativeField : function(component, event, helper) {
        console.log('----------------------populateRelativeField-----------------');
        console.log(event);
         console.log(event.getSource().get('v.class'));
        var slittedclass = event.getSource().get('v.class').split(' ');
		console.log(component.find(slittedclass[1]).get('v.value'))
		var updatedValue = component.find(slittedclass[1]).get('v.value');
		helper.updateRelatedField(component,helper,slittedclass[1],updatedValue);
		//console.log('=========FieldToUpdate'+FieldToUpdate);
		//component.find(FieldToUpdate).set('v.value',valueToUpdate);
	},
	setCurrentTab: function(component, event, helper) {
		helper.setCurrentTabHelper(component, event, helper);
	},
	goNext: function(component, event, helper) {
		console.log('claim record -------------------------------');
		console.log(component.get('v.claimRecord'));
        helper.recordUnLockHelper(component,helper,event,component.get("v.claimRecord.Id"),component.get("v.claimRecord"));
		helper.updateDom(component, event, 'v.claimRecord', 'v.dmlErrors', function(response){
            	if(helper.unlockstatus == 'recordUnlocked')
                {
            		helper.recordLockHelper(component,helper,event,component.get("v.claimRecord"));
                }
				console.log('update response -------------------------------');
			console.log(response);
            component.set('v.refreshSummary',true);
	  });
		event.preventDefault();
			component.set('v.isNextClicked',true);
			helper.setCurrentTabHelper(component, event, helper);
	},
	goPrevious: function(component, event, helper) {
		event.preventDefault();
        component.set('v.refreshSummary',false);
			component.set('v.isPrevClicked',true);
			helper.setCurrentTabHelper(component, event, helper);
	},
	submitClaim	: function(component, event, helper){
			helper.submitClaimRecord(component, event);
	},
    ApproveClaim : function(component, event, helper){
			helper.ApproveClaim(component, event, helper);
	},
    RejectClaim: function(component, event, helper){
			helper.RejectClaim(component, event, helper);
	},
    ShowApproveReject : function(component, event, helper){
        helper.claimStatusApproveReject(component,helper,event);
    }
})