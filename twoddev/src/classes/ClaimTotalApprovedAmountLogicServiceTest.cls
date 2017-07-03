@isTest
private class ClaimTotalApprovedAmountLogicServiceTest {
    private static List<Claim__c> clmList;
    private static Payment_Definitions__c pd;
    private id ApplicablePaymentDefinition {get;set;}
    
    static testmethod void testCalculateTotalClaimCost()
    {
    
       list<Payment_Definitions__c> TestPDlist = TestUtility.createPaymentDefinitionsTestRecords();
        If(CrudUtil.isPaymentDefinitionCreateable())
           // insert TestPDlist[0]; //flow is failing
        
        Claim__c objClm = [Select Id,Applicable_Policy__c,Applicable_Payment_Definition__c FROM Claim__c where id=:clmList[0].Id];
       

    
    list<ClaimTotalApprovedAmountLogicService.InputWrapper> TestInputWrapperList = new list<ClaimTotalApprovedAmountLogicService.InputWrapper>();
        ClaimTotalApprovedAmountLogicService.InputWrapper wrpInp = new ClaimTotalApprovedAmountLogicService.InputWrapper();
        wrpInp.ApplicablePaymentDefinition = TestPDlist[0].id; 
        //wrpInp.claim = objClm;
        TestInputWrapperList.add(wrpInp);
        ClaimTotalApprovedAmountLogicService.CalculateTotalClaimCost(TestInputWrapperList);
        
        list<ClaimAllAmountModifierService.InputWrapper> TestAmtInputWrapperList = new list<ClaimAllAmountModifierService.InputWrapper>();
        ClaimAllAmountModifierService.InputWrapper wrpAmtInp = new ClaimAllAmountModifierService.InputWrapper();
        wrpAmtInp.ApplicablePaymentDefinition = TestPDlist[0].id;
        //wrpAmtInp.claim = objClm;
       // wrpAmtInp.warrantyProductId = TestWarrantyProduct1.id;
        TestAmtInputWrapperList.add(wrpAmtInp);
    }
}