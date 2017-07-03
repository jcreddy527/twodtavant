@IsTest
global class GlobalVariableTest {

    global static testmethod void test_get_bad_input(){
        CustomSettingsUtilityTest.init();
        //no asserts, just making sure this doesn't throw an exception
        // if an exception were thrown, then this test would fail
        System.assertEquals(null,GlobalVariable.get(null));
        System.assertEquals(null,GlobalVariable.get('   '));
    }

    global static testmethod void test_put_bad_input(){
        CustomSettingsUtilityTest.init();
        //no asserts, just making sure this doesn't throw an exception
        // if an exception were thrown, then this test would fail
        System.assertEquals(null,GlobalVariable.put(null,null));
        System.assertEquals(null,GlobalVariable.put('   ',null));
    }

    global static testmethod void test_put_insert(){
        CustomSettingsUtilityTest.init();
        deleteGlobalVariableWithNameIfExists('test 123');

        String previousValue = GlobalVariable.put('test 123',null);
        assertGlobalVariableExistsWith('test 123',null);
        System.assertEquals(null,previousValue);
        System.assertEquals(null,GlobalVariable.get('test 123'));

        previousValue = GlobalVariable.put('test 123','xyz');
        assertGlobalVariableExistsWith('test 123','xyz');
        System.assertEquals(null,previousValue);
        System.assertEquals('xyz',GlobalVariable.get('test 123'));

        previousValue = GlobalVariable.put('test 123','abc');
        assertGlobalVariableExistsWith('test 123','abc');
        System.assertEquals('xyz',previousValue);
        System.assertEquals('abc',GlobalVariable.get('test 123'));
    }

    global static testmethod void test_put_update(){
        CustomSettingsUtilityTest.init();
        deleteGlobalVariableWithNameIfExists('test 123');
        if(Schema.sObjectType.Lookup_Layout_Fields__c.fields.Name.isCreateable() && Schema.sObjectType.Lookup_Layout_Fields__c.fields.Field1__c.isCreateable()){
            Lookup_Layout_Fields__c record = new Lookup_Layout_Fields__c(
                name     = 'test 123'
                ,Field1__c = 'xyz'
            );  
            if(CrudUtil.isLookUpLayoutCreateable()){
                insert record;
            }
            assertGlobalVariableExistsWith('test 123','xyz');
    
            String previousValue = GlobalVariable.put('test 123','abc');
            assertGlobalVariableExistsWith('test 123','abc');
            System.assertEquals('xyz',previousValue);
            System.assertEquals('abc',GlobalVariable.get('test 123'));
        }
    }
    global static void deleteGlobalVariableWithNameIfExists(String name){
        CustomSettingsUtilityTest.init();
        Lookup_Layout_Fields__c record = null;
        try{
            record = [    
               select id 
               from Lookup_Layout_Fields__c 
               where name = :name 
               limit 1 
            ];
        }catch(QueryException e){}
        if(record != null) {
            if(CrudUtil.isSmartLkpCSDeletable()){
                delete record; 
            }
        }
    }

    global static void assertGlobalVariableExistsWith(String name, String value){
        CustomSettingsUtilityTest.init();
        Lookup_Layout_Fields__c record = null;
        try{
            record = [    
               select Field1__c 
               from Lookup_Layout_Fields__c 
               where name = :name 
               limit 1 
            ];
        }catch(QueryException e){}
        System.assertNotEquals(null,record);
        System.assertEquals   (value,record.Field1__c);
    }


}