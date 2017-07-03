({    
    getApplicabilityTypes : function(component) {       
        var action=component.get("c.getApplicabilityTypes");                 
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var responseArray = response.getReturnValue();
                responseArray.unshift("--None--" );
                component.set("v.ApplicabilityTypes", responseArray);                
            } else{
                console.log('FAIL');
            }            
        });$A.enqueueAction(action); 
        
    },
    getApplicabilitySubTypes : function(component) {        
        var action=component.get("c.getApplicabilitySubTypes");
        var ApplicabilityType = component.find("ApplicabilityType").get("v.value");
        var ASTSelected = component.get("v.RelatedTo");
        action.setParams({"ApplicabilityTypeSelected": ApplicabilityType});      
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){                                                
                component.set("v.ApplicabilitySubTypes", response.getReturnValue());
                if(ApplicabilityType == 'Referred by ID' && ASTSelected ==  undefined){
                	component.set("v.RelatedTo", response.getReturnValue()[0]);                
                }else if(ASTSelected !=  undefined){
                    component.set("v.RelatedTo", ASTSelected);                    
                    var ApplicabilitySubTypesList = response.getReturnValue();
                    var firstele = ApplicabilitySubTypesList[0];
                    for(var idx=0; idx<ApplicabilitySubTypesList.length; idx++){
                        if(ApplicabilitySubTypesList[idx] == ASTSelected){
                            ApplicabilitySubTypesList[0] = ASTSelected;
                            ApplicabilitySubTypesList[idx] = firstele;
                            break;
                        }
                    }                    
                    component.set("v.ApplicabilitySubTypes", ApplicabilitySubTypesList);
                }
            } else{
                console.log('FAIL');
            }            
        });$A.enqueueAction(action); 
        
    },
    removeNoneOption : function(component) {       
        var array  = component.get("v.ApplicabilityTypes");
        var index = array.indexOf('--None--');
        if (index > -1) {
            array.splice(index, 1);
        }        
        component.set("v.ApplicabilityTypes", array);        
    },
    selectedRecordsblockHideAndShow : function(component) {
        if(component.find("ApplicabilityType").get("v.value") == 'Referred by ID'){
            component.set("v.RelatedToText1", true);
            component.set("v.RelatedToText2", false);
            var ele = component.get("v.selectedRecordswrapper");   
            if(!$A.util.isEmpty(component.get("v.selectedRecordswrapper"))){            
                component.set("v.RenderSelected", true);
            }            
        }else{
            component.set("v.RelatedToText1", false);
            component.set("v.RelatedToText2", true);
            component.set("v.RenderSelected", false);            
        }        		       
    },
    getWRFieldMappings : function(component) {       
        var action=component.get("c.getWRFieldMappings");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var str = response.getReturnValue();
                component.set("v.WRFieldMappings", response.getReturnValue());                
            } else{
                console.log('FAIL');
            }            
        });$A.enqueueAction(action); 
        
    },
    getRecords : function(component, event, searchKey) {       
        var action=component.get("c.getRecords");
        var ObjName = document.getElementById("ApplicabilitySubType").value;
        component.set("v.lookUpRecordswrapper", null);        
        
        if(ObjName == undefined){
            ObjName = 'Account';
        }
        if(searchKey == undefined){
            searchKey = null;
        }
        action.setParams({
            "oName":  ObjName,
            "searchKey" : searchKey
        });
        var headingLabels;
        var fieldApiNames;
        var fieldLabelMap;
        
        
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){ 
                var responsewrapper=response.getReturnValue().split("record-Field-Separater");
                fieldLabelMap = JSON.parse(responsewrapper[1]);
                var nameLabel = fieldLabelMap['Name'];
                delete fieldLabelMap['Name'];
                headingLabels  =Object.values(fieldLabelMap);                
                headingLabels.unshift(nameLabel);
                fieldApiNames = Object.keys(fieldLabelMap);
                fieldApiNames.unshift('Name');                
                component.set("v.headingLabels", headingLabels);
                component.set("v.fieldApiNames", fieldApiNames);
                var recordsList = JSON.parse(responsewrapper[0]);
                var wrappers=new Array();
                if(recordsList.length > 0){
                    for (var idx=0; idx<recordsList.length; idx++) {
                        var wrapper = { 'objMap' : recordsList[idx].objMap, 
                                       'isSelected' : false,
                                       objectId : recordsList[idx].objectId
                                      };
                        wrappers.push(wrapper);
                    }
                }
                component.set("v.lookUpRecordswrapper", wrappers);
            } else{
                console.log('FAIL');
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
        component.set("v.body", ""); 
    },
    displaySelected : function(component) {        
        component.set("v.RenderSelected", false);        
        var wrappers=component.get('v.lookUpRecordswrapper');        
        var selectedwrapper=new Array();
        if(wrappers.length > 0){	        
            for (var idx=0; idx<wrappers.length; idx++) {
                if (wrappers[idx].isSelected) {
                    wrappers[idx].isSelected = false;                
                    selectedwrapper.push(wrappers[idx]);
                }
            } 
        }
        if(selectedwrapper.length > 0){
            component.set("v.selectedRecordswrapper", selectedwrapper);
            component.set("v.headingLabelsSelected", component.get('v.headingLabels'));
            component.set("v.RenderSelected", true);            
        }else{
            component.set("v.selectedRecordswrapper", null);
        }
    },
    /*getSearchResult : function(component, event) { 
        var searchKey = event.getParam("searchKey");
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {            
            var records=a.getReturnValue()
            var wrappers=new Array();
            for (var idx=0; idx<records.length; idx++) {
                var wrapper = { 'acc' : records[idx], 
                               'selected' : false
                              };
                wrappers.push(wrapper);
            }
            component.set("v.lookUpRecordswrapper", wrappers);
        });
        $A.enqueueAction(action);        
    },*/
    saveRecord : function(component, event, helper) {
        try{
            var action=component.get("c.SavePDRecord");
            var selectedRecords = [];
            var recordname;
            var Ids = [];
            var patId =component.get('v.id');
            var selectedRecordsStr;
            var selectedRecordsList = component.get('v.selectedRecordswrapper');
            if(selectedRecordsList != undefined ){
                if(selectedRecordsList.length > 0){
                    recordname = selectedRecordsList[0].objMap["Name"];
                    for (var idx=0; idx<selectedRecordsList.length; idx++) {
                        if(selectedRecordsList[idx].isSelected){
                            Ids.push(selectedRecordsList[idx].objectId);
                            selectedRecords.push(selectedRecordsList[idx]);
                        }
                    }        
                    selectedRecordsStr = JSON.stringify(selectedRecordsList);
                }
                console.log('selectedRecordsStr');
                console.log(selectedRecordsStr);
                console.log('recordname');
                console.log(recordname);
                var ApplicabilityType = component.find("ApplicabilityType").get("v.value");
                //var ApplicabilitySubType = document.getElementById("ApplicabilitySubType").value;
                var ApplicabilitySubType = component.get("v.RelatedTo");
                //var WRFieldMappings = component.find("WRFieldMappings").get("v.value");
                var WRFieldMappings = '';
                if(!$A.util.isEmpty(component.get("v.RelatedToInput")) && ApplicabilitySubType == undefined){
                    ApplicabilitySubType  = 'Customer Type' ; 
                }
                console.log('-------------RelatedTo-----------'+component.get("v.RelatedTo"));
                console.log('----------RelatedToInput--------------'+component.get("v.RelatedToInput"));
                /*if($A.util.isEmpty(component.get("v.RelatedToInput"))){
                    ApplicabilitySubType  = 'Account'; 
                } */
                console.log('----------ApplicabilitySubType--------------'+ApplicabilitySubType);
                if( selectedRecords.length > 0 || selectedRecords.length == 1 || !$A.util.isEmpty(component.get("v.RelatedToInput"))){
                    helper.showSpinner(component, event, helper);                    
                    action.setParams({
                        "fieldValueWrapperRecordString":  selectedRecordsStr,
                        "RecordName"       		:  	recordname,
                        "ApplicabilityTermType"	:	ApplicabilityType,
                        "ApplicabilitySubType" 	:	ApplicabilitySubType,
                        "recordIDList" 			:	Ids,
                        "polDefId" 				: 	patId,
                        "WRFieldMappings" 		: 	WRFieldMappings || 'Inventory__c',
                        "ApplicabilityLabel"	: 	component.get("v.RelatedToInput")                        
                    });
                    action.setCallback(this,function(response){
                        var state = response.getState();
                        if(state == 'SUCCESS'){ 
                            var res=response.getReturnValue();
                            helper.hideSpinner(component, event, helper);                
                            location.replace("/"+patId);                
                        } else{
                            helper.hideSpinner(component, event, helper);
                            var errorMessage = component.find("errorMessage");
                            $A.util.removeClass(errorMessage, 'hide');
                            var error = response.getError()[0]["message"];
                            if(component.get('v.id') == undefined){
                                component.set("v.error", $A.get("$Label.c.URL_Does_Not_Have_ID"));
                            }else{
                                component.set("v.error", error);
                            }
                        }            
                    });
                    $A.enqueueAction(action);
                }else{
                    alert($A.get("$Label.c.Select_Records_To_Save"));
                }
            }else if(component.get("RelatedToInput") != undefined){
                
            }
        }
        catch(e){
            alert($A.get("$Label.c.Select_Records_To_Save"));
        }
    },
    deleteRecords : function(component) {
        var selectedRecords=component.get('v.selectedRecordswrapper');
        var selectedAnyRecord = false;
        var count = 0;
        var size = selectedRecords.length;
        for (var idx=0; idx<selectedRecords.length; idx++) {
            if (selectedRecords[idx].isSelected) {                                
                delete selectedRecords[idx];
                selectedAnyRecord = true;
                count+=1;
            }
        }
        if(count == size ){
            component.set("v.RenderSelected", false);   
        }         
        component.set('v.selectedRecordswrapper', selectedRecords);
        if(!selectedAnyRecord){
            alert($A.get("$Label.c.Delete_Selected_Records"));
        }
    },
    cancel : function(component) {        
        var patId =component.get('v.id');              
        location.replace("https://wod31dev-dev-ed.my.salesforce.com/"+patId); 
    },
    showSpinner : function (component, event, helper) {
        var cmpTarget = component.find('group');
        $A.util.addClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();         
    },
    
    hideSpinner : function (component, event, helper) {
        var cmpTarget = component.find('group');
        $A.util.removeClass(cmpTarget, 'hide');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
})