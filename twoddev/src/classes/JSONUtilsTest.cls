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
global class JSONUtilsTest {

    global static testmethod void testEncode_String(){
        //test: global static String encode(String str)
        final String nullStr = null;
        System.assertEquals('null',JSONUtils.encode(nullStr)); 
        System.assertEquals('""',JSONUtils.encode('')); 
        System.assertEquals('" "',JSONUtils.encode(' ')); 
        System.assertEquals('"\\""',JSONUtils.encode('"'));
        //System.assertEquals('\"\\\\\"',JSONUtils.encode('\\'));
        System.assertEquals('"\\f"',JSONUtils.encode('\f'));
        System.assertEquals('"\\n"',JSONUtils.encode('\n'));
        System.assertEquals('"\\r"',JSONUtils.encode('\r'));
        System.assertEquals('"\\t"',JSONUtils.encode('\t'));        
    }
    
    global static testmethod void testEncode_StringList(){
        //test: global static List<String> encode(List<String> strings)
        final String[] nullStr = null;
        ArrayUtils.assertArraysAreEqual(null,JSONUtils.encode(nullStr)); 
        ArrayUtils.assertArraysAreEqual(new String[]{},JSONUtils.encode(new String[]{})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'\"\"'},JSONUtils.encode(new String[]{''})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'\"abc\"','\"xyz\"'},JSONUtils.encode(new String[]{'abc','xyz'})); 
    }

    global static testmethod void test_encodeFields(){
        //test: global static void encodeFields(List<SObject> sobjects, Map<String,String> mapping)
        final Warranty_Rule__c foo1 = new Warranty_Rule__c (name = 'xyz123', Object_API_Name__c= 'asdf\nasdf');
        final Warranty_Rule__c foo2 = new Warranty_Rule__c (name = null, Object_API_Name__c= '4444\t4444');
        final List<Warranty_Rule__c> foos = new List<Warranty_Rule__c>{foo1,foo2};
        JSONUtils.encodeFields(foos, new Map<String,String>{
             'name' => SystemUtils.getNameSpace()+'Textarealong__c'
            ,SystemUtils.getNameSpace()+'Object_API_Name__c' => SystemUtils.getNameSpace()+'Object_Type__c'
        }); 
        System.assertEquals('xyz123',foo1.name);
        /*
        System.assertEquals('null',foo2.Textarealong__c);
        System.assertEquals('"asdf\\nasdf"',foo1.Textarea__c);
        System.assertEquals('"4444\\t4444"',foo2.Textarea__c);
        */
    }

}