/**********************************************************************
 Name:  CSVIterator()
 Copyright © 2014  Tavant Technologies Inc.
 ==============================================================
===============================================================
Purpose: 
Iterator class for the batch upload process                                                  
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Manish         10/11/2014      INITIAL DEVELOPMENT
***********************************************************************/
global with sharing class CSVIterator implements Iterator<String>, iterable<String>{ 

    global String fileData;
    global String introValue;
    //Constructor
    global CSVIterator(String fileData, String introValue){ 
        this.fileData = fileData;
        this.introValue = introValue;
    }   

    /*******************************************************************
    Purpose: Check if the iterator has values or not                                                
    Parameters: N/A
    Returns: Boolean value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global boolean hasNext(){ 
       return fileData.indexOf(introValue) >= 0 ? true : false;
    }    

    /*******************************************************************
    Purpose: Get the next set of values for the iteration                                               
    Parameters: N/A
    Returns: String value
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global String next(){ 
       String row = fileData.subString(0, fileData.indexOf(introValue));
       fileData = fileData.subString(fileData.indexOf(introValue) + introValue.length(),fileData.length());
       return row;
    }
    
    /*******************************************************************
    Purpose: Return the above   code                                                 
    Parameters: N/A
    Returns: null
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    global Iterator<String> Iterator(){
        return this;
    } 
   
}