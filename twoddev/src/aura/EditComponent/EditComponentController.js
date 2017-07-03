({
    saveClaimTemplate : function(component, event, helper) {
        event.preventDefault();
        
        var isError	=	false;
        if(!component.get('v.isClaimTemplate')){
            console.log(':::::: save claim template');
            isError		=	helper.saveClaimTemplateValidation(component,event);
        }
        
        var isSaved = component.get('v.isSaved');        
        console.log('isSaved' + isSaved);
        if(isSaved)
        {
            component.set("v.isError", false); 
            isError	=	false;
        }
        
        // Debug the required information
        if(component.get('v.claimId') == null || component.get('v.claimId') == '' || typeof component.get('v.claimId') == "undefined"){
            if(component.get('v.ClaimType') == 'Serialized'){
                
            }else if(component.get('v.ClaimType') == 'Non-Serialized'){
                
            } else if(component.get('v.ClaimType') == 'Field Modification'){
                
            } else{
                
            }
        }
        
        console.log('::::: isError:'+isError);
        if(!isError){
            console.log('-------------------- before saving');
            console.log(component.get("v.claimRecord"));
            
            var claimRecord = JSON.parse(JSON.stringify(component.get("v.claimRecord")));
            if(claimRecord["Id"] != null && claimRecord["Id"] != undefined){
                helper.recordUnLockHelper(component,helper,event,claimRecord["Id"],claimRecord,function(unlockResponse){
                    console.log("unlock response status");
                    console.log(JSON.parse(JSON.stringify(unlockResponse)));   
                });	
            }
            
            
            var action = component.get("c.upsertClaim");
            action.setParams({
                "claimRecord"	: component.get("v.claimRecord"),
            });
            
            action.setCallback(this, function(a) {
                
                if(helper.unlockstatus == 'recordUnlocked'){
                    helper.recordLockHelper(component,helper,event,component.get("v.claimRecord"),function(lockResponse){
                        console.log("lock response status");
                        console.log(JSON.parse(JSON.stringify(lockResponse)));
                    });
                }
                
                console.log(a.getState());
                if (action.getState() == "SUCCESS") {
                    // Success completion
                    console.log('return value-------------');
                    console.log(a.getReturnValue());
                    var res	=	a.getReturnValue();
                    //component.set("v.claimRecordtoUpdate",a.getReturnValue());
                    //	var tmpclaim = component.get("v.claimRecord");
                    //	tmpclaim.Id = a.getReturnValue().Id;
                    //	tmpclaim.Name = a.getReturnValue().Name;
                    //  component.set("v.claimRecord", tmpclaim);
                    component.set("v.claimId",a.getReturnValue().Id);
                    component.set("v.claimName",res.Name);
                    console.log(res);
                    var action1 = component.get('c.findSObjectsBySOQL');
                    var query='Select Id, Name,Units_Run__c, RecordTypeId,RecordType.DeveloperName,Delay_Reason__c,Date_Of_Purchase__c,'+
                        'Invoice_Number__c, RecordType.Name,Service_Ticket__c,Work_order__c, Account__r.Name, Inventory__r.Name,'+
                        'Campaign_Members__r.Name, Warranty_Product__r.Name,Fault_Code__r.Name,Fault_Code__r.Description__c,'+
                        'Causal_Part_Number__r.Name,Causal_Part_Number__r.Description__c, Applicable_Policy__r.Name,Account__c,'+
                        'Total_Parts_Cost__c,Inventory__c,Warranty_Product__c,Campaign_Members__c,Host_NonHost__c,Serial_Number__c,'+
                        'Date_of_Failure__c,Date_of_Repair__c,Final_Parts_Cost__c,Applicable_Policy__c,Fault_Code__c,Causal_Part_Number__c,'+
                        'Request_SMR__c,Claim_Parts_Pending_Approval__c,SMR_Reason__c,Override_Policy__c,TravelByHours__c,'+
                        'TravelByDistance__c,Total_Labor_Cost__c,Final_Labor_Cost__c,Total_TravelByDistance_Cost__c,Final_TravelByDistance_Cost__c,'+
                        'Total_TravelByHours_Cost__c,Final_TravelByHours_Cost__c,Total_Meals_Cost__c,Final_Meals_Cost__c,Caused_by__c,'+
                        'Fault_found__c,Total_Parking_Cost__c,Final_Parking_Cost__c,Percent_Labor_Cost__c,Approved_Labor_Cost__c,'+
                        'Percent_TravelByDistance_Cost__c,Approved_TravelByDistance_Cost__c,Percent_TravelByHours_Cost__c,'+
                        'Approved_TravelByHours_Cost__c,Percent_Parts_Cost__c,Approved_Parts_Cost__c,Percent_Meals_Cost__c,Approved_Meals_Cost__c,'+
                        'Percent_Parking_Cost__c,Approved_Parking_Cost__c,Percent_Claim_Cost__c,Approved_Ignore_Sum__c,Final_Claim_Cost__c,'+
                        'Approved_Claim_Cost__c,Description__c,TravelByLocation__c,Fault_Code_Comment__c,CasualPart_Comments__c,'+
                        'work_Performed_comments__c from Claim__c Where Id= '+'\''+component.get('v.claimId')+'\'' ;
                    
                    console.log("aman query");
                    console.log(query);
                    
                    action1.setParams({
                        query : query
                    });
                    /* action1.setCallback(this, function(response) {
                        console.log('----Inside SOQL----');
                        console.log(response.getReturnValue());
                        console.log(response.getReturnValue()[0]);
                        component.set('v.claimRecord',response.getReturnValue()[0]);
                    });
                    
                    $A.enqueueAction(action1);*/
                    // helper.validationmethod(component,helper);
                    console.log('------claimId--------',component.get("v.claimId"));
                    console.log('------claimName--------',component.get("v.claimName"));
                    component.set("v.isSuccess", false);
                    component.set("v.isError", false);
                    component.set('v.isServiceInfoActivated',true);
                    component.set('v.isSaveEnabled',false);
                    component.set('v.isNextClicked',true);
                    component.settab(component, event, helper);
                    
                    /*************************************************************************/
                    
                    // New server call to get the details of the claim record
                    
                    /**************************************************************************/
                    var action1 = component.get("c.findSObjectsBySOQL");
                    
                    action1.setParams({
                        "query"	: query
                    });
                    action1.setCallback(this, function(a) {
                        console.log(':::: Query result:'+a.getReturnValue());
                        var result	=	JSON.parse(JSON.stringify(a.getReturnValue()[0]));
                        console.log(':::::: Result value from query');
                        console.log(result);
                        
                        //save claim in page variable
                        component.set("v.claimRecord",result);
                        
                        component.set('v.ClaimType',result.RecordType.Name);
                        if(result.Account__c != null && result.Account__c != '' && typeof result.Account__c != "undefined"){
                            component.set('v.dealerName',result.Account__r.Name);
                        }
                        
                        
                        if(result.Warranty_Product__c != null && result.Warranty_Product__c != '' && typeof result.Warranty_Product__c != "undefined"){
                            component.set('v.warrantyProductName',result.Warranty_Product__r.Name);
                        }
                        
                        if(result.Inventory__c != null && result.Inventory__c != '' && typeof result.Inventory__c != "undefined"){
                            component.set('v.inventoryName',result.Inventory__r.Name);
                        }
                        
                        
                        if(result.Fault_Code__c != null && result.Fault_Code__c != '' && typeof result.Fault_Code__c != "undefined"){
                            component.set('v.faultCode',result.Fault_Code__r.Name);
                        }
                        if(result.Causal_Part_Number__c != null && result.Causal_Part_Number__c != '' && typeof result.Causal_Part_Number__c != "undefined"){
                            component.set('v.causalPartName',result.Causal_Part_Number__r.Name);
                        }
                        if(result.Campaign_Members__c != null && result.Campaign_Members__c != '' && typeof result.Campaign_Members__c != "undefined"){
                            component.set('v.campaignMembers',result.Campaign_Members__r.Name);
                        }
                        if(component.get('v.isSerialized')){
                            console.log('::::: Inventory Name appending');
                            component.set('v.inventoryName',result.Inventory__r.Name);
                            console.log('::::: Inventory Name appended');
                        }
                        component.set('v.claimRecord.RecordType.Name',result.RecordType.Name);
                        
                        
                        
                        /*
                                component.set('v.causalPartName',result.Causal_Part_Number__r.Name);
                                component.set('v.policyName',result.Applicable_Policy__r.Name);
                                component.set('v.faultCode',result.Fault_Code__r.Name);
                                component.set('v.inventoryName',result.Inventory__r.Name);
                                component.set('v.campaignMembers',result.Campaign_Members__r.Name);
                                */
                        
                        //helper.validateClaimRecord(component, event,helper);
                        //component.set('v.validateClicked',false);                        
                        //helper.invisible(component,'TabDiv');
                        /*
                        var action2 = component.get('c.updatePolicyDefinition');
                        action2.setParams({
                            'tmpClm' : component.get('v.claimRecord')
                        });
                        action2.setCallback(this, function(response) {
                            console.log('---after validation---')
                            console.log(response.getReturnValue());
                            component.set('v.policyType',response.getReturnValue());
                        });
                        
                        $A.enqueueAction(action2);
                        */
                        
                        
                    });
                    $A.enqueueAction(action1);
                    
                    
                    
                } else if (action.getState() == "ERROR") {
                    helper.errorHandling(a,action,component);
                }
            });
            $A.enqueueAction(action);
            
            
            
            
        }
    },
    
    
    saveClaim : function(component, event, helper){
        event.preventDefault();
        console.log(':::: is admin:'+component.get('v.isSysAdmin'));
        
        console.log('::::: dealer name:'							+component.get('v.dealerName'));
        console.log('::::: warrantyProductName name:'	+component.get('v.warrantyProductName'));
        console.log('::::: causalPartName:'						+component.get('v.causalPartName'));
        console.log('::::: policyName:'								+component.get('v.policyName'));
        
        //component.set('v.claimRecord.sobjectType','Claim__c');
        
        var isAdmin	=	component.get('v.isSysAdmin');
        var Errorcount = 0;
        //helper.updateClaimRecord(component, event);
        Errorcount = helper.updateClaimValidationforAdmin(component, event,'totalParkingCost',Errorcount);
        Errorcount = helper.updateClaimValidationforAdmin(component, event,'totalMealsCost',Errorcount);
        
        if(Errorcount == 0) {
            console.log('::::: claim record after insertion:');
            console.log(component.get('v.claimRecord'));
            helper.updateClaimRecord(component, event, helper);
            component.set('v.isNextClicked',true);
            component.settab(component, event, helper);
        }
        
        
        //console.log('::::: dealer name:'+component.get('v.dealerName'));
        //console.log('::::: warrantyProductName name:'+component.get('v.warrantyProductName'));
        //console.log('::::: causalPartName:'+component.get('v.causalPartName'));
        //console.log('::::: policyName:'+component.get('v.policyName'));
        
    },
    /*
    navigateURL : function(component, event, helper) {
        console.log('trying to navigate to the standard page');
        window.location.href = window.location.origin + '/'+component.get('v.claimId');
    },*/
    
    selectedclaimtype : function(component, event, helper){
        component.set('v.claimRecord.Inventory__c',null);
        component.set('v.claimRecord.Warranty_Product__c',null);
        component.set('v.claimRecord.Campaign_Members__c',null);
        component.set('v.claimRecord.Units_of_Measure__c',null);
        component.set('v.isFieldModification', false);
        component.set('v.isNonSerialized', false);
        component.set('v.isSerialized', false);
        component.set("v.isError", false);
        component.set('v.isUnitRun',false);
        
        console.log(component.find("claimtype").get("v.value"));
        var serializedPartId = '';
        var nonSerializedPartId='';
        var FieldModId='';
        var claimTemplateId='';
        
        for(var i=0; i<component.get('v.claimrecordTypes').length; i++){
            if(component.get('v.claimrecordTypes')[i].DeveloperName == 'Serialized_Part'){
                serializedPartId = component.get('v.claimrecordTypes')[i].Id;
            } else if(component.get('v.claimrecordTypes')[i].DeveloperName == 'Non_Serialized_Part'){
                nonSerializedPartId = component.get('v.claimrecordTypes')[i].Id;
            }else if(component.get('v.claimrecordTypes')[i].DeveloperName == 'Field_Modification'){
                FieldModId = component.get('v.claimrecordTypes')[i].Id;
            }else if(component.get('v.claimrecordTypes')[i].DeveloperName == 'Claim_Template'){
                claimTemplateId = component.get('v.claimrecordTypes')[i].Id;
            }
        }
        
        var claimtype = component.find("claimtype").get("v.value");
        
        if(claimtype == 'None')
        {
            //component.set("v.isError", true);
            component.set("v.claimTypeError", $A.get("$Label.c.Claim_Type_Empty_Error"));
            return;
        }else {
            component.set("v.claimTypeError", "");
        }
        if(claimtype == 'Field Modification')
        {
            component.set('v.claimRecord.RecordTypeId',FieldModId);
            component.set('v.ClaimRecordType','Field_Modification');
            component.set('v.isFieldModification', true);
            component.set('v.isClaimTemplate', false);
        }
        else if(claimtype == 'Non-Serialized'){
            component.set('v.claimRecord.RecordTypeId',nonSerializedPartId);
            component.set('v.ClaimRecordType','Non_Serialized_Part');
            component.set('v.isNonSerialized', true);
            component.set('v.isClaimTemplate', false);
        }
            else if(claimtype == 'Serialized'){
                component.set('v.claimRecord.RecordTypeId',serializedPartId);
                component.set('v.ClaimRecordType','Serialized_Part');
                component.set('v.isSerialized', true);
                component.set('v.isClaimTemplate', false);
            } if(claimtype == 'Claim Template'){
                component.set('v.claimRecord.RecordTypeId',claimTemplateId);
                component.set('v.ClaimRecordType','Claim_Template');
                component.set('v.isClaimTemplate', true);
            }
        /*
        	component.set('v.claimRecord.Inventory__c',null);
         	component.set('v.claimRecord.Warranty_Product__c',null);
         	component.set('v.claimRecord.Campaign_Members__c',null);
        	var RecordType = component.get('v.ClaimRecordType');
        	console.log('----RecordType------'+RecordType);
            var action2 = component.get("c.findSObjectsBySOQL");
            action2.setParams({
                "query"	: 'Select Id,DeveloperName FROM RecordType Where DeveloperName= '+'\''+RecordType+'\''
            });
            action2.setCallback(this, function(a) {
                console.log('::::: return value for record type:'+a.getReturnValue()[0]);
                console.log('------------ inside record type setting');
                console.log(a.getReturnValue()[0].Id);
                console.log(a.getReturnValue()[0].DeveloperName);
                component.set('v.claimRecord.RecordType.Id',a.getReturnValue()[0].Id);
                console.log(component.get('v.claimRecord'));
            });
            $A.enqueueAction(action2);
            */
    },
    onCheckSMR : function(component, event, helper){
        var checkCmp = component.find("checkbox");
        console.log(checkCmp);
        console.log(checkCmp.get("v.value"));
        if(checkCmp.get("v.value"))
        {
            component.set("v.claimRecord.Request_SMR__c", checkCmp.get("v.value"));
            //helper.visible(component,'SMRReasonEnable');
        }
        else{
            component.set("v.claimRecord.Request_SMR__c", checkCmp.get("v.value"));
            component.set("v.claimRecord.SMR_Reason__c", '');
            //helper.invisible(component,'SMRReasonEnable');
        }
        
    },
    onDealerClick: function(component, event, helper){
        console.log('------ Inside dealer click');
        
        var claimtype = component.find("claimtype").get("v.value");
        console.log(claimtype);
        if(component.get('v.claimId') == null || component.get('v.claimId') == '' || typeof component.get('v.claimId') == "undefined" ){
            if(claimtype == 'None'){
                component.set("v.isError", true);
                component.set("v.message", "Please select Claim Type");
            }else
            {
                component.set("v.isError", false);
            }
        }
        
    },
    setCurrentTab : function(component, event, helper) {
        var currentTabVal	=	component.get('v.currentTab');
        
        console.log('Current tab');
        //console.log(currentTabVal);
        //console.log(event.target.tabIndex);
        
        if(currentTabVal == "1"){
            
            //component.claimBasicDetails();
            var hasErrors 	= 	false;
            if(!component.get('v.isClaimTemplate')){
                hasErrors		=	helper.findPolicyHandler(component, event, helper);
            }
            
            console.log(':::: Fault code name value:'+component.get('v.faultCode'));
            console.log(':::: causal part name value:'+component.get('v.causalPartName'));
            if(hasErrors){
                component.set("v.isSuccess", false);
                //component.set("v.isError", true);
                component.set('v.isFaultCodeEnabled',false);
                return;
            }else{
                console.log('::::: We are at first place');
                component.set("v.isSuccess", false);
                component.set("v.isError", false);
                component.set('v.isFaultCodeEnabled',true);
                console.log(component.get("v.claimRecord"));
                $A.util.removeClass(document.getElementById('li-tab-' + currentTabVal), 'activeTabColor');
                $A.util.addClass(document.getElementById('li-tab-' + currentTabVal), 'TabColor');
            }
            //return;
        }
        if(currentTabVal == "2"){           
            console.log(':::: isPrev clicked:'+component.get('v.isPrevClicked'));
            if(component.get('v.isNextClicked')){
                var hasErrors  = false;
                if(!component.get('v.isClaimTemplate')){
                    hasErrors  =  helper.saveClaimTemplateValidation(component,event);
                }
                //var hasErrors  =  helper.saveClaimTemplateValidation(component,event);
                console.log('::::: Has errors in current tab2:'+hasErrors);
                if(!hasErrors){
                    $A.util.removeClass(document.getElementById('li-tab-' + currentTabVal), 'activeTabColor');
                    $A.util.addClass(document.getElementById('li-tab-' + currentTabVal), 'TabColor');
                    
                    
                }else{
                    return;
                }
            }
            if(!component.get('v.isNextClicked') && !component.get('v.isPrevClicked'))
            {
                console.log(document.getElementById('li-tab-1'));
                var whichTab = 'tab-'+event.target.tabIndex;
                console.log(whichTab);
                if(whichTab != "tab-1")
                {
                    var hasErrors  = false;
                    
                    if(!component.get('v.isClaimTemplate')){
                        hasErrors  =  helper.saveClaimTemplateValidation(component,event);
                    }
                    console.log('::::: Has errors in current tab2:'+hasErrors);
                    if(!hasErrors){
                        $A.util.removeClass(document.getElementById('li-tab-' + currentTabVal), 'activeTabColor');
                        $A.util.addClass(document.getElementById('li-tab-' + currentTabVal), 'TabColor');
                        
                        
                    }else{
                        return;
                    }
                }
            }
            
            //component.faultCodeValidation(true);
            //return;
        }
        
        if(currentTabVal == "6"){
            component.set('v.isError',false);
            component.set('v.validateClicked',false);
            helper.invisible(component,'TabDiv');
            console.log('6---');
            console.log(component.get("v.claimRecord"));
        }
        
        
        var nextclicked =  component.get('v.isNextClicked');
        var prevclicked = component.get('v.isPrevClicked');
        var tabCount = component.get("v.numRecords");
        if(!nextclicked && !prevclicked)
        {
            console.log('inside not--next clicked-------------');
            for (var i=1; i<= tabCount ; i++) {
                $A.util.removeClass(document.getElementById('li-tab-' + i), 'activeTabColor');
                $A.util.removeClass(document.getElementById('div-tab-' + i), 'slds-show');
                $A.util.addClass(document.getElementById('div-tab-' + i), 'slds-hide');
            }
            console.log("The tab count is : " + tabCount);
            console.log(event);
            var whichTab = 'tab-' + event.target.tabIndex;
            var splittedtab = event.target.tabIndex;
            console.log('-----whichTab----'+whichTab);
            
            var cmpTargetLi = document.getElementById('li-' + whichTab);
            var cmpTargetDiv = document.getElementById('div-' + whichTab);
            $A.util.addClass(cmpTargetLi, 'activeTabColor');
            $A.util.removeClass(cmpTargetDiv, 'slds-hide');
            $A.util.addClass(cmpTargetDiv, 'slds-show');
            console.log(component.get('v.currentTab'));
            console.log(splittedtab);
            console.log(parseInt(component.get('v.currentTab')) - splittedtab);
            if(parseInt(component.get('v.currentTab')) - splittedtab == -1)
            {
                var ColorTab = parseInt(splittedtab)-1;
                console.log(document.getElementById('li-tab-'+ColorTab));
                $A.util.removeClass(document.getElementById('li-tab-' + currentTabVal), 'activeTabColor');
                $A.util.addClass(document.getElementById('li-tab-'+ColorTab), 'TabColor');
            }
            
            component.set('v.currentTab',splittedtab);
        }
        else if(nextclicked || prevclicked)
        {
            var currentTab = component.get('v.currentTab');
            
            $A.util.removeClass(document.getElementById('li-tab-' + currentTab), 'activeTabColor');
            $A.util.removeClass(document.getElementById('div-tab-' + currentTab), 'slds-show');
            $A.util.addClass(document.getElementById('div-tab-' + currentTab), 'slds-hide');
            console.log("The tab count is : " + tabCount);
            console.log("--------------currentTab: " + currentTab);
            if(nextclicked)
            {
                console.log('inside ----next clicked-------------',currentTab);
                var NextTab = parseInt(currentTab)+1;
                console.log("--------------NextTab: " + NextTab);
                $A.util.addClass(document.getElementById('li-tab-' + currentTab), 'TabColor');
            }
            else if(prevclicked)
            {
                console.log('inside ----prev clicked-------------',currentTab);
                var NextTab = parseInt(currentTab)-1;
                console.log("--------------NextTab: " + NextTab);
            }
            var whichTab = 'tab-'+NextTab;
            console.log('-----whichTab----'+whichTab);
            var cmpTargetLi = document.getElementById('li-' + whichTab);
            var cmpTargetDiv = document.getElementById('div-' + whichTab);
            $A.util.addClass(cmpTargetLi, 'activeTabColor');
            $A.util.removeClass(cmpTargetDiv, 'slds-hide');
            $A.util.addClass(cmpTargetDiv, 'slds-show');
            component.set('v.isNextClicked',false);
            component.set('v.isPrevClicked',false);
            console.log('---------v.currentTab--------'+NextTab);
            component.set('v.currentTab',NextTab);
        }
        
    },
    goPrevious : function(component, event, helper) {
        event.preventDefault();
        console.log(':::: We are at go previous method');
        component.set('v.isError',false);
        component.set('v.isSuccess',false);
        component.set('v.isNextClicked',false);
        component.set('v.isPrevClicked',true);
        component.settab(component, event, helper);
        
    },
    
    // Go to next tab
    goNext: function(component, event, helper) {
        event.preventDefault();
        component.set('v.isNextClicked',true);
        component.set('v.isServiceInfoActivated',true);
        console.log('--------isServiceInfoActivated------------',component.get('v.isServiceInfoActivated'));
        component.settab(component, event, helper);
    },
    
    // Code to populate the claim type based on the inventory value
    populateClaimType : function(component, event, helper) {
        //component.set('v.isChanged',true);
        console.log('-------in --populateClaimType-----------');
        var InventoryId = component.get('v.claimRecord.Inventory__c');
        
        
        if(InventoryId != null && InventoryId != undefined && InventoryId != ''){
            var query = 'Select Units_Run__c,Item__c,Item__r.Parent_Product__c,Item__r.Parent_Product__r.Type__c from Inventory__c where Id=\'' +  InventoryId +'\'';
            var actionInventory = component.get('c.findSObjectsBySOQL');
            actionInventory.setParams({
                query : query
            });
            actionInventory.setCallback(this, function(a) {
                console.log(a.getReturnValue()[0]);
                console.log('Units Run in Inventory' )
                if(a.getReturnValue()[0] != null)
                {    console.log('Units Run in Inventory' )
                /*console.log(a.getReturnValue()[0].Item__c); 
                console.log(a.getReturnValue()[0].Item__r.Parent_Product__c);
                console.log(a.getReturnValue()[0].Item__r.Parent_Product__r.Type__c);
                */
                component.set(('v.InventoryUnitsRun'),a.getReturnValue()[0].Units_Run__c);
                 //populating the inventory's warranty products parent product type
                 if(a.getReturnValue()[0].Item__c != null){
                     component.set('v.InventoryWarrantyProductParentID',a.getReturnValue()[0].Item__r.Parent_Product__c);     
                 }else{
                     component.set('v.InventoryWarrantyProductParentID','');       
                 }     
                 
                 //populating the inventory's warranty products parent product type
                 if(a.getReturnValue()[0].Item__r != null && a.getReturnValue()[0].Item__r != undefined){
                     if(a.getReturnValue()[0].Item__r.Parent_Product__r != null && a.getReturnValue()[0].Item__r.Parent_Product__r != undefined){
                         if(a.getReturnValue()[0].Item__r.Parent_Product__r.Type__c != null && a.getReturnValue()[0].Item__r.Parent_Product__r.Type__c 
                            != undefined){
                             component.set('v.InventoryWarrantyProductParentType',a.getReturnValue()[0].Item__r.Parent_Product__r.Type__c);   
                         }else{
                             component.set('v.InventoryWarrantyProductParentType','');      
                         }
                     }else{
                         component.set('v.InventoryWarrantyProductParentType','');    
                     }
                 }else{
                     component.set('v.InventoryWarrantyProductParentType','');    
                 }
                 
                 
                }
                console.log(':::The new values:::');
                console.log(component.get('v.InventoryWarrantyProductParentID'));
                console.log(component.get('v.InventoryWarrantyProductParentType'));
                helper.FetchFaultcodes(component, event, helper);
                console.log('Units Run in Inventory' )
                console.log( component.get('v.InventoryUnitsRun'))
            });
            $A.enqueueAction(actionInventory);
            component.set('v.inventoryError','');
            component.set('v.isSuccess',false);
            component.set('v.isError',false);
            var action = component.get('c.popClaimType');
            action.setParams({
                InventoryId :InventoryId
            });
            action.setCallback(this, function(a) {
                console.log(action.getState());
                if (action.getState() == "SUCCESS") {
                    console.log('------Inventory related wp------',a.getReturnValue());
                    if(component.get('v.isFieldModification'))
                    {
                        component.set('v.ClaimType','Field Modification');
                        component.set('v.claimRecord.Claim_Type__c','Field Modification');
                        component.set('v.claimRecord.Units_of_Measure__c',a.getReturnValue().Units_of_Measure__c);
                        
                    }
                    else
                    {
                        component.set('v.ClaimType',a.getReturnValue().Item_Type__c);
                        component.set('v.claimRecord.Claim_Type__c',a.getReturnValue().Item_Type__c);
                        component.set('v.claimRecord.Units_of_Measure__c',a.getReturnValue().Units_of_Measure__c);
                        if(a.getReturnValue().Item_Type__c == 'Part')
                            component.set('v.isHostNonHost',true);
                    }
                    console.log('v.claimRecord.Units_of_Measure__c---' + (component.get('v.claimRecord.Units_of_Measure__c')));
                    if( (component.get('v.claimRecord.Units_of_Measure__c') != null))
                    {
                        component.set('v.isUnitRun',true);
                    }
                    var SerialNumber = a.getReturnValue().Product_Name__c ;
                    component.set('v.claimRecord.Serial_Number__c',SerialNumber);
                    if(SerialNumber != null)
                    {
                        component.set('v.ClaimSerialNumberOutput',true);
                        component.set('v.ClaimSerialNumberInput',false);
                    }
                    else{
                        component.set('v.ClaimSerialNumberOutput',false);
                        component.set('v.ClaimSerialNumberInput',true);
                    }
                    
                }
                else if (action.getState() == "ERROR") {
                    helper.errorHandling(a,action,component);
                }
            });
            $A.enqueueAction(action);
            
            /*var action2 = component.get('c.findSObjectsBySOQL');
             action2.setParams({
                 query :"Select Serial_Number__c FROM Inventory__c Where Id="+'\''+InventoryId+'\''
            });
            action2.setCallback(this, function(a) {
                console.log(a.getReturnValue()[0].Serial_Number__c);
                var SerialNumber = a.getReturnValue()[0].Serial_Number__c;
                component.set('v.claimRecord.Serial_Number__c',SerialNumber);
                if(SerialNumber != null)
                {
                     component.set('v.ClaimSerialNumberOutput',true);
                     component.set('v.ClaimSerialNumberInput',false);
                }
                else{
                     component.set('v.ClaimSerialNumberOutput',false);
                     component.set('v.ClaimSerialNumberInput',true);
                }
            });
            $A.enqueueAction(action2);*/
        }
        else{
            component.set('v.ClaimType',null);
            component.set('v.ClaimSerialNumberOutput',false);
            component.set('v.ClaimSerialNumberInput',false);
            //component.set('v.inventoryError','Please select an Inventory');
            component.set('v.isError',false);
            component.set('v.isHostNonHost',false);
            
        }
    },
    
    
    // Warranty product Id
    populateWarrantyClaimType : function(component, event, helper) {
        //component.set('v.isChanged',true);
        console.log('-------in --populateWarrantyClaimType-----------');
        var WarrantyProductId = component.get('v.claimRecord.Warranty_Product__c');
        console.log(':::: Warranty product id:'+WarrantyProductId);
        if(WarrantyProductId != null && WarrantyProductId != undefined && WarrantyProductId != ''){
            var action = component.get('c.findSObjectsBySOQL');
            component.set('v.warrantyProductError','')
            action.setParams({
                query :'Select Item_Type__c,Product_Name__c,Units_of_Measure__c FROM Warranty_Product__c Where Id= '+'\''+WarrantyProductId+'\''
            });
            action.setCallback(this, function(a) {
                console.log(action.getState());
                if (action.getState() == "SUCCESS") {
                    console.log('------------',a.getReturnValue());
                    if(a.getReturnValue()[0])
                    {
                        component.set('v.ClaimType',a.getReturnValue()[0].Item_Type__c);
                        component.set('v.claimRecord.Units_of_Measure__c',a.getReturnValue()[0].Units_of_Measure__c);
                        component.set('v.claimRecord.Claim_Type__c',a.getReturnValue()[0].Item_Type__c);
                        if(component.get('v.isSerialized') || component.get('v.isNonSerialized') && a.getReturnValue()[0].Item_Type__c == 'Part')
                            component.set('v.isHostNonHost',true);
                        var SerialNumber = a.getReturnValue()[0].Product_Name__c ;
                        component.set('v.claimRecord.Serial_Number__c',SerialNumber);
                        if(SerialNumber != null)
                        {
                            component.set('v.ClaimSerialNumberOutput',true);
                            component.set('v.ClaimSerialNumberInput',false);
                        }
                        else{
                            component.set('v.ClaimSerialNumberOutput',false);
                            component.set('v.ClaimSerialNumberInput',true);
                        }
                        if( component.get('v.claimRecord.Units_of_Measure__c') != null)
                        {
                            component.set('v.isUnitRun',true);
                        }
                    }else
                    {
                        component.set('v.ClaimType',null);
                    }
                }
                else if (action.getState() == "ERROR") {
                    helper.errorHandling(a,action,component);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set('v.isHostNonHost',false);
            component.set('v.ClaimType',null);
            //component.set('v.warrantyProductError','Please select Warranty Product')
        }
    },
    
    
    // Dealer handler
    dealerHandler : function(component, event, helper){
        //component.set('v.isChanged',true);
        var dealerId	=	component.get('v.claimRecord.Account__c');
        if(dealerId	== null || dealerId == '' || typeof dealerId == "undefined") {
            component.set('v.dealorError',$A.get("$Label.c.Dealer_Value_Empty_Error"));
        }else{
            component.set('v.dealorError','');
        }
    },
    
    
    // Date of Failure handler
    dateOfFailureHandler : function(component, event, helper) {
        //component.set('v.isChanged',true);     
        if(component.get('v.claimRecord.Date_of_Failure__c') == null || component.get('v.claimRecord.Date_of_Failure__c') == ''
           || typeof component.get('v.claimRecord.Date_of_Failure__c') == "undefined"){
            component.set('v.dateofFailureError',$A.get("$Label.c.Failure_Date_Empty_Error"));
        }else {
            component.set('v.dateofFailureError','');
        }
    },
    
    dateOfRepairHandler : function(component, event, helper) {
        //component.set('v.isChanged',true);
        if(component.get('v.claimRecord.Date_of_Repair__c') == null || component.get('v.claimRecord.Date_of_Repair__c') == ''
           || typeof component.get('v.claimRecord.Date_of_Repair__c') == "undefined"){
            component.set('v.dateofRepairError',$A.get("$Label.c.Failure_Date_Empty_Error"));
        }else {
            component.set('v.dateofRepairError','');
        }
    },
    
    onFaultcodeSelect : function(component, event, helper) {
        
        /*
        var selectedId = component.find("faultCode").get("v.text");   
        var selectedvalue = component.find("faultCode").get("v.value");  
        component.set('v.claimRecord.Fault_Code__c',selectedvalue);
        */
        
        
        var selectedvalue = event.getSource().get("v.value");
        console.log("aman event");
        console.log(selectedvalue);
        component.set('v.claimRecord.Fault_Code__c',selectedvalue);
        
        
    },
    
    casualPartHandler : function(component, event, helper){
        //event.preventDefault();
        // component.set('v.isChanged',true);
        console.log("Hey aman so so...");
        if(component.get('v.claimRecord.Causal_Part_Number__c') == null || component.get('v.claimRecord.Causal_Part_Number__c') == ''
           || typeof component.get('v.claimRecord.Causal_Part_Number__c') == "undefined"){
            component.set('v.casualPartError',$A.get("$Label.c.Caused_By_Info_Error")); 
        }else {
            console.log('::Causal part changes::');
            console.log(component.get('v.claimRecord.Causal_Part_Number__c'));
            component.set('v.casualPartError','');
        }
        
        var claimRecord=JSON.parse(JSON.stringify(component.get("v.claimRecord")));
        console.log("claim record in casual part handeler method");
        console.log(claimRecord);
        helper.FetchFaultcodes(component, event, helper);
    },
    
    
    
    faultCodeHandler : function(component, event, helper){
        
        // component.set('v.isChanged',true);
        console.log("aman fault code");
        console.log(component.get('v.claimRecord.Fault_Code__c'));
        if(component.get('v.claimRecord.Fault_Code__c') == null || component.get('v.claimRecord.Fault_Code__c') == ''
           || typeof component.get('v.claimRecord.Fault_Code__c') == "undefined"){
            component.set('v.faultCodeError',$A.get("$Label.c.Fault_Found_Empty_Error"));
        }else {
            component.set('v.faultCodeError','');
        }
        
        //Retreving the Jobcode based on the Product set - WarrantyProductSetForFaultCode(Warranty Product codes)
        var JobCodeQuery = helper.JobCode_Query  + "'" + component.get("v.claimRecord.Fault_Code__c") + "'";
        console.log('::The In query is for jobcode::');
        console.log(JobCodeQuery);
        
        helper.readDom(component, event, JobCodeQuery, "v.JobCodeList", "v.dmlErrors", function(returnedValues) {
            console.log('Job Code list ');
            console.log(component.get("v.JobCodeList"));
        });
        
    },
    
    findPolicy : function(component, event, helper) {
        event.preventDefault();
        /*
        component.set('v.hasTabErrors',false);
        var claimType	=	component.find("claimtype").get("v.value");
        var isError		=	false;
        console.log('::: Claim Type:',claimType);
        component.set('v.isError',false);
        // Claim Type Error
        if(claimType == 'None' || claimType == '' || typeof claimType == "undefined"){
           	isError = true;
            component.set('v.hasTabErrors',true);
            component.set('v.claimTypeError','Please select a Claim Type');
        } else {
            component.set('v.claimTypeError','');
        }


        var dealer		=	component.get('v.claimRecord.Account__c');
        if(dealer == null || dealer == '' || typeof dealer == "undefined"){
           	isError = true;
            component.set('v.hasTabErrors',true);
            component.set('v.dealorError','Please select Dealer value');
        } else {
            component.set('v.dealorError','');
        }

        var dateofFailure	=	component.get('v.claimRecord.Date_of_Failure__c');
        console.log(':::: Date of failure:'+dateofFailure);
        if(dateofFailure == null || dateofFailure == '' || typeof dateofFailure == "undefined"){
            isError = true;
            component.set('v.hasTabErrors',true);
            component.set('v.dateofFailureError','Please select Date of Failure value');
        }else{
            component.set('v.dateofFailureError','');
        }

        var dateofRepair	=	component.get('v.claimRecord.Date_of_Repair__c');
        console.log(':::: dateofRepair:'+dateofRepair);
        if(dateofRepair == null || dateofRepair == '' || typeof dateofRepair == "undefined"){
            isError = true;
            component.set('v.hasTabErrors',true);
            component.set('v.dateofRepairError','Please select Date of Repair value');
        }else{
            component.set('v.dateofRepairError','');
        }

        if(claimType == 'Serialized_Part'){
            console.log('==inside findpolicy===========');
            var inventoryId	=	component.get('v.claimRecord.Inventory__c');
            console.log('::::: Inventory Id',inventoryId);
            if(inventoryId == null || inventoryId == '' || typeof inventoryId == "undefined"){
                isError = true;
                component.set('v.hasTabErrors',true);
                component.set("v.inventoryError","Please select an Inventory");
            } else {
                component.set("v.inventoryError","");
            }
        }

        if(claimType == 'Non-Serialized'){
            var warrantyId	=	component.get('v.claimRecord.Warranty_Product__c');
            console.log('::::: warrantyId:',warrantyId);
            if(warrantyId == null || warrantyId == '' || typeof warrantyId == "undefined"){
                isError = true;
                component.set('v.hasTabErrors',true);
                component.set("v.warrantyProductError","Please select Warranty Product");
            } else {
                component.set("v.warrantyProductError","");
            }
        }


        if(helper.dateDiff(component.get('v.claimRecord.Date_of_Failure__c'),component.get('v.claimRecord.Date_of_Repair__c')) < 0){
            console.log('-----------Date of failure cant exceed date of repair.--------------');
            component.set("v.isError", true);
            component.set('v.hasTabErrors',true);
            component.set("v.message", "Sorry !! Please check your Date fields.Date of failure can't exceed date of repair.");
            isError = true;
        } */
        console.log('inside find policyyyyyyyy');
        component.set("v.isError", false);
        component.set("v.isSuccess", false);
        
        if(!component.get('v.isClaimTemplate')){
            var hasErrors = helper.findPolicyHandler(component, event, helper);
            console.log(':::: Fault code name value:'+component.get('v.faultCode'));
            console.log(':::: causal part name value:'+component.get('v.causalPartName'));
            console.log('::::: Has Errors:'+hasErrors);
            if(!hasErrors){
                //var action = component.get('c.findSObjectsBySOQL');
                //  action.setParams({"query"  :  "Select Id,Name from Policy_Definition__c LIMIT 1" });
                //action.setCallback(this, function(a) {
                console.log('==inside findpolicy====callback=======');
                // if (action.getState() == "SUCCESS") {
                //component.set("v.claimRecord.Applicable_Policy__c", a.getReturnValue()[0].Id);
                //component.set("v.ApplicablePolicyName",a.getReturnValue()[0].Name);
                //component.set("v.isNext", true);
                component.set("v.isSuccess", true);
                component.set("v.isError", false);
                //component.set("v.message", 'Policy Picked successfully');
                component.set('v.isFaultCodeEnabled',true);
                console.log(component.get("v.claimRecord"));
                //}else if (action.getState() == "ERROR") {
                //  helper.errorHandling(a,action,component);
                //  }
                //});
                //  $A.enqueueAction(action);
            }else{
                return;
            }
        }else{
            return;
        }
        
    },
    
    
    goToclaimFaultCode: function(component, event, helper) {
        event.preventDefault();
        if(!component.get('v.isClaimTemplate'))
            var hasErrors = helper.findPolicyHandler(component,event,helper);
        else {
            var hasErrors = false;
        }
        if(hasErrors){
            
            return;
        } else{
            console.log(':::: No errors:');
            component.set("v.isError", false);
            component.set('v.isFaultCodeEnabled',true);
            console.log(JSON.parse(JSON.stringify(component.get("v.claimRecord"))));
            helper.goToclaimFaultCodeHandler(component,event);
            component.settab(component, event, helper);
            
        }
        
        
        /*
        console.log('------------- in goto2ndtab');
        component.set("v.isError", false);
        component.set("v.isSuccess", false);

        console.log('------------Account-----',component.get('v.claimRecord.Account__c'));
        console.log('------------Inventory__c-----',component.get('v.claimRecord.Inventory__c'));
        console.log('------------Date_of_Failure__c-----',component.get('v.claimRecord.Date_of_Failure__c'));
        console.log('------------Date_of_Repair__c-----',component.get('v.claimRecord.Date_of_Repair__c'));

        today = helper.formatdate('');
        console.log('----------today',today);

        if(component.get('v.claimRecord.Account__c') == undefined || component.get('v.claimRecord.Account__c') == ''){
            component.set("v.isError", true);
            component.set("v.message", "Required field missing Dealer");
        }else if(!component.get('v.isNonSerialized')  && component.get('v.claimRecord.Inventory__c') == undefined || component.get('v.claimRecord.Inventory__c')== ''){
            component.set("v.isError", true);
            component.set("v.message", "Required field missing Inventory");
        }else if(component.get('v.isNonSerialized') && component.get('v.claimRecord.Warranty_Product__c') == undefined || component.get('v.claimRecord.Warranty_Product__c') == ''){   component.set("v.isError", true);
            component.set("v.message", "Required field missing Warranty Product");
        }else if(component.get('v.claimRecord.Date_of_Failure__c') == undefined || component.get('v.claimRecord.Date_of_Failure__c').trim() == ''){
            component.set("v.isError", true);
            component.set("v.message", "Required field missing Date of Failure");
        }else if(component.get('v.claimRecord.Date_of_Repair__c') == undefined || component.get('v.claimRecord.Date_of_Repair__c').trim() == ''){
            component.set("v.isError", true);
            component.set("v.message", "Required field missing Date of Repair");
        }else if(helper.formatdate(component.get('v.claimRecord.Date_of_Failure__c').trim()) > today || helper.formatdate(component.get('v.claimRecord.Date_of_Repair__c').trim()) > today)
        {
            console.log('------failure date greater than today-------');
            component.set("v.isError", true);
            component.set("v.message", "Date of Failure/Repair should not exceed today date.");
        }else if(helper.dateDiff(component.get('v.claimRecord.Date_of_Failure__c'),component.get('v.claimRecord.Date_of_Repair__c')) < 0){
            console.log('-----------Date of failure cant exceed date of repair.--------------');
            component.set("v.isError", true);
            component.set("v.message", "Sorry !! Please check your Date fields.Date of failure can't exceed date of repair.");
        }else
        {
            console.log(component.get("v.claimRecord"));
            component.set("v.isError", false);
            component.set("v.isSuccess", false);
            component.set('v.isNextClicked',true);
            component.set('v.currentTab','1');
            component.set('v.NextTab','2');

            component.settab(component, event, helper);
            component.set("v.isNext", false);
        }*/
        
    },
    cancelclick: function(component,event,helper){
        
        var BaseUrl = component.get('v.BaseURL');
        var claimId = component.get('v.claimId');
        if(claimId != null  && claimId != '')
        {
            if(BaseUrl.indexOf('lightning') !=-1) 
                component.set('v.cancelUrl','/one/one.app#/sObject/'+claimId+'/view');
            else
                component.set('v.cancelUrl','/'+claimId);
        }
        else{
            var action = component.get("c.getclaimPrefix");
            action.setParams({
                
            });
            action.setCallback(this, function(a) {
                console.log('---------------------------------return prefix'+a.getReturnValue());
                var claimPrefix = a.getReturnValue();
                if(BaseUrl.indexOf('lightning') !=-1)                           
                    component.set('v.cancelUrl','/one/one.app#/sObject/'+claimPrefix+'/home');      
                else
                    component.set('v.cancelUrl','/'+claimPrefix+'/o'); 
            });
            $A.enqueueAction(action);
        }
    },
    doInit : function(component, event, helper) { 
        console.log('------------app------------');
        console.log($A);
        component.set("v.FaultCodeList[0].Name",'--------None--------');
        
        //component.set('v.context',$A.getContext().gg);
        if(component.get('v.claimId') != null  && component.get('v.claimId') != '')
        {
            component.set('v.isSaved',false);
            component.set('v.isSaveEnabled',false);
            console.log('----------------------------------edit----claim cmp doinit');
            console.log(component.get('v.claimId'));
            var action1 = component.get('c.findSObjectsBySOQL');
            action1.setParams({
                query : 'Select Id, Name, Applicable_Policy__r.Pricebook_Type__c,RecordTypeId,RecordType.DeveloperName,Delay_Reason__c,'+
                'Units_Run__c,Inventory__r.Units_Run__c,Inventory__r.Item__r.Units_of_Measure__c,Date_Of_Purchase__c,Invoice_Number__c,'+ 
                'RecordType.Name,Service_Ticket__c,Work_order__c, Account__r.Name, Inventory__r.Name, Campaign_Members__r.Name, '+
                'Warranty_Product__r.Name,Fault_Code__r.Name,Fault_Code__r.Description__c, Causal_Part_Number__r.Name,Total_Parts_Cost__c,'+
                'Causal_Part_Number__r.Description__c, Applicable_Policy__r.Name,Account__c,Inventory__c,Warranty_Product__c,Campaign_Members__c,'+
                'Host_NonHost__c,Serial_Number__c,Date_of_Failure__c,Date_of_Repair__c,Applicable_Policy__c,Fault_Code__c,Causal_Part_Number__c,'+
                'Request_SMR__c,Claim_Parts_Pending_Approval__c,SMR_Reason__c,Override_Policy__c,TravelByHours__c,TravelByDistance__c,'+
                'Total_Labor_Cost__c,Final_Labor_Cost__c,Total_TravelByDistance_Cost__c,Final_TravelByDistance_Cost__c,Total_TravelByHours_Cost__c,'+
                'Final_TravelByHours_Cost__c,Final_Parts_Cost__c,Total_Meals_Cost__c,Final_Meals_Cost__c,Caused_by__c,Fault_found__c,'+
                'Total_Parking_Cost__c,Final_Parking_Cost__c,Percent_Labor_Cost__c,Approved_Labor_Cost__c,Percent_TravelByDistance_Cost__c,'+
                'Approved_TravelByDistance_Cost__c,Percent_TravelByHours_Cost__c,Approved_TravelByHours_Cost__c,Percent_Parts_Cost__c,Approved_Parts_Cost__c,'+
                'Percent_Meals_Cost__c,Approved_Meals_Cost__c,Percent_Parking_Cost__c,Approved_Parking_Cost__c,Percent_Claim_Cost__c,Approved_Ignore_Sum__c,'+
                'Final_Claim_Cost__c,Approved_Claim_Cost__c,Description__c,TravelByLocation__c,Fault_Code_Comment__c,CasualPart_Comments__c,'+
                'work_Performed_comments__c from Claim__c Where Id= '+'\''+component.get('v.claimId')+'\''
            });
            action1.setCallback(this, function(response) {
                console.log(response.getReturnValue()[0]);
                component.set('v.claimRecord',response.getReturnValue()[0]);
                var result = response.getReturnValue()[0];
                console.log('-------dsa-----')
                console.log(result);
                if(result.Inventory__c!=null)
                {
                    if(result.Inventory__r.Units_Run__c != null && result.Inventory__r.Units_Run__c != ''
                       && typeof result.Inventory__r.Units_Run__c != "undefined"){
                        component.set('v.InventoryUnitsRun',result.Inventory__r.Units_Run__c);
                    }
                }
                
                if(result.Applicable_Policy__c != null)
                {
                    component.set('v.policyType',result.Applicable_Policy__r.Pricebook_Type__c) 
                }
                
                if(result.Account__c != null && result.Account__c != '' && typeof result.Account__c != "undefined"){
                    component.set('v.dealerName',result.Account__r.Name);
                }
                
                if(result.RecordType.DeveloperName == 'Claim_Template'){
                    component.set('v.isClaimTemplate',true);
                }
                if(result.RecordType.DeveloperName == 'Field_Modification'){
                    console.log(':::: Record type: Field modificaiton');
                    component.set('v.isFieldModification',true);
                }
                if(result.RecordType.DeveloperName == 'Non_Serialized_Part'){
                    console.log(':::: Record type: non serialized');
                    component.set('v.isNonSerialized',true);
                }
                if(result.RecordType.DeveloperName == 'Serialized_Part'){
                    console.log(':::: Record type: Serialized part');
                    component.set('v.isSerialized',true);
                }
                
                if(result.Warranty_Product__c != null && result.Warranty_Product__c != '' && typeof result.Warranty_Product__c != "undefined"){
                    component.set('v.warrantyProductName',result.Warranty_Product__r.Name);
                }
                
                if(result.Inventory__c != null && result.Inventory__c != '' && typeof result.Inventory__c != "undefined"){
                    component.set('v.inventoryName',result.Inventory__r.Name);
                }
                if(result.Fault_Code__c != null && result.Fault_Code__c != '' && typeof result.Fault_Code__c != "undefined"){
                    console.log('fault code not null-------------');
                    component.set('v.faultCode',result.Fault_Code__r.Name);
                }
                if(result.Causal_Part_Number__c != null && result.Causal_Part_Number__c != '' && typeof result.Causal_Part_Number__c != "undefined"){
                    component.set('v.causalPartName',result.Causal_Part_Number__r.Name);
                }
                if(result.Campaign_Members__c != null && result.Campaign_Members__c != '' && typeof result.Campaign_Members__c != "undefined"){
                    component.set('v.campaignMembers',result.Campaign_Members__r.Name);
                }
                if(result.Applicable_Policy__c != null && result.Applicable_Policy__c != '' && typeof result.Applicable_Policy__c != "undefined"){
                    component.set('v.policyName',result.Applicable_Policy__r.Name);
                }
                console.log('--------------------------claim record');
                console.log(component.get('v.claimRecord'));
                //component.set('v.isShowApprovalTab',false);
                component.set('v.isServiceInfoActivated',true);
                //helper.invisible(component,'SpinnerDiv');
                //helper.visible(component,'ContainerDiv');
                //component.set('v.isChanged',false);
            });
            $A.enqueueAction(action1);
            
        }
        
        var action = component.get('c.checkSystemAdmin');
        action.setParams({ });
        action.setCallback(this, function(response) {
            console.log('::::user profile: response:');
            console.log(response.getReturnValue());
            
            if(response.getReturnValue()=='Warranty Partner') {
                console.log('-----------------wp-----------');
                component.set('v.isDealer',true);
                
                var action2 = component.get('c.selectDealerAccount');
                action2.setParams({ });
                action2.setCallback(this, function(response) {
                    console.log('-----------------------'+response.getReturnValue());
                    console.log(response.getReturnValue());
                    component.set('v.dealerAccount',response.getReturnValue().Id);
                    component.set('v.dealerName',response.getReturnValue().Name);
                    component.set('v.claimRecord.Account__c',response.getReturnValue().Id);
                    console.log(component.get('v.dealerAccount'));
                    console.log(component.get('v.dealerName'));
                });
                $A.enqueueAction(action2);
                
            } else {
                component.set('v.isDealer',false);
            }
            
            var ProcessorProfile = $A.get("$Label.c.ApprovalEligibleProfiles");
            if(response.getReturnValue()== ProcessorProfile) {
                component.set('v.DisplayApprovalTab',true);
            }
            else {
                component.set('v.DisplayApprovalTab',false);
            }
            
        });
        $A.enqueueAction(action);
        console.log('----'+component.get('v.claimId')+'-----');
        console.log(component.get('v.claimRecord'));
        if(component.get('v.claimId') != null && component.get('v.claimId') != ''){
            component.set('v.isServiceInfoActivated',true);
            $A.util.addClass(component.find('li-tab-1'), 'activeTabColor');
            for (var i=2; i<= 6 ; i++) {
                console.log('----------------'+i);
                $A.util.removeClass(component.find('li-tab-'+i), 'activeTabColor');
                $A.util.addClass(component.find('li-tab-'+i), 'TabColor');
            }
        }
        //component.set('v.cancelUrl',document.referrer);
        
        
        
        /*if(window.location.href.indexOf('lightning') > -1 && component.get('v.cancelUrl').indexOf(component.get('v.claimId')) == -1)
        {
            console.log('--------------------in lightning');
            component.set('v.cancelUrl',window.location.href+'/'+component.get('v.claimId'));
            console.log(component.get('v.cancelUrl'));
        }*/
        
        console.log(':::: is non serialized:'+component.get('v.isNonSerialized'));
        
        var action1 	= 	component.get('c.findSObjectsBySOQL');
        action1.setParams({
            "query" : "SELECT DeveloperName,Id,Name FROM RecordType WHERE SobjectType = 'Claim__c' ORDER BY DeveloperName DESC"
        });
        action1.setCallback(this, function(response) {
            console.log(':::: Response from server record types:');
            console.log(response.getReturnValue());
            component.set("v.claimrecordTypes",response.getReturnValue());
            //component.set('v.isEnableModal',false);
        });
        $A.enqueueAction(action1);
    },
    
    validateClaim : function(component, event, helper){
        console.log('--------------------Claim Record----');
        console.log(JSON.parse(JSON.stringify(component.get('v.claimRecord'))));
        
        helper.visible(component,'TabSpinnerDiv');
        helper.invisible(component,'TabDiv');
        helper.updateClaimRecord(component, event, helper);
        console.log('--------------------inside validate clicked 3333');
        console.log(component.get('v.claimRecord'));
        helper.validateClaimRecord(component, event,helper);
        console.log('--------------------inside validate clicked 444444444');
        console.log(component.get('v.claimRecord'));
        $A.util.addClass(component.find('li-tab-6', 'TabColor'));
        //$A.util.addClass(component.find('li-tab-6', 'slds-show'));
        console.log('--------------------inside validate clicked 555555');
        helper.invisible(component,'TabSpinnerDiv');
        helper.visible(component,'TabDiv');
    },
    
    
    
    submitClaim	: function(component, event, helper){
        helper.submitClaimRecord(component, event);
    }
})