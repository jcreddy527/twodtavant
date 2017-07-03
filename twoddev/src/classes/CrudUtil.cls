global with sharing class CrudUtil {

    global static final ApexPages.Message INSUFFICIENT_ACCESS = new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access');
    //ApexPages.addMessage(CrudUtil.INSUFFICIENT_ACCESS);
    global static final String INSUFFICIENT_ACCESS_TGR = 'Insufficient access';
    
    
    global static Boolean isWCCreateable(){ 
        return Schema.sObjectType.Warranty_Coverages__c.isCreateable();
    }
    
    global static Boolean isWRupdateable(){ 
        return Schema.sObjectType.Warranty_Registration__c.isUpdateable();
    }
    global static Boolean isWRCreateable(){ 
        return Schema.sObjectType.Warranty_Registration__c.isCreateable();
    }
    global static Boolean isWRUpsertable(){
        return Schema.sObjectType.Warranty_Registration__c.isCreateable() && Schema.sObjectType.Warranty_Registration__c.isUpdateable();
    }   
    
    global static Boolean isWRDeletable(){
        return Schema.sObjectType.Warranty_Registration__c.isDeletable();
    } 
    
    global static Boolean isWRuleCreateable(){
        return Schema.sObjectType.Warranty_Rule__c.isCreateable();
    } 
    global static Boolean isWRuleUpdatable(){
        return Schema.sObjectType.Warranty_Rule__c.isUpdateable();
    }     

    global static Boolean isWRuleUpsertable(){
        return Schema.sObjectType.Warranty_Rule__c.isCreateable() && Schema.sObjectType.Warranty_Rule__c.isUpdateable();
    }   
    
    global static Boolean isWRuleCriteriaCreateable(){
        return Schema.sObjectType.Warranty_Rule_Criteria__c.isCreateable();
    }
    global static Boolean isWRuleCriteriaUpdatable(){
        return Schema.sObjectType.Warranty_Rule_Criteria__c.isUpdateable();
    } 
    global static Boolean isWRuleCriteriaUpsertable(){
        return Schema.sObjectType.Warranty_Rule_Criteria__c.isCreateable() && Schema.sObjectType.Warranty_Rule_Criteria__c.isUpdateable();
    }       
    
    global static Boolean isAccountCreateable(){
        return Schema.sObjectType.Account.isCreateable();
    }
    global static Boolean isAccountDeletable(){
        return Schema.sObjectType.Account.isDeletable();
    }   
    global static Boolean isContactCreateable(){
        return Schema.sObjectType.Contact.isCreateable();
    }  
     
    global static Boolean isPaymentDefinitionCreateable(){
        return Schema.sObjectType.Payment_Definitions__c.isCreateable();
    }
    global static Boolean isPaymentDefinitionUpdatable(){
        return Schema.sObjectType.Payment_Definitions__c.isUpdateable();
    }
    global static Boolean isPaymentDefinitionDeletable(){
        return Schema.sObjectType.Payment_Definitions__c.isDeletable();
    }
    global static Boolean isPaymentConfigurationCreateable(){
        return Schema.sObjectType.Payment_Configuration__c.isCreateable();
    }
    
    global static Boolean isClaimCreateable(){
        return Schema.sObjectType.Claim__c.isCreateable();
    }  
    global static Boolean isClaimUpdatable(){
    	return Schema.sObjectType.Claim__c.isUpdateable();
    }  
    global static Boolean isAttachmentCreateable(){
        return Schema.sObjectType.Attachment.isCreateable();
    }
    global static Boolean isLookUpLayoutCreateable(){
    	return Schema.sObjectType.Lookup_Layout_Fields__c.isCreateable();
    }
    global static Boolean isLookUpLayoutUpdateable(){
    	return Schema.sObjectType.Lookup_Layout_Fields__c.isUpdateable();
    }
    global static Boolean isPATCreateable(){
        return Schema.sObjectType.Policy_Applicability_Term__c.isCreateable();
    }
    global static Boolean isPATUpdateable(){
        return Schema.sObjectType.Policy_Applicability_Term__c.isUpdateable();
    }
    global static Boolean isPATUpsertable(){
        return Schema.sObjectType.Policy_Applicability_Term__c.isCreateable() && Schema.sObjectType.Policy_Applicability_Term__c.isUpdateable();
    }
     global static Boolean isPATDeletable(){
        return Schema.sObjectType.Policy_Applicability_Term__c.isDeletable();
    }  
    
    global static Boolean isPDItemsCreateable(){
        return Schema.sObjectType.Payment_Definition_Items__c.isCreateable();
    }
    global static Boolean isPDItemsDeletable(){
        return Schema.sObjectType.Payment_Definition_Items__c.isDeletable();
    } 
    global static Boolean isPolicyDefinitionCreatable(){
        return Schema.sObjectType.Policy_Definition__c.isCreateable();
    } 
    global static Boolean isWRuleAssociationCreatable(){
        return Schema.sObjectType.Warranty_Rule_Association__c.isCreateable();
    } 
    global static Boolean isWRuleAssociationUpdatable(){
        return Schema.sObjectType.Warranty_Rule_Association__c.isUpdateable();
    }          
    global static Boolean isServiceCampaignCreatable(){
        return Schema.sObjectType.Service_Campaign__c.isCreateable();
    }
    global static Boolean isSmartLkpCSCreateable(){
        return Schema.sObjectType.Lookup_Layout_Fields__c.isCreateable();
    }
    global static Boolean isSmartLkpCSDeletable(){
        return Schema.sObjectType.Lookup_Layout_Fields__c.isDeletable();
    }
    global static Boolean isOnOffTriggerCreateable(){
        return Schema.sObjectType.OnOffTrigger__c.isCreateable();
    }
    global static Boolean isWODCreateable(){
        return Schema.sObjectType.WOD__c.isCreateable();
    }
    global static Boolean isInventoryCreateable(){
        return Schema.sObjectType.Inventory__c.isCreateable();
    }
    global static Boolean isInventoryUpdatable(){
        return Schema.sObjectType.Inventory__c.isUpdateable();
    }
    global static Boolean isCampaignMemberCreatable(){
        return Schema.sObjectType.Campaign_Members__c.isCreateable();
    }
    global static Boolean isWarrantyProductCreateable(){
        return Schema.sObjectType.Warranty_Product__c.isCreateable();
    }
    
    //Warranty_Product_Pricebook__c CRUD check
    global static Boolean isWarrantyPricebookCreateable(){
        return Schema.sObjectType.Warranty_Product_Pricebook__c.isCreateable();
    }
    global static Boolean isWarrantyPricebookUpdatable(){
        return Schema.sObjectType.Warranty_Product_Pricebook__c.isUpdateable();
    }
    global static Boolean isWarrantyPricebookUpsertable(){
        return Schema.sObjectType.Warranty_Product_Pricebook__c.isCreateable() && Schema.sObjectType.Warranty_Product_Pricebook__c.isUpdateable();
    }
     global static Boolean isWarrantyPricebookDeletable(){
        return Schema.sObjectType.Warranty_Product_Pricebook__c.isDeletable();
    } 
    
    //Claim Part CRUD check
    global static Boolean isClaimPartCreateable(){
        return Schema.sObjectType.Claim_Part__c.isCreateable();
    }
    global static Boolean isClaimPartUpdatable(){
        return Schema.sObjectType.Claim_Part__c.isUpdateable();
    }
    global static Boolean isClaimPartUpsertable(){
        return Schema.sObjectType.Claim_Part__c.isCreateable() && Schema.sObjectType.Claim_Part__c.isUpdateable();
    }
     global static Boolean isClaimPartDeletable(){
        return Schema.sObjectType.Claim_Part__c.isDeletable();
    } 
    
    
    
}