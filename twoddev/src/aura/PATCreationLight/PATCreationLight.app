<aura:application extends="ltng:outApp">
    <ltng:require styles="{!$Resource.SLDS0122 + '/assets/styles/salesforce-lightning-design-system.css'}"/>
    
   <aura:attribute name="showResponsibleCode" type="boolean" default="false"/>
    <aura:attribute name="id" type="string"/>
    
    <c:ApplicabilityType id="{!v.id}"/>
    
    
</aura:application>