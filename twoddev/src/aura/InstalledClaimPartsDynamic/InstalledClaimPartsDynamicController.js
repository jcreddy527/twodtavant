({
	ToggleCollapse : function(component, event, helper) {
        var curElement = event.srcElement;
        var parElement = event.srcElement.parentElement.parentElement;
        for (var i = 0; i < parElement.childNodes.length; i++) {
            if (parElement.childNodes[i].className && parElement.childNodes[i].className.indexOf("container") > -1) {
                if(curElement.innerText == '[ + ]')
                {
                    parElement.childNodes[i].classList.remove("hide");
                    parElement.childNodes[i].classList.add("show");
                    curElement.innerText = '[ - ]';
                }else if(curElement.innerText == '[ - ]')
                {
                    parElement.childNodes[i].classList.remove("show");
                    parElement.childNodes[i].classList.add("hide");
                    curElement.innerText = '[ + ]';
                }
              break;
            }
        }
    },
    
    newLaborRecord:function(component, event, helper){
        var claimLaborRecord = component.get("v.claimLaborDetail_SObj");
        var claimRecord = 'a0p36000000MfVV'; //component.get("v.claim_SObj");
        claimLaborRecord.Claim__c = claimRecord;
        $A.createComponent(
            "c:InstalledClaimPartsDetail",
            {
                "claimLaborDetail_SObj": claimLaborRecord
            },
            function(newClaimLabor){
                //Add the new button to the body array
                if (component.isValid()) {
                    tmp = component.find('laborTable');
                    //alert('I am here.' + tmp);
                    var body = tmp.get("v.body");
                    //alert('Body is : ' + tmp);
                    body.unshift(newClaimLabor);
                    tmp.set("v.body", body);
                }
            }
        );
    },
    
    doInit : function(component, event, helper) {
        var claimLaborRecord = component.get("v.claimLaborDetail_SObj");
        var claimId	=	'a061500000X9djt';
        var action 	= component.get('c.findSObjectsBySOQL');
        var query	=	'SELECT Id, Name, Claim__c, Inventory__r.Name, Inventory__c, Warranty_Product__r.Name, Warranty_Product__c, Quantity__c, Price__c FROM Claim_Part__c WHERE Claim__c = '+'\''+claimId +'\'';
        action.setParams({ 
            "query" : query
        });
        action.setCallback(this, function(response) {
            var res	=	response.getReturnValue();
            
            console.log('::::: first record value:');
            console.log(res[0]);
            for(var i=0; i < res.length; i++) {
                claimLaborRecord = res[i];
                claimLaborRecord.Claim__c = claimId;
                $A.createComponent(
                    "c:InstalledClaimPartsDetail",
                    {
                        "claimLaborDetail_SObj": claimLaborRecord,
                        "isEdit" : false
                    },
                    function(newClaimLabor){
                        //Add the new button to the body array
                        if (component.isValid()) {
                            tmp = component.find('laborTable');
                            //alert('I am here.' + tmp);
                            var body = tmp.get("v.body");
                            //alert('Body is : ' + tmp);
                            body.unshift(newClaimLabor);
                            tmp.set("v.body", body);
                        }
                    }
                );
            }
        });
        $A.enqueueAction(action);
        
        
    }
})