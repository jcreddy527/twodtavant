/**********************************************************************
 Name:  TestUtility
 Copyright ? 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Contains data generating modules to create the test data for the RecoveryClaimpageCtrlTest.
                                                     -------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Rohit         03/10/2016      INITIAL DEVELOPMENT        */      


@isTest
public class TestutilityRecoveryClaim {


Static Warranty_Product__c WarrantyProduct = new Warranty_Product__c();
Static Supplier_Product__c supplierProduct = new Supplier_Product__c();
Static Supplier_Contract__c Contractrec = new Supplier_Contract__c();
/********************************************************************
PURPOSE:   To Create Test Record for claim object                                                
PARAMETERS: N/A
RETURNS: list of Claim Records
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/ 
   public static testmethod Claim__c createClaimTestRecords(){
            CustomSettingsUtilityTest.init();
            Warranty_Product__c  warrantyProd =TestUtility.createWarrantyProduct();
            integer i;
             list<Account> tempAccountRecordsList = TestUtility.createAccountTestRecords();
            If(CrudUtil.isAccountCreateable())
                insert tempAccountRecordsList;
            
            Claim__c tempClaimObj = new Claim__c();
            
            //tempClaimObj.id = 'a05610000069N4b';
            tempClaimObj.Delay_Reason__c     = 'test comment';
            tempClaimObj.Causal_Part_Number__c = warrantyProd.id;
            tempClaimObj.Date_of_Failure__c = system.today();
            tempClaimObj.Account__c= tempAccountRecordsList[0].id;
            system.debug(':::the warranty product is'+tempClaimObj.Causal_Part_Number__c);
            /*       if(Schema.sObjectType.Claim__c.fields.Name.isUpdateable()&&
               Schema.sObjectType.Claim__c.fields.Account__c.isUpdateable())
            {
                        
                        tempClaimObj.Name='TempClaim'+i;
                        tempClaimObj.Account__c='00161000003shad';
                   
              
            }*/
          
            
                
            //upsert tempClaimObj;
          
            return tempClaimObj;
    }
    
    

/********************************************************************
PURPOSE:   To Create Test Record for Removed Parts                                                
PARAMETERS: N/A
RETURNS: list of Claim Removed Parts 
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/ 

    

    public static testMethod Warranty_Product__c createWarrantyProductRecords(){
        //CustomSettingsUtilityTest.init();
        Warranty_Product__c TestWarrantyProduct = new Warranty_Product__c();
       
          TestWarrantyProduct.Name = 'EngineTestrecovery1';
          TestWarrantyProduct.Type__c = 'Item';
          TestWarrantyProduct.Item_Type__c = 'Parts';
          TestWarrantyProduct.Product_Name__c = 'EngineTestrecovery1'; 
          TestWarrantyProduct.Track_Type__c ='Non-Serialized';
          insert TestWarrantyProduct; 
          system.debug(':::the warranty prod id'+TestWarrantyProduct);
          WarrantyProduct.id = TestWarrantyProduct.id;
        
        return TestWarrantyProduct ;       
        
    }




/********************************************************************
PURPOSE:   To Create Test Record for Removed Parts                                                
PARAMETERS: N/A
RETURNS: list of Claim Removed Parts 
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/ 
    
    public static testMethod list<Removed_Claim_Part__c> createremovedclaimpartsRecords(){
        CustomSettingsUtilityTest.init();
        list<Removed_Claim_Part__c> testremovedpartrecords = new list<Removed_Claim_Part__c>();
        Integer i;
     /*   for(i=0;i<10;i++){
            Removed_Claim_Part__c testremovedpart = new Removed_Claim_Part__c();
            testremovedpart.Name = 'TestPartRem' + i;
            testremovedpart.Claim__c = createTestClaim().id;
            testremovedpart.Warranty_Product__c = createWarrantyProductRecords().id;
            testremovedpart.Quantity__c = 10;
            testremovedpartrecords.add(testremovedpart);
        }
        insert testremovedpartrecords;*/
        return Null;
        
    }
    
    
