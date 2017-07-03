({
    sobjectType:'',
    selectedInventoriesSize :'',
    currentRegisterInventory :'',
    registerInventoriesSize:'',
    currentInventory :'',
    inventoryWithPolicies:[],
    selectedPoliciesCount:0,
    isRegisterWR:true,

    formatdate : function(dateModify) {
        if(dateModify == '')
            var dateModify = new Date();
        else
            var dateModify = new Date(dateModify);

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

        return dateModify;
    },
    validateInputs:	function(component,event,helper){
        var isError	=	false;
        var today = helper.formatdate('');

        var dateOfIntalldate	=	component.get('v.inventoryInstallDate');

        if(dateOfIntalldate == null || dateOfIntalldate == '' || typeof dateOfIntalldate == "undefined"){
            isError = true;
            component.set('v.message',$A.get('$Label.c.Purchase_Date_Warranty_Registration_Error'));
        }else if(helper.formatdate(dateOfIntalldate) > today ){
            isError = true;
            component.set('v.message',$A.get('$Label.c.Purchase_Date_Warranty_Registration_Error'));
        }

        var customerId	=	component.get('v.customer.Id');

        if(customerId == null || customerId == '' || typeof customerId == "undefined"){
            isError = true;
            component.set('v.message',$A.get('$Label.c.Please_Select_customer'));
        }

        return isError;
    },

    addInventorywithpolicies : function(component, event, helper){

        if(helper.selectedInventoriesSize > 0 && helper.inventoryWithPolicies.indexOf(component.get('v.selectedInventories')[helper.currentInventory].Id) == '-1'){
            var isWRCreated = component.get('v.isWRCreated');
            component.set('v.CurrentInventory',component.get('v.selectedInventories')[helper.currentInventory]);
            //var CurrentInventory = component.get('v.CurrentInventory');
            var CurrentInventoryDetails = component.get('v.CurrentInventoryDetails');
            var CurrentInv = component.get('v.selectedInventories')[helper.currentInventory];
            var installdate = component.get('v.inventoryInstallDate');
            var isDeleted = component.get('v.isDeleted');
            component.set('v.isSearchPolicyClicked',true);
            helper.createWarrantyRegistrationhelper(component,isWRCreated,CurrentInv,CurrentInventoryDetails,installdate,helper);
        }else if(helper.selectedInventoriesSize > 0){
            helper.currentInventory++;
            helper.selectedInventoriesSize--;
            helper.addInventorywithpolicies(component, event, helper);
        }else if(helper.selectedInventoriesSize == 0){
            component.set('v.isSearchPolicyExecuting',false);
        }

    },

    createWarrantyRegistrationhelper : function(component,isWRCreated,CurrentInventory,CurrentInventoryDetails,installdate,helper){

        var installdate=new Date(installdate);
        var month = installdate.getMonth()+1;
        var date = installdate.getDate();
        var  year = installdate.getFullYear();
        var installstringdate = date+'/'+month+'/'+year;

        var existingWRrecordId = component.get('v.wrExistingId');

        var  InventoryCustomer =  component.get('v.customer.Id');
        var action = component.get("c.createWarrantyRegistration");
        var preOwnedFlag = component.get('v.preowned');
        var typeofregistration  = component.get('v.type');
        if(existingWRrecordId==''){
            existingWRrecordId=null;
        }
        var usegetypeValue = component.get('v.usageType');


        var currentUsage = component.get('v.unitUsageOnPage');
        // Add to send inventory record details.
        var invObject = {
            "Id" : CurrentInventory.Id,
            "Name" : CurrentInventory.Name,
            "Account__c" : CurrentInventory.Account__c,
            "Item__c" : CurrentInventory.Item__c,
            "Serial_Number__c" : CurrentInventory.Serial_Number__c,
            //"Units_Run__c" : CurrentInventory.Units_Run__c
            "Units_Run__c" : currentUsage
        };



        action.setParams({
            "isWRCreated"						:	isWRCreated ,
            "CurrentInventory"					:	invObject,
            "CurrentInventoryDetails"			:	CurrentInventoryDetails,
            "InstDate"							:	installstringdate,
            "WRID"							    :	existingWRrecordId,
            "WRUsageType"						:	usegetypeValue,
            "InventoryCustomer"					:	InventoryCustomer
        });
        if(preOwnedFlag == true && typeofregistration == 'Standard' ) {
            var CurrentInv = component.get('v.CurrentInventory');
            var isDeleted = component.get('v.isDeleted');
            helper.fetchPolicyDefinitionsMngrhelper(component,isDeleted,CurrentInv,helper);
        }
        else{
            action.setCallback(this, function(a) {

                if(a.getReturnValue() != null){
                    if(a.getReturnValue()[0].error == null){
                        component.set('v.isError',false);
                        component.set('v.WarrantyRegistration',a.getReturnValue()[0].WarrantyRegistration);

                        var CurrentInv = component.get('v.CurrentInventory');
                        var isDeleted = component.get('v.isDeleted');
                        helper.fetchPolicyDefinitionsMngrhelper(component,isDeleted,CurrentInv,helper);
                    }else{
                        var errorMessage = a.getReturnValue()[0].error;
                        component.set('v.message',errorMessage);
                        component.set('v.isError',true);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    fetchPolicyDefinitionsMngrhelper: function(component,isDeleted,CurrentInventory,helper){

        var sObjList = CurrentInventory;
        var fieldLe = component.get("v.fieldArr").length;
        var fieldAr = component.get("v.fieldArr");
        var WR = component.get('v.WarrantyRegistration');
        var preOwnedFlag = component.get('v.preowned');
        var typeofregistration  = component.get('v.type');
        //helper.constructTable(component,helper,sObjList,fieldLe,fieldAr,'tInventorywithpolicy','Inventory');

        var action = component.get("c.fetchPolicyDefinitionsMngr");
        action.setParams({
            "isDeleted"		:	isDeleted ,
            "newWR"		:	component.get('v.WarrantyRegistration'),
            "preowned"   : preOwnedFlag,
            "inventoryId" : CurrentInventory[0].Id,
            "regType" : typeofregistration
        });
        action.setCallback(this, function(a) {

            var policyresponse = a.getReturnValue()[0].PolicyDefWrapper;

            //get the type of Warranty registration
            var type = component.get('v.type');

            //if no error
            if(a.getReturnValue().error == null){
                component.set('v.isError',false);
                component.set('v.PolicyDefinitionWrapperList',a.getReturnValue()[0].PolicyDefWrapper);
                var poclicyfatchallPolicy =  a.getReturnValue()[0].PolicyDefWrapper;
                var polciylistwer = [];

                polciylistwer = poclicyfatchallPolicy.filter(function(a){
                    if(type=='Goodwill'){
                        if(a['ObjPolicyDefinition']['Type__c']==='Standard' || a['ObjPolicyDefinition']['Type__c']==='Goodwill'){
                            return a;
                        }
                    }else{
                        if(a['ObjPolicyDefinition']['Type__c']==type){
                            return a;
                        }
                    }
                });

                component.set('v.PolicyDefinitionWrapperListclon',polciylistwer);
                var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
                mapInventoryPolicies[CurrentInventory[0].Id] = component.get('v.PolicyDefinitionWrapperListclon');
                component.set('v.mapInventoryPolicies',mapInventoryPolicies);


                var sObjectList = mapInventoryPolicies[CurrentInventory[0].Id];
                component.set("v.PolicyList", sObjectList);
                component.set("v.PolicyListCount", sObjectList.length);

                component.set('v.showPolicySpinner',false);


            }else{
                var errorMessage = a.getReturnValue()[0].error;
                component.set('v.message',errorMessage);
                component.set('v.isError',true);
            }

            // disable the checkbox of default policy.
            //this.defaultPolicies(component, helper);
            this.onclickCheckboxHelper(component, helper);

            component.set('v.showPolicySpinner',false);
        });
        $A.enqueueAction(action);
    },

    defaultPolicies: function(component, helper){
        var policyList = component.get("v.PolicyList");
        var registerButton = component.find('registerBtn');

        for(var i=0; i<policyList.length; i++){
            if(policyList[i].selected){

            }
        }
    },

    onclickCheckboxHelper : function(component, helper) {
        var registerButton = component.find('registerBtn');
        var policies = component.get('v.PolicyList');
        var count = 0;

        for(var i=0; i<policies.length; i++){
            if(policies[i].selected){
                count = count + 1;
            }
        }

        if(count != 0){
            $A.util.removeClass(registerButton, 'BtnCSS');
        }
        else{
            if(!$A.util.hasClass(registerButton, 'BtnCSS'))
                $A.util.addClass(registerButton, 'BtnCSS');
        }

        component.set('v.selectedPoliciesCount', count);
    },

    registerInventoryHelper: function(component, helper){

        var registerInventoriesSize = helper.registerInventoriesSize;
        var currentRegisterInventory = helper.currentRegisterInventory;
        var selectedInventories = component.get('v.selectedInventories');
        var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
        var mapInventories = component.get('v.mapInventories');
        var InventoryCustomer = component.get('v.customer.Id');

        if(registerInventoriesSize != '0' && currentRegisterInventory < registerInventoriesSize){

            if(mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id].length > 0 && typeof mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id] != 'undefined'){

                var policyDef = mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id];
                //var CurrentInventory = mapInventories[selectedInventories[currentRegisterInventory].Id];
                var CurrentInventory = component.get('v.inventoryForDate');
                var currentUsage = component.get('v.unitUsageOnPage');
                // Add to send inventory record details.
                var invObject = {
                    "Id" : CurrentInventory.Id,
                    "Name" : CurrentInventory.Name,
                    "Account__c" : CurrentInventory.Account__c,
                    "Item__c" : CurrentInventory.Item__c,
                    "Serial_Number__c" : CurrentInventory.Serial_Number__c,
                    //"Units_Run__c" : CurrentInventory.Units_Run__c
                    "Units_Run__c" :currentUsage
                };


                var CurrentInventoryDetails = component.get('v.CurrentInventoryDetails');

                var installdate = component.get('v.inventoryInstallDate');
                installdate=new Date(installdate);
                var month = installdate.getMonth()+1;
                var date = installdate.getDate();
                var  year = installdate.getFullYear();
                var installstringdate = date+'/'+month+'/'+year;
                var existingWRrecordId = component.get('v.wrExistingId');

                var action = component.get("c.registerInventory");
                if(existingWRrecordId == ''){
                    existingWRrecordId = null;
                }

                var usegetypeValue = component.get('v.usageType');


                var coverageEndDate = component.get('v.coverageEndDate');
                var type=component.get('v.type');

                if(coverageEndDate!=null && type!='Goodwill'){
                    coverageEndDate = null;
                }else if(coverageEndDate!=null){
                    coverageEndDate = new Date(component.get('v.coverageEndDate'));
                    coverageEndDate = (coverageEndDate.getMonth()+1) + '/' + (coverageEndDate.getDate()) + '/' +coverageEndDate.getFullYear();
                    alert('...............'+JSON.stringify(coverageEndDate));
                }

                action.setParams({
                    "PolicyDefinitionList"				:	JSON.stringify(policyDef) ,
                    "CurrentInventoryDetails"			:	CurrentInventoryDetails,
                    "CurrentInventory"					:	invObject,
                    "InstDate"							:	installstringdate,
                    "WRID"							    :	existingWRrecordId,
                    "WRUsageType"						:	usegetypeValue,
                    "InventoryCustomer"				    :	InventoryCustomer,
                    "coverageEndDate"					:	coverageEndDate
                });
                action.setCallback(this, function(a) {
                    if(a.getReturnValue() != null){
                        if(a.getReturnValue()[0].error == null){
                            component.set('v.isError',false);
                            helper.currentRegisterInventory++;
                            helper.registerInventoryHelper(component, helper);
                        }
                        else{
                            var errorMessage = a.getReturnValue()[0].error;
                            component.set('v.registrationErrorMessage',errorMessage);
                            component.set('v.isRegistrationError',true);
                        }
                    }else{
                        component.set('v.isRegistrationError',false);
                        helper.currentRegisterInventory++;
                        helper.registerInventoryHelper(component, helper);
                    }
                });
                $A.enqueueAction(action);

            }else{

                helper.currentRegisterInventory++;
                helper.registerInventoryHelper(component, helper);
            }
        }else{

            var ProceedURL = '';
            var BaseUrl = component.get('v.BaseURL');
            var InventoryId	=	component.get('v.inventoryId');
            if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined')
            {
                if(BaseUrl.indexOf('lightning') !=-1)
                    ProceedURL = "/one/one.app#/sObject/"+InventoryId+'/view';
                else
                    ProceedURL = BaseUrl+"/"+InventoryId;
            }
            else{
                if(BaseUrl.indexOf('lightning') !=-1)
                    ProceedURL = "/one/one.app#/sObject/"+InventoryId+'/view';
                else
                    ProceedURL = "/"+InventoryId;
            }

            window.open(ProceedURL,'_self');
        }
    },

    newAccountObject: function(component, helper){
        var formNewAccount={
            sobjectType : 'Account',
            Name : null,
            ShippingState: null,
            ShippingStreet: null,
            ShippingCountry: null,
            ShippingPostalCode: null,
            Phone : null,
            Email__c : null,
            Website : null,
            Warranty_Account_Type__c : 'Customer'
        };
        component.set('v.formNewAccount',formNewAccount);
    },

    /***alert box helper method***/
    showAlert: function(component, event, alertboxContent) {

        // create dynamic alert box with some initializations
        var self = this;
        var test;
        $A.createComponent(
            "c:AlertboxCmp", {
                message: alertboxContent.message,
                heading: alertboxContent.heading,
                class: alertboxContent.class,
                onOkay: alertboxContent.callableFunction,
                onSecondaryOkay: alertboxContent.secondaryCallableFunction,
                buttonHeading: alertboxContent.buttonHeading,
                secondaryButtonHeading: alertboxContent.secondaryButtonHeading
            },
            function(alertbox) {


                if (alertbox !== undefined && alertbox !== null && alertbox.isValid()) {
                    var body = [];
                    body.push(alertbox);
                    if (!alertbox.isInstanceOf("c:AlertboxCmp")) {
                        component.set("v.body", []);

                    } else {
                        component.set("v.body", body);
                    }

                }
            }

        );

    },
    getTodayDate: function(component, event) {

        var timezone = $A.get("$Locale.timezone");
        var todayDateString = '';
        var self = this;

        $A.localizationService.getToday(timezone, function(today) {
            todayDateString = today;
            todayDateString = self.getDateReadableFormat(todayDateString);
            return todayDateString;
        });
        return todayDateString;

    },


    /****Validation checker method********/
    validationSuccesStatus: function(component,event){

        var finalStatus = false;
        var temporaryStatusObject = {};
        var self = this;
        //unitUsage check
        if(component.get('v.error.fieldError.unitUsage')!==''){
            temporaryStatusObject.unitUsage = false;
        }else{

            var unitUsageValue = parseFloat(component.get('v.unitUsageOnPage'));
            var inventoryUnitsUsage = parseFloat(component.get('v.inventoryForDate.Units_Run__c'));
            var error = JSON.parse(JSON.stringify(component.get('v.error')));



            if(!isNaN(unitUsageValue) && !isNaN(inventoryUnitsUsage)){

                if(unitUsageValue<0){

                    component.set('v.error.fieldError.unitUsage',$A.get('$Label.c.Units_Run_Negative'));
                    temporaryStatusObject.unitUsage = false;

                }else{

                    if(unitUsageValue < inventoryUnitsUsage){
                        component.set('v.error.fieldError.unitUsage',$A.get('$Label.c.Units_Run_Less_Than_Inventory') +inventoryUnitsUsage);
                        temporaryStatusObject.unitUsage = false;
                    }else{
                        component.set('v.error.fieldError.unitUsage','');
                        temporaryStatusObject.unitUsage = true;
                    }

                }

            }else{
                if(!isNaN(unitUsageValue) && unitUsageValue<0){
                    component.set('v.error.fieldError.unitUsage',$A.get('$Label.c.Units_Run_Negative'));
                    temporaryStatusObject.unitUsage = false;
                }else{
                    component.set('v.error.fieldError.unitUsage','');
                    temporaryStatusObject.unitUsage = true;
                }

            }

        }

        //purchase date and coverage end date error
        if(error.fieldError.purchaseDate!==''  || error.fieldError.coverageEndDate!==''){
            temporaryStatusObject.datesError = false;
        }else{
            temporaryStatusObject.datesError = true;
        }

        finalStatus = self.analyseTempValidation(temporaryStatusObject);

        return finalStatus;


    },
    analyseTempValidation: function(temporaryValidationObject) {

        var validationSuccess = true;

        for (var key in temporaryValidationObject) {
            if (temporaryValidationObject[key] === false) {
                validationSuccess = false;
                break;
            }
        }
        return validationSuccess;

    },
    updateCoverages : function(component,event,helper,coveragesList) {
        var CurrentInv = JSON.parse(JSON.stringify(component.get('v.CurrentInventory')));
        CurrentInv = JSON.stringify(CurrentInv[0]);
        var customerId = component.get('v.customerId');
        var action = component.get("c.updateCoverages");
        action.setParams({
            coveragesList :coveragesList,
            currentInventory : CurrentInv,
            customerId: customerId
        });
        action.setCallback(this, function(coveragesresponse) {
            var state = coveragesresponse.getState();           
            if(state === "SUCCESS" && component.isValid()) {
                var response = coveragesresponse.getReturnValue();
                if(response == true) {
                    var ProceedURL = '';
                    var BaseUrl = component.get('v.BaseURL');
                    var InventoryId	=	component.get('v.inventoryId');
                    if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined')
                    {
                        if(BaseUrl.indexOf('lightning') !=-1)
                            ProceedURL = "/one/one.app#/sObject/"+InventoryId+'/view';
                        else
                            ProceedURL = BaseUrl+"/"+InventoryId;
                    }
                    else{
                        if(BaseUrl.indexOf('lightning') !=-1)
                            ProceedURL = "/one/one.app#/sObject/"+InventoryId+'/view';
                        else
                            ProceedURL = "/"+InventoryId;
                    }

                    window.open(ProceedURL,'_self');
                }

                else {

                    console.log('Error Occured');
                }
            }

        }); 
        $A.enqueueAction(action);
    },
    getDateReadableFormat: function(dateString) {

        var returnableDateString = "";
        var convertableDate = new Date(dateString);
        var dateString = convertableDate.getDate() + "";
        var monthString = (convertableDate.getMonth() + 1) + "";
        if (dateString.length === 1) {
            dateString = "0" + dateString;
        }
        if (monthString.length === 1) {
            monthString = "0" + monthString;
        }
        returnableDateString = convertableDate.getFullYear() + "-" + monthString + "-" + dateString;

        return returnableDateString;
    },
    
    registrableCheck : function(component,pageBlockerBooleanObject){

        var message='';
        var type= component.get("v.type");

        if(pageBlockerBooleanObject['isScrappedOrStolen']==true){
            message = $A.get("$Label.c.Page_Blocker_Message");
        }
        else if(pageBlockerBooleanObject['visualCheckListNotcompleted']==true){
            message = $A.get("$Label.c.Visual_Checklist_Alert")
        }

        if(type=='Extended'){
            var todayDate = new Date();
            var inventoryPurchaseDate = component.get('v.inventoryPurchaseDate');
            var enableExtended = component.get('v.EnabledExtened');                      
            if(enableExtended == true){
                $A.localizationService.getDateStringBasedOnTimezone($A.get("$Locale.timezone"), todayDate, function(today){                    
                    todayDate = new Date(today);
                    var allowableDifferenceInDays =  parseInt($A.get('$Label.c.Extended_Registration_Maximum_Days'));
                    var timeDiff = Math.abs(new Date(todayDate) - new Date(inventoryPurchaseDate));
                    var diffBetweenInstalledAndToday = Math.ceil(timeDiff / (1000 * 3600 * 24));
                    if(diffBetweenInstalledAndToday > allowableDifferenceInDays){
                        message = $A.get('$Label.c.Extended_Warranty_Registration_Max_Days_Exceeded');
                    }else{
                        message = '';
                    }
                    component.set('v.pageBlockerMessage', message);
    
                });
            }
        }

        return message;


    },
    
    getEnableExtended : function(component,pageBlockerBooleanObject){
        var enableExtened = false;
        var action=component.get("c.EnableExtendedRegistrationLogic"); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){                             
                enableExtened = response.getReturnValue();                                
            	component.set('v.EnabledExtened',response.getReturnValue()); 
                this.registrableCheck(component,pageBlockerBooleanObject);  
            }
        });$A.enqueueAction(action);
        
    }

})