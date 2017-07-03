({
    claim_record : 'SELECT Id,Name, CreatedDate,Date_of_Failure__c,Date_of_Repair__c,Date_Of_Purchase__c,Account__c,Account__r.Name,Causal_Part_Number__r.Name,Claim_Type__c from Claim__c where id = ',
    Causal_PartDataQuery : 'SELECT id,Name,Item_Type__c,Track_Type__c,Product_Name__c from Warranty_Product__c where id = ',
    Removed_PartListQuery : 'SELECT id,Warranty_Product_on_Recovery_Claim__c,Quantity__c,Warranty_Product_Name_on_Recovery_Claim__c,RecordType.name,Warranty_Product__c,Warranty_Product__r.name,Warranty_Product__r.Product_Name__c,Inventory__r.Item__r.name,Inventory__r.Item__c, Inventory__r.Item__r.Product_Name__c from Removed_Claim_Part__c where Claim__c = ',
    Supplier_ContractQuery : 'select id,Name, Supplier_Product__r.OEM_Purchase_Date_del__c,Supplier_Product__c,Supplier_Product__r.name,Supplier_Product__r.Product__c,Supplier_Product__r.Manufacuture_Date_del__c,Supplier_Product__r.Product__r.name,Supplier_Contract__c,Supplier_Contract__r.Name,Supplier_Contract__r.Is_Collateral_Applicable__c,Supplier_Contract__r.Is_Part_Return_Required__c,Supplier_Contract__r.Validity_Date_Type__c,Supplier_Contract__r.Valid_From__c,Supplier_Contract__r.Valid_To__c,Supplier_Contract__r.Months_Covered__c,Supplier_Contract__r.Supplier_Account__r.Name,Supplier_Contract__r.Minimum_recoverable_percent__c,Supplier_Contract__r.Part_Return_Location__r.name,Supplier_Contract__r.Part_Return_Location__c  from Supplier_Contract_Item__c where Supplier_Product__r.Product__r.name IN (',
    RecoveryClaim_Query : 'select id,Name,Warranty_Claim__r.Name,Supplier_Contract__r.Name,Supplier_Contract__r.Supplier_Account__r.Name,Supplier_Account_Name__c,Supplier_Contract__c,Warranty_Claim__c from Supplier_Recovery_Claim__c where id IN (',
    ExistingRecoveryClaim_Query : 'select id,Name,Warranty_Claim__r.Name,Supplier_Contract__r.Name,Supplier_Contract__r.Supplier_Account__r.Name,Supplier_Account_Name__c,Supplier_Contract__c,Warranty_Claim__c from Supplier_Recovery_Claim__c where Warranty_Claim__r.Id = ',
    searchContracts : function(component) {
              

              },
    
    //The Below method is used to get the distinct Products as Recovery LineItems when the causal part with collateral contract applicable is selected
    GetdistinctItems : function(SupplyRecoveryLineItems,component){
        
        var elementContains;
        var temp = component.get("v.supplierContracts");        
                             var tempMap = [];
        var ProductPresent = [];
                                     
        for(var i=0;i<SupplyRecoveryLineItems.length;i++){
            var count = 0;
            for(var j=0; j<SupplyRecoveryLineItems.length;j++ ){//check duplicates                
                if(SupplyRecoveryLineItems[i].Supplier_Product__r.Product__c == temp[j].Supplier_Product__r.Product__c && SupplyRecoveryLineItems[i].Supplier_Product__r.Product__r.Name == temp[j].Supplier_Product__r.Product__r.Name ){//skip if already present                                  
                    count = count + 1;                                
               }
            }           
            if(count > 0){
                for(var k=0;k<ProductPresent.length;k++){
                    if(SupplyRecoveryLineItems[i].Supplier_Product__r.Product__c == ProductPresent[k]){
                        elementContains = 'true';
                    }
                }                
                if(elementContains ==  'true'){
                             console.log('It containss');
              }else{
                    tempMap.push(SupplyRecoveryLineItems[i]);
                    ProductPresent.push(SupplyRecoveryLineItems[i].Supplier_Product__r.Product__c); 
              }
            }                              
            elementContains = '';
        }
        return tempMap;
    },
    
    CreateSupplyRecoveryHelper : function(SupplyRecoveryClaimMapVar,component,helper){

        //var SelectedContractToCreateRecoveryClaim = SupplyRecoveryClaimMapVar.contract.id;
        var SupplierContractsData = component.get("v.supplierContracts");
                            var TempLineItemsContracts = [];
        //show the page spinner
        component.set('v.spinnerBool.pageSpinner', true);
     
        for(var k = 0 ;k < SupplyRecoveryClaimMapVar.length ; k++){
              for(var i = 0 ;i < SupplyRecoveryClaimMapVar[k].lineitems.length ; i++){
                for(var j = 0 ; j < SupplierContractsData.length ; j++){
                    
                    if(component.get("v.CollateralApplicableLogic") == 'true'){
                        if(SupplyRecoveryClaimMapVar[k].lineitems[i].id == SupplierContractsData[j].Supplier_Product__r.Product__c){
                            TempLineItemsContracts.push(SupplierContractsData[j]);
                        }       
                    }else{
                        if(SupplyRecoveryClaimMapVar[k].lineitems[i].id == SupplierContractsData[j].Supplier_Product__r.Product__c && SupplierContractsData[j].Supplier_Contract__c == SupplyRecoveryClaimMapVar[k].contract.id){
                            TempLineItemsContracts.push(SupplierContractsData[j]);
                        }   
                    }
                       
                }
              }           
        }
        
        
        //Extracting the Removed Parts        
        var RemovedPartList = component.get("v.RemovedpartArray");
        
        var supplyRecoveryList = [];        
        for(var i = 0 ;i < SupplyRecoveryClaimMapVar.length ; i++){
              
              var supplyRecoveryClaim = {'sobjectType':'Supplier_Recovery_Claim__c', 'Id' : null };
            supplyRecoveryClaim.Warranty_Claim__c = component.get("v.ClaimRecord").Id;
            supplyRecoveryClaim.Supplier_Contract__c = SupplyRecoveryClaimMapVar[i].contract.id;
            supplyRecoveryClaim.Status__c = 'Draft';
            supplyRecoveryClaim.Repair_Date__c = component.get("v.ClaimRecord").Date_of_Repair__c;
            supplyRecoveryClaim.Purchase_Date__c = component.get("v.ClaimRecord").Date_Of_Purchase__c;
            supplyRecoveryClaim.Failure_Date__c = component.get("v.ClaimRecord").Date_of_Failure__c;
            supplyRecoveryList[i] = supplyRecoveryClaim;
        }
        component.set("v.SupplyRecoveryClaim",supplyRecoveryList);
        console.log('the suppliyrecovery'+JSON.stringify(component.get("v.SupplyRecoveryClaim")));        
             
        
        //Inserting the created Recovery Claim Record in the database      
                  helper.insertRaw(component, event,supplyRecoveryList,function(returnedValues) {
            
            //component.set("v.RecoveryClaimURL",helper.renderURL((component.get("v.SupplyRecoveryClaimRecord")).Id));
            console.log('the returned values'+JSON.stringify(returnedValues));
            var recoveryClaimIds = [];
            var sobjectList = [];
            var newRecoveryClaimsURLs = [];
            var newRecoveryclaims = [];
            sobjectList = returnedValues.sobjectsAndStatus;
            console.log('the returned ids...'+sobjectList.length);
            for(var i=0; i<sobjectList.length;i++ ){
                if(i == 0 && sobjectList.length > 1){
                   recoveryClaimIds[i] = sobjectList[i].sObject.Id+"'"; 
                }
                else if(i == 0 && sobjectList.length == 1){
                   recoveryClaimIds[i] = sobjectList[i].sObject.Id; 
                }
                else if(i == sobjectList.length - 1){
                   recoveryClaimIds[i] = "'"+sobjectList[i].sObject.Id;
                }
                else{
                   recoveryClaimIds[i] = "'"+sobjectList[i].sObject.Id+"'";     
                }
                console.log('the returned ids12'+sobjectList[i].sObject.Id);
                
            }
            component.set("v.SupplyRecoveryClaimList", recoveryClaimIds);                        
            var SupplierRecoveryClaimQuery = helper.RecoveryClaim_Query + "'" + component.get("v.SupplyRecoveryClaimList") + "'" + ")";
            
            //Reading the RecoveryClaim record
                    helper.readDom(component, event, SupplierRecoveryClaimQuery, "v.SupplyRecoveryClaim", "v.dmlErrors", function(returnedValues) {

                        //Insert the Newly created Supply Recovery Claim into the List                       
                        var object= [];
                        object= component.get("v.SupplyRecoveryClaim");
                        component.set("v.CreatedSupplyRecoveryClaimList",object);
                        console.log("The supply Recovery Claim list is**************"+JSON.stringify(component.get("v.CreatedSupplyRecoveryClaimList")));
  
                        if(component.get("v.CreatedSupplyRecoveryClaimList").length>0){                           
                            newRecoveryclaims = component.get("v.CreatedSupplyRecoveryClaimList");                                        
                            for(var i=0; i<newRecoveryclaims.length;i++){
                                var newRecoveyClaimURLMap ={rId : {id : '',url : '',url1:'', url2:''}};  
                                var newRecoveyClaimURL = helper.renderURL(component.get("v.baseURL"),newRecoveryclaims[i].Id);
                                var newRecoveyClaimURL1 = helper.renderURL(component.get("v.baseURL"),newRecoveryclaims[i].Supplier_Contract__c);
                                var newRecoveyClaimURL2 = helper.renderURL(component.get("v.baseURL"),newRecoveryclaims[i].Supplier_Contract__r.Supplier_Account__c);
                                newRecoveyClaimURLMap.rId.id = newRecoveryclaims[i].Id;
                                newRecoveyClaimURLMap.rId.url = newRecoveyClaimURL;
                                newRecoveyClaimURLMap.rId.url1 = newRecoveyClaimURL1;
                                newRecoveyClaimURLMap.rId.url2 = newRecoveyClaimURL2;
                                newRecoveryClaimsURLs[i] = newRecoveyClaimURLMap;
                                           }
                        }
                    component.set("v.newRecoveryClaimsURL",newRecoveryClaimsURLs);
                    console.log('.......12356...'+JSON.stringify(newRecoveryClaimsURLs));
                        
                        
                        //Inserting the related Line Items in the Recovery Line Items Object                        
                        for(var k = 0; k < object.length ; k++){
                             for(var i = 0; i < TempLineItemsContracts.length ; i++){
                                for(var j = 0; j < RemovedPartList.length ; j++){
                                    console.log('the temp line items'+JSON.stringify(TempLineItemsContracts[i].Supplier_Contract__c));
                                    console.log('the temp line items'+JSON.stringify(object[k].Supplier_Contract__c));
                                    if(TempLineItemsContracts[i].Supplier_Product__r.Product__r.Name == RemovedPartList[j].Warranty_Product_on_Recovery_Claim__c && object[k].Supplier_Contract__c == TempLineItemsContracts[i].Supplier_Contract__c){
                                        component.set("v.SupplyRecoveryLineItemRecord.Quantity__c",RemovedPartList[j].Quantity__c);        
                                        component.set("v.SupplyRecoveryLineItemRecord.Pending_Shipment_Quantity__c",RemovedPartList[j].Quantity__c); 
                                        component.set("v.SupplyRecoveryLineItemRecord.Removed_Claim_Part__c",RemovedPartList[j].Id); 
                                        component.set("v.SupplyRecoveryLineItemRecord.Part_Type__c",'Removed'); 
                                        component.set("v.SupplyRecoveryLineItemRecord.Supplier_Recovery_Claim__c",component.get("v.SupplyRecoveryClaim")[k].Id);
                                        component.set("v.SupplyRecoveryLineItemRecord.Warranty_Product__c",TempLineItemsContracts[i].Supplier_Product__r.Product__c);
                                        component.set("v.SupplyRecoveryLineItemRecord.Part_Return_Location_Warehouse__c",TempLineItemsContracts[i].Supplier_Contract__r.Part_Return_Location__c);
                                        component.set("v.SupplyRecoveryLineItemRecord.Supplier_Product__c",TempLineItemsContracts[i].Supplier_Product__c);
                                        
                                        //Insert the recovery Line Item record 
                                        helper.insertRaw(component, event,component.get("v.SupplyRecoveryLineItemRecord"),function(returnedValues) {
                                            console.log('Line Items Returned values after inserting the record.');
                                            console.log(returnedValues);
                                        });              
                                    }
                                }
                             }    
                        }
                        
                       
                    })
            
            
             component.set("v.showRecoveryClaims", true);
             component.set('v.spinnerBool.pageSpinner', false);
        });   
        
     
    },
    
    SearchValidContracts : function(component,SupplierContracts){
        
        var ContractIsActive = false;
        console.log("The Contracts that needs to be filtered");
        console.log(JSON.stringify(SupplierContracts));
        var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
        var inValidContracts = [];
        for(var i=0 ; i < SupplierContracts.length ; i++){
            ContractIsActive = false;
            //Below If condition is executed when the Validity Type on contract in 'Manufacturing Date'
            if(SupplierContracts[i].Supplier_Contract__r.Validity_Date_Type__c == 'Manufacturing Date'){
                console.log("In If");
                console.log(SupplierContracts[i].Name);
                console.log(SupplierContracts[i].Supplier_Product__r.Manufacuture_Date_del__c);
                console.log(SupplierContracts[i].Supplier_Contract__r.Valid_From__c);
                if(SupplierContracts[i].Supplier_Product__r.Manufacuture_Date_del__c >= SupplierContracts[i].Supplier_Contract__r.Valid_From__c && SupplierContracts[i].Supplier_Product__r.Manufacuture_Date_del__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c && (component.get("v.ClaimRecord").Date_of_Failure__c >= SupplierContracts[i].Supplier_Contract__r.Valid_From__c && component.get("v.ClaimRecord").Date_of_Failure__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c)){
                    
                    var MonthsCovered = parseInt(SupplierContracts[i].Supplier_Contract__r.Months_Covered__c);
                    var TempDate1 = new Date(SupplierContracts[i].Supplier_Product__r.OEM_Purchase_Date_del__c);
                    var dateOfFailure = new Date(component.get("v.ClaimRecord").Date_of_Failure__c);
                    //Formatting the Manufacture Date  from YYYY-MM-DD to DD/MM/YYYY
                    if (!isNaN(TempDate1.getTime())) {
                        // Months use 0 index.
                        var   FormateddManufacutureDate = new Date(TempDate1.getMonth() + 1 + '/' + TempDate1.getDate() + '/' + TempDate1.getFullYear());
                        console.log('......date'+FormateddManufacutureDate);
                    }
         
                    var ValidityCoverageDate = new Date();
                    ValidityCoverageDate.setMonth(FormateddManufacutureDate.getMonth() + MonthsCovered);
                    console.log("The Add months is");
                    console.log(ValidityCoverageDate);
                    
                    //Getting todays date in YYYY/MM/DD format
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = today.getMonth()+1; //January is 0!
                    var yyyy = today.getFullYear();
                    
                    if(dd<10) {
                        dd='0'+dd
                    } 
                    
                    if(mm<10) {
                        mm='0'+mm
                    } 
                    
                    today = mm+'/'+dd+'/'+yyyy;
                    console.log(today);
                    var finalToday = new Date(today);
                    console.log(finalToday.getTime());
                    
                    //Getting the ValidityCoverage date in YYYY/MM/DD format
             
                    var dd = ValidityCoverageDate.getDate();
                    var mm = ValidityCoverageDate.getMonth()+1; //January is 0!
                    var yyyy = ValidityCoverageDate.getFullYear();
                    
                    if(dd<10) {
                        dd='0'+dd
                    } 
                    
                    if(mm<10) {
                        mm='0'+mm
                    } 
                    
                    var ValidCoverageDateFormat = new Date(mm+'/'+dd+'/'+yyyy);
                    console.log("Contract date");
                    console.log(SupplierContracts[i].Supplier_Contract__r.Valid_To__c);
                    
                    var TempDate = new Date(SupplierContracts[i].Supplier_Contract__r.Valid_To__c);
                    
                    //Formatting the Contract date from YYYY-MM-DD to DD/MM/YYYY
                    if (!isNaN(TempDate.getTime())) {
                        // Months use 0 index.
                      var   FormateddDateOnContract = new Date(TempDate.getMonth() + 1 + '/' + TempDate.getDate() + '/' + TempDate.getFullYear());
              
                    }

                    var diffDays1 = Math.round(Math.abs((finalToday.getTime() - ValidCoverageDateFormat.getTime())/(oneDay)));
                             var diffDays2 = Math.round(Math.abs((finalToday.getTime() - FormateddDateOnContract.getTime())/(oneDay)));
                    console.log('diff days1'+diffDays1);
                    console.log('diff days2'+diffDays2);
                    
                    if(diffDays1 > diffDays2){
                        
                        if(component.get("v.ClaimRecord").Date_of_Failure__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c ){
                            ContractIsActive = true;
                        }else{
                            //SupplierContracts.splice(i,1);
                            ContractIsActive = false;
                        }
                        
                    }else{
                        if(dateOfFailure.getTime() <= ValidityCoverageDate.getTime()){                            
                            ContractIsActive = true;
                        }else{                            
                            ContractIsActive = false;
                         
                        }
                        
                    }

                }
  
            }else{
                console.log("In else");
                if(SupplierContracts[i].Supplier_Product__r.OEM_Purchase_Date_del__c >= SupplierContracts[i].Supplier_Contract__r.Valid_From__c && SupplierContracts[i].Supplier_Product__r.OEM_Purchase_Date_del__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c && (component.get("v.ClaimRecord").Date_of_Failure__c >= SupplierContracts[i].Supplier_Contract__r.Valid_From__c && component.get("v.ClaimRecord").Date_of_Failure__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c)){
                 
                    var MonthsCovered = parseInt(SupplierContracts[i].Supplier_Contract__r.Months_Covered__c);
              
                    var TempDate1 = new Date(SupplierContracts[i].Supplier_Product__r.OEM_Purchase_Date_del__c);
                    var dateOfFailure = new Date(component.get("v.ClaimRecord").Date_of_Failure__c);
                    console.log("helloo");
                    console.log(TempDate1);
                    
                                 //Formatting the OEM Purchase Date del date from YYYY-MM-DD to DD/MM/YYYY
                                 if (!isNaN(TempDate1.getTime())) {
                        // Months use 0 index.
                     
                                                var   FormateddOEMPurchaseDate = new Date(TempDate1.getMonth() + 1 + '/' + TempDate1.getDate() + '/' + TempDate1.getFullYear());
                        
                                 }
                    
                    var ValidityCoverageDate = new Date();
                    ValidityCoverageDate.setMonth(FormateddOEMPurchaseDate.getMonth() + MonthsCovered);
                    console.log("The Add months is");
                    console.log(ValidityCoverageDate);
                    
                    //Getting todays date in YYYY/MM/DD format
                    //-----------------------------------------------------------
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = today.getMonth()+1; //January is 0!
                    var yyyy = today.getFullYear();
                    
                        if(dd<10) {
                            dd='0'+dd
                        } 
                        
                        if(mm<10) {
                            mm='0'+mm
                        } 
                    
                    today = mm+'/'+dd+'/'+yyyy;
                    console.log(today);
                    var finalToday = new Date(today);
                    console.log(finalToday.getTime());
                    //---------------------------------------------------------------
                  
                    
                    //Getting the ValidityCoverage date in YYYY/MM/DD format
                    //-----------------------------------------------------------------
                    var dd = ValidityCoverageDate.getDate();
                    var mm = ValidityCoverageDate.getMonth()+1; //January is 0!
                    var yyyy = ValidityCoverageDate.getFullYear();
                    
                        if(dd<10) {
                            dd='0'+dd
                        } 
                        
                        if(mm<10) {
                            mm='0'+mm
                        } 
                    
                    var ValidCoverageDateFormat = new Date(mm+'/'+dd+'/'+yyyy);
                    //------------------------------------------------------------------
                    
                    console.log("Contract date");
                    console.log(SupplierContracts[i].Supplier_Contract__r.Valid_To__c);
                    
                    var TempDate = new Date(SupplierContracts[i].Supplier_Contract__r.Valid_To__c);
                    
                        //Formatting the Contract date from YYYY-MM-DD to DD/MM/YYYY
                        if (!isNaN(TempDate.getTime())) {
                            // Months use 0 index.
                            var   FormateddDateOnContract = new Date(TempDate.getMonth() + 1 + '/' + TempDate.getDate() + '/' + TempDate.getFullYear());
                            
                        }
                    
                    console.log('days');
                    
                    var diffDays1 = Math.round(Math.abs((finalToday.getTime() - ValidCoverageDateFormat.getTime())/(oneDay)));
                    console.log(diffDays1);
                    var diffDays2 = Math.round(Math.abs((finalToday.getTime() - FormateddDateOnContract.getTime())/(oneDay)));
                    console.log(diffDays2);
                    
                                            if(diffDays1 > diffDays2){
                                console.log(component.get("v.ClaimRecord").Date_of_Failure__c);
                                console.log(SupplierContracts[i].Supplier_Contract__r.Valid_To__c );
                                if(component.get("v.ClaimRecord").Date_of_Failure__c <= SupplierContracts[i].Supplier_Contract__r.Valid_To__c ){
                                    ContractIsActive = true;
                                }else{
                                    ContractIsActive = false;
                                    
                                }
                        
                                              }else{
                        
                                if(dateOfFailure.getTime() <= ValidityCoverageDate.getTime()){
                                    ContractIsActive = true;
                                }else{
                                    ContractIsActive = false;
                                    
                                }
                                            }
                }
            }
            console.log('....'+ContractIsActive);
            if(ContractIsActive == false){
                console.log('the enter123');
                //var FinalSupplierContract = component.get("v.supplierContracts");
                console.log('.......'+SupplierContracts.length);
                inValidContracts.push(SupplierContracts[i].Supplier_Contract__r.Id);
                SupplierContracts.splice(i,1);
                console.log('...final one ...'+JSON.stringify(SupplierContracts.length));
                component.set("v.supplierContracts",SupplierContracts);
                
            }
        }
    }

    
})