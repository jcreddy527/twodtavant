/**********************************************************************
 Name:  TriggerHandler
 Copyright � 2014  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: 
Parent class for the trigger handlers that has the overridable
trigger event methods, this class identifies the trigger event 
and redirects to the right event method.Also handles the infinite
loop and switch on/off triggers based on the profile and method.                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Neethu         31/10/2014      INITIAL DEVELOPMENT            
***********************************************************************/
global virtual class TriggerHandler{

    // static map of <handlername, times executeProcess() was invoked>
    private static Map<String, LoopCount> loopCountMap;
      
    static {
    loopCountMap = new Map<String, LoopCount>();
    }
  
    //Constructor  
    public  TriggerHandler() {}

    /*******************************************************************
    Purpose: Called during execution, that redirects to the right
             event methods                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/

    public void executeProcess() {
        system.debug('Entering executeProcess: ');
        //Checks if the max loop count has reached, to avoid recursive calls
        if(addToLoopCount()) return;

        if(Trigger.isBefore && Trigger.isInsert) {
          this.beforeInsert();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
          this.beforeUpdate();
        } else if(Trigger.isBefore && Trigger.isDelete) {
          this.beforeDelete();
        } else if(Trigger.isAfter && Trigger.isInsert) {
          this.afterInsert();
        } else if(Trigger.isAfter && Trigger.isUpdate) {
          this.afterUpdate();
        } else if(Trigger.isAfter && Trigger.isDelete) {
          this.afterDelete();
        } else if(Trigger.isAfter && Trigger.isUndelete) {
          this.afterUndelete();
        }
        system.debug('Exiting executeProcess:');  
    }
        
    /*******************************************************************
    Purpose: Context-specific methods for override                                                    
    Parameters: N/A
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/

    protected virtual void beforeInsert(){}
    protected virtual void beforeUpdate(){}
    protected virtual void beforeDelete(){}
    protected virtual void afterInsert(){}
    protected virtual void afterUpdate(){}
    protected virtual void afterDelete(){}
    protected virtual void afterUndelete(){}
    
    /*******************************************************************
    Purpose: Avoid recursive calls by checking if the max set loop 
             count has reached
    Parameters: N/A
    Returns: Boolean
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    private boolean addToLoopCount() {
        system.debug('Entering addToLoopCount: ');
        String handlerName = getHandlerName();//get the handler name
        system.debug('##'+handlerName);
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            return exceeded;
        }
        system.debug('Exiting addToLoopCount: False');
        return false;
    }

    /*******************************************************************
    Purpose: Method that returns the trigger handler name                                                    
    Parameters: N/A
    Returns: String(handler name)
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    private String getHandlerName() {
        system.debug('Entering getHandlerName'+String.valueOf(this));
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /*******************************************************************
    Purpose: Set the max loop count for the execution                                                   
    Parameters: Integer (Maximum loop count)
    Returns: void
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/

    public void setMaxLoopCount(Integer max) {
        system.debug('Entering setMaxLoopCount: '+max);
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
        system.debug('Exiting setMaxLoopCount: ');
    }

    /*******************************************************************
    Purpose: Switch on or off trigger based on method/profile name                                                  
    Parameters: String (Executed functionality name)
    Returns: Boolean
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/
    public boolean isEnabled(String functionName){
        system.debug('Entering isEnabled: '+functionName);
        String profName;
        set<String> functionalitySet = new set<String>();        
        profName =  [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1].Name;
        if(OnOffTrigger__c.getInstance(profName)!=null){
            functionalitySet.addAll(String.valueof(OnOffTrigger__c.getInstance(profName).Function_Name__c).split(';'));
            if(functionalitySet.contains(functionName) ){
                system.debug('Exiting isEnabled: '+OnOffTrigger__c.getInstance(profName).isEnabled__c);
                return (OnOffTrigger__c.getInstance(profName).isEnabled__c);
            }else{return true;}

        }else{
            return true;
        }
    }

    /*******************************************************************
    Purpose: Inner class to handle the recursive calls per handler                                            
    Parameters: N/A
    Returns: N/A
    Throws [Exceptions]: N/A                                                         
    ********************************************************************/

    private class LoopCount {
        private Integer max;
        private Integer count;
               
        //constructor that accepts the parameter for the max count
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        //setter method
        public void setMax(Integer max) {
            this.max = max;
        }
        
        //increments the loop count and checks if it exceeded the max limit
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        //method that check if the loop count has reached or not
        public Boolean exceeded() {
            if(this.max < 0) return false;
            if(this.count > this.max) {
                return true;
            }
            return false;
        }
                
    }

  // exception class
  public with sharing class TriggerHandlerException extends Exception {}

}