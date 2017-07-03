<aura:application access="GLOBAL" extends="ltng:outApp" >
 <aura:dependency resource="c:actionClaim"/>
    <ltng:require styles="/resource/slds/assets/styles/salesforce-lightning-design-system.css" />
    <!-- Include the SLDS static resource -->
	<!--<ltng:require styles="{!$Resource.SLDS0122 + '/assets/styles/salesforce-lightning-design-system.css'}"/>
         <div class="slds">
             <c:actionClaim />
        </div>-->
</aura:application>