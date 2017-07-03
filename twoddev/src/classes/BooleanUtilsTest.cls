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
global class BooleanUtilsTest {

    global static testmethod void testIsFalse()
    {
        System.assertEquals(BooleanUtils.isFalse(true),false);
        System.assertEquals(BooleanUtils.isFalse(false),true);
        System.assertEquals(BooleanUtils.isFalse(null),false);
    }
    
    global static testmethod void testIsNotFalse()
    {
        System.assertEquals(BooleanUtils.isNotFalse(true),true);
        System.assertEquals(BooleanUtils.isNotFalse(false),false);
        System.assertEquals(BooleanUtils.isNotFalse(null),true);
    }
    
    global static testmethod void testIsTrue()
    {
        System.assertEquals(BooleanUtils.isTrue(true),true);
        System.assertEquals(BooleanUtils.isTrue(false),false);
        System.assertEquals(BooleanUtils.isTrue(null),false);
    }
    
    global static testmethod void testIsNotTrue()
    {
        System.assertEquals(BooleanUtils.isNotTrue(true),false);
        System.assertEquals(BooleanUtils.isNotTrue(false),true);
        System.assertEquals(BooleanUtils.isNotTrue(null),true);
    }
    
    global static testmethod void testNegate()
    {
        System.assertEquals(BooleanUtils.negate(true),false);
        System.assertEquals(BooleanUtils.negate(false),true);
        System.assertEquals(BooleanUtils.negate(null),null);
    }
    
    global static testmethod void testToBoolanDefaultIfNull()
    {
        System.assertEquals(BooleanUtils.toBooleanDefaultIfNull(true,false),true);
        System.assertEquals(BooleanUtils.toBooleanDefaultIfNull(false,false),false);
        System.assertEquals(BooleanUtils.toBooleanDefaultIfNull(null,false),false);
    }
    
    
    global static testMethod void testToBoolean()
    {
        System.assertEquals(BooleanUtils.toBoolean(1),true);
        System.assertEquals(BooleanUtils.toBoolean(0),false);
        System.assertEquals(BooleanUtils.toBoolean(null),false);
    
        System.assertEquals(BooleanUtils.toBoolean(1,1,0),true);
        System.assertEquals(BooleanUtils.toBoolean(0,1,0),false);
        try
        {
            System.assertEquals(BooleanUtils.toBoolean(2,1,0),false);
        }
        catch(Exception exp){}
    }
    
    
    global static testMethod void testToInteger()
    {
        System.assertEquals(BooleanUtils.toInteger(true),1);
        System.assertEquals(BooleanUtils.toInteger(false),0);
        try
        {
            System.assertEquals(BooleanUtils.toInteger(null),0);
        }
        catch(Exception exp)
        {
        }
    }
     
    global static testMethod void testToStringYesNo()
    {
        System.assertEquals(BooleanUtils.toStringYesNo(true),'yes');
        System.assertEquals(BooleanUtils.toStringYesNo(false),'no');
        System.assertEquals(BooleanUtils.toStringYesNo(null),null);
    }
    
    global static testMethod void testToString()
    {
        System.assertEquals(BooleanUtils.toString(true,'true','false'),'true');
        System.assertEquals(BooleanUtils.toString(false,'true','false'),'false');
        System.assertEquals(BooleanUtils.toString(null,'true','false'),null);
    }
    
    global static testMethod void testXor()
    {
        System.assertEquals(BooleanUtils.xor(new List<Boolean>{true,true,true}),true);
        System.assertEquals(BooleanUtils.xor(new List<Boolean>{false,false,false}),true);
        try
        {
            System.assertEquals(BooleanUtils.xor(new List<Boolean>()),true);
        }
        catch(Exception exp){}
        
        try
        {
            System.assertEquals(BooleanUtils.xor(null),true);
        }
        catch(Exception exp){}
        
        System.assertEquals(BooleanUtils.xor(new List<Boolean>{false,false,true}),false);
    }
    
    global static testMethod void testStrToBoolean()
    {
        System.assertEquals(BooleanUtils.strToBoolean('true'),true);
        System.assertEquals(BooleanUtils.strToBoolean('false'),false);
        System.assertEquals(BooleanUtils.strToBoolean(null),false);
    }
    
    global static testMethod void testToStringYN()
    {
        System.assertEquals(BooleanUtils.toStringYN(true),'Y');
        System.assertEquals(BooleanUtils.toStringYN(false),'N');
        System.assertEquals(BooleanUtils.toStringYN(null),null);
    }
    
    
}