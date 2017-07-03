({
    
    FaultCode_Query: 'Select Id,Name,Description__c,Selectable__c,Standard_Labor_Hour__c,Parent_Warranty_Code__c,Warranty_Product__c from Warranty_Code__c where Selectable__c = true and Warranty_Product__c IN(',
    FaultCodeMapper_Query: 'Select Id,Name,Fault_Code__r.Name,Warranty_Product__r.Name,Status__c from FaultCode_Mapper__c where Warranty_Product__c IN(',
    JobCode_Query: 'Select Id,Name,Description__c,Selectable__c,Standard_Labor_Hour__c,Parent_Warranty_Code__c,Warranty_Product__c from Warranty_Code__c where Parent_Warranty_Code__c =',
    unlockstatus:'',
    validationmethod:function(component,helper){
        console.log('--before validation---');
        var action1 = component.get('c.findPolicyName');
        action1.setParams({
            'CurrentClaim' : component.get('v.claimRecord')
        });
        action1.setCallback(this, function(response) {
            console.log('---after validation---')
            console.log(response.getReturnValue());
        });
        
        $A.enqueueAction(action1);
        
    },
    visible : function(component,Element) {
        console.log('--------inside visible------');
        var pageElement = component.find(Element);
        console.log('--------pageElement------'+pageElement);
        $A.util.removeClass(pageElement, 'slds-hide');
        $A.util.addClass(pageElement, 'slds-show');
    },
    invisible: function(component,Element){
        var pageElement = component.find(Element);
        console.log(pageElement);
        $A.util.removeClass(pageElement, 'slds-show');
        $A.util.addClass(pageElement, 'slds-hide');
    },
    formatdate : function(dateModify) {
        if(dateModify == '')
            var dateModify = new Date();
        else
            var dateModify = new Date(dateModify);
        console.log('-----f----------',dateModify);
        var dd = dateModify.getDate();
        var mm = dateModify.getMonth()+1; //January is 0!
        var yyyy = dateModify.getFullYear();
        if(dd<10){
            dd='0'+dd;
        }
        if(mm<10){
            mm='0'+mm;
        }
        var dateModify = yyyy+'-'+mm+'-'+dd;
        console.log('------l---------',dateModify);
        return dateModify;
    },
    errorHandling : function(a,action,component) {
        var errors = a.getError();
        console.log(errors);
        console.log(errors[0]);
        if (errors) {
            console.log('----------------inside  error');
            component.set("v.isError", true);
            component.set("v.isSuccess", false);
            if (errors[0] && errors[0].message) {
                // System Error
                console.log('----------------inside system error');
                console.log( errors[0].message);
                component.set("v.message", errors[0].message);
            } else if (errors[0] && typeof errors[0].pageErrors != "undefined") {
                // DML Error
                console.log('----------------inside dml page error');
                console.log( errors[0].pageErrors[0]);
                component.set("v.message", errors[0].pageErrors[0].message);
            }
        }
    },
    
    saveClaimTemplateValidation : function(component, event){
        //event.preventDefault();
        console.log('::::::: Claim name:');
        console.log(JSON.parse(JSON.stringify(component.get('v.claimRecord'))));
        console.log(component.get('v.rateName'));
        console.log(component.get('v.warrantyProductName'));
        console.log(component.get('v.dealerName'));
        console.log(component.get('v.policyName'));
        console.log(component.get('v.casualPartNumber'));
        var isError	=	false;
        
        if(component.get('v.isDealer')){
            component.set('v.claimRecord.Account__c',component.get('v.dealerAccount'));
        }
        
        if(component.get('v.claimRecord.Fault_Code__c') == undefined || component.get('v.claimRecord.Fault_Code__c') == ''){
            isError = true;
            component.set("v.faultCodeError", $A.get("$Label.c.Fault_Code_Empty_Error"));  
            component.set('v.isSaved',false);
            
        }else{
            component.set("v.faultCodeError", "");
            component.set('v.isSaved',true);
            
        }
        
        
        
        if(component.get('v.claimRecord.Causal_Part_Number__c') == undefined || component.get('v.claimRecord.Causal_Part_Number__c') == '' || component.get('v.claimRecord.Causal_Part_Number__c') == null){
            component.set("v.casualPartError",$A.get("$Label.c.Casual_Part_Empty_Error"));  
            isError = true;
            component.set('v.isSaved',false);
            
        }else{
            component.set("v.casualPartError", "");
            component.set('v.isSaved',true);
            
        }
        
        // var isChanged = component.get('v.isChanged');        
        //  console.log('isChanged' + isChanged);
        //  if(isChanged)
        //  {
        //      component.set('v.isSaved',false);
        //  } 
        
        
        
        
        var isSaveEnabled = component.get('v.isSaveEnabled');        
        console.log('isSaveEnabled' + isSaveEnabled);
        if(isSaveEnabled)
        {
            isError = true;
            component.set("v.isError", true);
            //component.set('v.hasTabErrors',true);
            component.set('v.message',$A.get("$Label.c.Save_Before_Proceding_Error")); 
            
        } else {
            component.set('v.message','');      
            component.set("v.isError", false)         
        }
        
        
        
        console.log('---------------saveClaimTemplateValidation end--------------');
        return isError;
    },
    
    goToclaimFaultCodeHandler : function(component, event){
        console.log(component.get("v.claimRecord"));
        component.set("v.isError", false);
        console.log('::: isError:'+component.get('v.isError'));
        component.set("v.isSuccess", false);
        console.log('::: isSuccess:'+component.get('v.isSuccess'));
        component.set('v.isNextClicked',true);
        console.log('::: Clicked:'+component.get('v.isNextClicked'));
        component.set('v.currentTab','1');
        console.log('::: currentTab:'+component.get('v.currentTab'));
        component.set('v.NextTab','2');
        console.log('::: NextTab:'+component.get('v.NextTab'));
        
        //component.settab(component, event, helper);
    },
    
    dateDiff : function(date1,date2){
        var date1 = new Date(date1);
        var date2 = new Date(date2);
        var diffDays = parseInt((date2 - date1) / (1000 * 60 * 60 * 24));
        console.log('-----diffDays------',diffDays);
        return diffDays;
    },
    
    // For finding the policy
    findPolicyHandler : function(component, event, helper){
        component.set('v.hasTabErrors',false);
        var isError		=	false;
        var isSerialized	=	component.get('v.isSerialized');
        var isNonSerialized	=	component.get('v.isNonSerialized');
        var isClaimTemplate	=	component.get('v.isClaimTemplate');
        var isFieldModification	=	component.get('v.isFieldModification');
        var today = helper.formatdate('');
        console.log('----------today',today);
        
        if(!isClaimTemplate){
            if(component.get('v.claimId') == null || component.get('v.claimId') == '') {
                var claimType	=	component.find("claimtype").get("v.value");
                
                console.log('::: Claim Type:',claimType);
                component.set('v.isError',false);
                // Claim Type Error
                if(claimType == 'None' || claimType == '' || typeof claimType == "undefined"){
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set('v.claimTypeError',$A.get("$Label.c.Claim_Type_Empty_Error"));
                } else {
                    component.set('v.claimTypeError','');
                    
                }
                
            }
            console.log('::: InventoryRun :' + component.get('v.claimRecord.Units_Run__c') + component.get('v.InventoryUnitsRun'));
            
            if( component.get('v.isUnitRun') ==true && component.get('v.isNonSerialized')!=true )
            {
                if(component.get('v.claimRecord.Units_Run__c')==null || component.get('v.claimRecord.Units_Run__c') < 0)
                {
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set('v.UnitsRunError', $A.get("$Label.c.Unit_Run_Mandatory_Error"));                              
                }
                else if( component.get('v.claimRecord.Units_Run__c') < component.get('v.InventoryUnitsRun'))
                {
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set('v.UnitsRunError',' Already Inventory used for ' + component.get("v.InventoryUnitsRun") +' '+ component.get("v.claimRecord.Units_of_Measure__c") + $A.get("$Label.c.Check_Value_Error"));               
                }
                    else
                    {
                        component.set('v.UnitsRunError','');
                    }
                
            }
            else {
                component.set('v.UnitsRunError','');
            }
            
            
            
            var dealer		=	component.get('v.claimRecord.Account__c');
            console.log(':::: dealer value: '+dealer);
            if(dealer == null || dealer == '' || typeof dealer == "undefined"){
                console.log('::::: inside dealer error');
                isError = true;
                component.set('v.hasTabErrors',true);
                component.set('v.dealorError',$A.get("$Label.c.Dealer_Value_Empty_Error"));
            } else {
                component.set('v.dealorError','');
            }
            var dateofFailure	=	component.get('v.claimRecord.Date_of_Failure__c');
            console.log(':::: Date of failure:'+dateofFailure);
            if(dateofFailure == null || dateofFailure == '' || typeof dateofFailure == "undefined"){
                console.log('::: inside of date of failure');
                isError = true;
                component.set('v.hasTabErrors',true);
                component.set('v.dateofFailureError',$A.get("$Label.c.Failure_Date_Empty_Error"));
            }else{
                component.set('v.dateofFailureError','');
            }
            
            var dateofRepair	=	component.get('v.claimRecord.Date_of_Repair__c');
            console.log(':::: dateofRepair:'+dateofRepair);
            if(dateofRepair == null || dateofRepair == '' || typeof dateofRepair == "undefined"){
                console.log('::: inside of date of repair');
                isError = true;
                component.set('v.hasTabErrors',true);
                component.set('v.dateofRepairError',$A.get("$Label.c.Repair_Date_Empty_Error"));  
            }else{
                component.set('v.dateofRepairError','');
            }
            
            if(isNonSerialized){
                var warrantyId	=	component.get('v.claimRecord.Warranty_Product__c');
                console.log('::::: warrantyId:',warrantyId);
                if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined"){
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set("v.warrantyProductError",$A.get("$Label.c.Warranty_Product_Empty_Error"));
                } else {
                    component.set("v.warrantyProductError","");
                }
                if(component.get('v.claimRecord.Invoice_Number__c') == null || component.get('v.claimRecord.Invoice_Number__c') == '')
                {
                    console.log('-----------Invoice_Number__c error--------------');
                    component.set('v.hasTabErrors',true);
                    component.set("v.invoiceError",$A.get("$Label.c.Invoice_Number_Empty_Error"));	
                    isError = true;
                }
                else {
                    component.set("v.invoiceError","");
                }
                
                var dateofpurchase	=	component.get('v.claimRecord.Date_Of_Purchase__c');
                console.log(':::: dateofpurchase:'+dateofpurchase);
                if(dateofpurchase == null || dateofpurchase == '' || typeof dateofpurchase == "undefined"){
                    console.log('::: inside of dateofpurchase');
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set('v.dateofPurchaseError',$A.get("$Label.c.Purchase_Date_Empty_Error")); 
                }else if(helper.formatdate(component.get('v.claimRecord.Date_Of_Purchase__c')) > today )
                {
                    console.log('------purchase date greater than today-------');
                    component.set("v.isError", true);
                    component.set('v.hasTabErrors',true);
                    component.set("v.message", $A.get("$Label.c.Purchase_Date_Exceed_Today_Date_Error"));  
                    isError = true;
                }else{
                    component.set('v.dateofPurchaseError','');
                }
            }
            else{
                var inventoryId	=	component.get('v.claimRecord.Inventory__c');
                console.log('::::: Inventory Id',inventoryId);
                if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined"){
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set("v.inventoryError",$A.get("$Label.c.Inventory_Empty_Error"));  
                } else {
                    component.set("v.inventoryError","");
                }
            }
            if(isFieldModification){
                var CampaignMembersId	=	component.get('v.claimRecord.Campaign_Members__c');
                console.log('::::: CampaignMembersId Id',CampaignMembersId);
                if(CampaignMembersId == null || CampaignMembersId == '' || typeof CampaignMembersId == "undefined"){
                    isError = true;
                    component.set('v.hasTabErrors',true);
                    component.set("v.campaignMembersError", $A.get("$Label.c.Campaign_Member_Empty_Error"));   
                } else {
                    component.set("v.campaignMembersError","");
                }
            }
            
            console.log('smr reasonnnnnnnnnnnnnnnnnn');
            console.log(component.get('v.claimRecord.Request_SMR__c'));
            console.log('---------'+component.get('v.claimRecord.SMR_Reason__c')+'--------');
            if(component.get('v.claimRecord.Request_SMR__c') == true && (component.get('v.claimRecord.SMR_Reason__c') == null || component.get('v.claimRecord.SMR_Reason__c') == ' ' || component.get('v.claimRecord.SMR_Reason__c') == '' || typeof component.get('v.claimRecord.SMR_Reason__c') == "undefined"))
            {
                console.log('-----------Request SMR error--------------');
                component.set('v.hasTabErrors',true);
                component.set("v.SMRReasonError", $A.get("$Label.c.Pre_Authorization_Empty_Error"));  
                isError = true;
            }
            else {
                component.set("v.SMRReasonError","");
            }
            
            
            var diffDays = helper.dateDiff(component.get('v.claimRecord.Date_of_Failure__c'),component.get('v.claimRecord.Date_of_Repair__c'));
            console.log('-----diffDays------',diffDays);
            if(diffDays < 0){
                //var diffDays = parseInt((date2 - date1) / (1000 * 60 * 60 * 24));
                if(dateofRepair != null && dateofRepair != '' && typeof dateofRepair != "undefined" && dateofFailure != null && dateofFailure != '' && typeof dateofFailure != "undefined"){
                    
                    console.log('-----------Date of failure cant exceed date of repair.--------------',diffDays);
                    component.set("v.isError", true);
                    component.set('v.hasTabErrors',true);
                    component.set("v.message", $A.get("$Label.c.Date_Of_Failure_Exceed_Date_Of_Repair_Error"));   
                    isError = true;
                }
            } 
            else if(helper.formatdate(component.get('v.claimRecord.Date_of_Failure__c')) > today || helper.formatdate(component.get('v.claimRecord.Date_of_Repair__c')) > today)
            {
                if((dateofRepair != null && dateofRepair != '' && typeof dateofRepair != "undefined") ||( dateofFailure != null && dateofFailure != '' && typeof dateofFailure != "undefined")){
                    console.log('------failure date greater than today-------');
                    component.set("v.isError", true);
                    component.set('v.hasTabErrors',true);
                    component.set("v.message", $A.get("$Label.c.Failure_Repair_Date_Exceed_Error"));   
                    isError = true;
                }
            }
                else if(diffDays > $A.get("$Label.c.DifferenceDays")){
                    if(component.get('v.claimRecord.Delay_Reason__c') == null)
                    {
                        //var diffDays = parseInt((date2 - date1) / (1000 * 60 * 60 * 24));
                        if(dateofRepair != null && dateofRepair != '' && typeof dateofRepair != "undefined" && dateofFailure != null && dateofFailure != '' && typeof dateofFailure != "undefined"){
                            console.log('----------diffrence cannot be more than 30------------',diffDays);
                            component.set("v.isError", true);
                            component.set('v.hasTabErrors',true);
                            component.set("v.message", $A.get("$Label.c.Delay_For_Repair_Reason_Error"));  
                            isError = true;
                            component.set('v.isDelayReason',true);
                        }
                    }
                }
        }
        
        
        return isError;
    },
    CheckNumberOrNot: function(component, event, helper){
        
    },
    FetchFaultcodes : function(component, event, helper){
        //event.preventDefault();
        
        
        if(component.get('v.ClaimRecordType') != 'Claim_Template'){
            //populating the warranty product set to fetch the Associated Fault codes
            var productset = [];
            console.log('The valuess');
            console.log(component.get('v.InventoryWarrantyProductParentType'));
            console.log(component.get('v.InventoryWarrantyProductParentID'));
            if(component.get('v.InventoryWarrantyProductParentType') == 'Model' && component.get('v.InventoryWarrantyProductParentID') != null ){
                productset[0] = "'" + component.get('v.InventoryWarrantyProductParentID') + "'";
                productset[1] = "'" + component.get('v.claimRecord.Causal_Part_Number__c') + "'";
            }else{
                productset[0] = "'" + component.get('v.claimRecord.Causal_Part_Number__c') + "'";
            }
            
            component.set('v.WarrantyProductSetForFaultCode',productset);	
            console.log('::THe product set is');
            console.log(component.get('v.WarrantyProductSetForFaultCode'));	
            
            
            var warrantyProductSetForFaultCode = JSON.parse(JSON.stringify(component.get('v.WarrantyProductSetForFaultCode')));
            warrantyProductSetForFaultCode = warrantyProductSetForFaultCode.filter(function(a){
               return a!="'undefined'"; 
            });
            console.log("warrantyProductSetForFaultCode without undefined values");
            console.log(warrantyProductSetForFaultCode);
            //Retreving the Faultcodes based on the Product set - WarrantyProductSetForFaultCode(Warranty Product codes)
            var FaultCodeQuery = helper.FaultCodeMapper_Query  + warrantyProductSetForFaultCode + ")";
            console.log('::The In query is::');
            console.log(FaultCodeQuery);
            var faultcodelist = [];
            
            if(component.get('v.claimRecord.Causal_Part_Number__c') != undefined){
                helper.readRaw(component, event, FaultCodeQuery, function(returnedValues) {
                    
                    var returnedfaultCodeList=[];
                    
                   	returnedValues=JSON.parse(JSON.stringify(returnedValues));
                    if(typeof(returnedValues)=="string"){
                        component.set("v.dmlErrors",returnedValues);   
                    }else{
                        returnedfaultCodeList=returnedValues;
                   	}
                   	
                    console.log("returned values of falut code");
                    console.log(returnedfaultCodeList);
                    
                    //Below logic to get the faultcodes of 2 warranty Product(causalpart and parent warranty product of inventory)
                    //1. get the intersection of faultcodes of both the warranty product
                    //2. If the causalpart has no faultcode then pick all the faultcodes of the inventory parent warranty product
                    //3. If the inventory warranty product has no faultcodes then pick no faultcodes
                    console.log('::CiamType:::');
                    console.log(component.get("v.ClaimType"));
                    
                    if(component.get("v.ClaimType") != 'Part'){
                        var Faultcodematchcount = 0;
                        var Causalpartcount = 0;
                        console.log('::the length is');
                        console.log(returnedfaultCodeList.length);
                        
                        for(var i=0;i<returnedfaultCodeList.length;i++){
                            console.log('Warranty product name');
                            console.log(returnedfaultCodeList[i].Warranty_Product__c);
                            if(returnedfaultCodeList[i].Warranty_Product__c == component.get('v.claimRecord.Causal_Part_Number__c')){
                                console.log(returnedfaultCodeList[i].Warranty_Product__c);
                                Causalpartcount++;
                                for(var j=0;j<returnedfaultCodeList.length;j++){
                                    console.log('Faultcode name');
                                    //console.log(component.get("v.FaultCodeList")[i].Name);
                                    if(returnedfaultCodeList[i].Fault_Code__c == returnedfaultCodeList[j].Fault_Code__c && 
                                       returnedfaultCodeList[i].Warranty_Product__c != returnedfaultCodeList[j].Warranty_Product__c ){
                                        console.log('::Faultcode matched');
                                        Faultcodematchcount++ ;
                                        faultcodelist.push(returnedfaultCodeList[i]);
                                    }   
                                }
                            }
                        }
                        
                        if(faultcodelist.length > 0){
                            console.log("assigned as fc");
                            component.set("v.FaultCodeList",faultcodelist);
                        }else{
                            console.log("assigned as rl");
                            component.set("v.FaultCodeList",returnedfaultCodeList);
                        }
                        
                        console.log("fault code list");
                        console.log(JSON.parse(JSON.stringify(component.get("v.FaultCodeList"))));
                        console.log('::Welcome Count::');
                        console.log(Faultcodematchcount);
                        console.log(Causalpartcount);
                        
                        
                        //if the causalpartcount is zero(if there are no faultcodes present for the causalpart) In such case
                        //poplute all the faultcodes of the inventory warranty product of type Model
                        
                        
                        
                        //If the Faultcode match is zero(If there are not match/intersection between the fault codes of the causalpart 
                        //and the inverntory warranty product) In such case poplute only the faultcodes of the inventory warranty product of type Model
                        if(Faultcodematchcount == 0){
                            
                            for(var i=0;i<component.get("v.FaultCodeList").length;i++){
                                if(component.get("v.FaultCodeList")[i].Warranty_Product__c == component.get('v.InventoryWarrantyProductParentID')){
                                    faultcodelist.push(component.get("v.FaultCodeList")[i]); 
                                }
                            }
                            
                            if(faultcodelist.length!=0){
                            	component.set("v.FaultCodeList",faultcodelist);    
                            }
                            
                        }
                        
                        if(Causalpartcount == 0){
                            
                            console.log('yes there are no faultcode for causal part');
                            console.log(component.get("v.FaultCodeList"));
                        }
                        
                        console.log('The final List of faultcode to be shown are');
                        console.log(component.get("v.FaultCodeList").length);
                        console.log(component.get("v.FaultCodeList"));
                        
                        
                    }else{
                        
                        for(var i=0;i<returnedfaultCodeList.length;i++){
                            if(returnedfaultCodeList[i].Warranty_Product__c == component.get('v.claimRecord.Causal_Part_Number__c')){
                                faultcodelist.push(returnedfaultCodeList[i]); 
                            }
                            
                        }
                        
                        if(faultcodelist.length!=0){
                            component.set("v.FaultCodeList",faultcodelist);
                        }
                        
                    } 
                    
                    
                });  
                
            }
            
        }else{
            console.log('--------inside claim template claim fault code section--');
            var faultcodelist = [];
            var FaultCodeQuery = 'Select Id,Name,Fault_Code__r.Name,Warranty_Product__r.Name,Status__c from FaultCode_Mapper__c';
            helper.readDom(component, event, FaultCodeQuery, "v.FaultCodeList", "v.dmlErrors", function(returnedValues) {
                for(var i=0;i<component.get("v.FaultCodeList").length;i++){
                    if(component.get("v.FaultCodeList")[i].Warranty_Product__c == component.get('v.claimRecord.Causal_Part_Number__c')){
                        console.log('--------related to casual part');
                        
                        faultcodelist.push(component.get("v.FaultCodeList")[i]); 
                    }
                }
                
                console.log(faultcodelist);
                component.set("v.FaultCodeList",faultcodelist);
            });
        }
        
    },
    
    
    
    
    validateClaimRecord : function(component, event,helper){
        //var ClaimId	=	component.get('v.claimId');
        //window.open('/apex/searchcontact');
        //  window.open("/apex/FindClaimPolicy?id="+ClaimId,"_blank");
        console.log('--------------------inside validate clicked 111111');
        if(helper.findPolicyHandler(component, event, helper) || helper.saveClaimTemplateValidation(component, event))
        {
            console.log('--------------------inside validate clicked 2222222');
            component.set('v.isError',true);
            component.set('v.message', $A.get("$Label.c.Revalidate_Claim_Error"));   
        }else {
            console.log('--------------------inside validate clicked else block');
            component.set('v.validateClicked',true);
            //console.log('---------isShowApprovalTab--------'+component.get('v.isShowApprovalTab'));
            //component.set('v.DisplayApprovalTab',component.get('v.isShowApprovalTab'));
            //console.log('---------DisplayApprovalTab--------'+component.get('v.DisplayApprovalTab'));
            
        }
    },
    
    submitClaimRecord	: function(component, event){
        var ProceedURL = ''; 
        var BaseUrl = component.get('v.BaseURL');
        var ClaimId	=	component.get('v.claimId');
        if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined')
        {
            if(BaseUrl.indexOf('lightning') !=-1) 
                ProceedURL = "/one/one.app#/sObject/"+ClaimId+'/view';
            else
                ProceedURL = BaseUrl+"/"+ClaimId;
        }
        else{
            if(BaseUrl.indexOf('lightning') !=-1) 
                ProceedURL = "/one/one.app#/sObject/"+ClaimId+'/view';
            else
                ProceedURL = "/"+ClaimId;
        }
        component.set('v.ProceedURL',ProceedURL);
        
    },
    recordUnLockHelper : function(component,helper,event,recordId,SobjectRecord,callback) {
        console.log('---------------inside unlock helllllllper');
        var action = component.get("c.recordUnlock");
        action.setParams({
            "recordId"	: recordId,
            "claimRecord":SobjectRecord
        });
        action.setCallback(this, function(a) {
            //console.log(a.getReturnValue());
            //helper.unlockstatus = a.getReturnValue();              
            //console.log('---------------unlocked:'+a.getReturnValue());
            callback(a.getReturnValue());
        });
        $A.enqueueAction(action);
        
    },
    recordLockHelper : function(component,helper,event,SobjectRecord,callback) {
        console.log('---------------inside lock helper');
        var action = component.get("c.recordLock");
        action.setParams({
            "claimRecord":SobjectRecord
        });
        action.setCallback(this, function(a) {
            console.log('---------------locked');
                        console.log(a);
            callback(a.getReturnValue());
            console.log('Out locked');
            
        });
        $A.enqueueAction(action);
        
    },
    
    updateClaimRecord: function(component, event, helper){
        //component.set('v.claimRecord.sobjectType','Claim__c');
        var saveRecord =  component.get("v.claimRecord");
        console.log('---------------save rec');
        console.log(saveRecord);
        console.log('::::: Entered saveClaim');
        //var listRecs	=	[];
        //saveRecord.sobjectType = 'Claim__c';
        //component.set("v.claimRecordtoUpdate",component.get('v.claimRecord'));
        //listRecs.push(component.get('v.claimRecordtoUpdate'));
        //component.set('v.updateRecords',saveRecord);
        //console.log('----------------------listrecs');
        //console.log(listRecs);
        helper.recordUnLockHelper(component,helper,event,component.get("v.claimRecord.Id"),component.get("v.claimRecord"),function(unlockStatusResponse){
            	helper.unlockstatus = unlockStatusResponse;
   				
            	        console.log('+++++++++++++++++++++++'+helper.unlockstatus+'++++++++++++');
        var action 	= 	component.get("c.UpdateSObjects");
        
        action.setParams({
            "inputSObjectList" : [component.get("v.claimRecord")],
        });
        action.setCallback(this, function(response) {
            //console.log('+++++++++++++++++++++++'+helper.unlockstatus+'--------------');
            if(helper.unlockstatus == 'recordUnlocked'){
                helper.recordLockHelper(component,helper,event,component.get("v.claimRecord"),function(recordLockResponse){
                    
                    console.log("Hey response");
                    console.log(recordLockResponse);
                    
                    /////////////////////////////////////////
                    
                    console.log('::::: Respose value:');
            console.log(response);
            console.log(':::: Status:'+response.getState());
            
            var state = response.getState();
            var dmlErrors = [];
            if(state === "ERROR"){
                console.log(response.getError());
               // console.log(response.getError()[0].fieldErrors);
               // console.log(response.getError()[0].pageErrors);
                
                if(response.getError()[0]["fieldErrors"]!=null && response.getError()[0]["fieldErrors"]!=undefined){
                	if(response.getError()[0].fieldErrors.length > 0){
                        console.log('field errors');
                        console.log(response.getError()[0].fieldErrors[0].message);
                        dmlErrors.push(response.getError()[0].fieldErrors[0].message);
                        component.set('isError',true);
                        component.set('message',response.getError()[0].fieldErrors[0].message);
                    }    
                }else if(response.getError()[0]["pageErrors"]!=null && response.getError()[0]["pageErrors"]!=undefined){
                  if(response.getError()[0].pageErrors.length > 0){
                    console.log('page errors');
                    console.log( response.getError()[0].pageErrors[0].message);
                    dmlErrors.push(response.getError()[0].pageErrors[0].message);
                    component.set('isError',true);
                    component.set('message',response.getError()[0].pageErrors[0].message);
                  }
                }else{
                      var dmlErr = response.getError()[0]["message"];
                      dmlErrors.push( dmlErr );
                }
                
            }else if(state == "SUCCESS"){
                console.log(response.getReturnValue());
                
                /*if (response.getReturnValue()[0].errorCodeList) {
                    for  (var key in response.getReturnValue()[0].errorCodeList) {
                        console.log(response.getReturnValue()[0].errorCodeList[key]);
                        dmlErrors.push(response.getReturnValue()[0].errorCodeList[key]);
                    }
                }*/
                var saveResult = response.getReturnValue()[0];
                console.log('::::: Save Result:');
                console.log(saveResult);
                if(saveResult.success == Boolean(1)){
                    component.set('v.claimId',component.get('v.claimRecord.Id'));
                    //component.set("v.claimRecord.Id",saveResult.sObjID);
                    
                    
                } else {
                    //
                }
                
                //component.navigateMethod();
            }
            component.set("v.dmlErrors",dmlErrors);
                    
                    ////////////////////////////////////////
                    
                    
                    
                });
            }
                
            
        });
        console.log('Calling Action :::: c.UpdateSObjects');
        $A.enqueueAction(action);
        });

    },
    
    updateClaimValidationforDealer	: function(component, event, Elementid, errorCount){
        var inputCmp = component.find(Elementid);
        console.log('----------inputCmp----------');
        console.log(inputCmp);
        var value = inputCmp.get("v.value");
        if (isNaN(value)) {
            errorCount++;
            inputCmp.set("v.errors", [{message:"Input not a number: " + value}]);
        } else {
            inputCmp.set("v.errors", null);
        }
        return errorCount;
    },
    
    updateClaimValidationforAdmin	: function(component, event, Elementid, errorCount){
        var inputCmp = component.find(Elementid);
        console.log('----------inputCmp----------'+Elementid);
        console.log(inputCmp);
        var value = inputCmp.get("v.value");
        console.log(value);
        if (isNaN(value)) {
            errorCount++;
            inputCmp.set("v.errors", [{message:"Input not a number: " + value}]);
        } else {
            inputCmp.set("v.errors", null);
        }
        console.log('::: error count in helper:'+errorCount);
        return errorCount;
    }
    
})