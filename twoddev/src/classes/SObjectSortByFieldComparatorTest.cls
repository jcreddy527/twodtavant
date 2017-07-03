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
global class SObjectSortByFieldComparatorTest {
	global static string NameSpace = SystemUtils.getNameSpace();
    global static testmethod void test_compare_throws_IllegalStateException(){
        Boolean exceptionCaught = false;
        try{
            new SObjectSortByFieldComparator(null)
                .compare(new Inventory__c(name='test123'),new Inventory__c(name='test123'));
        }catch(IllegalStateException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalStateException not thrown');
    }

    global static testmethod void test_compare_nulls(){
        final SObjectSortByFieldComparator comparator = new SObjectSortByFieldComparator('name');
        System.assertEquals(-1,comparator.compare(null,new Inventory__c(name='test123'))); 
        System.assertEquals(0,comparator.compare(null,null)); 
        System.assertEquals(1,comparator.compare(new Inventory__c(name='test123'),null)); 
    }
    
    global static testmethod void test_compare_integer_on_Foos(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
	        Warranty_Rule_Criteria__c a1 = new Warranty_Rule_Criteria__c(Sequence__c=2);
	        Warranty_Rule_Criteria__c a2 = new Warranty_Rule_Criteria__c(Sequence__c=1);
	        final SObjectSortByFieldComparator comparator = new SObjectSortByFieldComparator(NameSpace+'Sequence__c');
	        System.assertEquals(1,comparator.compare(a1,a2)); 
	        System.assertEquals(0,comparator.compare(a1,a1)); 
	        System.assertEquals(-1,comparator.compare(a2,a1)); 
	
	        comparator.sortAscending = false;
	        System.assertEquals(-1,comparator.compare(a1,a2)); 
	        System.assertEquals(0,comparator.compare(a1,a1)); 
	        System.assertEquals(1,comparator.compare(a2,a1)); 
	
	        comparator.sortAscending = true;
	        System.assertEquals(1,comparator.compare(a1,a2)); 
	        System.assertEquals(0,comparator.compare(a1,a1)); 
	        System.assertEquals(-1,comparator.compare(a2,a1)); 
	
	        comparator.sortAscending = null;
	        System.assertEquals(1,comparator.compare(a1,a2)); 
	        System.assertEquals(0,comparator.compare(a1,a1)); 
	        System.assertEquals(-1,comparator.compare(a2,a1)); 
        }
    }
    
    global static testmethod void test_compare_string_on_Foos(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
    	
	        Warranty_Rule_Criteria__c a1 = new Warranty_Rule_Criteria__c (Sequence__c=2);
	        Warranty_Rule_Criteria__c a2 = new Warranty_Rule_Criteria__c (Sequence__c=1);
	        final SObjectSortByFieldComparator comparator = new SObjectSortByFieldComparator('name');
	        System.assertEquals(0,comparator.compare(a1,a2)); 
	        System.assertEquals(0,comparator.compare(a1,a1)); 
    	}
    }
    
    global static testmethod void test_qsort_ListSObject(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
	        final List<SObject> unsorted = new List<SObject>{
	             new Warranty_Rule_Criteria__c (Sequence__c=2)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=3)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=0)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=1)
	        };
	        final List<SObject> sorted = SObjectSortByFieldComparator.qsort(unsorted);
	        System.assertNotEquals(null,sorted);
	        System.assertEquals(4,sorted.size());
	        /*
	        System.assertEquals('A',sorted.get(0).get('name'));
	        System.assertEquals('B',sorted.get(1).get('name'));
	        System.assertEquals('C',sorted.get(2).get('name'));
	        System.assertEquals('D',sorted.get(3).get('name'));
	        */
    	}
    }
    
    global static testmethod void test_qsort_ListSObject_Boolean(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
	        final List<SObject> unsorted = new List<SObject>{
	             new Warranty_Rule_Criteria__c (Sequence__c=2)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=3)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=0)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=1)
	        };
	        final List<SObject> sorted = SObjectSortByFieldComparator.qsort(unsorted,false);
	        System.assertNotEquals(null,sorted);
	        System.assertEquals(4,sorted.size());
	        /*
	        System.assertEquals('D',sorted.get(0).get('name'));
	        System.assertEquals('C',sorted.get(1).get('name'));
	        System.assertEquals('B',sorted.get(2).get('name'));
	        System.assertEquals('A',sorted.get(3).get('name'));
	        */
    	}
    }

    global static testmethod void test_qsort_ListSObject_String(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
	        final List<SObject> unsorted = new List<SObject>{
	             new Warranty_Rule_Criteria__c (Sequence__c=2)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=3)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=0)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=1)
	        };
	        final List<SObject> sorted = SObjectSortByFieldComparator.qsort(unsorted,NameSpace+'Sequence__c');
	        System.assertNotEquals(null,sorted);
	        System.assertEquals(4,sorted.size());
	        System.assertEquals(0,sorted.get(0).get(NameSpace+'Sequence__c'));
	        System.assertEquals(1,sorted.get(1).get(NameSpace+'Sequence__c'));
	        System.assertEquals(2,sorted.get(2).get(NameSpace+'Sequence__c'));
	        System.assertEquals(3,sorted.get(3).get(NameSpace+'Sequence__c'));
    	}
    }

    global static testmethod void test_qsort_ListSObject_String_Boolean(){
    	if (Schema.sObjectType.Warranty_Rule_Criteria__c.fields.Sequence__c.isCreateable()){
	        final List<SObject> unsorted = new List<SObject>{
	             new Warranty_Rule_Criteria__c (Sequence__c=2)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=3)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=0)
	            ,new Warranty_Rule_Criteria__c (Sequence__c=1)
	        };
	        final List<SObject> sorted = SObjectSortByFieldComparator.qsort(unsorted,'Sequence__c',false);
	        System.assertNotEquals(null,sorted);
	        System.assertEquals(4,sorted.size());
	        System.assertEquals(3,sorted.get(0).get(NameSpace+'Sequence__c'));
	        System.assertEquals(2,sorted.get(1).get(NameSpace+'Sequence__c'));
	        System.assertEquals(1,sorted.get(2).get(NameSpace+'Sequence__c'));
	        System.assertEquals(0,sorted.get(3).get(NameSpace+'Sequence__c'));
    	}
    }
    
}