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
global class SObjectSortByNameComparatorTest {

    global static testmethod void testCompareBadInput(){
        ISObjectComparator comparator = new SObjectSortByNameComparator();
        System.assertEquals(-1,comparator.compare(null,new Account(name='test123'))); 
        System.assertEquals(0,comparator.compare(null,null)); 
        System.assertEquals(1,comparator.compare(new Account(name='test123'),null)); 
    }
    
    global static testmethod void testCompareWithFoos(){
    	if (Schema.sObjectType.Account.fields.name.isUpdateable()){
    	
	        Account a1 = new Account(name='abc');
	        Account a2 = new Account(name='efg');
	        ISObjectComparator comparator = new SObjectSortByNameComparator();
	        System.assert(0 > comparator.compare(a1,a2)); 
	        System.assert(0 == comparator.compare(a1,a1)); 
	        System.assert(0 < comparator.compare(a2,a1)); 
    	}
    }
    
}