({
    doInit: function(cmp,event,helper) {
        // Set the attribute value.
        // You could also fire an event here instead.
        var selectedSObject = cmp.find("selectedSObject");    
        $A.util.removeClass(selectedSObject, 'slds-show'); 
        $A.util.addClass(selectedSObject, 'slds-hide'); 
        
        var SObjectList = cmp.find("SObjectList");    
        $A.util.removeClass(SObjectList, 'slds-show'); 
        $A.util.addClass(SObjectList, 'slds-hide');
        if(cmp.get('v.selectedId') != null){
            //console.log('::: We entered here');
            cmp.sampleMethod();
        }
        
    } ,
    
    executeSOQL: function(cmp,event) {
        // console.log('I am inside' );
        var searchKey = cmp.find("lookup").get("v.value"); // value of the object on which the event occured          
        // cmp.set("v.searchKey", searchKey);
        if(searchKey == '') {
            cmp.set('v.sobjectList',null);
            //console.log('I am coming back');
            var SObjectList = cmp.find("SObjectList"); 
            $A.util.removeClass(SObjectList, 'slds-show'); 
            $A.util.addClass(SObjectList, 'slds-hide'); 
            return;    
            
        }
        
        var action = cmp.get('c.ReadSObjects');
        var query = ''
        if(cmp.get('v.condition') != '') {
            query = cmp.get('v.QuerySOQL') + ' WHERE Name LIKE \'%'  + searchKey + '%\'' + ' AND '+cmp.get('v.condition')+' LIMIT 10';
        } else {
            query = cmp.get('v.QuerySOQL') + ' WHERE Name LIKE \'%'  + searchKey + '%\'' + ' LIMIT 10';
        }
        
        console.log('Query : ' + query);
        
        action.setParams({ query : query });
        
        action.setCallback(this, function(response) {
            var state = response.getState();                                 
            //console.log('Called to Sever Successfully');
            if (state === "SUCCESS") {                             
                cmp.set('v.sobjectList',response.getReturnValue().sObjList);
                //console.log('::::: response value:');
                // console.log(response.getReturnValue());
                if(cmp.get("v.searchKey") != '')  {
                    
                    var SObjectList = cmp.find("SObjectList"); 
                    if(response.getReturnValue() != '')
                    {
                        $A.util.removeClass(SObjectList, 'slds-hide'); 
                        $A.util.addClass(SObjectList, 'slds-show');   
                    }
                    else{
                        $A.util.removeClass(SObjectList, 'slds-show'); 
                        $A.util.addClass(SObjectList, 'slds-hide');   
                    }
                }              else{
                    $A.util.removeClass(SObjectList, 'slds-show'); 
                    $A.util.addClass(SObjectList, 'slds-hide');   
                }                                        
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);         
    },
    
    selectSObject:function(cmp,event){
        //console.log('::: We are in selectSObject');
        //console.log('Selected value : ' + event.target.value);
        //console.log(event.target.value);
        var selectedRecord = '';
        var selectedId             = '';
        //console.log(event.target);
        //console.log(event);
        //capture value of selected name
        if(typeof event.target == "undefined") {
            
            selectedRecord   = cmp.get('v.selectedValue');
            selectedId                             = cmp.get('v.selectedId');
        } else {
            console.log(':::: Event target:');       
            selectedRecord = event.target.value;
            selectedId     = event.target.id;
        }
        console.log(':::: Selected Id:'+selectedId);
        
        var action = cmp.get('c.ReadSObjects');
        var query =cmp.get('v.QuerySOQL') + ' where Id= \'' + selectedId + '\'';
        console.log(query);
        action.setParams({ query : query });
        action.setCallback(this, function(response){
            console.log('::::: response value:');
            console.log(response.getReturnValue());
            if(response.getReturnValue().sObjList[0]!=undefined)
            {
                cmp.set('v.selectedValue',response.getReturnValue().sObjList[0].Name);
                
            }
            //            cmp.set('v.selectedValue',response.getReturnValue().sObjList[0].Name);
            //console.log(':::: Selected Id:'+selectedId);
            //console.log('::::: selected Record:'+  cmp.get('v.selectedValue') );
            selectedRecord   = cmp.get('v.selectedValue');
            var SObjectList = cmp.find("SObjectList");  
            $A.util.removeClass(SObjectList, 'slds-show'); 
            $A.util.addClass(SObjectList, 'slds-hide');   
            cmp.set('v.searchKey',selectedRecord);
            cmp.set('v.selSobject',selectedRecord);
            cmp.set('v.selectedId',selectedId);
            console.log(':::: Selected Id:'+cmp.get('v.selectedId'));
            
            var lookup = cmp.find("lookup_input");  
            $A.util.removeClass(lookup, 'slds-show'); 
            $A.util.addClass(lookup, 'slds-hide');
            var selectedSObject = cmp.find("selectedSObject");  
            $A.util.removeClass(selectedSObject, 'slds-hide'); 
            $A.util.addClass(selectedSObject, 'slds-show');
            //console.log('Selected selectedSObject : ');
            //console.log(selectedSObject);
        });
        $A.enqueueAction(action); 
    },
    
    resetInput : function(cmp, event, helper) {
        var lookup = cmp.find("lookup_input");  
        $A.util.removeClass(lookup, 'slds-hide'); 
        $A.util.addClass(lookup, 'slds-show');
        var selectedSObject = cmp.find("selectedSObject");  
        $A.util.removeClass(selectedSObject, 'slds-show'); 
        $A.util.addClass(selectedSObject, 'slds-hide');
        cmp.set('v.selSobject','');           
        cmp.set('v.searchKey',''); 
         cmp.set('v.selectedId',null);
        
    },
})