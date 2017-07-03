/**********************************************************************
 Name:  ServiceCampaignService
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Class used for copying claim template values into new field modification claim.
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Arun Kumar Anala        27/08/2015     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class ServiceCampaignLogicService {
    
    @InvocableMethod
    global static list<Claim__c> CopyDataFromClaimTemplate(list<ServiceCampaignLogicWrapper> ClaimsWithTemplateId)
    {
        system.debug('##'+ClaimsWithTemplateId);
        Set <Id> allClaimIDs = new Set <Id>();
        Map <Id,Claim__c> claimByClaimId = new Map<Id,Claim__c>();
        List <Claim__c> Claims = new list<Claim__c>();
        List <sObject> insertClaimPartsAndServInfos = new List <sObject>();
        List <sObject> deleteClaimPartsAndServInfos = new List <sObject>();  
       	
        
        for( ServiceCampaignLogicWrapper scw : ClaimsWithTemplateId) 
         {
             allClaimIDs.add(scw.claimTemplateId);
             allClaimIDs.add(scw.Claim.Id);
         }
        
        claimByClaimId = new Map<id,Claim__c>([SELECT Id, Total_Meals_Cost__c, TravelByDistance__c, TravelByHours__c, Causal_Part_Number__c, 
                                               Fault_Code__c, Total_Parking_Cost__c, Total_Category1_Cost__c,Total_Category10_Cost__c,
                                               Total_Category2_Cost__c,Total_Category3_Cost__c,Total_Category4_Cost__c,Total_Category5_Cost__c,
                                               Total_Category6_Cost__c,Total_Category7_Cost__c,Total_Category8_Cost__c,Total_Category9_Cost__c, 
                                               Claim_Parts_Pending_Approval__c,(SELECT Id, Name, Claim__c, Service_Job_Code__c, Additional_Labor_Hour__c,
                                               Total_Labor_hours__c, Reason_Additional_Labor_hour__c FROM Claim_Service_Informations__r),
                                               (SELECT Id, RecordTypeId, Name, Warranty_Product__c, Inventory__c, Quantity__c, Claim__c, 
                                               Custom_Part_Cost__c FROM Claim_Parts__r),(SELECT Id, RecordTypeId, Name, Quantity__c, Shipment_Due_Days__c,
                                               Warranty_Product__c, inventory__c, Payment_Condition__c FROM Removed_Claim_Parts__r) FROM Claim__c WHERE ID IN :allClaimIDs]);
      
         for(ServiceCampaignLogicWrapper scw : ClaimsWithTemplateId)
        {
         /*   if (Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isUpdateable() && 
                Schema.sObjectType.Claim__c.fields.TravelByHours__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByHours__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Fault_Code__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Fault_Code__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isUpdateable() )
            {
                claimByClaimId.get(sccId).TravelByDistance__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).TravelByDistance__c;
                claimByClaimId.get(sccId).TravelByHours__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).TravelByHours__c;
                claimByClaimId.get(sccId).Causal_Part_Number__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).Causal_Part_Number__c;
                claimByClaimId.get(sccId).Fault_Code__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).Fault_Code__c;
                claimByClaimId.get(sccId).Total_Meals_Cost__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).Total_Meals_Cost__c;
                claimByClaimId.get(sccId).Total_Parking_Cost__c = claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c).Total_Parking_Cost__c;
            }
            
           // System.Debug(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c);
           // System.Debug('Here is the culprit : ' + claimByClaimId.get(claimByClaimId.get(sccId).Campaign_Members__r.Service_Campaign__r.Claim_Template__c));
            Claim__c targetSObject = scw.Claim.Clone(true,false);
            
            if (Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isUpdateable() && 
                Schema.sObjectType.Claim__c.fields.TravelByHours__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByHours__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Fault_Code__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Fault_Code__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isUpdateable() &&
                Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isUpdateable() )
            {
                targetSObject.TravelByDistance__c = claimByClaimId.get(scw.claimTemplateId).TravelByDistance__c;
                targetSObject.TravelByHours__c = claimByClaimId.get(scw.claimTemplateId).TravelByHours__c;
                targetSObject.Causal_Part_Number__c = claimByClaimId.get(scw.claimTemplateId).Causal_Part_Number__c;
                targetSObject.Fault_Code__c = claimByClaimId.get(scw.claimTemplateId).Fault_Code__c;
                targetSObject.Total_Meals_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Meals_Cost__c;
                targetSObject.Total_Parking_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Parking_Cost__c;
            }
             */
             
            Claim__c targetSObject = scw.Claim.Clone(true,false);
            if (Schema.sObjectType.Claim__c.fields.Total_Category1_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category1_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category1_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category1_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category10_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category10_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category10_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category10_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category2_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category2_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category2_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category2_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category3_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category3_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category3_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category3_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category4_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category4_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category4_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category4_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category5_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category5_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category5_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category5_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category6_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category6_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category6_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category6_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category7_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category7_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category7_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category7_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category8_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category8_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category8_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category8_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Category9_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Category9_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Category9_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Category9_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Meals_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Meals_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Meals_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Total_Parking_Cost__c.isUpdateable()) 
            {
            targetSObject.Total_Parking_Cost__c = claimByClaimId.get(scw.claimTemplateId).Total_Parking_Cost__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByDistance__c.isUpdateable()) 
            {
            targetSObject.TravelByDistance__c = claimByClaimId.get(scw.claimTemplateId).TravelByDistance__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.TravelByHours__c.isCreateable() && Schema.sObjectType.Claim__c.fields.TravelByHours__c.isUpdateable()) 
            {
            targetSObject.TravelByHours__c = claimByClaimId.get(scw.claimTemplateId).TravelByHours__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Causal_Part_Number__c.isUpdateable()) 
            {
            targetSObject.Causal_Part_Number__c = claimByClaimId.get(scw.claimTemplateId).Causal_Part_Number__c;
            }
            
            if (Schema.sObjectType.Claim__c.fields.Fault_Code__c.isCreateable() && Schema.sObjectType.Claim__c.fields.Fault_Code__c.isUpdateable()) 
            {
            targetSObject.Fault_Code__c = claimByClaimId.get(scw.claimTemplateId).Fault_Code__c;
            }
            
            for(Claim_Part__c cp : claimByClaimId.get(scw.claimTemplateId).Claim_Parts__r)
            {
                //cp.Id = null;
                Claim_Part__c newClaimPart = cp.Clone(false,false);
              //  if(Schema.sObjectType.Claim_Part__c.fields.Claim__c.isCreateable() && Schema.sObjectType.Claim_Part__c.fields.Claim__c.isUpdateable())
                if(Schema.sObjectType.Claim_Part__c.fields.Claim__c.isCreateable())
                newClaimPart.Claim__c = scw.Claim.Id;
                //cp.Claim__c = scw.Claim.Id;
                insertClaimPartsAndServInfos.add(newClaimPart);
            }
            
            for(Claim_Part__c cp : claimByClaimId.get(scw.Claim.Id).Claim_Parts__r)
            {
                deleteClaimPartsAndServInfos.add(cp);
            }
            
            Double totalLaborHours = 0.00;
            for(Claim_Service_Information__c csi : claimByClaimId.get(scw.claimTemplateId).Claim_Service_Informations__r)
            {
               // csi.Id = null;
                Claim_Service_Information__c newCSI = csi.Clone(false,false);
                //if(Schema.sObjectType.Claim_Service_Information__c.fields.Claim__c.isCreateable() && Schema.sObjectType.Claim_Service_Information__c.fields.Claim__c.isUpdateable())
                if(Schema.sObjectType.Claim_Service_Information__c.fields.Claim__c.isCreateable())
                newCSI.Claim__c = scw.Claim.Id;
                totalLaborHours += csi.Total_Labor_hours__c;
                //csi.Claim__c = scw.Claim.Id;
                insertClaimPartsAndServInfos.add(newCSI);
            }
            SYSTEM.DEBUG('HERE IS CLAIM : '+ claimByClaimId.get(scw.Claim.Id));
         
           targetSObject.Total_Labor_Cost__c = totalLaborHours * scw.DealerLaborRate;
            
            for(Claim_Service_Information__c csi : claimByClaimId.get(scw.Claim.Id).Claim_Service_Informations__r)
            {
                deleteClaimPartsAndServInfos.add(csi);
            }
            
            Double partsPendingApprovalCount = 0.0;
            for(Removed_Claim_Part__c rcp : claimByClaimId.get(scw.claimTemplateId).Removed_Claim_Parts__r)
            {
                //rcp.Id = null;
                Removed_Claim_Part__c newRCP = rcp.Clone(false,false);
                if(Schema.sObjectType.Removed_Claim_Part__c.fields.Claim__c.isCreateable()) {
                 newRCP.Claim__c = scw.Claim.Id;   
                }
              	 
               
                if(newRCP.Is_Approved__c == False ){
                    
                    // changed by aman
                    if((rcp.Payment_Condition__c == 'Pay After Return') || (rcp.Payment_Condition__c == 'Pay After Inspection')){
                        partsPendingApprovalCount += 1.0;
                    }
               	}
               
               // rcp.Claim__c = scw.Claim.Id;
                insertClaimPartsAndServInfos.add(newRCP);
            }
            targetSObject.Claim_Parts_Pending_Approval__c = partsPendingApprovalCount;
            
            for(Removed_Claim_Part__c rcp : claimByClaimId.get(scw.Claim.Id).Removed_Claim_Parts__r)
            {
                deleteClaimPartsAndServInfos.add(rcp);
            }
            
            Claims.add(targetSObject);
        }
        
        
        if(insertClaimPartsAndServInfos.size() > 0)
        {
            insertClaimPartsAndServInfos.sort();
            insert(insertClaimPartsAndServInfos);
        }
        
        if(deleteClaimPartsAndServInfos.size() > 0)
        {
            delete(deleteClaimPartsAndServInfos);
        }
              
        return Claims;
    }
    
     global class ServiceCampaignLogicWrapper
    {
        @InvocableVariable(required=false)
        global Claim__c Claim;
        
        @InvocableVariable(required=false)
        global Id claimTemplateId; 
        
        @InvocableVariable(required=false)
        global double DealerLaborRate; 
  
    }
    
     
}