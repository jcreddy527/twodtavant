({
    ShowSelectedContracts : function(component, event, helper) {
        console.log('.....test url'+component.get("v.baseURL"));
        var contractURL = component.get("v.baseURL") +'/'+component.get("v.supplierContract").Supplier_Contract__c;
        var supplierURL = component.get("v.baseURL") +'/'+component.get("v.supplierContract").Supplier_Contract__r.Supplier_Account__c;
        CollateralApplicableLogic = false;
        component.set("v.ShowComponent",'No');
        component.set("v.IsCollateralApp",'false');
        var ProductNameEvent = event.getParam("ProductName");
        var IscausalPart = event.getParam("IsCausalPart");
        var CollateralApplicableLogic = component.get("v.supplierContract.Supplier_Contract__r.Is_Collateral_Applicable__c");
        var CausalPartId = component.get("v.supplierContract").Supplier_Product__r.Product__c;
 
        //Show the component(contract) which matches the supplier product Id of the selected product
        if(component.get("v.supplierContract").Supplier_Product__r.Product__c === ProductNameEvent){
            
            component.set("v.ShowComponent",'Yes');
            component.set("v.contractURL",contractURL);
            component.set("v.supplierURL",supplierURL); 
        }	
        
        //If the collateral is true for the given component(contract) highlight the Row
 
        if(CollateralApplicableLogic == true && IscausalPart == true && CausalPartId == component.get("v.ProductID")){
            //component.set("v.CollateralColour",'#F3FF33'); 
            component.set("v.IsCollateralApp",'true');
        }

    },
    
    onCheck : function(component, event, helper){
        
        var ContractRecord = component.find("checkbox").get("v.text");
        var IsCousalandCollateralTrue = component.get("v.IsCollateralApp");
        var SupplierContract = component.find("checkbox").get("v.text").Supplier_Contract__c;
        var Product = component.find("checkbox").get("v.text").Supplier_Product__r.Name;
        var ProductID = component.find("checkbox").get("v.text").Supplier_Product__r.Product__c;
        // console.log(id);
        var checkCmp = component.find("checkbox");
        if(checkCmp.get("v.value") == true){
            
            //Fire the Below event when the component checkbox is checked 
            //If the select contract checkbox field is checked then uncheck all other contracts for that particular Product and contract combination           
            var myEvent = $A.get("e.c:RecoveryClaimPageSelfFireEvent");
            myEvent.setParams({
                ContractID: SupplierContract,
                WarrantyProductID: ProductID,
                IsSelected: true
            });
            myEvent.fire();
            
            var myEvent = $A.get("e.c:RecoveryClmPageCreateLineItemEvent");
            myEvent.setParams({
                RecoveryLineItemsCreatVar: ContractRecord,
                IsCausalAndCollateralProduct: IsCousalandCollateralTrue,
                IsContractChecked: false
            });
            myEvent.fire();
            

            //Fire the Below event when the component checkbox is checked - To create the lineItem in the LineItem MAP
            var myEvent = $A.get("e.c:RecoveryClmPageCreateLineItemEvent");
            myEvent.setParams({
                RecoveryLineItemsCreatVar: ContractRecord,
                IsCausalAndCollateralProduct: IsCousalandCollateralTrue,
                IsContractChecked: true
            });
            myEvent.fire();
            component.set("v.IsSelected",true);
            checkCmp.set("v.value",true);
            
        }else if(checkCmp.get("v.value") == false){
            var myEvent = $A.get("e.c:RecoveryClmPageCreateLineItemEvent");
            myEvent.setParams({
                RecoveryLineItemsCreatVar: ContractRecord,
                IsCausalAndCollateralProduct: IsCousalandCollateralTrue,
                IsContractChecked: false
            });
            myEvent.fire();
        } 
        
    },
    
    
    UnselectOtherCheckboxes : function(component, event, helper){
        var SelectedProductLT = event.getParam("WarrantyProductID");
        var SelectedContractIdLT = event.getParam("ContractID");
        var IsContractDeleted = event.getParam("IsSelected"); 
        if(component.get("v.supplierContract").Supplier_Product__r.Product__c == SelectedProductLT) {
            var checkCmp = component.find("checkbox");
            checkCmp.set("v.value",false);
        }
    },
    
    RemoveTheDeletedRecoveryLineItem : function(component, event, helper){
        var SelectedProductLT = event.getParam("ProductId");
        var SelectedContractIdLT = event.getParam("ContractId");
        var IsContractDeleted = event.getParam("IsContractDeleted");
        
        if(IsContractDeleted == true){
            //If the Contract is Unchecked in the Recovery Claim Line item Map
            //Uncheck all the component checkbox that matched with the contract Id
            if(component.get("v.supplierContract").Supplier_Contract__c == SelectedContractIdLT){
                var checkCmp = component.find("checkbox");
                checkCmp.set("v.value",false);
            } 
            
            
        }else{
            //check if the deleted lineitem matches with the component lineitem
            //If yes - uncheck the checkbox of  the component
            //If No - leave the current state of checkbox
            if(component.get("v.supplierContract").Supplier_Contract__c == SelectedContractIdLT && component.get("v.supplierContract.Supplier_Product__r.Product__c") == SelectedProductLT){
                
                var checkCmp = component.find("checkbox");
                checkCmp.set("v.value",false);
            }  
        }
        
    }

})