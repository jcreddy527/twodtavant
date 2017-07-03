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
global class OrConditionTest {
    
    global static testmethod void testOrConditionEmpty(){
        System.assertEquals('',new OrCondition().toSoql());   
    }

    global static testmethod void testNestedOrConditionEmpty(){
        System.assertEquals('',new OrCondition().add(new OrCondition()).add(new OrCondition()).toSoql());   
    }

    global static testmethod void testOrConditionWithOneConditionOnly(){
        System.assertEquals(
            'name = \'acme\'',
            new OrCondition()
                .add(new FieldCondition('name ',Operator.EQUALS,'acme'))
                .toSoql());   
    }

    global static testmethod void testTwoFieldConditions(){
        System.assertEquals(
            '(name = \'acme\' OR ispartner = true)',
            new OrCondition()
                .add(new FieldCondition('name ',Operator.EQUALS,'acme'))
                .add(new FieldCondition('ispartner',Operator.EQUALS,true))
                .toSoql()
        );   
    }

}