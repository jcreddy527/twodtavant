global with sharing class WarrantyRegisterManager{
    global List<Warranty_Coverages__c> wCoverage;
    global static string NameSpace = SystemUtils.getNameSpace();
    global WarrantyRegisterManager(){
        wCoverage = new List<Warranty_Coverages__c>();
    }
    
    /*******************************************************************
Purpose: Insert Warranty Coverage with selected list of Policy Definition                                      
Parameters: warranty Register object and policyDefWrapper list
Returns: page - Warranty Register Page
Throws [Exceptions]: if warranty register id is null                                                         
********************************************************************/
    global void doRegisterManager(Warranty_Registration__c wRegistration,list<PolicyDefWrapper> policyDefList){
            system.debug('****** doRegister WarrantyRegisterManager******');
        try{
            
            if(Schema.sObjectType.Warranty_Coverages__c.fields.Is_Active__c.isCreateable() &&
               Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Start_Date__c.isCreateable() &&
               Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_End_Date__c.isCreateable() &&
               Schema.sObjectType.Warranty_Coverages__c.fields.Policy_Definition__c.isCreateable() &&
               Schema.sObjectType.Warranty_Coverages__c.fields.Warranty_Registration__c.isCreateable()                       
              ){ 
                  
                  for(PolicyDefWrapper eachwrap : policyDefList) {
                      if(eachwrap.selected == true) {
                          Warranty_Coverages__c wc = new Warranty_Coverages__c();                                               
                          wc.Policy_Definition__c = eachwrap.pd.Id;
                          wc.Warranty_Registration__c = wRegistration.id;
                          wc.Is_Active__c = true;
                          wc.Warranty_Start_Date__c = wRegistration.Registration_Date__c;
                          wc.Warranty_End_Date__c = wRegistration.Registration_Date__c.addMonths(Integer.valueOf(eachwrap.pd.Months_Covered__c != null ?eachwrap.pd.Months_Covered__c:0));
                          wCoverage.add(wc);
                      }
                  }
                  System.debug('coverage record============>'+wCoverage);
                  if(wCoverage.size() >0)
                  {
                      if(CrudUtil.isWCCreateable()){
                          insert wCoverage;
                      }
                      else
                          ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
                  }
              } 
            else
                ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
            
            
        } catch(Exception e) {
            system.debug('In catch : '+e);                
        }
    }
    
    /*******************************************************************
Purpose: Search Policy Definitions associated with warranty register                                    
Parameters: string - Warranty register object
Returns: list of Policy Definitions
Throws [Exceptions]: N/A                                            
*******************************************************************/
    global List<Policy_Definition__c> doSearch(Warranty_Registration__c wRegistration){
        try{
            List<Policy_Definition__c> pdlist = new List<Policy_Definition__c>();
            Set<String> setFieldMap = new Set<String>();
            Set<String> setOfWRFields = new Set<String>{'Id',NameSpace+'Account__c',NameSpace+'Inventory__c','Name',NameSpace+'Registration_Comments__c',NameSpace+'Registration_Date__c',NameSpace+'Warranty_End_Date__c',NameSpace+'Warranty_Start_Date__c'};
                Set<String> setOfPATFields = new Set<String>{'Id',NameSpace+'Policy_Definition__c'};           
                    
                    Schema.DescribeFieldResult fieldResult = Policy_Applicability_Term__c.WR_Field_Mapping__c.getDescribe();
            List<Schema.PicklistEntry> pickListEnt = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry ple: pickListEnt ){
                setFieldMap.add(Ple.getValue());
                if(!setOfWRFields.contains(Ple.getValue())) 
                    setOfWRFields.add(Ple.getValue());
            }
            String ids = wRegistration.id;   
            String queryWR = new SoqlBuilder()
                .selectx(setOfWRFields)
                .fromx(NameSpace+'Warranty_Registration__c')
                .wherex(new FieldCondition('id').EQUALS(ids))
                .toSoql();
            system.debug('****Query string Warranty reg: '+queryWR);
            wRegistration = database.query(queryWR);
            String value;
            List<String> lss =new List<String>();
            for(String s : setFieldMap) {
                if(!s.contains('.')){
                    system.debug('Warranty REG VALUE------------------->');
                    SYSTEM.debug(wRegistration);
                    system.debug(wRegistration.get(s));
                    value = String.valueOF(wRegistration.get(s));                        
                }
                
                else {
                    value = splitString(s,wRegistration);
                }
                if(value != '' && value != null) {
                    lss.add(value);
                }                                    
            }
            system.debug('lss--' + lss);
            //Code to get PAT from Groups  
            string strAccountId=string.valueOf(wRegistration.Account__c);
            strAccountId=strAccountId.substring(0, 15);
            string strInventoryId=string.valueOf(wRegistration.Inventory__c);
            strInventoryId=strInventoryId.substring(0, 15);
            
            
            Inventory__c objInventory=[select id,Item__c from Inventory__c where Id=:strInventoryId];
            system.debug('$$$'+objInventory.Item__c);
            string strProductId=string.valueOf(objInventory.Item__c);
            strProductId=strProductId.substring(0, 15);
            
            List<Group_Member__c> groupIds=[select Id,Group__c,Group__r.Object_Name__c from Group_Member__c where (Record_Id__c=:strAccountId OR Record_Id__c=:strInventoryId OR Record_Id__c=:strProductId )];
            Map<String,String> groupMap=new Map<String,String>();                                                
            if(!groupIds.isEmpty()){
                for(Group_Member__c grpIds:groupIds){
                    system.debug('---groupid---'+ids);
                    lss.add(string.valueOf(grpIds.Group__c));
                    groupMap.put(string.valueOf(grpIds.Group__c), grpIds.Group__r.Object_Name__c);   
                }
            } 
            
            if(ArrayUtils.isEmpty(lss)){
                lss.add('');
            }
            system.debug('$$$querystring'+lss);       
            String queryString = new SoqlBuilder()
                .selectx(setOfPATFields)
                .fromx(NameSpace+'Policy_Applicability_Term__c')
                .wherex(new SetCondition(NameSpace+'Applicability_Value__c').inx(lss))
                .toSoql();
            system.debug('****Query on pat queryString******:'+queryString);
            List<Policy_Applicability_Term__c> ls= database.query(queryString);
            
            Set<String> pdsId = new Set<String>();
            for(Policy_Applicability_Term__c p : ls) {
                pdsId.add(String.valueOf(p.get(NameSpace+'Policy_Definition__c')));
            }
            List<String> pdId = new List<string>(pdsId);
            Date regDate = wRegistration.Registration_Date__c;
            //Date regStartDate = CurrentInventory.Install_Date__c;
            if(ArrayUtils.isEmpty(pdId)){
                pdId.add('');
            }
            System.debug('---------------->>>' + pdId);
            System.debug('---------------->>>' + lss );
            System.debug('---------------->>>' + groupMap );
            
            //Code for Limiting the Policy
            WarrantyRegistrationPolicyManager obj=new WarrantyRegistrationPolicyManager();
            list<id> ppid=obj.searchPolicy(pdId,lss,groupMap,false);
            System.debug('---------ppid------->>>' + ppid );
            pdId=ppid;
            /*Set<Object> nameSpaceFeilds='';
            Schema.FieldSet fs1 = Schema.SObjectType.Account.fieldSets.getMap().get('field_set_name');  
            for(){
                
                nameSpaceFeilds.add(NameSpace+fieldName);
            }
            nameSpaceFeilds.add('Id').add('Name');*/
            
            String soqlbld = new SoqlBuilder()
                .selectx(new Set<Object>{'Id','Name',NameSpace+'Active_From__c',NameSpace+'Months_Covered__c',NameSpace+'Extended_policy_cost__c',NameSpace+'Active_Until__c',NameSpace+'Priority__c',NameSpace+'Status__c',NameSpace+'Transferable__c',NameSpace+'Transfer_Fee__c',NameSpace+'Type__c',NameSpace+'Is_Policy_Optional__c',NameSpace+'Pricebook_Type__c '})
                .fromx(NameSpace+'Policy_Definition__c')
                .wherex(new AndCondition()
                        .add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(regDate))
                        .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(regDate))
                        .add(new FieldCondition(NameSpace+'Status__c').equals('Active'))
                        .add(new SetCondition('Id').inx(pdId))
                       )
                .toSoql();
            System.debug('---------------->>>'+soqlbld);
            
              
            for(Policy_Definition__c eachPD : database.query(soqlbld)) {
                pdlist.add(eachPD);
            }
             System.debug('Aman is Here -->'+pdList);
            return pdList;
        } catch(Exception e) {
            system.debug('In catch : '+e.getMessage());
            return null;
        }
    }
    
    /*******************************************************************
Purpose: Search Policy Definitions associated                                      
Parameters: Map<String,String> WR_Field_Mapping__c(as keys) and values for search query, Date - Warranty register registration date
Returns: list of Policy Definitions
Throws [Exceptions]: N/A                                            
*******************************************************************/
    
    global List<Policy_Definition__c> doSearch(Map<String, String> mapWRFieldValue, Date wRegistrationDate){
        try{
            List<Policy_Definition__c> pdlist = new List<Policy_Definition__c>();
            Set<String> setOfPATFields = new Set<String>{'Id',NameSpace+'Policy_Definition__c'};
                List<String> lss = new List<String>();
            lss.addAll(mapWRFieldValue.values());
            
            if(ArrayUtils.isEmpty(lss)){
                lss.add('');
            }
            
            String queryString = new SoqlBuilder()
                .selectx(setOfPATFields)
                .fromx(NameSpace+'Policy_Applicability_Term__c')
                .wherex(new SetCondition(NameSpace+'Applicability_Value__c').inx(lss))
                .toSoql();
            system.debug('****Query on pat queryString******:'+queryString);
            List<Policy_Applicability_Term__c> ls= database.query(queryString);
            
            Set<String> pdsId = new Set<String>();
            for(Policy_Applicability_Term__c p : ls) {
                pdsId.add(String.valueOf(p.get(NameSpace+'Policy_Definition__c')));
            }
            List<String> pdId = new List<string>(pdsId);
            Date regDate = wRegistrationDate;
            if(ArrayUtils.isEmpty(pdId)){
                pdId.add('');
            }
            String soqlbld = new SoqlBuilder()
                .selectx(new Set<Object>{'Id','Name',NameSpace+'Active_From__c',NameSpace+'Months_Covered__c',NameSpace+'Active_Until__c',NameSpace+'Priority__c',NameSpace+'Status__c',NameSpace+'Transferable__c',NameSpace+'Transfer_Fee__c',NameSpace+'Type__c',NameSpace+'Is_Policy_Optional__c',NameSpace+'Pricebook_Type__c' })
                .fromx(NameSpace+'Policy_Definition__c')
                .wherex(new AndCondition()
                        .add(new FieldCondition(NameSpace+'Active_From__c').lessThanOrEqualTo(regDate))
                        .add(new FieldCondition(NameSpace+'Active_Until__c').greaterThanOrEqualTo(regDate))
                        .add(new FieldCondition(NameSpace+'Status__c').equals('Active'))
                        .add(new SetCondition('Id').inx(pdId))
                       )
                .toSoql();
            System.debug('---------------->>>'+soqlbld);
            for(Policy_Definition__c eachPD : database.query(soqlbld)) {
                pdlist.add(eachPD);
            }
             System.debug('Aman is Here -->'+pdList);
            return pdList;
        } catch(Exception e) {
            system.debug('In catch : '+e.getMessage());
            return null;
        }
    }
    
    /*******************************************************************
Purpose: Search existing Policy Definitions associated with an inv                                     
Parameters: Inventory__c CurrentInventory
Returns: list of Policy Definitions Ids
Throws [Exceptions]: N/A                                            
*******************************************************************/
    global set<Id> findExistingPolicies(Id CurrentInventoryId){
        try{
            
            list<Warranty_Registration__c> WRlist = [Select Id,Inventory__c,(Select Id,Policy_Definition__c,Warranty_Registration__c FROM Warranty_Coverages__r) FROM Warranty_Registration__c WHERE Inventory__c =:CurrentInventoryId];
            system.debug('WRlist is--->>>'+WRlist);
            set<Id> allPolicyDefIdSet = new set<Id>();
            if(WRlist != null && WRlist.size() > 0)
            {
                for(Warranty_Registration__c WR : WRlist)
                {
                    If(WR.Warranty_Coverages__r != null && WR.Warranty_Coverages__r.size() > 0)
                    {
                        for(Warranty_Coverages__c WC : WR.Warranty_Coverages__r)
                        {
                            allPolicyDefIdSet.add(WC.Policy_Definition__c);
                        }
                    }
                }
            }
            system.debug('allPolicyDefIdSet is ----->>>'+allPolicyDefIdSet);
            return allPolicyDefIdSet;
            
        } catch(Exception e) {
            system.debug('In catch : '+e.getMessage());
            return null;
        }
    }
    
    global with sharing class MyCustomException extends Exception{}
    
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
        system.debug('------objectData---------' + objectData );
        system.debug('------parentObject---------' + parentObject );
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
    
}