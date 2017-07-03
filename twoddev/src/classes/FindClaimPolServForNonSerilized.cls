/**********************************************************************
Name:  FindClaimPolServForNonSerilized
Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Class used find policy definition for non serilzied items

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 - AKR                 12/14/2016     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class FindClaimPolServForNonSerilized
{
    
    /*******************************************************************
Purpose:  to update the Policy Definition for the claim                                                   
Parameters: N/A
Returns: none
Throws [Exceptions]:                                                      
********************************************************************/
    global static string NameSpace = SystemUtils.getNameSpace();
    @InvocableMethod
    global static void findClaimPolicyForNonSerilized(List<Claim__c> ObjClaimList){
        system.debug('$$$'+ObjClaimList[0].id);
        Set<Id> claimSet=new  Set<Id>();
        set<String> PolicyDefinitionIdSet = new set<String>();
        List<String> claimId=new  List<String>();
        Set<String> setFieldMap = new Set<String>();
        //8-Dec-2016 commented to pick the policy for non-serialized based on purchase date instead of failure date
        //Set<String> setOfCLFields = new Set<String>{'Id',NameSpace+'Date_of_Failure__c','recordtype.developername'};
        Set<String> setOfCLFields = new Set<String>{'Id',NameSpace+'Warranty_Product__r.Units_of_Measure__c',NameSpace+'Units_Run__c',NameSpace+'Date_Of_Purchase__c',NameSpace+'Date_of_Repair__c','recordtype.developername'};
            Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.WR_Field_Mapping_NS__c.getDescribe();
        List<Schema.PicklistEntry> pickListEnt = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple: pickListEnt ){
            setFieldMap.add(Ple.getValue());
            if(!setOfCLFields.contains(Ple.getValue())) 
                setOfCLFields.add(Ple.getValue());
        }
        
        
        String queryCL = new SoqlBuilder()
            .selectx(setOfCLFields)
            .fromx(NameSpace+'claim__c')
            .wherex(new FieldCondition('id').EQUALS(ObjClaimList[0].id))
            .toSoql();
        
        Claim__c objClaim;
        objClaim=database.query(queryCL);
        
        List<string> strSoql=new List<string>();
        String value;
        for(String s : setFieldMap) {
            if(!s.contains('.')){
                system.debug(' VALUE------------------->');
                SYSTEM.debug(objClaim);
                system.debug(objClaim.get(s));
                value = String.valueOF(objClaim.get(s));                        
            }            
            else {
                value = splitString(s,objClaim);
            }
            if(value != '' && value != null) {
                strSoql.add(value);
            }                                    
        }
        
        
        objClaim=database.query(queryCL);
        Map<String,String> groupMap=new Map<String,String>(); 
        if(objClaim.recordtype.developername !='Claim_Template') {          
        claimSet.add(Id.valueof(objClaim.Warranty_Product__c));
        claimSet.add(Id.valueof(objClaim.Account__c));
        
        
        List<Group_Member__c> memberList=[select id ,Group__c,Group__r.Object_Name__c from Group_Member__c where Record_Id__c in:claimSet];
                                               
        if(!memberList.isEmpty()){
            for(Group_Member__c grpIds:memberList){
                strSoql.add(string.valueOf(grpIds.Group__c));
                groupMap.put(string.valueOf(grpIds.Group__c), grpIds.Group__r.Object_Name__c);   
            }
        } 
        
       } 
        List<Policy_Applicability_Term__c> PATList=[SELECT Id,Policy_Definition__c FROM Policy_Applicability_Term__c WHERE Applicability_Value__c IN :strSoql];
        
        for(Policy_Applicability_Term__c PAT:PATList){
            PolicyDefinitionIdSet.add(PAT.Policy_Definition__c );
        }
        List<string> pdId=new List<string>(PolicyDefinitionIdSet);
        
        if(PolicyDefinitionIdSet.size()>0){
            String soqlbld = new SoqlBuilder()
                .selectx(new Set<Object>{'Id','Name',NameSpace+'Active_From__c',NameSpace+'Months_Covered__c',NameSpace+'Active_Until__c',NameSpace+'Priority__c',NameSpace+'Status__c',NameSpace+'Transferable__c',NameSpace+'Transfer_Fee__c',NameSpace+'Type__c',NameSpace+'Is_Policy_Optional__c'})
                .fromx(NameSpace+'Policy_Definition__c')
                .wherex(new AndCondition()
                        //8-Dec-2016 commented to pick the policy for non-serialized based on purchase date instead of failure date
                        //.add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(objClaim.Date_of_Failure__c))
                        //.add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(objClaim.Date_of_Failure__c))
                        .add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(objClaim.Date_Of_Purchase__c))
                        .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(objClaim.Date_Of_Purchase__c))
                        .add(new FieldCondition(NameSpace+'Status__c').equals('Active'))
                        .add(new SetCondition('Id').inx(pdId))
                       )
                .orderByx(new OrderBy(NameSpace+'Priority__c').ascending().nullsLast())
                .toSoql();
                     
            List<Policy_Definition__c> activePolDefList=Database.query(soqlbld );
            
             //add by siva -- query the policy definition inventory usage details
            List<Policy_Definition_Inventory_Usage__c> PDIUList = new List<Policy_Definition_Inventory_Usage__c>();
            PDIUList = [select id,Units_of_Measure__c,Maximum_Unit__c,Policy_Definition__c from Policy_Definition_Inventory_Usage__c where Policy_Definition__c IN:PolicyDefinitionIdSet];
            
            if(!activePolDefList.isEmpty()){
                //clear to remove inactive policies 12-12-2016
                pdid.clear();
            for(Policy_Definition__c policy:activePolDefList){
                 for(Policy_Definition_Inventory_Usage__c pdiu:PDIUList ){
                    if(pdiu.Policy_Definition__c == policy.Id){
                        if(objClaim.Units_Run__c<=pdiu.Maximum_Unit__c && objClaim.Warranty_Product__r.Units_of_Measure__c == pdiu.Units_of_Measure__c){
                            //added logic to handle non serialzied policy picking compare against repair date.
                            Integer months = Integer.valueOf(policy.Months_Covered__c);
                            date policyEndDate = objClaim.Date_Of_Purchase__c.addMonths(months);
                            if(objClaim.Date_of_Repair__c>=objClaim.Date_Of_Purchase__c && objClaim.Date_of_Repair__c<=policyEndDate ){
                                pdId.add(policy.Id );
                            }  
                        }
                    }
                }        
            }
            if(!pdId.isEmpty()){
            //Code for Limiting the Policy
            WarrantyRegistrationPolicyManager obj=new WarrantyRegistrationPolicyManager();
            list<id> ppid=obj.searchPolicy(pdId,strSoql,groupMap,true);
            System.debug('---------ppid------->>>' + ppid );
            pdId=ppid;
            
            Set<Id> policySet=new  Set<Id>();
            for(String policy:pdId){
                policySet.add(policy);
            }
            System.debug('---------policySet------->>>' + policySet );
            
            if(policySet.size()>0){
                
                List<Policy_Definition__c> poldefList = RuleEngine.RunEligibityRules(objClaim,policySet);
                //List<Policy_Definition__c> poldefList = new list<Policy_Definition__c>();
                list<Claim__c> ClmUpdateList = new list<Claim__c>();
                for(Claim__c tmpClm : ObjClaimList)
                {
                    Claim__c crntClm = new Claim__c(Id=objClaim.Id);
                    if (Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isUpdateable()){
                        crntClm.Applicable_Policy__c = poldefList.size() > 0 ? poldefList[0].Id :null;
                    }
                    ClmUpdateList.add(crntClm);
                }
                
                if(ClmUpdateList != null && ClmUpdateList.size() > 0)
                {
                    //updates the ratedetails for every claim
                    if(CrudUtil.isClaimUpdatable()){
                        Database.SaveResult[] claimUpdateList = database.update(ClmUpdateList ,false);
                        
                        for(Database.SaveResult sr : claimUpdateList){
                            if (sr.isSuccess()){
                                System.debug('Successfully updated claim Policy: ' + sr.getId());
                            }else{
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred while updating claim Policy.'+err);                 
                                }
                            }
                        }
                    }
                    else
                    {
                        System.debug('-----INSUFFICIENT_ACCESS---');
                    }
                }
                }
            }
            //if no policy do not set anything.. making it previous policy null
            else{
                   makePolicyNull(objClaim,ObjClaimList);
            }
            }
            else{
                 //no policy qualified reset the policy.
                makePolicyNull(objClaim,ObjClaimList);
            
            }
        }
        else{
        //no PAT qualified. 
        //reset the policy.
                makePolicyNull(objClaim,ObjClaimList);
        }
        
        
    }
    
    /*******************************************************************
Purpose: Find the value of related list                                     
Parameters: String(value which we want) and Sobject Object
Returns: String value
Throws [Exceptions]: N/A                                            
*******************************************************************/
    
    global static String splitString(String text,sobject objectData)
    {
        String[] obj ;
        String val;
        system.debug('-------TEXT--------' + text );
        obj = text.split('\\.',2);
        system.debug('------OBJ---------' + obj );
        val=obj[1];
        sobject parentObject = objectData.getSobject(obj[0]);
        if(parentObject==null)
        {
            return '';
        }        
        if(val.contains('.'))
        {
            return( splitString(val,parentObject) );
        }
        else
        {
            return( (String)parentObject.get(obj[1]) );
        }
    }
    
    global static void makePolicyNull(Claim__c objClaim,List<Claim__c> ObjClaimList){
        //no policy qualified reset the policy.
                list<Claim__c> ClmUpdateList = new list<Claim__c>();
                for(Claim__c tmpClm : ObjClaimList)
                {
                    Claim__c crntClm = new Claim__c(Id=objClaim.Id);
                    if (Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Applicable_Policy__c.isUpdateable()){
                        crntClm.Applicable_Policy__c = null;
                    }
                    ClmUpdateList.add(crntClm);
                }
                
                 if(ClmUpdateList != null && ClmUpdateList.size() > 0)
                {
                    //updates the ratedetails for every claim
                    if(CrudUtil.isClaimUpdatable()){
                        Database.SaveResult[] claimUpdateList = database.update(ClmUpdateList ,false);
                        
                        for(Database.SaveResult sr : claimUpdateList){
                            if (sr.isSuccess()){
                                System.debug('Successfully updated claim Policy: ' + sr.getId());
                            }else{
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred while updating claim Policy.'+err);                 
                                }
                            }
                        }
                    }
                    else
                    {
                        System.debug('-----INSUFFICIENT_ACCESS---');
                    }
                }
    }
    
}