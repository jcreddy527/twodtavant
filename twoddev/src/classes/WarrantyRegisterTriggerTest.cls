@isTest(seealldata=true)
global class WarrantyRegisterTriggerTest {
    global static testMethod void insertTest(){
    Warranty_Registration__c warrantyReg=new Warranty_Registration__c();
    warrantyReg.Registration_Date__c =system.today() - 1;
    insert warrantyReg;
     if(warrantyReg.Id !=null){
        System.assertEquals(system.today()-1,warrantyReg.Registration_Date__c );
      }
    }
}