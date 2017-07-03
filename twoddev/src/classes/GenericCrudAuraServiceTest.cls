@isTest
global class GenericCrudAuraServiceTest {
    ///////////////////////insert testing/////////////////////////////////////
    @isTest static void insertTestPositive() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, false);
            GenericCrudAuraService.DMLOutputWrapper real=GenericCrudAuraService.InsertSObjects(contacts)[0];
            System.assertNotEquals(null, real.sObjID);

    }

    @isTest static void insertTestNegative() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, false);
            contacts[0].LastName=null;
            GenericCrudAuraService.DMLOutputWrapper real=GenericCrudAuraService.InsertSObjects(contacts)[0];
            System.assertEquals(null, real.sObjID);

    }

    @isTest static void insertTestBulk() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts;

            /////////////////////all good values//////////////////////////////////////////

            contacts= test_helperMethods.prepareContacts(250, false);

            List<GenericCrudAuraService.DMLOutputWrapper> realList=GenericCrudAuraService.InsertSObjects(contacts);

            for (GenericCrudAuraService.DMLOutputWrapper wrapper:realList){
                    System.assertNotEquals(null, wrapper.sObjID);
            }

            /////////////////////some bad values//////////////////////////////////////////

            contacts= test_helperMethods.prepareContacts(250, false);
            Contact contactfalliable = test_helperMethods.prepareContacts(1, false)[0];
            contactfalliable.LastName=null;
            contacts.add(contactfalliable);
            realList.clear();
            realList=GenericCrudAuraService.InsertSObjects(contacts);

            for(Integer i=0;i<realList.size()-1;i++){
                    GenericCrudAuraService.DMLOutputWrapper wrapper=realList[i];
                    System.assertNotEquals(null, wrapper.sObjID);
            }
            System.assertEquals(null, realList[realList.size()-1].sObjID);

    }

    ///////////////////////update testing/////////////////////////////////////
    @isTest static void updateTestPositive() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, true);
            contacts[0].FirstName='amanChanged';
            contacts[0].LastName='sawhneyChanged';

            GenericCrudAuraService.DMLOutputWrapper real=GenericCrudAuraService.UpdateSObjects(contacts)[0];

            System.assertEquals(TRUE, real.success);

    }

    @isTest static void updateTestNegative() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, false);
            GenericCrudAuraService.DMLOutputWrapper real=GenericCrudAuraService.UpdateSObjects(contacts)[0];
            System.assertEquals(FALSE, real.success);

    }

    @isTest static void updateTestBulk() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts;

            /////////////////////all good values//////////////////////////////////////////
            contacts= test_helperMethods.prepareContacts(250, true);
            for(Contact contactObj : contacts){
                    contactObj.Firstname='newName';
                    contactObj.LastName='newSurname';
            }
            List<GenericCrudAuraService.DMLOutputWrapper> realList=GenericCrudAuraService.UpdateSObjects(contacts);

            for (GenericCrudAuraService.DMLOutputWrapper wrapper:realList){
                    System.assertNotEquals(null, wrapper.sObjID);
            }

            /////////////////////some bad values//////////////////////////////////////////

            for(Contact contactObj : contacts){
                    contactObj.Firstname='newName';
                    contactObj.LastName='newSurname';
            }
            Contact falliableContact=test_helperMethods.prepareContacts(1, false)[0];
            contacts.add(falliableContact);

            realList=GenericCrudAuraService.UpdateSObjects(contacts);

            for (Integer i=0;i<realList.size()-1;i++){
                    System.assertNotEquals(null, realList[i].sObjID);
            }
            System.assertEquals(null, realList[realList.size()-1].sObjID);

    }

    ///////////////////////read testing/////////////////////////////////////

    @isTest static void readTestPositive() {
            CustomSettingsUtilityTest.init();
            String query='select Id from Contact';
            GenericCrudAuraService.OutputWrapper realResponse = GenericCrudAuraService.ReadSObjects(query);
            System.assertEquals(TRUE, realResponse.success);

    }

    @isTest static void readTestNegative() {
            CustomSettingsUtilityTest.init();
            String query='select Id from Contact8';
            GenericCrudAuraService.OutputWrapper realResponse = GenericCrudAuraService.ReadSObjects(query);
            System.assertEquals(FALSE, realResponse.success);

    }

    @isTest static void readTestBulk() {
            CustomSettingsUtilityTest.init();
            String query='select Id from Contact';
            GenericCrudAuraService.OutputWrapper realResponse = GenericCrudAuraService.ReadSObjects(query);
            System.assertEquals(TRUE, realResponse.success);

    }

    ///////////////////////delete testing/////////////////////////////////////

    @isTest static void deleteTestPositive() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, true);
            GenericCrudAuraService.DMLOutputWrapper real=GenericCrudAuraService.DeleteSObjects(contacts)[0];
            System.assertEquals(TRUE, real.success);

    }

    @isTest static void deleteTestNegative() {
            CustomSettingsUtilityTest.init();
            List<Contact> contacts = test_helperMethods.prepareContacts(1, true);

            List<GenericCrudAuraService.DMLOutputWrapper> real = GenericCrudAuraService.DeleteSObjects(contacts);
            System.assertEquals(TRUE, real[0].success);

            real = GenericCrudAuraService.DeleteSObjects(contacts);
            System.assertEquals(FALSE, real[0].success);

    }

    @isTest static void deleteTestBulk() {
            CustomSettingsUtilityTest.init();
            ///////////all good values//////////////////////////
            List<Contact> contacts= test_helperMethods.prepareContacts(250, true);
            List<GenericCrudAuraService.DMLOutputWrapper> real=GenericCrudAuraService.DeleteSObjects(contacts);
            for(Integer i=0;i<real.size();i++){
                    System.assertEquals(TRUE, real[i].success);
            }

            ///////////////bad values////////////////////////
            real=GenericCrudAuraService.DeleteSObjects(contacts);
            for(Integer i=0;i<real.size()-1;i++){
                    System.assertEquals(FALSE, real[i].success);
            }

    }

    //////////////////////////////////////////////////////////////////////other users tests//////////////////////////////////////////////////////////////////////////////////////////////////////////////

    @isTest static void otherUserTest() {
            CustomSettingsUtilityTest.init();
            // ORDER BY CreatedDate ASC LIMIT 1 ensures to return the Salesforce standard profile
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' ORDER BY CreatedDate ASC LIMIT 1];
            User user = test_helperMethods.prepareStandardUsers(p.Id, 1, true)[0];
            System.RunAs(user){

                    GenericCrudAuraServiceTest.insertTestPositive();
                    GenericCrudAuraServiceTest.insertTestNegative();
                    GenericCrudAuraServiceTest.insertTestBulk();

                    GenericCrudAuraServiceTest.updateTestPositive();
                    GenericCrudAuraServiceTest.updateTestNegative();
                    GenericCrudAuraServiceTest.updateTestBulk();

                    GenericCrudAuraServiceTest.readTestPositive();
                    GenericCrudAuraServiceTest.readTestNegative();
                    GenericCrudAuraServiceTest.readTestBulk();

                    GenericCrudAuraServiceTest.deleteTestPositive();
                    GenericCrudAuraServiceTest.deleteTestNegative();
                    GenericCrudAuraServiceTest.deleteTestBulk();

            }

    }

}