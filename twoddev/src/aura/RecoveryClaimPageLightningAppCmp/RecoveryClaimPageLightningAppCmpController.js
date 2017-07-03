({
    
    doInit : function(component, event, helper) {
        
        //component for icons
        component.set( "v.CloseSymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#close"));
        component.set( "v.searchsymbolURL" ,helper.renderURL(component.get("v.baseURL"),"resource/slds/assets/icons/utility-sprite/svg/symbols.svg#search"));
        
        var spinnerBool = {
            pageSpinner: false,
            claimServiceInfoSpinner: false,
            summarySpinner: true
        };
        component.set('v.spinnerBool', spinnerBool);
        
        //show the page spinner
        component.set('v.spinnerBool.pageSpinner', true);
        
        var RemovedPartList = [];
        var ExistingRecoveryclaims = [];
        var ContractClaimsURLs = [];
        var ClaimQuery = helper.claim_record   + "'" + component.get("v.ClaimRecordId") + "'";
        
        //Fetching the claim record
        helper.readDom(component, event, ClaimQuery, "v.ClaimRecord", "v.dmlErrors", function(returnedValues) {
            component.set("v.ClaimURL",helper.renderURL(component.get("v.baseURL"),component.get("v.ClaimRecord").Id));
            var CausalPartquery             = helper.Causal_PartDataQuery + "'" + component.get("v.ClaimRecord.Causal_Part_Number__c") + "'";
            var RemovedPartquery            = helper.Removed_PartListQuery + "'" + component.get("v.ClaimRecord").Id + "'";
            var existingRecoveryClaimsQuery = helper.ExistingRecoveryClaim_Query+ "'"+ component.get("v.ClaimRecord").Id+"'";
            //Reading the causal part record
            helper.readDom(component, event, CausalPartquery, "v.causalPartRecord", "v.dmlErrors", function(returnedValues) {
                if(component.get("v.causalPartRecord")!=null){
                    component.set("v.causalPartRecordID",component.get("v.causalPartRecord")[0].Id); 
                }  
            });
            //Fetch existing recovery Claims
            helper.readDom(component, event, existingRecoveryClaimsQuery, "v.ExistingRecoveryClaims", "v.dmlErrors", function(returnedValues){
                
                var existingRecoveryClaimsURLs = [];
                
                if(component.get("v.ExistingRecoveryClaims")!=undefined && component.get("v.ExistingRecoveryClaims").length>0){
                    ExistingRecoveryclaims = component.get("v.ExistingRecoveryClaims");             
                    component.set("v.showExistingClaims", true);
                    for(var i=0; i<ExistingRecoveryclaims.length;i++){
                        var ExistingRecoveyClaimURLMap ={rId : {id : '',url : '',url1:'', url2:''}};  
                        var ExistingRecoveyClaimURL = helper.renderURL(component.get("v.baseURL"),ExistingRecoveryclaims[i].Id);
                        var ExistingRecoveyClaimURL1 = helper.renderURL(component.get("v.baseURL"),ExistingRecoveryclaims[i].Supplier_Contract__c);
                        var ExistingRecoveyClaimURL2 = helper.renderURL(component.get("v.baseURL"),ExistingRecoveryclaims[i].Supplier_Contract__r.Supplier_Account__c);
                        ExistingRecoveyClaimURLMap.rId.id = ExistingRecoveryclaims[i].Id;
                        ExistingRecoveyClaimURLMap.rId.url = ExistingRecoveyClaimURL;
                        ExistingRecoveyClaimURLMap.rId.url1 = ExistingRecoveyClaimURL1;
                        ExistingRecoveyClaimURLMap.rId.url2 = ExistingRecoveyClaimURL2;
                        existingRecoveryClaimsURLs[i] = ExistingRecoveyClaimURLMap;
                    }
                    component.set("v.ExistingRecoveryClaimsURL",existingRecoveryClaimsURLs);                   
                }               
            })
            
            //Reading the removed part record
            helper.readDom(component, event, RemovedPartquery, "v.RemovedpartArray", "v.dmlErrors", function(returnedValues) {
                RemovedPartList = component.get("v.RemovedpartArray");
                var productset = [];
                if(RemovedPartList.length != undefined && RemovedPartList.length!=null){
                    //Populating the Product set                   
                    for(var i = 0; i < RemovedPartList.length; i++){
                        console.log('The product name');
                        console.log(RemovedPartList[i].Warranty_Product_on_Recovery_Claim__c);
                        if(i==0){
                            productset[i] = RemovedPartList[i].Warranty_Product_on_Recovery_Claim__c + "'";
                        } else if(i == RemovedPartList.length - 1 ){
                            if(component.get("v.causalPartRecord")!=null){
                                if(component.get("v.causalPartRecord")[0].Name != undefined || component.get("v.causalPartRecord")[0].Name != Null || component.get("v.causalPartRecord")[0].Name != ''){
                                    productset[i] = "'" + RemovedPartList[i].Warranty_Product_on_Recovery_Claim__c + "'";
                                }else{                                
                                    productset[i] = "'" + RemovedPartList[i].Warranty_Product_on_Recovery_Claim__c;
                                }   
                            }
                            
                        }else{
                            
                            productset[i] = "'" + RemovedPartList[i].Warranty_Product_on_Recovery_Claim__c + "'";
                        }
                        console.log(productset);
                    }
                    
                    if(RemovedPartList.length == 0){
                        if(component.get("v.causalPartRecord")!=null){
                            productset[i] = component.get("v.causalPartRecord")[0].Name;
                        }                       
                    }else{
                        if(component.get("v.causalPartRecord")!=null){
                            productset[i] = "'" + component.get("v.causalPartRecord")[0].Name;   
                        }
                        
                    }
                    
                }
                
                component.set("v.ProductSetcmp",productset);
                //Fetching all the contract for the products
                if(component.get("v.ProductSetcmp").length>0){
                    var SupplierContractQuery = helper.Supplier_ContractQuery + "'" + component.get("v.ProductSetcmp") + "'" + ")";
                    helper.readDom(component, event, SupplierContractQuery, "v.supplierContracts", "v.dmlErrors", function(returnedValues) {                   
                        if(returnedValues!=undefined && Array.isArray(returnedValues) && returnedValues.length!=0){
                            component.set("v.supplierContracts",returnedValues);
                            helper.SearchValidContracts(component,component.get("v.supplierContracts"));                   
                        }     
                    }); 
                }
                
            });
            
            //show the page spinner
            component.set('v.spinnerBool.pageSpinner', false);
        });
        
    },
    
    viewActiveContractsForCausal : function(component, event, helper){
        
        //show the page spinner
        component.set('v.spinnerBool.pageSpinner', true);
        //enable valid contract table
        component.set("v.validContracts", true);
        if(typeof(event.target.parentElement.tabIndex) == undefined || event.target.parentElement.tabIndex < 0){
            var  currentRecordNumClick = event.target.tabIndex;
        }else{
            var  currentRecordNumClick = event.target.parentElement.tabIndex;
        }
        
        
        var allCausalProducts = component.get("v.causalPartRecord");       
        var causalproductID = component.get("v.causalPartRecord")[currentRecordNumClick].Id;
        
        var myEvent = $A.get("e.c:RecoveryClmPageSelprodWarEvent");
        myEvent.setParams({
            ProductName: causalproductID,
            IsCausalPart: true
        });
        console.log(myEvent);
        myEvent.fire();
        
        var validCount = 0;
        
        
        var supplierContractList = component.get("v.supplierContracts");
        if(supplierContractList!=undefined && Array.isArray(supplierContractList) && supplierContractList.length!=0){
            supplierContractList = JSON.parse(JSON.stringify(component.get("v.supplierContracts")));
            for(var i=0; i<supplierContractList.length;i++){
                if(component.get("v.supplierContracts")[i].Supplier_Product__r.Product__c === causalproductID){
                    validCount = validCount+1;
                }   
            }
            
            if(validCount == 0){
                component.set("v.validCount", true);
            }
            else{
                component.set("v.validCount", false);
            }            
        }
      
        component.set('v.spinnerBool.pageSpinner', false);
    },
    
    viewActiveContracts : function(component, event, helper){
        
        //show the page spinner
        component.set('v.spinnerBool.pageSpinner', true);
        //enable valid contract table
        component.set("v.validContracts", true);
        
        if(typeof(event.target.parentElement.tabIndex) == undefined || event.target.parentElement.tabIndex < 0){
            var currentRecordNumClick = event.target.tabIndex; 
        }else{
            var currentRecordNumClick = event.target.parentElement.tabIndex;
        }
        
        var allProducts = component.get("v.RemovedpartArray");        
        if(allProducts[currentRecordNumClick].Inventory__c){
            var productID =  allProducts[currentRecordNumClick].Inventory__r.Item__c
            } else {
                var productID =  allProducts[currentRecordNumClick].Warranty_Product__c;
            }
        
        var myEvent = $A.get("e.c:RecoveryClmPageSelprodWarEvent");
        myEvent.setParams({
            ProductName: productID,
            IsCausalPart: false
        });
        myEvent.fire();
        
        var validCount = 0;
        
        var supplierContractList = component.get("v.supplierContracts");
        if(supplierContractList!=undefined && Array.isArray(supplierContractList) && supplierContractList.length!=0){
            supplierContractList = JSON.parse(JSON.stringify(component.get("v.supplierContracts")))
            for(var i=0; i<supplierContractList.length;i++){
                if(component.get("v.supplierContracts")[i].Supplier_Product__r.Product__c === productID){
                    validCount = validCount+1;
                }   
            }
            
            if(validCount == 0){
                component.set("v.validCount", true);
            }
            else{
                component.set("v.validCount", false);
            }            
        }
        
        
        component.set('v.spinnerBool.pageSpinner', false);
    },
    
    ShowRecoveryClaimLineItems : function(component, event, helper){
        //Enable the recovery claim info
        component.set("v.ShowCreatedRecoveryClaimInfo", true);
        
        var contractlist = [];
        var ProductList = [];
        var EmptyMap = [];
        var finalcontractClaims = [];
        var ProductPresent = false;
        var ContractPresent = false;
        var SelectedContractId = event.getParam("RecoveryLineItemsCreatVar").Supplier_Contract__c;
        var SelectedContractName = event.getParam("RecoveryLineItemsCreatVar").Supplier_Contract__r.Name;
        var SelectedProductName  = event.getParam("RecoveryLineItemsCreatVar").Supplier_Product__r.Product__r.Name;
        var SelectedProductId  = event.getParam("RecoveryLineItemsCreatVar").Supplier_Product__r.Product__c;
        var IsCausalAndCollateralLogicTrue = event.getParam("IsCausalAndCollateralProduct");
        
        var IsContractChecked = event.getParam("IsContractChecked");
        var RecoveryLineItem = component.get("v.RecoveryClaimLineItemTobeCreated");
        console.log('the first value'+JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
        finalcontractClaims = component.get("v.ContractClaimsURL");
        //Below piece of code set the CollateralApplicableLogic variable to check if for the current functionality collateral is true or false
        component.set("v.CollateralApplicableLogic",IsCausalAndCollateralLogicTrue)
        
        //If the IsContractChecked is True  i.e the contract is selected in the component level - Add the selected contract data into the MAP
        //If the IsContractChecked is False i.e the contract is Unselected in the component level - Delete the selected contract data from the MAP
        
        if(IsContractChecked == true){
            if(IsCausalAndCollateralLogicTrue == 'true'){
                
                component.set("v.RecoveryClaimLineItemTobeCreated",EmptyMap);
                var RecoveryLineItem = [{contract : {id : '', name : ''}, lineitems : [{id:'',name: ''}]}];
                var DistinctSupplierContrats = helper.GetdistinctItems(component.get("v.supplierContracts"),component);              
                DistinctSupplierContrats = JSON.parse(JSON.stringify(DistinctSupplierContrats));
                
                //Fill the MAP with the Contract of the Causal and add all the removed parts as the lineItems
                var TempMapCollateral = {contract : {id : '', name : ''}, lineitems : []};
                
                TempMapCollateral.contract.id = SelectedContractId;
                TempMapCollateral.contract.name = SelectedContractName;
                console.log(component.get("v.supplierContracts").length);
                for(var i=0 ; i < DistinctSupplierContrats.length ;i++){                   
                    TempMapCollateral.lineitems.push({id : DistinctSupplierContrats[i].Supplier_Product__r.Product__c,name : DistinctSupplierContrats[i].Supplier_Product__r.Product__r.Name})
                }
                RecoveryLineItem.push(TempMapCollateral);
                component.set("v.RecoveryClaimLineItemTobeCreated",RecoveryLineItem);
                RecoveryLineItem = JSON.parse(JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
                component.set("v.RecoveryClaimLineItemTobeCreated", RecoveryLineItem);
                
                
            }else{
                
                //Check if the selected Contract exists in the MAP.
                //If the Product already exist - Skip
                //If the Product does not exist - Add the product
                
                for(var  i=0 ; i < RecoveryLineItem.length ; i++){
                    
                    if(RecoveryLineItem[i].contract.id == SelectedContractId){
                        ContractPresent = true;
                        console.log(RecoveryLineItem[i].lineitems.length);
                        for(var j=0; j < RecoveryLineItem[i].lineitems.length ; j++){
                            console.log('the ............'+JSON.stringify(RecoveryLineItem[i].lineitems[j]));
                            if(RecoveryLineItem[i].lineitems[j].id == SelectedProductId){
                                
                                ProductPresent = true;
                            }
                        }
                        
                        if(ProductPresent != true){                           
                            var tempMAP1 = {};                            
                            var lineitems = RecoveryLineItem[i].lineitems;
                            lineitems.push({id:SelectedProductId,name : SelectedProductName});                           
                            RecoveryLineItem[i].lineitems = lineitems;                             
                            component.set("v.RecoveryClaimLineItemTobeCreated",JSON.parse(JSON.stringify(RecoveryLineItem)));                            
                        }
                    }
                    count = i;
                }
                
                
                var count = i + 1 ;
                if(count > RecoveryLineItem.length  && ContractPresent == false){                  
                    var TempMap = {contract : {id : '', name : ''}, lineitems : [{id:'',name: ''}]};
                    TempMap.contract.id = SelectedContractId;
                    TempMap.contract.name = SelectedContractName;
                    
                    TempMap.lineitems[0].id = SelectedProductId;
                    TempMap.lineitems[0].name = SelectedProductName;
                    RecoveryLineItem.push(TempMap);
                    component.set("v.RecoveryClaimLineItemTobeCreated",RecoveryLineItem);
                }
                console.log(JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
            }
        }else if(IsContractChecked == false && IsCausalAndCollateralLogicTrue == 'false'){
            console.log('the step2'+JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));            
            var CurrentLineItemMapArray = component.get("v.RecoveryClaimLineItemTobeCreated");
            var index1;
            var index2;
            //Get the index of the selected Contract
            for(var j = 0 ; j < CurrentLineItemMapArray.length ; j++ ){
                
                if(CurrentLineItemMapArray[j].contract.id == SelectedContractId ){                   
                    for(var i=0 ; i < CurrentLineItemMapArray[j].lineitems.length ; i++){
                        if(CurrentLineItemMapArray[j].lineitems[i].id == SelectedProductId){
                            CurrentLineItemMapArray[j].lineitems.splice(i,1)                          
                            
                        }
                    }
                }
            }
            
            component.set("v.RecoveryClaimLineItemTobeCreated",CurrentLineItemMapArray);
            console.log(component.get("v.RecoveryClaimLineItemTobeCreated"));
            
        }else if(IsContractChecked == false && IsCausalAndCollateralLogicTrue == 'true'){            
            component.set("v.RecoveryClaimLineItemTobeCreated",EmptyMap);
        }
        console.log('the recovery*******************'+JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
        
        //Check if the elements are present in the MAP
        //Yes - Show the CreateRecoveryClaimButton
        //No  - Hide the CreateRecoveryClaimButton
        
        if(component.get("v.RecoveryClaimLineItemTobeCreated").length > 0){          
            var recoveryItemMapArray = component.get("v.RecoveryClaimLineItemTobeCreated");
            for(var i=0 ; i < recoveryItemMapArray.length ; i++){               
                if(recoveryItemMapArray[0].contract.id==''){
                    recoveryItemMapArray.splice(i,1);
                    
                }                
            } 
            component.set("v.RecoveryClaimLineItemTobeCreated",recoveryItemMapArray);          
            console.log('the recovery*******************111111'+JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
            component.set("v.ShowTheCreateClamButton",true);
        }else{
            component.set("v.ShowTheCreateClamButton",false);
        }
    },
    
    RemoveLineItems : function(component, event, helper){
        
        var EmptyMap = [];         
        var currentRecordNumClick =           event.target.value;
        var CurrentLineItemMapArray = JSON.parse(JSON.stringify(component.get("v.RecoveryClaimLineItemTobeCreated")));
        var RecoveryLineItemMapArray = component.get("v.RecoveryClaimLineItemTobeCreated");
        component.set("v.RecoveryClaimLineItemTobeCreated",EmptyMap);
        
        if(event.target.parentElement.id !=undefined && event.target.parentElement.id !=null && event.target.parentElement.id !=''){
            currentRecordNumClick = event.target.parentElement.id ;
        }
        else if(event.target.parentNode.parentElement.id !=undefined && event.target.parentNode.parentElement.id!=null && event.target.parentNode.parentElement.id!=''){
            currentRecordNumClick = event.target.parentNode.parentElement.id;
        }
        
        var ClickIndexIndexVal = currentRecordNumClick.split(",");       
        var LineItemIndex = ClickIndexIndexVal[0];        
        var ContractIndex = ClickIndexIndexVal[1];
        
        var index;        
        for(var i=0 ; i < CurrentLineItemMapArray[ContractIndex].lineitems.length ; i++){
            if(CurrentLineItemMapArray[ContractIndex].lineitems[i].id == CurrentLineItemMapArray[ContractIndex].lineitems[LineItemIndex].id){
                var index = i;
            }
        }
        
        //Copying the LineItemValues to uncheck the selected product and contract from the component by triggering the event
        
        var LinetemValue = CurrentLineItemMapArray[ContractIndex].lineitems[index].id;
        var ContractValue = CurrentLineItemMapArray[ContractIndex].contract.id;        
        var myEvent = $A.get("e.c:DeleteCreatedRecoveryLineItemEvent");
        myEvent.setParams({
            ProductId: LinetemValue,
            ContractId: ContractValue,
            IsContractDeleted: false
        });
        myEvent.fire();
        
        //delete the Lineitem from the Lineitem MAP object
        
        CurrentLineItemMapArray[ContractIndex].lineitems.splice(index,1);
        console.log('***********'+JSON.stringify(CurrentLineItemMapArray));
        for(var i=0 ; i < CurrentLineItemMapArray.length ; i++ ){            
            if(CurrentLineItemMapArray[i].lineitems.length == 0){
                CurrentLineItemMapArray.splice(i,1);
            }            
        }
        
        component.set("v.RecoveryClaimLineItemTobeCreated",CurrentLineItemMapArray);
        
        //Check if the elements are present in the MAP
        //Yes - Show the CreateRecoveryClaimButton
        //No  - Hide the CreateRecoveryClaimButton
        
        if(component.get("v.RecoveryClaimLineItemTobeCreated").length > 0){
            component.set("v.ShowTheCreateClamButton",true);
        }else{
            component.set("v.ShowTheCreateClamButton",false);
        }
        
    },
    
    CreateSupplyRecoveryClaims : function(component, event, helper){
        
        var SupplyRecoveryClaimMap = component.get("v.RecoveryClaimLineItemTobeCreated");
        //call helper to create recovery claims
        helper.CreateSupplyRecoveryHelper(SupplyRecoveryClaimMap,component,helper);    
        component.set("v.ShowTheCreateClamButton",false);
    },
    
    Cancel: function(component, event, helper) { 
        var ProceedURL = ''; 
        
        var BaseUrl =component.get('v.baseURL');        
        var claimId =component.get("v.ClaimRecordId");
        if(BaseUrl != 'undefined' && typeof BaseUrl != 'undefined')
        {
            if(BaseUrl.indexOf('lightning') !=-1) 
                ProceedURL = "/RecoveryClaimPageLightningAppCmp/RecoveryClaimPageLightningApp.app#/sObject/"+claimId+'/view';
            else
                ProceedURL = BaseUrl+"/"+claimId;
            
            window.location.href=ProceedURL;
        }        
    }
    
})