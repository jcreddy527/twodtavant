/**********************************************************************
Name:  ClaimAmountModifierService
Copyright ? 2015  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Class used for calculating the Amount Modifiers for the claim payment.

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    Arun Kumar Anala        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ClaimRateDetailLogicService {
    
    @InvocableMethod
    global static list<Id> SetRateDetail(list<Claim__c> Claims)
    {
        set<id> dealerIdSet = new set<id>();
        set<id> warrantyProductIdSet = new set<id>();
        List<Id> rateDetailIds = new List<Id>();
        Boolean foundFlag = false;
        List<Id> claimIds = new List<Id>();//added by siva
        Id defaultRate = WOD__c.getInstance('Default Rate').Trigger_Value__c;
        List<Rates_Details__c> rateDetailsList = new List<Rates_Details__c>();
        Map<Id,Rates_Details__c> RatesDetailsByIdMap = new Map<Id,Rates_Details__c>();
        
        //code added by shambhavi
        set<string> delerGroup=new set<string>();
        Set<Id> delerGroupMember=new Set<Id>();
        Set<Id> warrantyProductGroupMember=new Set<Id>();
        set<string> warrantyProductGroup=new set<string>();
        List<Id> inventoryId=new List<Id>();
        
        //code added by Dharmil
        Boolean isTriggered;
        WOD__c CustomSettingValue = new WOD__c();
        CustomSettingValue = WOD__c.getValues('Warranty Product Group');
        if(CustomSettingValue != null){
            isTriggered=CustomSettingValue.isTriggered__c;
        }
        
        for(Claim__c clm : Claims) {
            inventoryId.add(clm.Inventory__c);
            dealerIdSet.add(clm.Account__c);
            claimIds.add(clm.Id);
        }
        system.debug('inventoryId->'+inventoryId);
        system.debug('dealerIdSet->'+dealerIdSet);
        //---------------------
        for(Group__c gp:[Select id,(Select Id,Account__c,Warranty_Product__c from Group_Members__r where Account__c IN:dealerIdSet) from Group__c where Object_Name__c=:'Account']){
            system.debug('gp.Group_Members__r-->'+gp.Group_Members__r);
            List<Group_Member__c> gpm = new List<Group_Member__c>();
            
            if(gp.Group_Members__r !=null && gp.Group_Members__r.size() >0 ){
                delerGroup.add(gp.id);
                gpm = gp.Group_Members__r;
                delerGroupMember.add(gpm[0].Account__c);
            }
            
        }        
        system.debug('delerGroupMember-->'+delerGroupMember);
        
        //for dealer OR dealer Group logic
        if(isTriggered != true){            
            system.debug('delerGroup======>'+delerGroup);            
            if(dealerIdSet != null || delerGroup != null){
                rateDetailsList= [Select id,name,Priority__c,Dealer__c,Dealer_Group__c,Active_From__c,Active_Until__c from Rates_Details__c WHERE Status__c = 'Active' AND (Dealer__c IN: dealerIdSet OR Dealer_Group__c IN: delerGroup) ORDER BY Priority__c asc];
            }
            system.debug('rateDetailsList-->'+rateDetailsList);
            for(Claim__c clm: Claims){              
                for(Rates_Details__c rates: rateDetailsList){
                    if((clm.Account__c == rates.Dealer__c || delerGroupMember.Contains(clm.Account__c)) && clm.Date_of_Repair__c >= rates.Active_From__c && clm.Date_of_Repair__c <= rates.Active_Until__c){                     
                        if(rateDetailIds.isEmpty()){
                            rateDetailIds.add(rates.Id);                          
                        }
                    }
                }  
            }
            //Add default rate if rate details doesn't match
            if(rateDetailIds.isEmpty()){
                    rateDetailIds.add(defaultRate);                     
            }           
            system.debug('rateDetailIds-->'+rateDetailIds);
        }
        
        //for dealer OR dealer Group logic along with Warranty Product Group logic
        if(isTriggered == true){

            //Added by siva
             Set<String> setFieldMap = new Set<String>();
		     Set<String> setOfCLFields = new Set<String>{'Id','Warranty_Product__r.Units_of_Measure__c','Inventory__c','Units_Run__c','Date_Of_Purchase__c','Date_of_Repair__c','recordtype.developername'};
		     Schema.DescribeFieldResult fieldResult = claim__c.Rate_Grouping__c.getDescribe();
		     List<Schema.PicklistEntry> pickListEnt = fieldResult.getPicklistValues();
             for(Schema.PicklistEntry ple: pickListEnt ){
             	setFieldMap.add(Ple.getValue());
                	if(!setOfCLFields.contains(Ple.getValue())) 
                    	setOfCLFields.add(Ple.getValue());
              }
             String queryCL = new SoqlBuilder()
                        .selectx(setOfCLFields)
                        .fromx('claim__c')
                        .wherex(new  SetCondition('id').inx(claimIds))
                        .toSoql();
            
            List<Claim__c> objClaims = new List<Claim__c>();
            objClaims=database.query(queryCL);
            system.debug(objClaims);
            
            List<string> strSoql=new List<string>();
            List<string> allStrSoql=new List<string>();
            Map<Claim__c, List<String>> mapStrSoql = new Map<Claim__c, List<String>>(); 
            String value;
            for(Claim__c claim:objClaims){
                for(String s : setFieldMap) {
                    if(!s.contains('.')){                                                       
                        value = String.valueOF(claim.get(s));                        
                    }            
                    else {
                        value = splitString(s,claim);
                    }
                    if(value != '' && value != null) {
                        strSoql.add(value.left(15));
                        allStrSoql.add(value.left(15));
                        warrantyProductIdSet.add(value.left(15));
                    }                                    
                }  
                mapStrSoql.put(claim,strSoql);
                system.debug('the ids'+allStrSoql);
            }
                    
            system.debug('warrantyProductIdSet-->'+warrantyProductIdSet);
            system.debug('delerGroup-->'+delerGroup);
            //-------------
            for(Group__c gp:[Select id,(Select Account__c,Warranty_Product__c from Group_Members__r where Warranty_Product__c IN:warrantyProductIdSet) from Group__c where Object_Name__c=:'Warranty_Product__c']){
                if(gp.Group_Members__r !=null && gp.Group_Members__r.size() >0 ){
                    warrantyProductGroup.add(gp.id);
                }
            }
            system.debug('warrantyProductGroupMember-->'+warrantyProductGroupMember);
            
            List<Rates_Details__c> rateDetails = new List<Rates_Details__c>();
            if(dealerIdSet!=null || delerGroup != null){               
                rateDetails=[SELECT id,name,Priority__c,Dealer__c,Dealer_Group__c,Active_From__c,Active_Until__c FROM Rates_Details__c WHERE Status__c = 'Active' AND (Dealer__c IN:dealerIdSet OR Dealer_Group__c IN: delerGroup) AND (Warranty_Product_Group__c IN:warrantyProductGroup OR Warranty_Product_Group__c = null)order by Priority__c asc];
                system.debug('rateDetails-->'+rateDetails);
            }           
            for(Claim__c clm: Claims){
                for(Rates_Details__c rates: rateDetails){
                    if((clm.Account__c == rates.Dealer__c || delerGroupMember.Contains(clm.Account__c)) && clm.Date_of_Repair__c >= rates.Active_From__c && clm.Date_of_Repair__c <= rates.Active_Until__c){                       
                        if(rateDetailIds.isEmpty()){                           
                            rateDetailIds.add(rates.Id);                           
                        }
                    }
                }
            }
            //Add default rate if rate details doesn't match
            if(rateDetailIds.isEmpty()){
                    rateDetailIds.add(defaultRate);                  
            }
            system.debug('RatesDetailsByIdMap-->'+rateDetailIds);   
        }
        return rateDetailIds;
    }
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
}