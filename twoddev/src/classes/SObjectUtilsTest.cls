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
global class SObjectUtilsTest {

    global static testmethod void testIsAnyFieldBlank(){
        //test: global static Boolean isAnyFieldBlank(SObject obj, String[] fields){
        System.assertEquals(false,SObjectUtils.isAnyFieldBlank(null,null));
        System.assertEquals(false,SObjectUtils.isAnyFieldBlank(new Account(),null));
        System.assertEquals(false,SObjectUtils.isAnyFieldBlank(new Account(),new String[]{}));
		if (Schema.sObjectType.Account.fields.name.isCreateable() &&
			Schema.sObjectType.Account.fields.SicDesc.isCreateable()&&
			Schema.sObjectType.Account.fields.NumberofLocations__c.isCreateable()){     
	        Account foo = new Account(
	            name='Acme', 
	            SicDesc='Acme Computer Corp');
	        System.assertEquals(false,SObjectUtils.isAnyFieldBlank(foo,
	            new String[]{'name','SicDesc'}));
	        System.assertEquals(true,SObjectUtils.isAnyFieldBlank(foo,
	            new String[]{'name','SicDesc',SystemUtils.getNameSpace()+'NumberofLocations__c'}));
	        foo.NumberofLocations__c=10;
	        System.assertEquals(false,SObjectUtils.isAnyFieldBlank(foo,
	            new String[]{'name','SicDesc',SystemUtils.getNameSpace()+'NumberofLocations__c'}));
            
		}
    }

    global static testmethod void testToString(){
        //test: global static String toString(SObject obj){
        System.assertEquals('null',SObjectUtils.toString(null));
        if (Schema.sObjectType.Account.fields.name.isCreateable())
        Account foo = new Account(name='Acme');
        //System.assertNotEquals(null,SObjectUtils.toString(foo));
    }
        
    global static testmethod void testToStringFieldDescribeLimitsReached(){
        //test: global static String toString(SObject obj){
        for(Integer i = 0; i < Limits.getLimitFieldsDescribes(); i++){
               Map<String, Schema.SObjectField> m = Schema.sObjectType.Account.fields.getMap();        
        }
        System.assertEquals(null,SObjectUtils.toString(new Account(name='Acme')));
    }
    
    global static testmethod void testCopyAllFieldsNullInputs(){
        //test: global static SObject copyFields(SObject source, SObject dest){
        System.assertEquals(null,SObjectUtils.copyFields(null,null));
        System.assertEquals(null,SObjectUtils.copyFields(new Account(),null));
        System.assertNotEquals(null,SObjectUtils.copyFields(null,new Account()));
    }
    
    global static testmethod void testCopyFieldsFooToFoo(){
    	 if (Schema.sObjectType.Account.fields.name.isCreateable() &&
    	 		Schema.sObjectType.Account.fields.Phone.isCreateable() &&
    	 		Schema.sObjectType.Account.fields.SicDesc.isCreateable() &&
    	 		Schema.sObjectType.Account.fields.Description.isCreateable()){  
	        //test: global static SObject copyFields(SObject source, SObject dest){
	        final Account foo1 = new Account();
	        //SObjectUtils.putQuietly(foo1,'Datetime__c',Datetime.newInstance(2011,1,1,1,1,1));
	        SObjectUtils.putQuietly(foo1,'Phone','9876543210');
	        SObjectUtils.putQuietly(foo1,'SicDesc','test 123');
	        SObjectUtils.putQuietly(foo1,'Description','9876543210');
	        Account foo2 = new Account();
	        final SObject sobj = SObjectUtils.copyFields(foo1,foo2);
	        System.assert((sobj instanceof Account), 'Returned SObject type isn\'t Account as expected');
	        foo2 = (Account) sobj; 
	        //System.assertEquals(SObjectUtils.getQuietly(foo1,'Datetime__c'),
	          //  SObjectUtils.getQuietly(foo2,'Datetime__c'));
	        System.assertEquals(SObjectUtils.getQuietly(foo1,'Phone'),
	            SObjectUtils.getQuietly(foo2,'Phone'));
	        System.assertEquals(SObjectUtils.getQuietly(foo1,'SicDesc'),
	            SObjectUtils.getQuietly(foo2,'SicDesc'));
	        System.assertEquals(SObjectUtils.getQuietly(foo1,'Description'),
	            SObjectUtils.getQuietly(foo2,'Description'));
    	 }
    }
    
    global static testmethod void testPutQuietly(){
        //test: global static void putQuietly(SObject sobj, String fieldName, Object value){
        if (Schema.sObjectType.Account.fields.name.isCreateable()){     
	        final Account foo = new Account(name='test123');
	        System.assertEquals(null,SObjectUtils.putQuietly(null,null,null));
	        System.assertEquals(null,SObjectUtils.putQuietly(foo,null,null));
	        System.assertEquals('test123',SObjectUtils.getQuietly(foo,'name'));
	        System.assertEquals(null,SObjectUtils.putQuietly(foo,'namexxxx',null));
	        System.assertEquals('test123',SObjectUtils.getQuietly(foo,'name'));
	        System.assertEquals('test123',SObjectUtils.putQuietly(foo,'name',null));
	        System.assertEquals(null,SObjectUtils.getQuietly(foo,'name'));
	        System.assertEquals(null,SObjectUtils.putQuietly(foo,'name',''));
	        System.assertEquals('',SObjectUtils.getQuietly(foo,'name'));
	        System.assertEquals('',SObjectUtils.putQuietly(foo,'name','xyz'));
	        System.assertEquals('xyz',SObjectUtils.getQuietly(foo,'name'));
	        System.assertEquals(null,SObjectUtils.putQuietly(foo,'namexxxx','123'));
	        System.assertEquals('xyz',SObjectUtils.getQuietly(foo,'name'));
        }
    }
    
    global static testmethod void testGetQuietly(){
        //test: global static Object getQuietly(SObject sobj, String fieldName){    
        if (Schema.sObjectType.Account.fields.name.isCreateable()){        
	        final Account foo = new Account(name='test123');
	        System.assertEquals(null,SObjectUtils.getQuietly(null,null));
	        System.assertEquals(null,SObjectUtils.getQuietly(foo,null));
	        System.assertEquals(null,SObjectUtils.getQuietly(null,''));
	        System.assertEquals(null,SObjectUtils.getQuietly(foo,'namexxxxxx'));
	        System.assertEquals('test123',SObjectUtils.getQuietly(foo,'name'));
        }
    }    
    
}