/**********************************************************************
Name:  WarrantyRegistrationPolicyManager
Copyright ? 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose:  Manager Class to pick the policies

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Santhosh        29/07/2014      INITIAL DEVELOPMENT   
***********************************************************************/

global with sharing class WarrantyRegistrationPolicyManager {
    global static string NameSpace = SystemUtils.getNameSpace();
    global list<id> searchPolicy(List<String> pdId,List<String> lss,Map<String,String> groupMap,boolean isNonSerialized){
        //Declaration of variables
        Set<String> setOfPATFields = new Set<String>{'Id',NameSpace+'Policy_Definition__c',NameSpace+'Applicability_SubType__c',NameSpace+'Applicability_Value__c'}; 
            Set<String> setApplicableType = new Set<String>();
        List<Integer> flag=new List<Integer>();
        List<String> finalPolicy= new List<String>();
        Map< String, List<Policy_Applicability_Term__c> > policyMap = new  Map<String, List<Policy_Applicability_Term__c>>();   
        Integer WarrantyProduct;
        Integer Inventory;
        Integer Groups;
        
        //Getting the Picklist Types
        Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.Applicability_SubType__c.getDescribe();
        List<Schema.PicklistEntry> pickListEnt = fieldResult.getPicklistValues();
        system.debug('pickListEnt' + pickListEnt);        
        integer i=0;
        for(Schema.PicklistEntry ple: pickListEnt ){
            if(ple.getValue().contains(NameSpace+'Warranty_Product__c'))
                WarrantyProduct=flag.size();
            if(ple.getValue().contains(NameSpace+'Inventory__c'))
                Inventory=flag.size();
            if(ple.getValue().contains(NameSpace+'Group__c'))
                Groups=flag.size();
            flag.add(0);
            flag.add(0);            
            setApplicableType.add(ple.getValue());           
        }
        system.debug('WarrantyProduct::' + WarrantyProduct);
        //Assingment to a set
        Set<String> patValue = new Set<String>();
        for(String value:lss)
        {
            patValue.add(value);
        }
        system.debug('PAT' + patValue);
        
        //Getting all the PAT for the applicable policy
        String queryString = new SoqlBuilder()
            .selectx(setOfPATFields)
            .fromx(NameSpace+'Policy_Applicability_Term__c')
            .wherex(new SetCondition(NameSpace+'Policy_Definition__c').inx(pdId))
            .toSoql();
        system.debug('****Query on pat queryString******:'+queryString);
        List<Policy_Applicability_Term__c> ls= database.query(queryString);
        
        //Creating the Map
        for(String policyId : pdId)
        {
            List<Policy_Applicability_Term__c> patList = new List<Policy_Applicability_Term__c>(); 
            policyId=policyId.substring(0, 15);            
            for(Policy_Applicability_Term__c PAT : ls)
            {
                String patId=String.valueof(PAT.Policy_Definition__c).substring(0, 15);
                
                //System.debug(patId);
                //System.debug(policyId);
                if(patId==policyId)
                {
                     if(patId.equals(policyId)){
                     	//System.debug('Inside Policy Map');
                    	patList.add(PAT);
                     }
                }
            }
            policyMap.put(policyId,patList );
        }
        
        //Iteration over Policy
        for(String policyId : pdId)
        {
            policyId=policyId.substring(0, 15); 
            List<Policy_Applicability_Term__c> patList = policyMap.get(policyId);
            //Iteration over PAT
            for(Policy_Applicability_Term__c PAT : patList)
            {
                i=0;
                for(String applicableType : setApplicableType)
                {                   
                    if(PAT.Applicability_SubType__c==applicableType)
                    {
                        if(patValue.contains(PAT.Applicability_Value__c))
                        {
                            flag[i]=1;  //Our Item is there
                        }
                        flag[i+1]=1;  //Some Item is there
                    }
                    i=i+2;                    
                }
                
                //If Applicability subtype is Group
                i=0;
                if(PAT.Applicability_SubType__c.contains(NameSpace+'Group__c'))
                {
                    String objName = groupMap.get(PAT.Applicability_Value__c);
                    for(String applicableType : setApplicableType)
                    {         
                        System.debug('Inside Group');
                         System.debug(objName +  '-----' + applicableType); 
                        if(objName==applicableType)
                        {                            
                            system.debug('applicableType : ' + PAT.Applicability_Value__c);
                           
                            if(patValue.contains(PAT.Applicability_Value__c))
                            {
                                System.debug('Inside Group flag');
                                flag[i]=1;  //Our Item is there
                            }
                            flag[i+1]=1;  //some Item is there
                        }
                        i=i+2;                    
                    }
                    
                }
                
            }
            
            //Checking the flag whether the policy is applicable or not
            //if it comes 01 its not applicable
            
            system.debug('--flag-' + policyId);
            system.debug(flag);
            if(isNonSerialized)
            {
                flag[Inventory]=0;
                flag[Inventory+1]=0;
                flag[Groups]=0;
                flag[Groups+1]=0;                
            }
            for(i=0;i<flag.size();)
            {
                if(flag[i]==0 & flag[i+1]==1)
                {
                    break;
                }
                if(i==flag.size()-2)
                {
                    if(flag[WarrantyProduct]==1)
                        finalPolicy.add(policyId); 
                    system.debug('--Final-' + policyId);
                    system.debug('--final flag-' + flag);
                    
                }
                i=i+2;
            }
            
            //Resetting the flag
            i=0;
            for(Schema.PicklistEntry ple: pickListEnt ){
                flag[i]=0;
                flag[i+1]=0;
                i=i+2;                                   
            }
        }
        return finalPolicy;
    }
    
}