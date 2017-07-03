({
	doInit : function(component, event, helper) {
        component.set("v.ShowComponentforApprove",'Approve')
        var RecoveryClaimQuery = helper.Recovery_Claim_Record   + "'" + component.get("v.RecoveryClaimId") + "'";
        
        //Reading the Recovery Claim 
        helper.readDom(component, event, RecoveryClaimQuery, "v.RecoveryClaim", "v.dmlErrors", function(returnedValues) {
       
 			component.set("v.RecoveryClaimURL",helper.renderURL(component.get("v.baseURL"),component.get("v.RecoveryClaimId")));
            //If the Recovery Claim Status is Already 'Approved' redirect the page back to the Recovery Claim Detail page
            if(component.get("v.RecoveryClaim").Status__c == 'Approved' || component.get("v.RecoveryClaim").Status__c == 'Draft'){
                window.alert(' The Approve Button cannot be clicked on the  ' + '"' + component.get("v.RecoveryClaim").Status__c  + '"'  + '  Status');
                helper.RedirectToTheDetailPage(component,component.get("v.RecoveryClaimId"));
            }
           
        });	
    
    },
    
    ApprovedAmountChange : function(component, event, helper) {
      
        component.set("v.ShowComponentforDispute",'');
        component.set("v.ShowComponentforApprove",'');
        component.set("v.PageError",'');
    //  var amountentered = component.find('inputAmount').get('v.value');
        var amountentered = component.find("inputAmount").get("v.value"); // value of the object on which the event occured 
        component.set("v.UpdatedApprovedAmount",amountentered);
        
        //If Total Approved Amount Cost field is null on recovery claim
        if(component.get("v.RecoveryClaim").Total_Approved_Amount__c == undefined){
           component.set("v.RecoveryClaim.Total_Approved_Amount__c",0); 
        }
        
        //If Final Claim Cost field is null on recovery claim
        if(component.get("v.RecoveryClaim").Final_Claim_Cost__c == undefined){
           component.set("v.RecoveryClaim.Final_Claim_Cost__c",0); 
        }
        
        if(component.get("v.RecoveryClaim").Supplier_Contract__r.Minimum_recoverable_percent__c == undefined){
            component.set("v.RecoveryClaim.Supplier_Contract__r.Minimum_recoverable_percent__c",0);
        }
        
        var MinimumRecovarableAmount = (parseInt(component.get("v.RecoveryClaim").Supplier_Contract__r.Minimum_recoverable_percent__c) * parseInt(component.get("v.RecoveryClaim.Final_Claim_Cost__c"))) / 100 ;

        var ErrorMessageString = ' - ' + $A.get("$Label.c.ErrorMessageOnEditRecoveryClaimPage") + '  $' + Math.round(MinimumRecovarableAmount);      

        
        if(amountentered > MinimumRecovarableAmount){
            
            component.set("v.ShowComponentforApprove",'Approve');
            component.set("v.ShowComponentforDispute",'');
        
        }else{
            
            component.set("v.ShowComponentforApprove",'')
            component.set("v.ShowComponentforDispute",'Dispute');
            component.set("v.PageError",ErrorMessageString);
            
        }
    },
    
    
    ApproveRecord : function(component, event, helper){
        component.set("v.RecoveryClaim.Status__c","Approved");
        //If The Total Approved Amount is not changed, Approve the Record with the initial Approved Claim Cost
        if(component.get("v.UpdatedApprovedAmount") != undefined){
        component.set("v.RecoveryClaim.Total_Approved_Amount__c",component.get("v.UpdatedApprovedAmount"));
        }

        //Calling the helper method to force update the recovery claim record when the record is Locked
        helper.updateDomForce(component, event,"v.RecoveryClaim","v.dmlErrors",function(returnedValues){
            //Redirect the Page to the detailed Recovery CLaim Page after approval
            helper.RedirectToTheDetailPage(component,component.get("v.RecoveryClaimId"));
        });
    },
    
    DisputeRecord : function(component, event, helper){
        component.set("v.RecoveryClaim.Status__c","Dispute");
        //Calling the helper method to force update the recovery claim record when the record is Locked
        helper.updateDomForce(component, event,"v.RecoveryClaim","v.dmlErrors",function(returnedValues){
            //Redirect the Page to the detailed Recovery CLaim Page after approval
            helper.RedirectToTheDetailPage(component,component.get("v.RecoveryClaimId"));
        });
    }
})