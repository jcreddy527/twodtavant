/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
@IsTest
global class DatabaseUtilsTest {

    global static testmethod void test_query_String_Found(){
        //global static List<SObject> query(List<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }   
            final Account queried = (Account)DatabaseUtils.query(created.id);
            System.assertNotEquals(null, queried);
            System.assertEquals(created.id, queried.id);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_String_NotFound(){
        //global static List<SObject> query(List<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final String anId = created.id;
            if(CrudUtil.isAccountDeletable()){
                delete created;
            }
            final Account queried = (Account)DatabaseUtils.query(anId);
            System.assertEquals(null, queried);
        }
    }
    global static testmethod void test_query_String_ListString(){
        //global static List<SObject> query(String id, List<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final Account queried = (Account)DatabaseUtils.query(created.id, new List<String>{'id','name'} );
            System.assertNotEquals(null, queried);
            System.assertEquals(created.id, queried.id);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_String_SetString(){
        //global static List<SObject> query(String id, List<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final Account queried = (Account)DatabaseUtils.query(created.id, new Set<String>{'id','name'} );
            System.assertNotEquals(null, queried);
            System.assertEquals(created.id, queried.id);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_ListString(){
        //global static List<SObject> query(List<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final List<Account> created = new List<Account>{
                 new Account(name='test 123')
                ,new Account(name='test ABC')
            };
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(ArrayUtils.objectToString(ArrayUtils.pluck(created,'id')));
            System.assertNotEquals(null, records);
            System.assertEquals(2, records.size());
            final Set<Object> names = SetUtils.listToSet(ArrayUtils.pluck(created,'name'));
            System.assertNotEquals(null, names);
            System.assertEquals(2, names.size());
            System.assert(names.contains('test 123'));        
            System.assert(names.contains('test ABC'));        
        }
    }
    global static testmethod void test_query_SetString(){
        //global static List<SObject> query(Set<String> ids){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final List<Account> created = new List<Account>{
                 new Account(name='test 123')
                ,new Account(name='test ABC')
            };
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(SetUtils.listToSet(ArrayUtils.objectToString(ArrayUtils.pluck(created,'id'))));
            System.assertNotEquals(null, records);
            System.assertEquals(2, records.size());
            final Set<Object> names = SetUtils.listToSet(ArrayUtils.pluck(created,'name'));
            System.assertNotEquals(null, names);
            System.assertEquals(2, names.size());
            System.assert(names.contains('test 123'));        
            System.assert(names.contains('test ABC'));        
        }
    }
    global static testmethod void test_query_ListString_ListString(){
        //global static List<SObject> query(List<String> ids, List<String> fields){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(new List<String>{created.id}, new List<String>{'id','name'});
            System.assertNotEquals(null, records);
            System.assertEquals(1, records.size());
            final Account queried = records.get(0); 
            System.assertNotEquals(null, queried);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_ListString_SetString(){
        //global static List<SObject> query(List<String> ids, Set<String> fields){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(new List<String>{created.id}, new Set<String>{'id','name'});
            System.assertNotEquals(null, records);
            System.assertEquals(1, records.size());
            final Account queried = records.get(0); 
            System.assertNotEquals(null, queried);
            System.assertEquals(created.name, queried.name);
        }   
    }
    global static testmethod void test_query_SetString_ListString(){
        //global static List<SObject> query(Set<String> ids, List<String> fields){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(new Set<String>{created.id}, new List<String>{'id','name'});
            System.assertNotEquals(null, records);
            System.assertEquals(1, records.size());
            final Account queried = records.get(0); 
            System.assertNotEquals(null, queried);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_SetString_SetString_v1(){
        //global static List<SObject> query(Set<String> ids, Set<String> fields){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(name='test 123');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(new Set<String>{created.id}, new Set<String>{'id','name'});
            System.assertNotEquals(null, records);
            System.assertEquals(1, records.size());
            final Account queried = records.get(0); 
            System.assertNotEquals(null, queried);
            System.assertEquals(created.name, queried.name);
        }
    }
    global static testmethod void test_query_SetString_SetString_v2(){
        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
            final Account created = new Account(Name='Smith');
            if(CrudUtil.isAccountCreateable()){
                insert created;
            }
            final List<Account> records = DatabaseUtils.query(new Set<String>{created.id}, new Set<String>{'id','Name'});
            System.assertNotEquals(null, records);
            System.assertEquals(1, records.size());
            final Account queried = records.get(0); 
            System.assertNotEquals(null, queried);
            System.assertEquals(created.Name, queried.Name);
        }
    }
    global static testmethod void test_query_SetString_SetString_ERROR_EMPTY_SET(){
        Boolean exceptionCaught = false;
        try{
            DatabaseUtils.query(
                new Set<String>(), 
                new Set<String>()  //<= is empty so IllegalArgumentException should be thrown
            );
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    global static testmethod void test_query_SetString_SetString_ERROR_BAD_IDS(){
        Boolean exceptionCaught = false;
        try{
            DatabaseUtils.query(
                new Set<String>{'x','y'},  //<= invalid ids so IllegalArgumentException should be thrown
                new Set<String>() 
            );
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    global static testmethod void test_query_SetString_SetString_ERROR_DUP_PREFIXES(){
        Boolean exceptionCaught = false;
        try{
            DatabaseUtils.query(
                new Set<String>{'001012345678901234','003012345678901234'},  //<= key prefixes 001 & 003 differ
                new Set<String>() 
            );
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    global static testmethod void test_query_SetString_SetString_ERROR_PREFIX_NOT_FOUND(){
        Boolean exceptionCaught = false;
        try{
            DatabaseUtils.query(
                new Set<String>{'ZZZ012345678901234'},  //<= surely zzz won't ever be used as key prefix
                new Set<String>() 
            );
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

}