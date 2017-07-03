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
global class SoqlUtilsTest {
    
    global static testmethod void testInvalidValue(){
        Boolean exceptionCaught = false;
        try{
            SoqlUtils.toLiteral(new DecimalRange(0,1));
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    global static testmethod void testSoqlableValue(){
        System.assertEquals(
            'NEXT_N_FISCAL_QUARTERS:2',
            SoqlUtils.toLiteral(new DateFormula().next(2,UnitOfTime.FiscalQuarter))
        );
    }

    global static testmethod void testNullValue(){
        Object value = null;
        System.assertEquals('null',SoqlUtils.toLiteral(value));   
    }

    global static testmethod void testStringValue(){
        System.assertEquals('\'acme\'',SoqlUtils.toLiteral('acme'));   
    }

    global static testmethod void testBooleanValue(){
        System.assertEquals('true',SoqlUtils.toLiteral(true));   
        System.assertEquals('false',SoqlUtils.toLiteral(false));   
    }

    global static testmethod void testIntegerValue(){
        Integer i = 1;
        System.assertEquals('1',SoqlUtils.toLiteral(i));   
    }

    global static testmethod void testLongValue(){
        Long l = 1;
        System.assertEquals('1',SoqlUtils.toLiteral(l));   
    }

    global static testmethod void testDoubleValue(){
        Double d = 1.1;
        System.assertEquals('1.1',SoqlUtils.toLiteral(d));   
    }

    global static testmethod void testDecimalValue(){
        Decimal d = 1.1;
        System.assertEquals('1.1',SoqlUtils.toLiteral(d));   
    }

    global static testmethod void testDateValue(){
        System.assertEquals('1960-02-17',SoqlUtils.toLiteral(Date.newinstance(1960, 2, 17)));   
    }

    global static testmethod void testDatetimeValue(){
        System.assertEquals('2008-12-01T12:00:00Z',SoqlUtils.toLiteral(Datetime.newInstance(2008, 12, 1)));   
    }
    
    global static testmethod void testPrimitivesToSoqlLiterals(){
        final List<Object> values = new List<Object>{1,'test123',1.1,true,null};
        final List<String> literals = SoqlUtils.toLiteral(values);
        System.assertEquals('1',literals.get(0));
        System.assertEquals('\'test123\'',literals.get(1));
        System.assertEquals('1.1',literals.get(2));
        System.assertEquals('true',literals.get(3));
        System.assertEquals('null',literals.get(4));
    }

    global static testmethod void testEquals_1(){
        System.assertEquals(false,SoqlUtils.equals(
           'select id from account',
           'SELECT id FROM contact'
        ));
    }

    global static testmethod void testEquals_2(){
        System.assertEquals(true,SoqlUtils.equals(
           'select id from account',
           'SELECT id FROM account'
        ));
    }

    global static testmethod void testEquals_3(){
        System.assertEquals(false,SoqlUtils.equals(
           'select id,name from account',
           'SELECT id FROM account'
        ));
    }

    global static testmethod void testEquals_4(){
        System.assertEquals(true,SoqlUtils.equals(
           '  select    ispartner,rating,id, name    from   account  ',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

    global static testmethod void testEquals_5(){
        System.assertEquals(false,SoqlUtils.equals(
           'xxx',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

    global static testmethod void testEquals_newlinesInconsistent(){
        System.assertEquals(false,SoqlUtils.equals(
           '  select    ispartner,\nrating,\nid,\n name    from   account  ',
           ' SELECT  name,rating,  ispartner,id  FROM   account   '
        ));
    }

    global static testmethod void testEquals_newlinesConsistent(){
        System.assertEquals(true,SoqlUtils.equals(
           '  select    ispartner,\nrating,id, name    from   account  ',
           ' SELECT  name,rating, \n ispartner,id  FROM   account   '
        ));
    }

    global static testmethod void testAssertEquals(){
        SoqlUtils.assertEquals(
           'select id,name from account',
           'SELECT id,name FROM account'
        );
    }

}