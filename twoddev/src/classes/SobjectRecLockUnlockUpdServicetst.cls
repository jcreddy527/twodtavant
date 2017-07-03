@isTest
global class SobjectRecLockUnlockUpdServicetst {

    global static testMethod void SobjectRecLockUnlockUpdServicemthd() {
        CustomSettingsUtilityTest.init();
        test.startTest();
        Supplier_Recovery_Claim__c temprec = new Supplier_Recovery_Claim__c();
        temprec.Status__c = 'Submit';
        insert temprec;
        
        //Test Scenario when the record is unlocked
       
        SobjectRecLockUnlockUpdService.LockUnlockBasedOnAction1(temprec.id,SystemUtils.getNameSpace()+'Status__c','On Hold');
        system.debug('Lock status1'+Approval.isLocked(temprec.id));
        String RecStatus = [select id,Status__c from Supplier_Recovery_Claim__c where id =: temprec.id].Status__c;
        
        system.debug('::::record status' + RecStatus);
        System.assertEquals(RecStatus,'On Hold');
        
        
        //Test Scenario when the record is locked
        
         Approval.lock(temprec.id);
          system.debug('Lock status2'+Approval.isLocked(temprec.id));
         SobjectRecLockUnlockUpdService.LockUnlockBasedOnAction1(temprec.id,SystemUtils.getNameSpace()+'Status__c','On Hold');
        
        
        test.stopTest();
    }

}