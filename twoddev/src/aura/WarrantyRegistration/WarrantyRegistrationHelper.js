({
    tbodyName :'',
    sobjectType:'',
    outputType :'',
    selectedInventoriesSize :'',
    currentRegisterInventory :'',
    registerInventoriesSize:'',
    currentInventory :'',
    inventoryWithPolicies:[],
    deleteTabIndex:'0',
    selectedInventoryId:'',
    tInventorywithpolicyInv:'',
    
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
    
    validateInputs:	function(component,event,helper){
        var isError	=	false;
        var today = helper.formatdate('');
        
        var dateOfIntalldate	=	component.get('v.inventoryInstallDate');
        console.log('::::  dateOfIntalldate:'+dateOfIntalldate);
        
        if(dateOfIntalldate == null || dateOfIntalldate == '' || typeof dateOfIntalldate == "undefined"){
            isError = true;
            component.set('v.message','Please select Purchase date value');
        }else if(helper.formatdate(dateOfIntalldate) > today ){
            isError = true;
            component.set('v.message','Purchase date cannot exceed today');
        }
        
        var customerId	=	component.get('v.customer.Id');
        console.log('::::  customerId:'+customerId);
        if(customerId == null || customerId == '' || typeof customerId == "undefined"){
            isError = true;
            component.set('v.message','Please select customer');
        }
        
        return isError;
    },
    
    constructMultipleInventoriesTable:	function(component,event,helper){
        var allFieldsToQuery = component.get('v.allFieldsToQuery');
        var inventoryId = component.get('v.selectedInventoryId');
        var fields = component.get('v.allFieldsToQuery');
        console.log('-----helper.lstSelectedInventories----'+inventoryId+'-------------'+component.get('v.lstSelectedInventories'));
        var lstSelectedInventories = component.get('v.lstSelectedInventories');
        var lstInventories = component.get('v.selectedInventories');
        if(lstSelectedInventories.indexOf(inventoryId) == '-1'){
            var query = 'SELECT ' + fields+ ' FROM Inventory__c Where Id='+ '\'' + component.get('v.selectedInventoryId') + '\'';
            console.log('-------- query current inv--------'+query);
            helper.readDom(component, event, query, 'v.selectedInventory', 'v.dmlErrors', function(response){
                console.log('----------response inventory------------');
                console.log(response);
                var myEvent = $A.get("e.c:InventoryDelete");
                myEvent.fire();
                helper.addSelectedInventoryBlock(component, event, helper);
            });
            
            
        }
    },
    
    fetchInventory	:	function(component,event,helper){
        // fetch fieldset data of inventory to display on the page
        var action = component.get("c.fieldstodisplay");
        console.log('------------------- action-----------'+action);
        action.setParams({
        });
        action.setCallback(this, function(a) {
            console.log('------------------- inside wr cmp-------------');
            console.log(a.getReturnValue());
            component.set('v.inventoryfieldset',a.getReturnValue());
            
            // form string to query fieldset fields related to inventory
            var fieldsfromFieldset = '';
            
            if(component.get('v.inventoryfieldset').length -1 > 0){
                for(var i=0; i< component.get('v.inventoryfieldset').length; i++){
                    // fieldsfromFieldset is to add into query and looping to display
                    if(i != component.get('v.inventoryfieldset').length-1)
                        fieldsfromFieldset += component.get('v.inventoryfieldset')[i].apiName +',';
                    else if(i == component.get('v.inventoryfieldset').length-1)
                        fieldsfromFieldset += component.get('v.inventoryfieldset')[i].apiName ;
                    console.log(fieldsfromFieldset);
                    // if field type is reference add field apiname and refrence name to map.
                    var refrencefieldstoQuery = '';
                    if(component.get('v.inventoryfieldset')[i].type == 'REFERENCE')
                    {
                        var mapFieldApi_Reference = component.get("v.mapFieldApi_Reference");
                        mapFieldApi_Reference[component.get('v.inventoryfieldset')[i].apiName] = component.get('v.inventoryfieldset')[i].RelationShipName;
                        component.set('v.mapFieldApi_Reference',mapFieldApi_Reference);
                        
                        // add relationship fields to query but not to display on screen
                        
                        if(i != component.get('v.inventoryfieldset').length-1)
                            refrencefieldstoQuery += component.get('v.inventoryfieldset')[i].RelationShipName +',';
                        else if(i == component.get('v.inventoryfieldset').length-1)
                            refrencefieldstoQuery += component.get('v.inventoryfieldset')[i].RelationShipName ;
                        
                    }
                }
                component.set('v.fieldArr',fieldsfromFieldset.split(','));
            }
            // query other inventory fields which are not to display but necessary
            if(refrencefieldstoQuery == '')
                var fields = component.get('v.additionalFields') +','+ fieldsfromFieldset;
            else
                var fields = component.get('v.additionalFields') +','+ fieldsfromFieldset +','+ refrencefieldstoQuery ;
            
            console.log(fields);
            component.set('v.allFieldsToQuery',fields);
            var query = 'SELECT ' + fields+ ' FROM Inventory__c Where Id='+ '\'' + component.get('v.inventoryId') + '\'';
            console.log('mitul query');
            console.log(query);
            helper.readDom(component, event, query, 'v.Inventory', 'v.dmlErrors', function(response){
                console.log('----------response inventory------------');
                console.log(response);
                component.set('v.inventoryForDate',response[0]);
                var installdate = component.get('v.inventoryForDate.Install_Date__c');
                component.set('v.inventoryInstallDate',installdate);
                var inventories = component.get('v.selectedInventories');
                inventories.push(response[0]);
                component.set('v.selectedInventories',inventories);
                helper.createInventoryBlock(component, event, helper);
                helper.fetchCustomerData(component, event, helper);
            });
            
        });
        $A.enqueueAction(action);
        
        /* ------------------- fetch policy fieldset----------------------------*/
        
        var action1 = component.get("c.policydefFields");
        action1.setParams({
        });
        action1.setCallback(this, function(a) {
            console.log('------------------- inside wr cmp-------------');
            console.log(a.getReturnValue());
            component.set('v.policyfieldset',a.getReturnValue());
            
            // form string to query fieldset fields related to inventory
            var policyfieldsfromFieldset = '';
            if(component.get('v.policyfieldset').length-1 > 0){
                for(var i=0; i< component.get('v.policyfieldset').length; i++){
                    // policyfieldsfromFieldset is to add into query and looping to display
                    if(i != component.get('v.policyfieldset').length-1)
                        policyfieldsfromFieldset += component.get('v.policyfieldset')[i].apiName +',';
                    else if(i == component.get('v.policyfieldset').length-1)
                        policyfieldsfromFieldset += component.get('v.policyfieldset')[i].apiName ;
                    console.log('--------------- policy fields apinames----------------');
                    console.log(policyfieldsfromFieldset);
                    // if field type is reference add field apiname and refrence name to map.
                    if(component.get('v.policyfieldset')[i].type == 'REFERENCE')
                    {
                        var mapPolicyFieldApi_Reference = component.get("v.mapPolicyFieldApi_Reference");
                        mapPolicyFieldApi_Reference[component.get('v.policyfieldset')[i].apiName] = component.get('v.policyfieldset')[i].RelationShipName;
                        component.set('v.mapPolicyFieldApi_Reference',mapPolicyFieldApi_Reference);
                    }
                }
                component.set('v.policyFieldArr',policyfieldsfromFieldset.split(','));
            }
        });
        $A.enqueueAction(action1);
    },
    
    addInventorywithpolicies : function(component, event, helper){
        console.log('inside addinventorywithpolicies');
        console.log('--------remaining inventories-------'+helper.selectedInventoriesSize);
        console.log('--------current inventory------'+helper.currentInventory);
        console.log(helper.inventoryWithPolicies);
        
        if(helper.selectedInventoriesSize > 0 && helper.inventoryWithPolicies.indexOf(component.get('v.selectedInventories')[helper.currentInventory].Id) == '-1'){
            var isWRCreated = component.get('v.isWRCreated');
            component.set('v.CurrentInventory',component.get('v.selectedInventories')[helper.currentInventory]);
            //var CurrentInventory = component.get('v.CurrentInventory');
            var CurrentInventoryDetails = component.get('v.CurrentInventoryDetails');
            var CurrentInv = component.get('v.selectedInventories')[helper.currentInventory];
            var installdate = component.get('v.inventoryInstallDate');
            var isDeleted = component.get('v.isDeleted');
            component.set('v.isSearchPolicyClicked',true);
            helper.createWarrantyRegistrationhelper(component,isWRCreated,CurrentInv,CurrentInventoryDetails,installdate,helper,event,function(response){
                if(helper.selectedInventoriesSize == 0){
                    component.set('v.isSearchPolicyExecuting',false);
                    component.set('v.isRegisterDisabled',false);
                    if( typeof document.getElementsByClassName('delete-Icon-E-D') != 'undefined'){
                        for(var i=0;i< document.getElementsByClassName('delete-Icon-E-D').length;i++){
                            document.getElementsByClassName('delete-Icon-E-D')[i].style.display='block';
                        }
                    }
                }
            });
        }else if(helper.selectedInventoriesSize > 0){
            
            helper.currentInventory++;
            helper.selectedInventoriesSize--;
            helper.addInventorywithpolicies(component, event, helper);
            
        }else if(helper.selectedInventoriesSize == 0){
            
            component.set('v.isSearchPolicyExecuting',false);
            component.set('v.isRegisterDisabled',false);
            if( typeof document.getElementsByClassName('delete-Icon-E-D') != 'undefined'){
                for(var i=0;i< document.getElementsByClassName('delete-Icon-E-D').length;i++){
                    document.getElementsByClassName('delete-Icon-E-D')[i].style.display='block';
                }
            }
        }
        
    },
    
    createInventoryBlock : function(component, event, helper){
        console.log(component.get('v.Inventory'));
        var sObjectList = component.get("v.Inventory");
        var fieldLen = component.get("v.fieldArr").length;
        var fieldArr = component.get("v.fieldArr");
        console.log('---fieldArr---'+fieldArr);
        console.log('---fieldLen---'+fieldLen);
        helper.constructTable(component,helper,sObjectList,fieldLen,fieldArr,'tbody','Inventory');
    },
    
    addSelectedInventoryBlock: function(component, event, helper){
        console.log(component.get('v.selectedInventory'));
        var sObjectList = component.get("v.selectedInventory");
        var fieldLen = component.get("v.fieldArr").length;
        var fieldArr = component.get("v.fieldArr");
        var inventoryId = helper.selectedInventoryId;
        var lstSelectedInventories = component.get('v.lstSelectedInventories');
        var lstInventories = component.get('v.selectedInventories');
        console.log('------inside addselectedinv ------------- '+inventoryId);
        lstSelectedInventories.push(inventoryId);
        lstInventories.push(component.get('v.selectedInventory')[0]);
        component.set('v.lstSelectedInventories',lstSelectedInventories);
        component.set('v.selectedInventories',lstInventories);
        helper.constructTable(component,helper,sObjectList,fieldLen,fieldArr,'tSelectedInventoryBody','Inventory');
    },
    
    createWarrantyRegistrationhelper : function(component,isWRCreated,CurrentInventory,CurrentInventoryDetails,installdate,helper,event,callback){
        console.log('-------- inside create wr helper '+installdate);
        var installdate=new Date(installdate);
        var month = installdate.getMonth()+1;
        var date = installdate.getDate();
        var  year = installdate.getFullYear();
        var installstringdate = date+'/'+month+'/'+year;
        console.log(installstringdate);
        var existingWRrecordId = component.get('v.wrExistingId');
        console.log('---existingWRrecordId---'+existingWRrecordId);
        var  InventoryCustomer =  component.get('v.customer.Id');
        var action = component.get("c.createWarrantyRegistration");
        if(existingWRrecordId==''){
            existingWRrecordId=null;
        }
        var usegetypeValue = component.get('v.usageType');
        console.log('---usegetypeValue---'+usegetypeValue)
        
        action.setParams({
            "isWRCreated"						:	isWRCreated ,
            "CurrentInventory"					:	CurrentInventory,
            "CurrentInventoryDetails"			:	CurrentInventoryDetails,
            "InstDate"							:	installstringdate,
            "WRID"							    :	existingWRrecordId,
            "WRUsageType"						:	usegetypeValue,
            "InventoryCustomer"					:	InventoryCustomer
        });
        
        console.debug('isWRCreated--------' + isWRCreated);
        console.debug('CurrentInventory--------' + CurrentInventory);
        console.debug('CurrentInventoryDetails-------' + CurrentInventoryDetails);
        console.debug('installstringdate---------' + installstringdate);
        console.debug('existingWRrecordId--------' + existingWRrecordId);
        console.debug('usegetypeValue---------' + usegetypeValue);
        console.debug('InventoryCustomer----------' + InventoryCustomer);
        
        action.setCallback(this, function(a) {
            console.log('---createWarrantyRegistration response-----------');
            console.log(a.getReturnValue());
            if(a.getReturnValue() != null){
                if(a.getReturnValue()[0].error == null){
                    component.set('v.isError',false);
                    component.set('v.WarrantyRegistration',a.getReturnValue()[0].WarrantyRegistration);
                    var CurrentInv = component.get('v.CurrentInventory');
                    var isDeleted = component.get('v.isDeleted');
                    helper.fetchPolicyDefinitionsMngrhelper(component,isDeleted,CurrentInv,helper,event);
                }else{
                    var errorMessage = a.getReturnValue()[0].error;
                    component.set('v.message',errorMessage);
                    component.set('v.isError',true);
                }
            }
            callback(a);
            
        });
        $A.enqueueAction(action);
        
    },
    
    fetchPolicyDefinitionsMngrhelper: function(component,isDeleted,CurrentInventory,helper,event){
        console.log('---fetchPolicyDefinitionsMngrhelper -----------');
        console.log(component.get("v.fieldArr"));
        var sObjList = CurrentInventory;
        var fieldLe = component.get("v.fieldArr").length;
        var fieldAr = component.get("v.fieldArr");
        var WR = component.get('v.WarrantyRegistration');
        console.log(component.get('v.WarrantyRegistration'));
        helper.constructTable(component,helper,sObjList,fieldLe,fieldAr,'tInventorywithpolicy','Inventory');
        
        var action = component.get("c.fetchPolicyDefinitionsMngr");
        action.setParams({
            "isDeleted"		:	isDeleted , 
            "newWR"		:	component.get('v.WarrantyRegistration')
        });
        action.setCallback(this, function(a) {
            console.log('---fetchPolicyDefinitionsMngrhelper response-----------');
            console.log(a.getReturnValue());
            console.log(a.getReturnValue()[0].PolicyDefWrapper);
            var policyresponse = a.getReturnValue()[0].PolicyDefWrapper;
            
            var currentUrl =  window.location.href;
            component.set("v.currentUrl",currentUrl);
            if(a.getReturnValue().error == null){
                component.set('v.isError',false);
                component.set('v.PolicyDefinitionWrapperList',a.getReturnValue()[0].PolicyDefWrapper);
                var poclicyfatchallPolicy =  a.getReturnValue()[0].PolicyDefWrapper;
                var polciylistwer = [];
                for(var i=0; i< poclicyfatchallPolicy.length; i++){
                    if(currentUrl.includes(poclicyfatchallPolicy[i].ObjPolicyDefinition.Type__c)){
                        polciylistwer.push(poclicyfatchallPolicy[i]);
                    }
                }
                
                component.set('v.PolicyDefinitionWrapperListclon',polciylistwer);
                var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
                mapInventoryPolicies[CurrentInventory[0].Id] = component.get('v.PolicyDefinitionWrapperListclon');
                component.set('v.mapInventoryPolicies',mapInventoryPolicies);
                console.log(component.get('v.mapInventoryPolicies'));
                
                if(component.get('v.PolicyDefinitionWrapperList').length > 0 && policyresponse != null && policyresponse.length > 0){
                    var sObjectList = mapInventoryPolicies[CurrentInventory[0].Id];                    
                    
                    console.log('-----------sObjectList-------------');
                    console.log(sObjectList);
                    var fieldLen = component.get("v.policyFieldArr").length;
                    var fieldArr = component.get("v.policyFieldArr");
                    
                    helper.constructTable(component,helper,sObjectList,fieldLen,fieldArr,'tInventorywithpolicy','Policy');
                }else if(helper.selectedInventoriesSize > 0){
                    helper.currentInventory++;
                    helper.selectedInventoriesSize--;
                    helper.addInventorywithpolicies(component, event, helper);
                }
            }else{
                var errorMessage = a.getReturnValue()[0].error;
                component.set('v.message',errorMessage);
                component.set('v.isError',true);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerData : function(component, event, helper){
        console.log('-------------customer dataa');
        console.log(component.get('v.customer'));
        console.log(component.get('v.Inventory')[0].Customer__c);
        if(component.get('v.Inventory')[0].Customer__c != null && typeof component.get('v.Inventory')[0].Customer__c !='undefined')
        {
            var customerId = component.get('v.Inventory')[0].Customer__c;
            console.log(component.get('v.Inventory')[0].Customer__c);
            var query = 'SELECT Id,Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode FROM Account Where Id='+ '\'' + customerId + '\'';
            console.log(query);
            helper.readRaw(component, event, query, function(response){
                console.log('----response customer--------');
                console.log(response[0]);
                
                console.log("my customer");
                JSON.parse(JSON.stringify(response[0]));
                
                component.set('v.customer',response[0]);
                console.log(component.get('v.customer'));
                console.log(component.get('v.customer.Name'));
            });
        }
    },
    
    registerInventoryHelper: function(component, helper){
        console.log('--------------inside registerInventoryHelper------');
        var registerInventoriesSize = helper.registerInventoriesSize;
        var currentRegisterInventory = helper.currentRegisterInventory;
        var selectedInventories = component.get('v.selectedInventories');
        var mapInventoryPolicies = component.get('v.mapInventoryPolicies');
        var mapInventories = component.get('v.mapInventories');
        var InventoryCustomer = component.get('v.customer.Id');
        console.log(selectedInventories.length);
        console.log(selectedInventories[0].Id);
        console.log(mapInventories);
        console.log(mapInventoryPolicies);
        console.log(registerInventoriesSize+'--'+currentRegisterInventory);
        if(registerInventoriesSize != '0' && currentRegisterInventory < registerInventoriesSize){
            console.log('---------------- inside registerInventoryHelper if---------');
            console.log('-------------inventy registration---------');
            console.log(mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id].length);
            if(mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id].length > 0 && typeof mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id] != 'undefined'){
                console.log('-----inside present policies---');
                var policyDef = mapInventoryPolicies[selectedInventories[currentRegisterInventory].Id];
                var CurrentInventory = mapInventories[selectedInventories[currentRegisterInventory].Id];
                console.log('-------------CurrentInventory-----------');
                console.log(CurrentInventory);
                var CurrentInventoryDetails = component.get('v.CurrentInventoryDetails');
                
                var installdate = component.get('v.inventoryInstallDate');
                installdate=new Date(installdate);
                var month = installdate.getMonth()+1;
                var date = installdate.getDate();
                var  year = installdate.getFullYear();
                var installstringdate = date+'/'+month+'/'+year;
                var existingWRrecordId = component.get('v.wrExistingId');
                console.log('--------existingWRrecordId-------'+existingWRrecordId);
                console.log(installstringdate);
                
                console.log('--------PolicyDefinitionWrapperList-------');
                console.log(policyDef); 
                console.log(JSON.stringify(policyDef));
                var action = component.get("c.registerInventory");
                if(existingWRrecordId == ''){
                    existingWRrecordId = null;
                }
                
                var usegetypeValue = component.get('v.usageType');
                console.log('---usegetypeValue---'+usegetypeValue);                
                
                var coverageEndDate = null;
                var type=component.get('v.type');
                
                console.log(coverageEndDate);
                
                if(coverageEndDate!=null && type!='Goodwill'){
                    coverageEndDate = null;
                }else{
                    coverageEndDate = new Date(component.get('v.coverageEndDate'));
                    coverageEndDate = (coverageEndDate.getMonth()+1) + '/' + coverageEndDate.getDate() + '/' +coverageEndDate.getFullYear();
                }
                
                console.log('====coverageEndDate====');	
                console.log(coverageEndDate);	
                
                console.log('====InventoryCustomer====');	
                console.log(InventoryCustomer);
                
                action.setParams({
                    "PolicyDefinitionList"				:	JSON.stringify(policyDef) , 
                    "CurrentInventoryDetails"			:	CurrentInventoryDetails,
                    "CurrentInventory"					:	CurrentInventory,
                    "InstDate"							:	installstringdate,
                    "WRID"							    :	existingWRrecordId,
                    "WRUsageType"						:	usegetypeValue,
                    "InventoryCustomer"				    :	InventoryCustomer,
                    "coverageEndDate"					:	coverageEndDate
                });
                action.setCallback(this, function(a) {
                    
                    console.log("result here");
                    console.log(a.getError());
                    
                    
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
                console.log('--------- no policies----------');
                helper.currentRegisterInventory++;
                helper.registerInventoryHelper(component, helper);
            }
        }else{
            console.log('---------------- inside registerInventoryHelper else---------');
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
    
    constructTable : function(cmp,helper,sObjectList,fieldLen,fieldArr,tbody,sobjectType) {
        helper.tbodyName = tbody;
        helper.sobjectType = sobjectType;
        var recordLen = sObjectList.length;
        console.log("XXXXXXXXXConstruct Table StartsXXXXXXXXX" );
        console.log("Record length---" + recordLen);
        console.log("Field length---" + fieldLen);
        //Start constructing tableRows from here
        var tbodyCmp = cmp.find(tbody);
        var tmpBody = tbodyCmp.get("v.body");
        helper.constructTableRow(cmp,helper,sObjectList,fieldArr,tbodyCmp,tmpBody,recordLen,fieldLen,0,0);
        
    },
    
    constructTableRow : function(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField) {
        
        
       
        
        fieldLen = fieldArr.length;
        console.log("---I am inside the construct Table Row---");
        var InvId = '';
        var bgColor = '';
        console.log("---helper.sobjectType---"+helper.sobjectType);
        if(helper.sobjectType == 'Inventory'){
            
            if(sObjectList!=undefined &&  sObjectList!=null){
                InvId= sObjectList[currentRecord].Id;
                var DeletionId = '';
                if(helper.tbodyName == 'tSelectedInventoryBody'){
                    DeletionId = 'Id_'+helper.deleteTabIndex;
                }else if(helper.tbodyName == 'tInventorywithpolicy' && helper.sobjectType == 'Inventory'){
                    DeletionId = 'Id_'+InvId;
                    helper.tInventorywithpolicyInv = InvId;
                    bgColor = 'bgColor';
                }
            }
            
            
        }else if(helper.tbodyName == 'tInventorywithpolicy' && helper.sobjectType == 'Policy'){
            console.log('----currentRecord----'+currentRecord);
            
            if(sObjectList.length!=0){
                DeletionId = 'Id_'+sObjectList[currentRecord].ObjPolicyDefinition['Id']+'_'+helper.tInventorywithpolicyInv;
            }	    
            
            
            
        }
        
        //null check of current record
        if(sObjectList[currentRecord]!=undefined && sObjectList[currentRecord]!=null){
            
            
            
            
            $A.createComponent("aura:html",
                               {
                                   "HTMLAttributes" : {
                                       "class": "slds-hint-parent " + bgColor,
                                       "id":DeletionId,
                                       "lang": InvId,
                                   }
                               },
                               function(newtr){
                                   newtr.set("v.tag","tr");
                                   var trBody = newtr.get("v.body");
                                   
                                   
                                   //--------- Add checkbox as first td to all rows of policy def table --------//
                                   console.log('----------helper.sobjectType--'+helper.sobjectType);
                                   if(helper.sobjectType == 'Policy')
                                   {
                                       console.log('------------ inside policy def checkbox execution');
                                       
                                       
                                       
                                       $A.createComponent("aura:html",
                                                          {
                                                              "HTMLAttributes" : {
                                                                  "class": "slds-cell-wrap slds-truncate",
                                                                  "data-label" : "Action"
                                                              }
                                                          },
                                                          function(newtd){
                                                              newtd.set("v.tag","td");
                                                              var CurrentInventoryId = cmp.get('v.CurrentInventory')[0].Id;
                                                              console.log('----------CurrentInventoryId------------'+CurrentInventoryId);
                                                              $A.createComponent("ui:inputCheckBox",
                                                                                 {
                                                                                     "value" 	: sObjectList[currentRecord].selected,
                                                                                     "disabled"	: sObjectList[currentRecord].isDisabled,
                                                                                     "change"	: cmp.getReference("c.checkedPolicies"),
                                                                                     "class"    : currentRecord+'_'+CurrentInventoryId
                                                                                     
                                                                                 }
                                                                                 ,
                                                                                 function(newData){
                                                                                     var tmpTdBody = newtd.get("v.body");
                                                                                     tmpTdBody.push(newData);
                                                                                     newtd.set("v.body",tmpTdBody);
                                                                                     trBody.push(newtd);
                                                                                     console.log('trBody--------------');
                                                                                     console.log(trBody);
                                                                                     
                                                                                     //Add other tds to tr here
                                                                                     helper.constructTableData(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody);
                                                                                     
                                                                                 });
                                                          });
                                   }else
                                   {
                                       console.log('--else--------helper.sobjectType--'+helper.sobjectType);
                                       if(helper.tbodyName == 'tInventorywithpolicy'){
                                           helper.inventoryWithPolicies.push(sObjectList[currentRecord].Id);
                                           var mapInventories = cmp.get('v.mapInventories');
                                           mapInventories[sObjectList[currentRecord].Id] = sObjectList[currentRecord];
                                           cmp.set('v.mapInventories',mapInventories);
                                       }
                                       console.log(sObjectList[currentRecord]);
                                       //Add other tds to tr here
                                       helper.constructTableData(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody);
                                       
                                   }
                                   
                                   // ----- checkbox addition end -------------------------//
                                   
                               }
                              );
        }
    },
    
    constructTableData : function(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody) {
        console.log("---I am inside the construct Table Data---");
        console.log("Current Record -- " + currentRecord);
        console.log("Current Field -- " + currentField);
        console.log("current field name----"+fieldArr[currentField]);
        var fieldSetValues='';
        var datalabel = '';
        if(fieldArr[currentField] == 'Is_Policy_Optional__c'){
            helper.outputType = 'ui:outputCheckBox';
        }else{
            helper.outputType = 'ui:outputText';
        }
        console.log(helper.tbodyName);
        if(helper.sobjectType != 'Policy')
        {
            
            fieldSetValues=cmp.get("v.inventoryfieldset");
            console.log('-----------policy def------');
            console.log(fieldSetValues);
            datalabel = fieldSetValues[currentField].label;
            console.log("Current Data -- " + sObjectList[currentRecord][fieldArr[currentField]]);
            var fieldData = sObjectList[currentRecord][fieldArr[currentField]];
            var mapFieldApi_Reference = cmp.get('v.mapFieldApi_Reference');
            console.log('---------mapFieldApi_Reference--------');
            console.log(mapFieldApi_Reference);
            
            if(fieldArr[currentField] in mapFieldApi_Reference){
                console.log('-------------------------------inside reference fields');
                var refrenceApiName = mapFieldApi_Reference[fieldArr[currentField]];
                console.log('---refrenceApiName----------');
                console.log(refrenceApiName);
                console.log(sObjectList[currentRecord]);
                var splittedAPIName = refrenceApiName.split('.');
                refrenceApiName = splittedAPIName[0];
                console.log(refrenceApiName);
                fieldData = sObjectList[currentRecord][refrenceApiName]['Name'];
                console.log(fieldData);
            }
            
        }
        else {
            
            fieldSetValues=cmp.get("v.policyfieldset");
            datalabel = fieldSetValues[currentField].label;
            console.log("Current Data -- " + sObjectList[currentRecord].ObjPolicyDefinition[fieldArr[currentField]]);
            var fieldData = sObjectList[currentRecord].ObjPolicyDefinition[fieldArr[currentField]];
            var mapPolicyFieldApi_Reference = cmp.get('v.mapPolicyFieldApi_Reference');
            console.log('---------mapPolicyFieldApi_Reference--------');
            console.log(mapPolicyFieldApi_Reference);
            
            if(fieldArr[currentField] in mapPolicyFieldApi_Reference){
                console.log('-------------------------------inside reference fields');
                var refrenceApiName = mapPolicyFieldApi_Reference[fieldArr[currentField]];
                console.log('---refrenceApiName----------');
                console.log(refrenceApiName);
                console.log(sObjectList[currentRecord]);
                var splittedAPIName = refrenceApiName.split('.');
                refrenceApiName = splittedAPIName[0];
                console.log(refrenceApiName);
                fieldData = sObjectList[currentRecord].ObjPolicyDefinition[refrenceApiName]['Name'];  
                console.log(fieldData);
            }
        }
        
        
        $A.createComponent("aura:html",
                           {
                               "HTMLAttributes" : {
                                   "class": "slds-cell-wrap slds-truncate",
                                   "data-label" : datalabel
                               }
                           },
                           function(newtd){
                               newtd.set("v.tag","td");
                               helper.constructFieldData(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody,newtd,fieldData);
                           }
                          );
    },
    
    constructFieldData : function(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody,newtd,currentData) {
        var outputType = helper.outputType;
        var colorDefined="";
        $A.createComponent(outputType,
                           {
                               "value" : currentData
                           }
                           ,
                           function(newData){
                               console.log('Current Data---' + currentData);
                               var tmpTdBody = newtd.get("v.body");
                               tmpTdBody.push(newData);
                               newtd.set("v.body",tmpTdBody);
                               trBody.push(newtd);
                               console.log(trBody);
                               console.log('XXXXXXThis is the End of ExecutionXXXXXXX ' );
                               fieldLen = fieldLen - 1 ;
                               if(fieldLen > 0)
                               {
                                   console.log("I am here");
                                   currentField = currentField + 1;
                                   console.log("Field Length -- " + fieldLen);
                                   helper.constructTableData(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,currentField,newtr,trBody);
                                   //console.log("I am failing here");
                               } else {
                                   console.log(fieldLen);
                                   console.log(helper.tbodyName);
                                   if( fieldLen == 0 && helper.tbodyName == 'tSelectedInventoryBody' )
                                   {
                                       $A.createComponent("aura:html",
                                                          {
                                                              "HTMLAttributes" : {
                                                                  "class"			 :	"slds-cell-wrap slds-truncate",
                                                                  "data-label" 	 :	"Units Run",
                                                                  "tabIndex"		 :	helper.deleteTabIndex,
                                                              }
                                                          },
                                                          function(newinputtd){
                                                              newinputtd.set("v.tag","td");
                                                              $A.createComponent("ui:inputText",
                                                                                 {
                                                                                     "class"		: 	"slds-input"+" "+sObjectList[currentRecord].Id,
                                                                                     "value"		:	sObjectList[currentRecord].Units_Run__c,
                                                                                     "change"		:	cmp.getReference('c.UnitsRunChange')
                                                                                 },
                                                                                 function(newinput){
                                                                                     var tmpTdBody = newinputtd.get("v.body");
                                                                                     tmpTdBody.push(newinput);
                                                                                     newinputtd.set("v.body",tmpTdBody);
                                                                                     trBody.push(newinputtd);
                                                                                     console.log(trBody);
                                                                                 });
                                                          }
                                                         );
                                       
                                       $A.createComponent("aura:html",
                                                          {
                                                              "HTMLAttributes" : {
                                                                  "class"			 :	"slds-cell-wrap slds-truncate",
                                                                  "data-label" 	 :	"Delete",
                                                                  "tabIndex"		 :	helper.deleteTabIndex,
                                                                  "onclick"		 :	cmp.getReference("c.deleteInventoryBlock"),
                                                              }
                                                          },
                                                          function(newsvgtd){
                                                              helper.deleteTabIndex++;
                                                              newsvgtd.set("v.tag","td");
                                                              var url = cmp.get('v.BaseURL')+'/resource/slds/assets/icons/utility-sprite/svg/symbols.svg#delete';
                                                              console.log('svg url--------------');
                                                              console.log(url);
                                                              
                                                              $A.createComponent("c:svg",
                                                                                 {
                                                                                     "class"		: 	"slds-icon slds-icon--x-small slds-icon-text-default delete-Icon-E-D",
                                                                                     "xlinkHref" 	: 	url,
                                                                                     "ariaHidden"	:	'false',
                                                                                     "tabIndex"	:	helper.deleteTabIndex,
                                                                                 },
                                                                                 function(newsvg){
                                                                                     console.log('Current Data---' + currentData);
                                                                                     var tmpTdBody = newsvgtd.get("v.body");
                                                                                     tmpTdBody.push(newsvg);
                                                                                     newsvgtd.set("v.body",tmpTdBody);
                                                                                     trBody.push(newsvgtd);
                                                                                     console.log(trBody);
                                                                                 });
                                                          }
                                                         );
                                       cmp.set('v.isAddInvClicked',false); 
                                   }
                                   
                                   console.log("Am I setting Table Row Body once -- " + trBody );
                                   newtr.set("v.body",trBody);
                                   console.log('----bgColor---');
                                   console.log(newtr.get('v.body'));    
                                   tableBody.push(newtr);
                                   recordLen = recordLen - 1 ;
                                   if(recordLen > 0)
                                   {
                                       currentRecord = currentRecord + 1;
                                       helper.constructTableRow(cmp,helper,sObjectList,fieldArr,tbodyCmp,tableBody,recordLen,fieldLen,currentRecord,0);
                                   } else {
                                       tbodyCmp.set("v.body",tableBody);
                                       if(helper.sobjectType == 'Policy')
                                       {
                                           console.log('after completing policy def addition----------');
                                           helper.currentInventory++;
                                           helper.selectedInventoriesSize--;
                                           
                                           //event is undefined--> AMAN EDITED
                                           //passed undefined insted of event
                                           helper.addInventorywithpolicies(cmp, undefined , helper);
                                       }
                                   }
                               } 
                               
                           }
                          );
    }
    
})