/********************************************************************
PURPOSE:   To Create Test Record for Supplier Product                                                
PARAMETERS: N/A
RETURNS: list of Supplier Product 
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/   
    
    public static testMethod list<Supplier_Product__c> createsupplierproductRecords(){
        CustomSettingsUtilityTest.init();
        list<Supplier_Product__c> testsupplierproductrecords = new list<Supplier_Product__c>();
        Integer i;
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        for(i=0;i<10;i++){
            Supplier_Product__c testsupplierProduct = new Supplier_Product__c();
            testsupplierProduct.Name = 'TestSupplierProduct' + i;
            testsupplierProduct.Product__c = WarrantyProduct.id;
            //testsupplierProduct.Supplier_Account__c = '001j0000007HE1L';
            testsupplierProduct.Supplier_Account__c = acc.id;
            testsupplierProduct.Manufacuture_Date_del__c = System.today();
            
            testsupplierproductrecords.add(testsupplierProduct);
        }
        insert testsupplierproductrecords;
        //supplierProduct.id = testsupplierproductrecords[0].id;
        return testsupplierproductrecords;
        
    }


/********************************************************************
PURPOSE:   To Create Test Record for Supplier Contract                                                
PARAMETERS: N/A
RETURNS: Supplier Contract Record 
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/ 

    public static testMethod Supplier_Contract__c createsuppliercontractRecords(){
        CustomSettingsUtilityTest.init();
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        Payment_Definitions__c pd = new Payment_Definitions__c();
        pd.Status__c = 'Active';
        insert pd;
        
        Supplier_Contract__c testSupplierContract = new Supplier_Contract__c();
        testSupplierContract.Name = 'TestSupplierContract';
        testSupplierContract.Is_Collateral_Applicable__c = True;
        //testSupplierContract.Supplier_Account__c = '001j0000007HE1L';
        testSupplierContract.Supplier_Account__c = acc.id;
        testSupplierContract.Valid_From__c = System.today()-2;
        testSupplierContract.Valid_To__c = System.today()+2;
        testSupplierContract.Months_Covered__c = 24;
    //    testSupplierContract.Payment_Definition__c = 'a0C61000000A5cn';
        //testSupplierContract.Payment_Definition__c = pd.id;
        testSupplierContract.Validity_Date_Type__c = 'Manufacturing Date';
        insert testSupplierContract;
        Contractrec.id = testSupplierContract.id;
        system.debug('::contract'+Contractrec.id);
        Return testSupplierContract;
            
        
    }


/********************************************************************
PURPOSE:   To Create Test Record for Supplier Contract Lineitems                                                
PARAMETERS: N/A
RETURNS: Supplier Contract Lineitems  list 
THROWS [EXCEPTIONS]: N/A                                                         
********************************************************************/ 

        public static testMethod list<Supplier_Contract_Item__c> createcontractlineitems(){
        CustomSettingsUtilityTest.init();
        list<Supplier_Contract_Item__c> testsuppliercontractrecords = new list<Supplier_Contract_Item__c>();
        Integer i;
        Supplier_Contract__c supplierContractRec = createsuppliercontractRecords();
        for(i=0;i<10;i++){
            Supplier_Contract_Item__c testContractlineitem = new Supplier_Contract_Item__c();
            testContractlineitem.Name = 'TestSupplierContractLineItems' + i;
            system.debug('::contract2'+Contractrec.id);
            //testContractlineitem.Supplier_Contract__c = 'a0cj0000007aEJL';
            testContractlineitem.Supplier_Contract__c = supplierContractRec.id;
            testContractlineitem.Supplier_Product__c = supplierProduct.id;
            testsuppliercontractrecords.add(testContractlineitem);
        }
        insert testsuppliercontractrecords;
        return testsuppliercontractrecords;
        
        }



}