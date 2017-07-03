/**********************************************************************
 Name:  CSVReader
 Copyright © 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
Class to read the csv file uploaded                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Manish         10/11/2014      INITIAL DEVELOPMENT
***********************************************************************/
global with sharing class CSVReader {
    
    /*******************************************************************
    Purpose: Read the complete CSV string and convert to list of list of string                                        
    Parameters: N/A
    Returns: List<list<String>> value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global static List<List<String>> readCSVFile(String fileString) {
        if (!fileString.endsWith(Parser.CRLF)) {
            fileString = fileString + Parser.CRLF;
        }
        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();
        
        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
            System.debug(fileString);
            csvValue = readCSVValue(fileString);
            rowValues.add(csvValue.value);
            if (csvValue.delimiter == Parser.CRLF) {
                fileValues.add(rowValues);
                rowValues = new List<String>();
            }
                
            if (csvValue.biteSize() == fileString.length()) {
                eod = true;
            }else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }
        return fileValues;
    }
    
    /*******************************************************************
    Purpose:                                            
    Parameters: N/A
    Returns: String value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global static CSVValue readCSVValue(String sData) {       
        CSVValue csvValue = new CSVValue();
        
        if (sData.startsWith(Parser.DQUOTE)) {
            csvValue.enclosed = true;          
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE                            
            Boolean closerFound = false;
            
            while (!closerFound) {
                dquoteIndex = sData.indexOf(Parser.DQUOTE, searchIndex);                
                dquotesIndex = sData.indexOf(Parser.DQUOTEDQUOTE,searchIndex);                
                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex
                            + Parser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }            
            csvValue.value = sData.substring(
                    Parser.DQUOTE.length(), dquoteIndex)
                            .replaceAll(Parser.DQUOTEDQUOTE, Parser.DQUOTE);
            
            Integer commaIndex = sData.indexOf(Parser.COMMA, dquoteIndex);
            Integer crlfIndex = sData.indexOf(Parser.CRLF, dquoteIndex);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.delimiter = Parser.CRLF;
            }
        }
        else {
            csvValue.enclosed = false;          
            Integer commaIndex = sData.indexOf(Parser.COMMA);
            Integer crlfIndex = sData.indexOf(Parser.CRLF);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = sData.substring(0, commaIndex);
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.value = sData.substring(0, crlfIndex);
                csvValue.delimiter = Parser.CRLF;
            }
        }
        System.debug('Returning: ' + csvValue);        
        return csvValue;
    }
    
    /*******************************************************************
    Purpose: Wrapper class                                     
    Parameters: N/A
    Returns: String value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global with sharing class CSVValue {
        global String value;
        global Boolean enclosed;
        global String delimiter;
        
        global CSVValue() {
            this(null, null, null);
        }
        
        global CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }
        
        global Integer biteSize() {
          Integer biteSize = value.replaceAll(Parser.DQUOTE, Parser.DQUOTEDQUOTE).length()+ delimiter.length();
          
          if (enclosed) {
            biteSize += Parser.DQUOTE.length() * 2;
          }          
          return biteSize;
        }
    }
    
}