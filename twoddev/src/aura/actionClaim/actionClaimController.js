({  
    doInit : function(component, event, helper) {
        helper.getCurrentApprover(component);                
        helper.getFieldSet(component);               
        helper.getApprovalActionList(component);
        helper.getResponsibleCodeOption(component);
     

    } ,   
    doneRendering: function(component, event, helper) {        
        if(!component.get("v.isDoneRendering")){             
            component.set("v.isDoneRendering", true);
            helper.getClaimDetails(component);   
         } 
    },
    flatRadioButton : function(component, event) 
    {
        component.set('v.isPercent',true);
        component.set('v.isFlat',false);
       
    },
    percentRadioButton : function(component, event)
    {
        component.set('v.isPercent',false);
        component.set('v.isFlat',true);
    },
    
    changeApprovedValues : function(component, event){              
        component.set('v.errorSpan',false);
        component.set('v.buttonSpan',true);
        var percentCost = event.target.value;
    
        if(isNaN(percentCost)){                  
            component.set('v.errorSpan',true);
            component.set('v.buttonSpan',false);
        }
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index;
        var selectedCost = component.get("v.actionCostFields")[index]; 
        var str = 'Approved_'+selectedCost;
        var approvedCost = document.getElementById(str).value;
        var str1 = 'Final_'+selectedCost;         
        var FinalCost = document.getElementById(str1).innerHTML;       
        var modifiedvalue = (FinalCost * percentCost)/100;
        var modifiedvalue1 = modifiedvalue.toFixed(2);         
        document.getElementById(str).value = modifiedvalue1; 
        
        if(isNaN(modifiedvalue)){
            var modifiedvalue1 = 0.00 ;         
            document.getElementById(str).value = modifiedvalue1;
        }
        else{
         var modifiedvalue1 = modifiedvalue.toFixed(2);         
         document.getElementById(str).value = modifiedvalue1;  
        }
        var item = 'Approved_';
        var totalAmount = 0.00;                    
        // loop is loging with each cost values
        component.get("v.actionCostFields").forEach( 
        	function myFunction2(item2, index2){                            
            	var fieldName=item+item2;                
                totalAmount = totalAmount+ +(document.getElementById(fieldName).value);        
             })
        if(percentCost!=null){
                totalAmount = totalAmount.toFixed(2);
                document.getElementById('ApprovedTotal').innerHTML=""+totalAmount+"";      
        } 
    },
    
    changePercentValues : function(component, event){              
        component.set('v.errorSpan',false);
        component.set('v.buttonSpan',true);
        var ApprovedCost = event.target.value;
     
        if(isNaN(ApprovedCost)){                  
            component.set('v.errorSpan',true);
            component.set('v.buttonSpan',false);
        }          
        var selectedItem = event.currentTarget;        
        var index = selectedItem.dataset.index;         
        var selectedCost = component.get("v.actionCostFields")[index];         
        var str = 'Percent_'+selectedCost;       
        var percentCost = document.getElementById(str).value;        
        var str1 = 'Final_'+selectedCost;         
        var FinalCost = document.getElementById(str1).innerHTML;                  
        var modifiedvalue = 0;
        if(FinalCost == 0){
             modifiedvalue = 0.00; 
        }
        else{
             modifiedvalue = (ApprovedCost * 100)/FinalCost; 
        }  
   
        
        if(isNaN(modifiedvalue)){
           var modifiedvalue1 = 0.00;
           document.getElementById(str).value = modifiedvalue1;  
        }
        else{
        	var modifiedvalue1 = modifiedvalue.toFixed(2);
            document.getElementById(str).value = modifiedvalue1;     
        }
         var item = 'Approved_';
        var totalAmount = 0.00;                    

        component.get("v.actionCostFields").forEach( 
        	function myFunction2(item2, index2){                            
            	var fieldName=item+item2;                                                            	                                  
                totalAmount = totalAmount+ +(document.getElementById(fieldName).value);        
             })                    
            if(ApprovedCost!=null){
                totalAmount = totalAmount.toFixed(2);
                document.getElementById('ApprovedTotal').innerHTML=""+totalAmount+"";      
            }   
    },
    onActionChange : function(component, event, helper) {
    	var selected = component.find("Actions");
        var resultCmp = component.find("actionsValue");
        resultCmp.set("v.value", selected.get("v.value"));        
        if(selected.get("v.value") == 'Approved'){
        	component.set("v.showResponsibleCode",true);   
        }
        else{
        	component.set("v.showResponsibleCode",false);    
        }
        if(selected.get("v.value") == 'Approved' || selected.get("v.value") == 'On hold'){
            component.set("v.AllowPaymentDef",true); 
        }
        else{
            component.set("v.AllowPaymentDef",false); 
        }
        if(selected.get("v.value") == 'Open'){
           component.set("v.openComments",true);
           component.set("v.showTable",false);
        }
    },
    onResCodeChange : function(component, event, helper) {
    	var selected = component.find("resCode");
        var resultCmp = component.find("resCodevalue");
        resultCmp.set("v.value", selected.get("v.value"));
    },
    SaveAndReturn: function(component, event, helper) {
        var validExpense = true;
        component.set("v.showSpinner",true);
        
        //approval actions can't be blank
        var actionField = component.find("Actions");
        var actionName =  actionField.get("v.value");
        if ($A.util.isEmpty(actionName)){
            validExpense = false;
            component.set("v.showSpinner",false);
            actionField.set("v.errors", [{message: $A.get("$Label.c.Please_Select_Approval_Action") }]);
        }
        else {
            actionField.set("v.errors", null);
        }
    
        
        // Comments must not be blank
        if(actionName!='Open'){
            var CommenField = component.find("comments");                
            var Commenname = CommenField.get("v.value");            
            if ($A.util.isEmpty(Commenname)){
                validExpense = false;
                component.set("v.showSpinner",false);
                CommenField.set("v.errors", [{message: $A.get("$Label.c.Comments_Blank_Error") }]);
            }
            else {
                CommenField.set("v.errors", null);
            }
    	}
        
        if(actionName=='Open'){
            // open Comments must not be blank
            var openCommenField = component.find("opencomments");            
            var openCommenname = openCommenField.get("v.value");            
            if ($A.util.isEmpty(openCommenname)){
                validExpense = false;
                component.set("v.showSpinner",false);
                openCommenField.set("v.errors", [{message: $A.get("$Label.c.Comments_Blank_Error") }]);
            }
            else {
                openCommenField.set("v.errors", null);
            }
        }
              
        // If we pass error checking, do some real work
        if(validExpense){
            var namespace = '';
        	// creating claim record in json format storing in string
            var josnSTR = "{ \"sobjectType\": \"Claim__c\",\"Id\":"+"\""+component.get("v.ClaimSobj")+"\""+","                       
            if(actionName!='Open'){
                component.get("v.prefix").forEach(
                    function myFunction(item, index) {                        
                        // loop is loging with each cost values and getting each cost field value from page 
                        component.get("v.actionCostFields").forEach( 
                            function myFunction2(item2, index2){
                                var fieldName=namespace+item+item2+ component.get("v.Cost");                                
                                //check whether fields are in current and Percent Amount column
                                if(fieldName.indexOf("Percent") != -1||fieldName.indexOf("Approved") != -1){
                                                      
                                    josnSTR=josnSTR+"\""+fieldName+"\":"+"\""+document.getElementById(item+item2).value+"\""+","
                                }   
                            })                        
                    })                
                    if(component.get("v.Comments")!="" && component.get("v.Comments")!=undefined){                   
                        if(component.get("v.previousComments")!="" && component.get("v.previousComments")!=undefined){                        
                            var comments = component.get("v.previousComments")+" , "+component.get("v.Comments");                	
                            josnSTR=josnSTR+"\"Internal_Comments__c\":\""+comments+"\""+","    
                        }
                        else{                       
                            josnSTR=josnSTR+"\"Internal_Comments__c\":\""+component.get("v.Comments")+"\""+"," 
                        }
                           
                    }
                    else{                     
                        josnSTR=josnSTR+"\"Internal_Comments__c\":\""+component.get("v.previousComments")+"\""+"," 
                    }
                    if(actionName =='Approved' || actionName =='On hold'){
                        josnSTR=josnSTR+"\"Approved_Ignore_Sum__c\":\""+component.get("v.ignoreSUM")+"\""+","
                    }                
                    if(actionName =='Approved'){
                        if(component.find("resCodevalue").get("v.value")!="" && component.find("resCodevalue").get("v.value")!=undefined){
                            josnSTR=josnSTR+"\"Responsible_Code__c\":\""+component.find("resCodevalue").get("v.value")+"\""  
                        }else{
                            josnSTR=josnSTR+"\"Responsible_Code__c\":\""+component.get("v.responsibleCode[0]")+"\""    
                        }    
                    }                               
            	}
                if(actionName == 'Open'){
                	if(component.get("v.previousComments")!="" && component.get("v.previousComments")!=undefined){
                    	josnSTR=josnSTR+"\"Internal_Comments__c\":\""+component.get("v.previousComments")+"\""+","
                	}    
                }
                
            josnSTR=josnSTR+"}"
    
            
            
            var actionValue = "";
            if(component.find("actionsValue").get("v.value")!="" && component.find("actionsValue").get("v.value")!=undefined){
               actionValue = component.find("actionsValue").get("v.value"); 
            }else{
                actionValue = component.get("v.approvalActions[0]"); 
            }
            
            if(actionName!='Open'){ 
                var approvedClaimCost = 0.00;           
                if(document.getElementById('ApprovedTotal').innerHTML!=null){ 
                    approvedClaimCost = document.getElementById('ApprovedTotal').innerHTML;    
                }   
            }
            
            //storing string into clm attribute
            component.set("v.clm",josnSTR);   
            
            //created action
            var action = component.get("c.updateClaim");
            
            //setting parameter for server side controller method
            action.setParams({"clm":component.get("v.clm"),"actionRequire":actionValue,"currentComments":component.get("v.Comments"),"approvedClaimCost":approvedClaimCost});  
            
            //callback behavior for when response is received
            action.setCallback(this,function(response){               
                var state = response.getState();
                //check response is sucess or not      
                if(state == 'SUCCESS'){
              
                    component.set("v.showSpinner",false);
                    var listOfValues = [];
                    // storing claim Detail in variable 
                    listOfValues=response.getReturnValue();
                    var ProceedURL = ''; 
        			
       				var BaseUrl =component.get('v.BaseURL');                                                 
                    if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined') {
                    	if(BaseUrl.indexOf('lightning') !=-1){
                        	ProceedURL = "/actionClaim/actionClaimApp.app#/sObject/"+listOfValues.Id+'/view';
                        }else{
                        	ProceedURL = BaseUrl+"/"+listOfValues.Id;
                        }                                
                        window.location.href=ProceedURL;
                     }                            
                }else{
                    //check response
                    console.log('FAIL');
                }
                
            });   $A.enqueueAction(action);  
        } 
    },
    Cancel: function(component, event, helper) { 
        var ProceedURL = ''; 
        
        var BaseUrl =component.get('v.BaseURL');        
        var claimId	 =component.get("v.ClaimSobj");
        if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined')
        {
            if(BaseUrl.indexOf('lightning') !=-1) 
                ProceedURL = "/actionClaim/actionClaimApp.app#/sObject/"+listOfValues.Id+'/view';
            else
            ProceedURL = BaseUrl+"/"+claimId;
            
            window.location.href=ProceedURL;
        }        
    },
})