/**********************************************************************
 Name:  RecoveryClaimpageCtrl
 Copyright � 2016   Tavant tech inc
 ==============================================================
===============================================================
Purpose:  To create Supply Recovery Claim
                                                     
-------                                                             
===============================================================
without sharing explanation:
This is class used to query warranty product and remove claim part data. 
Admin user only have full access on warranty product and remove claim part data object. 
Dealer/Internal users don’t have permissions for all fields on warranty product and remove claim part data object.
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR                    DATE                 DETAIL   FEATURES/CSR/TTP
1.0 -    Rohit    02/02/2016       INITIAL DEVELOPMENT            
***********************************************************************/

global without sharing class RecoveryClaimpageCtrl {
    
    global list<claim__c> ClaimRecordList{get;set;}
    global Warranty_Product__c CausalPartDataList{get;set;}
    global claim__c Claimrecord{get;set;}
    global List<Id> claimIdList{get;set;}
    global Boolean ShowContractButton{get;set;}
    global Boolean ShowRemovedPartSection{get;set;}
    global list<Supplier_Recovery_Claim__c> SupplyRecoveryClaimLinkList{get;set;}
    global Boolean ShowCreateClaimButton{get;set;}
    global Boolean ShowRecoveryClaimTable{get;set;}
    global list<Supplier_Contract_Item__c> SupplierContractList{get;set;}
    global Map<String,List<WarrantyProductWrapperClass>> mapObj{get;set;}
    global list<Supplier_Contract_Item__c> ValidSupplierContractList{get;set;}
    global list<Removed_Claim_Part__c> RemovedPartList{get;set;}
    global list<WarrantyProductWrapperClass> SupplierContractData{get;set;}
    global List<WarrantyProductWrapperClass> ContractInfo; 
    global List<SupplyRecoveryWrapperClass> SupplyRecoveryClaimInfoList{get;set;} 
    global claim__c CurrentClaimRecord;
    global Map<String,integer> CausalPart;
    global Map<String,Decimal> RemovedPartMap;
    global String RemovedPart;
    global Set<String> RecovertClaimProductsSet; 
    global Map<String,Integer> PartsHavingNoContractsCollatLogic; 
    global Boolean CausalApplicableLogic;
    global ApexPages.standardcontroller controller;
    
    
global RecoveryClaimpageCtrl(ApexPages.standardcontroller controller){
    
    
    PartsHavingNoContractsCollatLogic =  new Map<String,Integer>();
    this.CurrentClaimRecord = (claim__c)controller.getRecord();
    RemovedPartList = new list<Removed_Claim_Part__c>();
    claimIdList = new list<id>();
    SupplyRecoveryClaimLinkList = new list<Supplier_Recovery_Claim__c>();
    SupplyRecoveryClaimInfoList = new List<SupplyRecoveryWrapperClass>();
    SupplierContractList = new list<Supplier_Contract_Item__c>();
    ValidSupplierContractList = new list<Supplier_Contract_Item__c>();
    CausalPart = new Map<String,Integer>();
    RemovedPartMap = new Map<String,Decimal>();
    Removed_Part_Visibility__c CustomSettingForRemovedParts = Removed_Part_Visibility__c.getOrgDefaults();
    Boolean customvalue = CustomSettingForRemovedParts.Show_Removed_Parts__c;
    ShowRemovedPartSection = False;
    ShowContractButton = True;
    ShowCreateClaimButton = False;
    ShowRecoveryClaimTable = False;
    CausalApplicableLogic = False;
    RecovertClaimProductsSet = new Set<String>();
    ClaimRecordList = [select id,Date_of_Repair__c,Date_Of_Purchase__c,causal_Part_Number__c,Date_of_Failure__c from claim__c where id =: CurrentClaimRecord.id];
    getCausalPartdetails();
   
   // If custom Setting Value is True then Removed parts will be included in the Recovery CLaim
    if(customvalue == True){
       getRemovedPartdetails(); 
       ShowRemovedPartSection = True;
    }
}

global void getCausalPartdetails(){
    CausalPartDataList = new Warranty_Product__c();
    CausalPartDataList = [select id,Name,Item_Type__c,Track_Type__c,Product_Name__c from Warranty_Product__c where id =: ClaimRecordList[0].causal_Part_Number__c limit 1];
    if(CausalPartDataList != Null){
       CausalPart.put(CausalPartDataList.Name,1);
       RecovertClaimProductsSet.add(CausalPartDataList.Name);    
    }
    
    system.debug('%%%%'+RecovertClaimProductsSet);
}




global void getRemovedPartdetails(){
    List<String> RemovedPartList1 = new list<String>();
    system.debug('##coming to pate2');
    RemovedPartList = [select id,Warranty_Product_on_Recovery_Claim__c,Quantity__c,Warranty_Product_Name_on_Recovery_Claim__c,RecordType.name,Warranty_Product__c,Warranty_Product__r.name,Warranty_Product__r.Product_Name__c,Inventory__r.Item__r.name, Inventory__r.Item__r.Product_Name__c from Removed_Claim_Part__c where Claim__c =:  CurrentClaimRecord.id];


    for(Removed_Claim_Part__c rec: RemovedPartList){
        
        RemovedPartList1.add(rec.Warranty_Product_on_Recovery_Claim__c);
        RemovedPartMap.put(rec.Warranty_Product_on_Recovery_Claim__c,rec.Quantity__c);
        
    }
    
    system.debug('####'+RecovertClaimProductsSet);
    RecovertClaimProductsSet.addAll(RemovedPartList1);
    system.debug('&&&&&&'+RecovertClaimProductsSet);
}


//Seacrh the availaible contracts for the causal or removed parts fetched from the warranty Claim.

global void SearchContractForParts(){

     
    Set<Supplier_Contract_Item__c> DistinctContracts = new Set<Supplier_Contract_Item__c>();
    SupplierContractList = [select id,  Supplier_Product__r.OEM_Purchase_Date_del__c,Supplier_Product__c,Supplier_Product__r.name,Supplier_Product__r.Product__c,Supplier_Product__r.Manufacuture_Date_del__c,Supplier_Product__r.Product__r.name,Supplier_Contract__r.Name,Supplier_Contract__r.Is_Collateral_Applicable__c,Supplier_Contract__r.Is_Part_Return_Required__c,Supplier_Contract__r.Validity_Date_Type__c,Supplier_Contract__r.Valid_From__c,Supplier_Contract__r.Valid_To__c,Supplier_Contract__r.Months_Covered__c,Supplier_Contract__r.Supplier_Account__r.Name,
    Supplier_Contract__r.Minimum_recoverable_percent__c,Supplier_Contract__r.Part_Return_Location__r.name  from Supplier_Contract_Item__c where Supplier_Product__r.Product__r.name =: RecovertClaimProductsSet];
    GetValidContracts(SupplierContractList);
    DistinctContracts.addAll(ValidSupplierContractList);
    ValidSupplierContractList.clear();
    ValidSupplierContractList.addAll(DistinctContracts);
    system.debug('$$$the all contractlist $$$' +SupplierContractList);
    system.debug('$$$the valid supplier contract list$$$' +ValidSupplierContractList);
    ShowCreateClaimButton = True; 
}


//The Below Method gets the Valid Active Contracts for the Respective cousal/Removed parts from the above SupplierContractList

global void  GetValidContracts(list<Supplier_Contract_Item__c> SupplierContractList){
    Date ValidityCoverageDate;
    Integer Days1;
    Integer Days2;
    Boolean ContractIsActive;
    Integer  MonthsCovered;
    
   // mapObj.clear();
   System.debug(':::1:::: mapObj:'+mapObj);
    mapObj = new Map<String,List<WarrantyProductWrapperClass>>();
    System.debug(':::2:::: mapObj:'+mapObj);
    System.debug('::::::: Supplieer contract list:'+SupplierContractList);
    for(Supplier_Contract_Item__c Rec : SupplierContractList){
    ContractIsActive = false;
    if(Rec.Supplier_Contract__r.Validity_Date_Type__c == 'Manufacturing Date'){
      
            if(Rec.Supplier_Product__r.Manufacuture_Date_del__c > = Rec.Supplier_Contract__r.Valid_From__c && Rec.Supplier_Product__r.Manufacuture_Date_del__c <=  Rec.Supplier_Contract__r.Valid_To__c && (ClaimRecordList[0].Date_of_Failure__c >= Rec.Supplier_Contract__r.Valid_From__c && ClaimRecordList[0].Date_of_Failure__c <= Rec.Supplier_Contract__r.Valid_To__c)){
         
                MonthsCovered = Rec.Supplier_Contract__r.Months_Covered__c.intValue();
               
             
                ValidityCoverageDate = Rec.Supplier_Product__r.Manufacuture_Date_del__c.addMonths(MonthsCovered);
              
                days1 =  system.today().daysBetween(ValidityCoverageDate);
                days2 =  system.today().daysBetween(Rec.Supplier_Contract__r.Valid_To__c);
               
                if(days1 > days2){
                  
                        if(ClaimRecordList[0].Date_of_Failure__c < = Rec.Supplier_Contract__r.Valid_To__c){
                            ContractIsActive = True;
                        }else{
                            ContractIsActive = False;
                        }
                 }else{
    
                        if(ClaimRecordList[0].Date_of_Failure__c < = ValidityCoverageDate){
                            ContractIsActive = True;
                        }else{
                            ContractIsActive = False;
                        }
                    }
            }
    } 
    else{
            if(Rec.Supplier_Product__r.OEM_Purchase_Date_del__c > = Rec.Supplier_Contract__r.Valid_From__c && Rec.Supplier_Product__r.OEM_Purchase_Date_del__c <=  Rec.Supplier_Contract__r.Valid_To__c && ClaimRecordList[0].Date_of_Failure__c >= Rec.Supplier_Contract__r.Valid_From__c && ClaimRecordList[0].Date_of_Failure__c <= Rec.Supplier_Contract__r.Valid_To__c){
             
                MonthsCovered = Rec.Supplier_Contract__r.Months_Covered__c.intValue();
                ValidityCoverageDate = Rec.Supplier_Product__r.OEM_Purchase_Date_del__c.addMonths(MonthsCovered);
                days1 =  system.today().daysBetween(ValidityCoverageDate);
                days2 =  system.today().daysBetween(Rec.Supplier_Contract__r.Valid_To__c);
            
                    if(days1 > days2){
                        
                        if(ClaimRecordList[0].Date_of_Failure__c < = Rec.Supplier_Contract__r.Valid_To__c){
                            ContractIsActive = True;
                        }else{
                            ContractIsActive = False;
                        }
                    }else{
                        if(ClaimRecordList[0].Date_of_Failure__c < = ValidityCoverageDate){
                            ContractIsActive = True;
                        }else{
                            ContractIsActive = False;
                        }
                
                    }
        
         }
      
    }
    
    if(ContractIsActive == True){
        ValidSupplierContractList.add(Rec);    
    }
        
    }
    
   //Below code to create wrapper data based on the validsuppliercontractlist, seperate contract data based on the Parts. 
        
        for(integer i = 0;i<RecovertClaimProductsSet.size();i++){
             List<WarrantyProductWrapperClass> ContractInfo = new List<WarrantyProductWrapperClass>();
             List<WarrantyProductWrapperClass> tempWrapperClass = new List<WarrantyProductWrapperClass>();
             for(Supplier_Contract_Item__c Rec : ValidSupplierContractList){
                    
                   
                        if(rec.Supplier_Product__r.Product__r.name == (new list<string>(RecovertClaimProductsSet) )[i]){
               
                        WarrantyProductWrapperClass ContractWrapperObject = new WarrantyProductWrapperClass();
                        ContractWrapperObject.WarrantyProductName = Rec.Supplier_Product__r.Product__r.name;
                        ContractWrapperObject.SupplierProductId = Rec.Supplier_Product__c;
                        ContractWrapperObject.IsPartReturnRequired = Rec.Supplier_Contract__r.Is_Part_Return_Required__c;
                        ContractWrapperObject.SupplierProductName = Rec.Supplier_Product__r.name;
                        ContractWrapperObject.WarrantyProductId = Rec.Supplier_Product__r.Product__c;
                        ContractWrapperObject.ContractName = Rec.Supplier_Contract__r.Name;
                            if(CausalPart.containsKey(Rec.Supplier_Product__r.Product__r.name) == True){
                                ContractWrapperObject.PartType = 'Causal';
                            }else{
                                ContractWrapperObject.PartType = 'Removed';
                            }    
                        
                        
                        ContractWrapperObject.PartReturnLocation = Rec.Supplier_Contract__r.Part_Return_Location__r.name;
                        ContractWrapperObject.isSelected = False;
                        ContractWrapperObject.SupplierAccountName = Rec.Supplier_Contract__r.Supplier_Account__r.Name;
                        ContractWrapperObject.MinimumRecovareablePercentage = Rec.Supplier_Contract__r.Minimum_recoverable_percent__c;
                            if(Rec.Supplier_Contract__r.Is_Collateral_Applicable__c == True){
                            ContractWrapperObject.IsCollateralApplicable = True;    
                            }else{
                            ContractWrapperObject.IsCollateralApplicable = False;    
                            }
                        
                        tempWrapperClass.add(ContractWrapperObject);
           
                        }  
                    
            }
            
            system.debug('##contract info' + i + '%%%' + ContractInfo);
            ContractInfo.addAll(tempWrapperClass);
            system.debug(':::::RecovertClaimProductsSet' + (new list<string>(RecovertClaimProductsSet) )[i]);
            mapObj.put((new list<string>(RecovertClaimProductsSet) )[i],ContractInfo);
            System.debug('######11'+ (new list<string>(RecovertClaimProductsSet) )[i] + '&&&&' +mapObj.get((new list<string>(RecovertClaimProductsSet) )[i]));
            
            if(mapObj.get((new list<string>(RecovertClaimProductsSet) )[i]).size() == 0){
              PartsHavingNoContractsCollatLogic.put(new list<string>(RecovertClaimProductsSet)[i],1);    
              ApexPages.Message myMsg4 = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Active Contract Availaible for   '+new list<string>(RecovertClaimProductsSet)[i] );
              ApexPages.addMessage(myMsg4);    
           
            }  
       }
       
      system.debug('::The no warrant product are::'+PartsHavingNoContractsCollatLogic.keySet());
      ShowContractButton = False;  
}


global void ShowCreatedClaim(){
    ShowRecoveryClaimTable = True;
    list<WarrantyProductWrapperClass> MapValuesVFPage = new   list<WarrantyProductWrapperClass>();
    list<WarrantyProductWrapperClass> MapValuesVFPageCollateral = new   list<WarrantyProductWrapperClass>();
    
    Map<String,Integer> TempMap = new Map<String,Integer>(); 
    Set<String> ProductKeySet = new Set<String>();
    ProductKeySet = mapObj.keySet();
    for(integer j=0;j<ProductKeySet.size();j++){
        
        list<WarrantyProductWrapperClass> ValidSupplyRecoveryClaimList = new list<WarrantyProductWrapperClass>();   
        ValidSupplyRecoveryClaimList = (mapObj.get((new list<string>(ProductKeySet) )[j]));
      
            for(WarrantyProductWrapperClass rec : ValidSupplyRecoveryClaimList){
               if(rec.isSelected == True){    
               MapValuesVFPage.add(rec);
               }else{
               MapValuesVFPageCollateral.add(rec);          
               }
            }
        
     }
     
   //MapValuesVFPage contains all the data of the contract which is selected on VF page
   //MapValuesVFPageCollateral contains all the data of the contract which is not selected but have active contract and under collateral logic
    system.debug('::::::final lists'+MapValuesVFPage);
    system.debug('::::::final lists for collateral'+MapValuesVFPageCollateral);
    
   //Below Code Populate the Causal part contract information
    WarrantyProductWrapperClass tempWrapObjectCollateral = new WarrantyProductWrapperClass();      
    for(WarrantyProductWrapperClass TempwrapCausal : MapValuesVFPage){
        system.debug(':::contains key product name:::'+TempwrapCausal.WarrantyProductName);
        system.debug(':::causal part keyset:::'+CausalPart.keySet());
        if(TempwrapCausal.IsCollateralApplicable == True && CausalPart.containsKey(TempwrapCausal.WarrantyProductName) == True ){
            system.debug(':::Applicable to collateral logic::');
            CausalApplicableLogic = True;
            tempWrapObjectCollateral.ContractName = TempwrapCausal.ContractName;
            tempWrapObjectCollateral.IsPartReturnRequired = TempwrapCausal.IsPartReturnRequired;
            tempWrapObjectCollateral.SupplierProductId = TempwrapCausal.SupplierProductId;
            tempWrapObjectCollateral.PartReturnLocation = TempwrapCausal.PartReturnLocation;
            tempWrapObjectCollateral.WarrantyProductName = TempwrapCausal.WarrantyProductName;
            tempWrapObjectCollateral.SupplierProductName = TempwrapCausal.SupplierProductName;
            tempWrapObjectCollateral.WarrantyProductId = TempwrapCausal.WarrantyProductId;
            tempWrapObjectCollateral.SupplierAccountName = TempwrapCausal.SupplierAccountName;
            tempWrapObjectCollateral.MinimumRecovareablePercentage = TempwrapCausal.MinimumRecovareablePercentage;
        }
        
    } 
    
    //Below "IF" set of code will work when the Collateral logic is applicable
   
    if(CausalApplicableLogic == True){
          system.debug('yes collateral logic is true');
          Map<String,Integer> DistinctPartsCollateralLogic = new Map<String,Integer>();
          list<WarrantyProductWrapperClass> WrapValuesCollateral = new   list<WarrantyProductWrapperClass>(); 
          if(tempWrapObjectCollateral != Null){
          WrapValuesCollateral.add(tempWrapObjectCollateral);
          DistinctPartsCollateralLogic.put(tempWrapObjectCollateral.WarrantyProductName, 1);
          }
          
          //For Loop to select all remaining parts having active contracts in collateral logic
           for(WarrantyProductWrapperClass TempRecCollateral : MapValuesVFPageCollateral){
                if(DistinctPartsCollateralLogic.containsKey(TempRecCollateral.WarrantyProductName) != True){
                WarrantyProductWrapperClass tempwrap1Object1 = new WarrantyProductWrapperClass();  
                tempwrap1Object1.ContractName = tempWrapObjectCollateral.ContractName;
                tempwrap1Object1.IsPartReturnRequired = tempWrapObjectCollateral.IsPartReturnRequired;
                tempwrap1Object1.SupplierProductId = TempRecCollateral.SupplierProductId;
                tempwrap1Object1.SupplierProductName = TempRecCollateral.SupplierProductName;
                tempwrap1Object1.WarrantyProductId = TempRecCollateral.WarrantyProductId;
                tempwrap1Object1.PartReturnLocation = tempWrapObjectCollateral.PartReturnLocation;
                tempwrap1Object1.WarrantyProductName = TempRecCollateral.WarrantyProductName;
                tempwrap1Object1.SupplierAccountName = tempWrapObjectCollateral.SupplierAccountName;
                tempwrap1Object1.MinimumRecovareablePercentage = tempWrapObjectCollateral.MinimumRecovareablePercentage;  
                WrapValuesCollateral.add(tempwrap1Object1);
                DistinctPartsCollateralLogic.put(TempRecCollateral.WarrantyProductName, 1);
                }
           }
           
           //For Loop to select all remaining parts having No active contracts in collateral logic
            system.debug(':::The list after collateral logic'+WrapValuesCollateral);    
                
             for(String Prodtemp : PartsHavingNoContractsCollatLogic.keySet())    {
                
                system.debug('::::The no contract part in of loop');
                WarrantyProductWrapperClass tempwrap1Object2 = new WarrantyProductWrapperClass();    
                tempwrap1Object2.ContractName = tempWrapObjectCollateral.ContractName;    
                tempwrap1Object2.IsPartReturnRequired = tempWrapObjectCollateral.IsPartReturnRequired;  
                tempwrap1Object2.WarrantyProductId = [select id,name from Warranty_Product__c where name =: Prodtemp][0].id;
                tempwrap1Object2.PartReturnLocation  =  tempWrapObjectCollateral.PartReturnLocation;
                tempwrap1Object2.WarrantyProductName = Prodtemp;
                tempwrap1Object2.SupplierAccountName = tempWrapObjectCollateral.SupplierAccountName;
                tempwrap1Object2.MinimumRecovareablePercentage = tempWrapObjectCollateral.MinimumRecovareablePercentage; 
                WrapValuesCollateral.add(tempwrap1Object2);
                
            }
                
                CreateSuppyRecoveryClaim(WrapValuesCollateral);

    }else{
           
          if(MapValuesVFPage.isEmpty() == False){
     
                for(WarrantyProductWrapperClass TempRec : MapValuesVFPage){
                    Integer ind = 0;
                    list<WarrantyProductWrapperClass> WrapValues = new   list<WarrantyProductWrapperClass>(); 
                    for(WarrantyProductWrapperClass TempRec1 : MapValuesVFPage){
             
                         if(TempRec1.ContractName == TempRec.ContractName  && TempMap.containsKey(TempRec.ContractName) == false){
                                WarrantyProductWrapperClass tempwrap1Object = new WarrantyProductWrapperClass();  
                                tempwrap1Object.WarrantyProductName = TempRec1.WarrantyProductName;
                                tempwrap1Object.ContractName = TempRec1.ContractName;
                                tempwrap1Object.IsPartReturnRequired = TempRec1.IsPartReturnRequired;
                                tempwrap1Object.SupplierProductId = TempRec1.SupplierProductId;
                                tempwrap1Object.PartReturnLocation = TempRec1.PartReturnLocation;
                                tempwrap1Object.SupplierProductName = TempRec1.SupplierProductName;
                                tempwrap1Object.WarrantyProductId = TempRec1.WarrantyProductId;
                                tempwrap1Object.SupplierAccountName = TempRec1.SupplierAccountName;
                                tempwrap1Object.MinimumRecovareablePercentage = TempRec1.MinimumRecovareablePercentage;
                                WrapValues.add(tempwrap1Object);
                            
                        }
            
                    }
                            
                        system.debug('::::the send wrap::::'+WrapValues);
                        CreateSuppyRecoveryClaim(WrapValues);
                        TempMap.put(TempRec.ContractName, ind);
                        ind++;
                }    
                ShowCreateClaimButton = False;    
         }else{
              
                ShowCreateClaimButton = True;
                ShowRecoveryClaimTable = False;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Select contract to create Recovery Claim.');
                ApexPages.addMessage(myMsg);
              
        }
      

  }

}


global void CreateSuppyRecoveryClaim(list<WarrantyProductWrapperClass> WrapValues){
    String SupplierContractName;
  
    system.debug(':::::the claim values' +WrapValues );
    Supplier_Recovery_Claim__c SupplierRecoveryClaimRec = new  Supplier_Recovery_Claim__c();

           if(WrapValues.size() > 0){ 
                        System.debug('::::contract is checked::::    ');
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Warranty_Claim__c.isCreateable()){
                        SupplierRecoveryClaimRec.Warranty_Claim__c = CurrentClaimRecord.id;
                        }
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Supplier_Contract__c.isCreateable() && Schema.sObjectType.Supplier_Contract__c.fields.Name.isAccessible()){
                        SupplierRecoveryClaimRec.Supplier_Contract__c = [select id,Name from Supplier_Contract__c where name =: WrapValues[0].ContractName  ][0].id;
                        }
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Status__c.isCreateable()){
                        SupplierRecoveryClaimRec.Status__c = 'Draft'; 
                        } 
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Is_Part_Return_Required__c.isCreateable()){
                        SupplierRecoveryClaimRec.Is_Part_Return_Required__c = WrapValues[0].IsPartReturnRequired;
                        }  
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Repair_Date__c.isCreateable()){
                        SupplierRecoveryClaimRec.Repair_Date__c = ClaimRecordList[0].Date_of_Repair__c;  
                        }
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Purchase_Date__c.isCreateable()){
                        SupplierRecoveryClaimRec.Purchase_Date__c = ClaimRecordList[0].Date_Of_Purchase__c;
                        }
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Failure_Date__c.isCreateable()){
                        SupplierRecoveryClaimRec.Failure_Date__c = ClaimRecordList[0].Date_of_Failure__c;  
                        }
                        if (Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Submission_Date__c.isCreateable()){
                        SupplierRecoveryClaimRec.Submission_Date__c = system.today();
                        } 
                        if(ClaimRecordList[0].Date_of_Failure__c > system.today() && Schema.sObjectType.Supplier_Recovery_Claim__c.fields.Failure_Date__c.isCreateable()){
   
                             SupplierRecoveryClaimRec.Failure_Date__c = ClaimRecordList[0].Date_of_Failure__c;
   
                        }else{
   
                             system.debug('The Failure date is the future date');
       
                        }
           }
          
        
          try{
              if (Schema.sObjectType.Supplier_Recovery_Claim__c.isCreateable()) {
              insert SupplierRecoveryClaimRec;
              }
              //Hide the Show Claim Button after inserting i.e creation of supply recovery claim
             
              system.debug('::::supplier claim:::' +SupplierRecoveryClaimRec);
              String ClaimName = [select name from Supplier_Recovery_Claim__c where id = :SupplierRecoveryClaimRec.id][0].name;
              claimIdList.add(SupplierRecoveryClaimRec.id); 
              //Populating the supply recovery claim wrapper class to show the details on the VF page.
              SupplyRecoveryWrapperClass ClaimWrapObj = new SupplyRecoveryWrapperClass();
              ClaimWrapObj.SupplyRecoveryClaimId = SupplierRecoveryClaimRec.id;
              ClaimWrapObj.SupplyRecoveryClaimName = ClaimName;
              ClaimWrapObj.SupplyRecoveryContractName = WrapValues[0].ContractName;
              SupplyRecoveryClaimInfoList.add(ClaimWrapObj);
              System.debug('::::The supplly recovery wrapper::::' +SupplyRecoveryClaimInfoList);
             
              
          }catch(exception e){
              
              system.debug(':::::Insert Problem');
          }
          
          
           for(WarrantyProductWrapperClass lineItems : WrapValues){
             
               Supply_Recovery_Claim_Line_Items__c RecoveryClaimLineItem = new Supply_Recovery_Claim_Line_Items__c();   
           
           //CausalPart Map is used to add the causal part, to differentiate the product as cousal or removed part.
           
                       if(CausalPart.containsKey(lineItems.WarrantyProductName) == True){
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Quantity__c.isCreateable()){
                             RecoveryClaimLineItem.Quantity__c=1;
                             }
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isCreateable()){
                             RecoveryClaimLineItem.Pending_Shipment_Quantity__c=1;
                             }
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Part_Type__c.isCreateable()){
                             RecoveryClaimLineItem.Part_Type__c = 'Causal';
                             }
           
                       }else{
                             //The quanity field is populated by the quanity field from the removed part
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Quantity__c.isCreateable()){
                             RecoveryClaimLineItem.Quantity__c = RemovedPartMap.get(lineItems.WarrantyProductName);
                             }
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Pending_Shipment_Quantity__c.isCreateable()){
                             RecoveryClaimLineItem.Pending_Shipment_Quantity__c = RemovedPartMap.get(lineItems.WarrantyProductName);
                             }
                             if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Part_Type__c.isCreateable()){
                             RecoveryClaimLineItem.Part_Type__c   = 'Removed'; 
                             }
                       }
                       
                       //Below Logic sets the part cost for the removed parts with no contracts to Zero so that it can skip the 
                       // flow to calculate the part cost having no matching Contract line items 
                       if(PartsHavingNoContractsCollatLogic.containsKey(lineItems.WarrantyProductName) && Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Part_Price__c.isCreateable()){
                             RecoveryClaimLineItem.Part_Price__c = 0;
                       }
                       if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Supplier_Recovery_Claim__c.isCreateable()){
                       RecoveryClaimLineItem.Supplier_Recovery_Claim__c = SupplierRecoveryClaimRec.id;
                       }
                       system.debug('The Values of claim id'+RecoveryClaimLineItem.Supplier_Recovery_Claim__c );
                       if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Warranty_Product__c.isCreateable()){
                       RecoveryClaimLineItem.Warranty_Product__c  = lineItems.WarrantyProductId;
                       }
                       system.debug(':::return lcoation'+lineItems.PartReturnLocation);
                           if(lineItems.PartReturnLocation != Null){
                            Id ReturnLocationId = [select id,name from Warehouse__c where name =: lineItems.PartReturnLocation ].id;
                            system.debug(':::WarehouseId'+ReturnLocationId);
                            if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Part_Return_Location_Warehouse__c.isCreateable()){
                            RecoveryClaimLineItem.Part_Return_Location_Warehouse__c = ReturnLocationId; 
                            }
                           }else{
                           if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Part_Return_Location_Warehouse__c.isCreateable()){
                            RecoveryClaimLineItem.Part_Return_Location_Warehouse__c = Null;  
                            } 
                               
                           }
                       
                       system.debug(':::dsdsd'+RecoveryClaimLineItem.Part_Return_Location_Warehouse__c);
                       if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Is_Part_Return_Required__c.isCreateable()){
                       RecoveryClaimLineItem.Is_Part_Return_Required__c  = lineItems.IsPartReturnRequired; 
                       }
                       if (Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.fields.Supplier_Product__c.isCreateable()){
                       RecoveryClaimLineItem.Supplier_Product__c   = lineItems.SupplierProductId;
                       }
            
                       try{
                            system.debug(':::the product name is'+lineItems.WarrantyProductName);
                            system.debug(':::Keysetproduct::'+CausalPart.keySet());
                            system.debug('::the causal part or no');
                            system.debug(CausalPart.containsKey(lineItems.WarrantyProductName));
                            if(CausalPart.containsKey(lineItems.WarrantyProductName) != true && Schema.sObjectType.Supply_Recovery_Claim_Line_Items__c.isCreateable() )    {
                                system.debug('+++Inside id');
                               insert RecoveryClaimLineItem;
                               system.debug(':::the recovery claim line item id'+RecoveryClaimLineItem.id);                
                            }
                           
                       }catch(exception e){
                           system.debug(':::::Insert Problem');
                       }
              
          }
          
   
      System.debug('::::contract is not checked');
      ShowCreateClaimButton = False; 
      system.debug(':::::::The supplyrecoveryclaim created::::::::'+SupplierRecoveryClaimRec);
      system.debug(':::::::The claim Ids::::::::'+claimIdList);
}


global pagereference Goback(){
    return null;
}

global  class WarrantyProductWrapperClass{
global String WarrantyProductName{get;set;}    
global String ContractName{get;set;}  
global Boolean IsPartReturnRequired{get;set;}  
global String SupplierAccountName{get;set;}
global String SupplierProductId{get;set;}
global String SupplierProductName{get;set;}
global String WarrantyProductId{get;set;}
global String PartType{get;set;}
global String PartReturnLocation{get;set;}
global boolean isSelected{get;set;}
global Decimal MinimumRecovareablePercentage{get;set;}
global boolean IsCollateralApplicable{get;set;}


   global WarrantyProductWrapperClass(){
       
   }
    
}

global class SupplyRecoveryWrapperClass{
global String SupplyRecoveryClaimId{get;set;}    
global String SupplyRecoveryClaimName{get;set;}
global String SupplyRecoveryContractName{get;set;}
    
   global  SupplyRecoveryWrapperClass(){
       
       
   }
    
}

}