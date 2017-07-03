({
    doInit:function(component, event, helper) {
    	var action = component.get("c.getServiceCampaignStatus");
    	var inputsel = component.find("InputSelectDynamic");
    	var opts=[];
    		action.setCallback(this, function(a) {
        	for(var i=0;i< a.getReturnValue().length;i++){
            	opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
        	}
            
            ///filter only Draft status///
            	opts = opts.filter(function(a){
                   if(a['label']=='Draft'){
                        return a;
                    }
                });
                opts[0]['selected'] = true;
            ///////////////////////////////    
                
        	inputsel.set("v.options", opts);

    	});
        $A.enqueueAction(action);
        
        var actionType = component.get("c.getServiceCampaignType");
    	var inputselType = component.find("InputSelectDynamicType");
    	var optsType=[];
    		actionType.setCallback(this, function(aa) {
        	for(var j=0;j< aa.getReturnValue().length;j++){
            	optsType.push({"class": "optionClass", label: aa.getReturnValue()[j], value: aa.getReturnValue()[j]});
        	}
        	inputselType.set("v.options", optsType);

    	});
    	$A.enqueueAction(actionType);
    },
  	createNewGroup : function(component, event, helper) {
    var Cam_Name = component.find("Cam_Name")
    var Cam_NameVal = Cam_Name.get("v.value");
    var Cam_StartDate = component.find("Cam_StartDate")
    var Cam_StartDate1 = Cam_StartDate.get("v.value");
    var Cam_Enddate = component.find("Cam_Enddate")
    var Cam_Enddate1 = Cam_Enddate.get("v.value");
    var InputSelectDynamicType = component.find("InputSelectDynamicType")
    var InputSelectDynamicType1 = InputSelectDynamicType.get("v.value");
    var InputSelectDynamic = component.find("InputSelectDynamic")
    var InputSelectDynamic1 = InputSelectDynamic.get("v.value");
    var Cam_ClaimTemp = component.find("Cam_ClaimTem")
    var Cam_ClaimTemp1 = Cam_ClaimTemp.get("v.value");
    var Cam_PayDef = component.find("Cam_PayDef")
    var Cam_PayDef1 = Cam_PayDef.get("v.value");
               
        if(Cam_NameVal.length == 0 ){
          
            Cam_Name.set("v.errors", [{message:"{!$Label.c.Please_Enter_Name}"}]);
        }
        else if(Cam_StartDate1.length == 0 && Cam_NameVal.length != 0){
            Cam_Name.set("v.errors", null);
            Cam_StartDate.set("v.errors", [{message:"{!$Label.c.Please_Enter_Start_Date}"}]);
        }
        else if(Cam_Enddate1.length == 0 && Cam_StartDate1.length != 0){
            Cam_StartDate.set("v.errors", null);
            Cam_Enddate.set("v.errors", [{message:"{!$Label.c.Please_Enter_End_Date}"}]);
        }                
        else if(InputSelectDynamicType1 == '--None--' && Cam_Enddate1.length != 0){
            Cam_Enddate.set("v.errors", null);
            InputSelectDynamicType.set("v.errors", [{message:"{!$Label.c.Please_Select_Campaign_Type}"}]);
        }
        else if(InputSelectDynamic1 == '--None--' && InputSelectDynamicType1 != '--None--'){
            InputSelectDynamicType.set("v.errors", null);
            InputSelectDynamic.set("v.errors", [{message:"{!$Label.c.Please_Select_Status}"}]);            
        }
        else if(Cam_PayDef1.length == 0 && InputSelectDynamic1 != '--None--'){
            InputSelectDynamic.set("v.errors", null);           
            component.set("v.errorMessagePayDef", $A.get("$Label.c.Please_Select_Payment_Definitions"));
        }
 		else if(Cam_ClaimTemp1.length == 0){ 
            component.set("v.errorMessagePayDef", null);
            component.set("v.errorMessageClaTem", $A.get("$Label.c.Please_Enter_Claim_Template")); 
        }
        else{
        	component.set("v.showSpinner",true);
        	component.set("v.showTable",false);
        	var action=component.get("c.createNwGroup");
        	var objGrp=component.get("v.newCampaign");
        	var recordIds=[];
        	var ids=component.get("v.recordIds");
        	

        var fieldName = component.find("Cam_Name").get("v.value");
        
        
        recordIds = component.get("v.recordIds").split(",");
        action.setParams({"objGroup":objGrp,"recordids":recordIds});

        action.setCallback(this, function(a) { 
        var result = a.getReturnValue();
               window.history.go(-1);
            });        
        $A.enqueueAction(action);
        }
	},
    cancel : function(component, event, helper) {
        window.history.back();
    },
    gotoListView:function(component, event, helper) {
        //window.history.go(-1);
    }
})