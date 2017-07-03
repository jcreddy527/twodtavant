({   
    getFieldSet : function(component) {
        component.set("v.showSpinner",true);        
        var action=component.get("c.getFields");  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.actionCostFields",response.getReturnValue());                
                component.set("v.showTable", true);
                component.set("v.showSpinner",false);              
                
            } else{
                console.log('FAIL');
            }
            
        });$A.enqueueAction(action);
		        
    },    
    getClaimDetails : function(component) {
        
        // COMMENTS must not be blank
        component.set("v.showSpinner",true);
        var action = component.get("c.getClaimDetails");
        action.setParams({"claimID":component.get("v.ClaimSobj")});
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log(response.getReturnValue());                               
                 var listOfValues = [];
                // storing claim Detail in variable 
                listOfValues=response.getReturnValue();                
                console.log(JSON.stringify(listOfValues));
                
                // set the claim status Claim Number and Comments on Component 
                component.set("v.claimNumber",listOfValues.Claim_Auto_Number__c);
                component.set("v.claimStatus",listOfValues.Claim_Status__c);                
				component.set("v.previousComments",listOfValues.Internal_Comments__c);                                
                component.set("v.ignoreSUM", listOfValues.Approved_Ignore_Sum__c);
                //checking the claim status
                if(listOfValues.Claim_Status__c =='Pending SMR Review' || listOfValues.Claim_Status__c =='SMR Approved' || listOfValues.Claim_Status__c=='SMR Rejected'){               	 
                     component.set("v.radioSpan",false);    
                }
                
                // for each type of cost values Ex.Total,Final,Percent,Approved
                console.log(component.get("v.actionCostFields"));
                var actionListSize =[];
                actionListSize = component.get("v.actionCostFields");
                console.log(actionListSize.length);
                if(actionListSize.length == 0){
                    component.set("v.isDoneRendering", false);       
                }
                // loop is loging with each cost values
                // $Label.c.ClaimActionRowHeader8
                // $Label.c.ClaimActionRowHeader7
                // $Label.c.ClaimActionRowHeader6
                // $Label.c.ClaimActionRowHeader5               
                // $Label.c.ClaimActionRowHeader4
                // $Label.c.ClaimActionRowHeader3
                // $Label.c.ClaimActionRowHeader2
                // $Label.c.ClaimActionRowHeader1
                if(actionListSize.length != 0){
                var intValue = 1;
                var isRequired = false;
        		component.get("v.actionCostFields").forEach(                    
        			function myFunction2(item2, index2){                       
                        var labelString = "ClaimActionRowHeader";
                        labelString = labelString+intValue;                        
            			var fieldName=item2;            			                       
                        var labelReference = $A.getReference("$Label.c."+labelString);                                             
                        component.set("v.tempLabelAttr", labelReference);
                        var dynamicLabel = component.get("v.tempLabelAttr");
                        if(dynamicLabel=='[c.ClaimActionRowHeader1]'){
                        	isRequired = true;   
                        }                        
                        document.getElementById(item2).innerHTML= dynamicLabel;
                        intValue = intValue+1;                        
             		})
                    //if(isRequired == true){
                    	//component.set("v.isDoneRendering", false);   
                   // }
                var namespace = '';
            	component.get("v.prefix").forEach(
                function myFunction(item, index) {
                    var totalAmount = 0.00;                    
                    // loop is loging with each cost values
                    component.get("v.actionCostFields").forEach( 
                        function myFunction2(item2, index2){                            
                            var fieldName=namespace+item+item2+ component.get("v.Cost"); 
                            var val1 = 0.00;
                            if(listOfValues[fieldName] != null){
                                if(fieldName.indexOf("Final")!= -1 || fieldName.indexOf("Total")!= -1){
                                    if(listOfValues[fieldName]==0){
                                       document.getElementById(item+item2).innerHTML='0.00'; 
                                    }else{
                                       val1 = listOfValues[fieldName];
                                       val1 = val1.toFixed(2);                                       
                                       document.getElementById(item+item2).innerHTML=val1;
                                       //document.getElementById(item+item2).innerHTML=listOfValues[fieldName]; 
                                    }                                                                       
                                    
                                } 
                                else{
                                    val1 = listOfValues[fieldName];
                                    val1 = val1.toFixed(2);                                    
                                    document.getElementById(item+item2).value=val1;
                                    //document.getElementById(item+item2).value=listOfValues[fieldName];   
                                }
                                totalAmount = totalAmount+listOfValues[fieldName];
                            } 
                            
                        })
                    
                       //Add the total values
                        if(item == 'Total_'){
                           totalAmount = totalAmount.toFixed(2);
                           document.getElementById('RequestTotal').innerHTML=""+totalAmount+"";
                        }
                        if(item == 'Final_'){
                           totalAmount = totalAmount.toFixed(2);
                           document.getElementById('ModifiedTotal').innerHTML=""+totalAmount+"";  
                        }
                        if(item == 'Approved_'){
                           totalAmount = totalAmount.toFixed(2);
                           document.getElementById('ApprovedTotal').innerHTML=""+totalAmount+""; 
                        }
                        
                })
                component.set("v.showSpinner",false);
                }
            }
        });
    
        $A.enqueueAction(action);
        
    },
    getApprovalActionList : function(component) {
        component.set("v.showSpinner",true);        
        var action2=component.get("c.getApprovalAction"); 
		action2.setParams({"currentStatus":component.get("v.currClaimStatus")});        
        action2.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){                
                component.set("v.approvalActions",response.getReturnValue());                
            } else{
                console.log('FAIL');
            }
            
        });$A.enqueueAction(action2); 
        
    },
    getResponsibleCodeOption : function(component) {                 
        component.set("v.showSpinner",true);
        var action=component.get("c.getResponsibleCodeOption");  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){                
                component.set("v.responsibleCode",response.getReturnValue());                
            } else{
                console.log('FAIL');
            }
            
        });$A.enqueueAction(action); 
    },    
    
    getCurrentApprover : function(component){
       component.set("v.showSpinner",true);
       var action=component.get("c.getCurrentApproverId");
       action.setParams({"targetObjectId":component.get("v.ClaimSobj")});
       action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log('test'+response.getReturnValue());
                if(response.getReturnValue() == true){
                   component.set('v.renderSpan',true);                   
                }
                else{
                    component.set('v.renderSpan',false);
                	component.set("v.showError",true);                   
                }
                
            } else{                
                console.log('FAIL');
            }
            
        });$A.enqueueAction(action);
    }
    
})