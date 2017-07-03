//Wrapper class to store the selected records   
    global with sharing class SObjectFieldValueWrapper{
    	global boolean isSelected {get;set;}
        global String objectId{get;set;}
        global Map<String, String> objMap{get;set;}
        global SObjectFieldValueWrapper( String objId, Map<String,String> stringMap) {
        	isSelected = false;
            objectId = objId;
            objMap = stringMap;
        }
    }