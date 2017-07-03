/********************************************************************************
 Name:  Custom Settings Test utility class
 Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: 
This class is used to create data for custom settings.
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR         DATE             DETAIL                FEATURES/CSR/TTP
1.0 -    Siva          11/9/2016     INITIAL DEVELOPMENT            
**********************************************************************************/
@isTest(seeAllData = true)
global class CustomSettingsUtilityTest{
    
    public static WOD__c changeCustomerName;
    public static WOD__c PaymentDefinitionTrigger;
    public static WOD__c PaymentDefinitionItemsTrigger;
    public static WOD__c updateMaximumUnit;
    public static WOD__c WarrantyRegistrationTrigger;
    public static WOD__c WarrantyRuleAssociationTrigger;
    public static WOD__c WarrantyRuleCriteriaTrigger;
    public static WOD__c OnPolicyChange;
    public static WOD__c InstalledClaimPart_AT;
    public static WOD__c MasterRecoveryClaim;
    public static WOD__c RemovedClaimPartTrigger;
    public static WOD__c PrefixConfigurations;
    public static WOD__c PaymentConfigurations;
    public static WOD__c NamespacePrefix;
    public static WOD__c DefaultPrice;
    public static WOD__c EnablePDIGroupLogic;
    
    //method to prepare test data
    global static void init(){
    
        //Create claim fields custom settings
        changeCustomerName = new WOD__c();
        changeCustomerName = WOD__c.getInstance('Enable changeCustomerName');
        if(changeCustomerName==null){
            changeCustomerName = new WOD__c();
            changeCustomerName.Name = 'Enable changeCustomerName';
            changeCustomerName.isTriggered__c =true;
            insert changeCustomerName;
            system.debug('the value is'+changeCustomerName);    
        }
        
        PaymentDefinitionTrigger = new WOD__c();
        PaymentDefinitionTrigger = WOD__c.getInstance('Enable PaymentDefinitionTrigger');
        if(PaymentDefinitionTrigger==null){
            PaymentDefinitionTrigger = new WOD__c();
            PaymentDefinitionTrigger.Name = 'Enable PaymentDefinitionTrigger';
            PaymentDefinitionTrigger.isTriggered__c =true;
            insert PaymentDefinitionTrigger;
            system.debug('the value is'+PaymentDefinitionTrigger);    
        }
        
        PaymentDefinitionItemsTrigger = new WOD__c();
        PaymentDefinitionItemsTrigger = WOD__c.getInstance('Enable PaymentDefinitionItemsTrigger');
        if(PaymentDefinitionItemsTrigger==null){
            PaymentDefinitionItemsTrigger = new WOD__c();
            PaymentDefinitionItemsTrigger.Name = 'Enable PaymentDefinitionItemsTrigger';
            PaymentDefinitionItemsTrigger.isTriggered__c =true;
            insert PaymentDefinitionItemsTrigger;
            system.debug('the value is'+PaymentDefinitionItemsTrigger);    
        }
        
        updateMaximumUnit = new WOD__c();
        updateMaximumUnit = WOD__c.getInstance('Enable updateMaximumUnit');
        if(updateMaximumUnit==null){
            updateMaximumUnit = new WOD__c();
            updateMaximumUnit.Name = 'Enable updateMaximumUnit';
            updateMaximumUnit.isTriggered__c =true;
            insert updateMaximumUnit;
            system.debug('the value is'+updateMaximumUnit);    
        }
        
        WarrantyRegistrationTrigger = new WOD__c();
        WarrantyRegistrationTrigger = WOD__c.getInstance('Enable WarrantyRegistrationTrigger');
        if(WarrantyRegistrationTrigger==null){
            WarrantyRegistrationTrigger = new WOD__c();
            WarrantyRegistrationTrigger.Name = 'Enable WarrantyRegistrationTrigger';
            WarrantyRegistrationTrigger.isTriggered__c =true;
            insert WarrantyRegistrationTrigger;
            system.debug('the value is'+WarrantyRegistrationTrigger);    
        }
        
        WarrantyRuleAssociationTrigger = new WOD__c();
        WarrantyRuleAssociationTrigger = WOD__c.getInstance('Enable WarrantyRuleAssociationTrigger');
        if(WarrantyRuleAssociationTrigger==null){
            WarrantyRuleAssociationTrigger = new WOD__c();
            WarrantyRuleAssociationTrigger.Name = 'Enable WarrantyRuleAssociationTrigger';
            WarrantyRuleAssociationTrigger.isTriggered__c =true;
            insert WarrantyRuleAssociationTrigger;
            system.debug('the value is'+WarrantyRuleAssociationTrigger);    
        }
        
        WarrantyRuleCriteriaTrigger = new WOD__c();
        WarrantyRuleCriteriaTrigger = WOD__c.getInstance('Enable WarrantyRuleCriteriaTrigger');
        if(WarrantyRuleCriteriaTrigger==null){
            WarrantyRuleCriteriaTrigger = new WOD__c();
            WarrantyRuleCriteriaTrigger.Name = 'Enable WarrantyRuleCriteriaTrigger';
            WarrantyRuleCriteriaTrigger.isTriggered__c =true;
            insert WarrantyRuleCriteriaTrigger;
            system.debug('the value is'+WarrantyRuleCriteriaTrigger);    
        }
        
        OnPolicyChange = new WOD__c();
        OnPolicyChange = WOD__c.getInstance('Enable OnPolicyChange');
        if(OnPolicyChange==null){
            OnPolicyChange = new WOD__c();
            OnPolicyChange.Name = 'Enable OnPolicyChange';
            OnPolicyChange.isTriggered__c =true;
            insert OnPolicyChange;
            system.debug('the value is'+OnPolicyChange);    
        }
        
        InstalledClaimPart_AT = new WOD__c();
        InstalledClaimPart_AT = WOD__c.getInstance('Enable InstalledClaimPart_AT');
        if(InstalledClaimPart_AT==null){
            InstalledClaimPart_AT = new WOD__c();
            InstalledClaimPart_AT.Name = 'Enable InstalledClaimPart_AT';
            InstalledClaimPart_AT.isTriggered__c =true;
            insert InstalledClaimPart_AT;
            system.debug('the value is'+InstalledClaimPart_AT);    
        }
        
        
        MasterRecoveryClaim = new WOD__c();
        MasterRecoveryClaim = WOD__c.getInstance('Enable MasterRecoveryClaim');
        if(MasterRecoveryClaim==null){
            MasterRecoveryClaim = new WOD__c();
            MasterRecoveryClaim.Name = 'Enable MasterRecoveryClaim';
            MasterRecoveryClaim.isTriggered__c =true;
            insert MasterRecoveryClaim;
            system.debug('the value is'+MasterRecoveryClaim);    
        }
        
        
        RemovedClaimPartTrigger = new WOD__c();
        RemovedClaimPartTrigger = WOD__c.getInstance('Enable RemovedClaimPartTrigger');
        if(RemovedClaimPartTrigger==null){
            RemovedClaimPartTrigger = new WOD__c();
            RemovedClaimPartTrigger.Name = 'Enable RemovedClaimPartTrigger';
            RemovedClaimPartTrigger.isTriggered__c =true;
            insert RemovedClaimPartTrigger;
            system.debug('the value is'+RemovedClaimPartTrigger);    
        }
        
        PrefixConfigurations = new WOD__c();
        PrefixConfigurations = WOD__c.getInstance('All Prefix Configurations');
        if(PrefixConfigurations==null){
            PrefixConfigurations = new WOD__c();
            PrefixConfigurations.Name = 'All Prefix Configurations';
            PrefixConfigurations.Trigger_Value__c = 'Percent_,Final_,Total_,Approved_';            
            insert PrefixConfigurations;
            system.debug('the value is'+PrefixConfigurations);    
        }
        
        PaymentConfigurations = new WOD__c();
        PaymentConfigurations = WOD__c.getInstance('All Payment Configurations');
        if(PaymentConfigurations==null){
            PaymentConfigurations = new WOD__c();
            PaymentConfigurations.Name = 'All Payment Configurations';
            PaymentConfigurations.Trigger_Value__c = 'Labor,Meals,Parking,TravelByDistance,TravelByHours';            
            insert PaymentConfigurations;
            system.debug('the value is'+PaymentConfigurations);    
        }
        
        NamespacePrefix = new WOD__c();
        NamespacePrefix = WOD__c.getInstance('Namespace Prefix');
        if(NamespacePrefix==null){
            NamespacePrefix = new WOD__c();
            NamespacePrefix.Name = 'Namespace Prefix';                     
            insert NamespacePrefix;
            system.debug('the value is'+NamespacePrefix);    
        }
        
        Warranty_Product__c TestWarrantyProduct = TestUtility.createWarrantyProduct();
        insert TestWarrantyProduct;
        
        Country__c country = new Country__c();
        country.name = 'US';
        insert country;
        
        Warranty_Product_Pricebook__c  priceBook = new Warranty_Product_Pricebook__c ();
        priceBook.name = 'test';
        priceBook.Price__c = 12;
        priceBook.Warranty_Product__c = TestWarrantyProduct.Id;
        priceBook.Country__c = country.Id;
        priceBook.Valid_From__c = date.parse('8/12/1990');
        priceBook.Valid_Until__c = date.parse('8/12/2099'); 
        insert priceBook;
        
        DefaultPrice = new WOD__c();
        DefaultPrice = WOD__c.getInstance('Default Price');
        if(DefaultPrice ==null){
            DefaultPrice = new WOD__c();
            DefaultPrice.Name = 'Default Price';
            DefaultPrice.Trigger_Value__c = priceBook.Id;                       
            insert DefaultPrice;
            system.debug('the value is'+DefaultPrice);    
        }
        
        EnablePDIGroupLogic = new WOD__c();
        EnablePDIGroupLogic = WOD__c.getInstance('Enable PDI Group Logic');
        if(EnablePDIGroupLogic ==null){
            EnablePDIGroupLogic = new WOD__c();
            EnablePDIGroupLogic.Name = 'Enable PDI Group Logic';
            EnablePDIGroupLogic.isTriggered__c = true;                       
            insert EnablePDIGroupLogic;
        }
        
        if(Removed_Part_Visibility__c.getOrgDefaults() == null){
            insert new Removed_Part_Visibility__c(SetupOwnerId=UserInfo.getOrganizationId(), Show_Removed_Parts__c=true);
        }
        
        
    }
}