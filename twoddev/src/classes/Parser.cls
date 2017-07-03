/**********************************************************************
 Name:  Parser()
 Copyright © 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
Returns static variables                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Manish         10/11/2014      INITIAL DEVELOPMENT
***********************************************************************/
global with sharing class Parser {
    global static final String COMMA = String.fromCharArray(new List<Integer> { 44 });
    global static final String CR = '\r';
    global static final String DQUOTE = '\"';
    global static final String LF = '\n';
    global static final String CRLF = CR + LF;
    global static final String LFCR = LF + CR;
    global static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;
}