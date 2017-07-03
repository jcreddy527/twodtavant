@isTest
private class CruderTest {
    
    ///////////////////////insert testing/////////////////////////////////////
    
    @isTest static void insertTestPositive() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, false);
        CruderCntrl.DMLOutputWrapper real=CruderCntrl.InsertSObjects(contacts)[0];
        System.assertNotEquals(null, real.sObjID);
        
    }
    
    @isTest static void insertTestNegative() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, false);
        contacts[0].LastName=null;
        CruderCntrl.DMLOutputWrapper real=CruderCntrl.InsertSObjects(contacts)[0];
        System.assertEquals(null, real.sObjID);
        
    }
    
    @isTest static void insertTestBulk() {
        
        List<Contact> contacts;
        
        /////////////////////all good values//////////////////////////////////////////
        
        contacts= testHelperMethods.prepareContacts(250, false);
        
        List<CruderCntrl.DMLOutputWrapper> realList=CruderCntrl.InsertSObjects(contacts);
        
        for (CruderCntrl.DMLOutputWrapper wrapper:realList){
            System.assertNotEquals(null, wrapper.sObjID);
        }
        
        /////////////////////some bad values//////////////////////////////////////////
        
        contacts= testHelperMethods.prepareContacts(250, false);
        Contact contactfalliable = testHelperMethods.prepareContacts(1, false)[0];
        contactfalliable.LastName=null;
        contacts.add(contactfalliable);
        realList.clear();
        realList=CruderCntrl.InsertSObjects(contacts);
        
        for(Integer i=0;i<realList.size()-1;i++){
            CruderCntrl.DMLOutputWrapper wrapper=realList[i];
            System.assertNotEquals(null, wrapper.sObjID);
        }
        System.assertEquals(null, realList[realList.size()-1].sObjID);
        
    }
    
    ///////////////////////update testing/////////////////////////////////////
    
    @isTest static void updateTestPositive() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
        contacts[0].FirstName='amanChanged';
        contacts[0].LastName='sawhneyChanged';
        
        CruderCntrl.DMLOutputWrapper real=CruderCntrl.UpdateSObjects(contacts)[0];
        
        System.assertEquals(TRUE, real.success);
        
    }
    
    @isTest static void updateTestNegative() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, false);
        CruderCntrl.DMLOutputWrapper real=CruderCntrl.UpdateSObjects(contacts)[0];
        System.assertEquals(FALSE, real.success);
        
    }
    
    @isTest static void updateTestBulk() {
        
        List<Contact> contacts;
        
        /////////////////////all good values//////////////////////////////////////////
        contacts= testHelperMethods.prepareContacts(250, true);
        for(Contact contactObj : contacts){
            contactObj.Firstname='newName';
            contactObj.LastName='newSurname';
        }
        List<CruderCntrl.DMLOutputWrapper> realList=CruderCntrl.UpdateSObjects(contacts);
        
        for (CruderCntrl.DMLOutputWrapper wrapper:realList){
            System.assertNotEquals(null, wrapper.sObjID);
        }
        
        /////////////////////some bad values//////////////////////////////////////////
        
        for(Contact contactObj : contacts){
            contactObj.Firstname='newName';
            contactObj.LastName='newSurname';
        }
        Contact falliableContact=testHelperMethods.prepareContacts(1, false)[0];
        contacts.add(falliableContact);
        
        realList=CruderCntrl.UpdateSObjects(contacts);
        
        for (Integer i=0;i<realList.size()-1;i++){
            System.assertNotEquals(null, realList[i].sObjID);
        }
        System.assertEquals(null, realList[realList.size()-1].sObjID);
        
    }
    
    ///////////////////////read testing/////////////////////////////////////
    
    @isTest static void readTestPositive() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
        String query='select Id from Contact';
        CruderCntrl.OutputWrapper realResponse = CruderCntrl.ReadSObjects(query);
        System.assertEquals(TRUE, realResponse.success);
        
    }
    
    @isTest static void readTestNegative() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
        String query='select Id from Contact8';
        CruderCntrl.OutputWrapper realResponse = CruderCntrl.ReadSObjects(query);
        System.assertEquals(FALSE, realResponse.success);
        
    }
    
    @isTest static void readTestBulk() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(250, true);
        String query='select Id from Contact';
        CruderCntrl.OutputWrapper realResponse = CruderCntrl.ReadSObjects(query);
        System.assertEquals(TRUE, realResponse.success);
        
    }
    
    ///////////////////////delete testing/////////////////////////////////////
    
    @isTest static void deleteTestPositive() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
        CruderCntrl.DMLOutputWrapper real=CruderCntrl.DeleteSObjects(contacts)[0];
        System.assertEquals(TRUE, real.success);
        
    }
    
    @isTest static void deleteTestNegative() {
        
        List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
        
        List<CruderCntrl.DMLOutputWrapper> real = CruderCntrl.DeleteSObjects(contacts);
        System.assertEquals(TRUE, real[0].success);
        
        real = CruderCntrl.DeleteSObjects(contacts);
        System.assertEquals(FALSE, real[0].success);
        
    }
    
    @isTest static void deleteTestBulk() {
        
        ///////////all good values//////////////////////////
        List<Contact> contacts= testHelperMethods.prepareContacts(250, true);
        List<CruderCntrl.DMLOutputWrapper> real=CruderCntrl.DeleteSObjects(contacts);
        for(Integer i=0;i<real.size();i++){
            System.assertEquals(TRUE, real[i].success);
        }
        
        ///////////////bad values////////////////////////
        real=CruderCntrl.DeleteSObjects(contacts);
        for(Integer i=0;i<real.size()-1;i++){
            System.assertEquals(FALSE, real[i].success);
        }
        
    }
    
    
    //////////////////////update locked record test///////////////////////////
    
    @isTest static void updateLockedRecordTestPositiveAsStandardUser(){
        
        Id standardUserId = [select Id from Profile where name='Standard User' limit 1][0].Id;
        User userX = testHelperMethods.prepareStandardUsers(standardUserId, 1, true)[0];
        System.RunAs(userX){
            
            List<Contact> contacts = testHelperMethods.prepareContacts(1, true);
            //Approval.lock(contacts[0].Id);
            
            contacts[0].FirstName='amanChanged';
            contacts[0].LastName='sawhneyChanged';
            
            // CruderForceCntrl.DMLOutputLockWrapper real=CruderForceCntrl.UpdateForceSObjects(contacts)[0];
            // System.assertEquals(TRUE, real.success); 
            
        }
    }
    
    @isTest static void updateLockedRecordTestBulkPositiveAndNegativeAsStandardUser(){
        
        Id standardUserId = [select Id from Profile where name='Standard User' limit 1][0].Id;
        User userX = testHelperMethods.prepareStandardUsers(standardUserId, 1, true)[0];
        
        System.RunAs(userX){
            
            List<Contact> contacts;
            
            /////////////////////add some locked and some normal contacts/////////////////////////////////
            /////positive testing////
            contacts= testHelperMethods.prepareContacts(125, true);
            //Approval.lock(contacts);
            contacts.addAll(testHelperMethods.prepareContacts(125, true));
            
            
            for(Contact contactObj : contacts){
                contactObj.Firstname='newName';
                contactObj.LastName='newSurname';
            }
            
            /* List<CruderForceCntrl.DMLOutputLockWrapper> realList=CruderCntrl.UpdateForceSObjects(contacts);
            
            for (CruderForceCntrl.DMLOutputLockWrapper wrapper:realList){
                System.assertNotEquals(null, wrapper.sObjID);
            }
            */
            /////negative testing////
            contacts= testHelperMethods.prepareContacts(125, true);
            //Approval.lock(contacts);
            contacts.addAll(testHelperMethods.prepareContacts(125, true));
            
            for(Contact contactObj : contacts){
                contactObj.Firstname='newName';
                contactObj.LastName='newSurname';
            }
            contacts[249].LastName=null;
            
            /* realList=CruderCntrl.UpdateForceSObjects(contacts);
            
            for (Integer i=0;i<realList.size()-1;i++){
                System.assertNotEquals(null, realList[i].sObjID);
            }
            system.assertEquals(null,realList[realList.size()-1].sObjID);
            */
        }
        
    }
    
    
    //////////////////////////////////////////////////////////////////////other users tests//////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @isTest static void otherUserTest() {
        
        Id standardUserId = [select Id from Profile where name='Standard User' limit 1][0].Id;
        User userX = testHelperMethods.prepareStandardUsers(standardUserId, 1, true)[0];
        System.RunAs(userX){
            
            CruderTest.insertTestPositive();
            CruderTest.insertTestNegative();
            CruderTest.insertTestBulk();
            
            CruderTest.updateTestPositive();
            CruderTest.updateTestNegative();
            CruderTest.updateTestBulk();
            
            CruderTest.readTestPositive();
            CruderTest.readTestNegative();
            CruderTest.readTestBulk();
            
            CruderTest.deleteTestPositive();
            CruderTest.deleteTestNegative();
            CruderTest.deleteTestBulk();
            
        }
        
    }
    
}