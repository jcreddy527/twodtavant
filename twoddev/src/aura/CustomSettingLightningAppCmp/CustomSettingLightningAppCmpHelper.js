({
    getAllCustomSettingsName : function(component) {       
        var action=component.get("c.getAllCustomSettingsName");                 
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseArray = response.getReturnValue();                
                component.set("v.customSettingsName", Object.keys(responseArray));
                component.set("v.customSettingsAll", Object.keys(responseArray));
                //component.find("customSetting").set("v.value" , Object.keys(responseArray)[0]);
                component.set("v.csName",Object.keys(responseArray)[0] );
                component.set("v.customSettingsMap", responseArray);
                this.getCustomSettingRecords(component, event);
                component.set("v.showSpinner",false);                
            } else{
                console.log('FAIL');
                component.set("v.showSpinner",false);
            }            
        });$A.enqueueAction(action); 
        
    },
    getCustomSettingRecords : function(component, selectedCS) {       
        var action=component.get("c.getCustomSettingRecords");
        var csName=component.get("v.customSettingsName");
        var selectedCS = selectedCS || csName[0];
        var objectNames = component.get("v.customSettingsMap");
        action.setParams({
            "cSLabel": selectedCS,
            "objectNames": objectNames
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseArray = response.getReturnValue();
                var retRecords = responseArray.sObjectrecords;                
                var fieldsLabelMap =  responseArray.fieldsLabelMap;
                var fieldsApi =  Object.keys(fieldsLabelMap);
                var test = fieldsLabelMap['Trigger_Value__c'];
                fieldsLabelMap['Name'] = 'Name';
                fieldsApi.unshift('Name');                
                component.set("v.cSRecordsWrapper", Object.values(retRecords));                
                component.set("v.fieldsApi", fieldsApi);
                component.set("v.fieldsLabelMap", fieldsLabelMap);                
                if(retRecords.length > 0){
                    component.set("v.recordsFound", true);
                }else{
                    component.set("v.recordsFound", false);
                }
                component.set("v.showSpinner",false);
            } else{
                var error = response.getError();
                console.log('FAIL');
                component.set("v.recordsFound", false);
                component.set("v.showSpinner",false);
            }            
        });$A.enqueueAction(action); 
        
    },
    goSelceted : function(component, event) {
        var modalEdit = $(event.currentTarget);
		var modalSave = $(event.currentTarget).siblings('button');         
        $(event.currentTarget).parent().parent().children('td').each(function(){             
            var ff = $(this).children('input:text').prop('disabled', false);            
        });
        modalSave.removeClass('slds-hide');
        modalSave.addClass('slds-open');
        modalEdit.removeClass('slds-open');
        modalEdit.addClass('slds-hide');
        
    },
    cancel : function(component, event, current) {
        var modalcancel = $(event.currentTarget);
		var modalEdit = $(event.currentTarget).siblings('button[name="Edit"]');
        var modalSave = $(event.currentTarget).siblings('button[name='+current+']');
        $(event.currentTarget).parent().parent().children('td').each(function(){             
            var ff = $(this).children('input:text').prop('disabled', true);            
        });
        modalcancel.removeClass('slds-open');
        modalcancel.addClass('slds-hide');
        modalSave.removeClass('slds-open');
        modalSave.addClass('slds-hide');
        modalEdit.removeClass('slds-hide');
        modalEdit.addClass('slds-open');
        
    },
    saveSelceted : function(component, event) {       
        var modalEdit = $(event.currentTarget);
        var fieldsValue = {};
        var fieldsApi = component.get('v.fieldsApi');       
        var index = 0;
        
        var objectNames = JSON.parse(JSON.stringify(component.get("v.customSettingsMap")));
        var customSettingName = objectNames[component.find('customSetting').get('v.value')]; 
        $(event.currentTarget).parent().parent().children('td').each(function(){
            if(index < fieldsApi.length){
               fieldsValue[fieldsApi[index]] = $(this).children('input:text').val();               
            }else{
                fieldsValue['Id'] = $(this).children('div').children('input:text').val();
            }
            index++;
        });
        
        var ssd=JSON.stringify(fieldsValue);
        var action=component.get("c.saveRecord");
        action.setParams({
            "objectName": customSettingName,
            "fieldsValue": JSON.stringify(fieldsValue)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseArray = response.getReturnValue();                
                component.set("v.showSpinner",false);             
            } else{
                console.log('FAIL');
                component.set("v.showSpinner",false);
            }            
        });$A.enqueueAction(action);
        
    },
    showPopupHelper: function(component, componentId, className){    	    	
        var modal = component.find(componentId); 
        $A.util.removeClass(modal, className+'hide'); 
        $A.util.addClass(modal, className+'open');
    },
    hidePopupHelper: function(component, componentId, className){
        var modal = component.find(componentId); 
        $A.util.addClass(modal, className+'hide'); 
        $A.util.removeClass(modal, className+'open');         
    },
    getRecords : function(component, event, searchKey) {       
        var csNames = [];//component.get("v.customSettingsName");
        var csNamesAll = component.get("v.customSettingsAll");
        for(var cs in csNamesAll){
            if(csNamesAll[cs].toUpperCase().includes(searchKey.toUpperCase())){ 
                csNames.push(csNamesAll[cs]);
            }
        }
        component.set("v.customSettingsName",csNames);
    },
})