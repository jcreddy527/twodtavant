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
            console.log('::: We entered here');
            cmp.sampleMethod();
        } 
        	
	} ,
    
    executeSOQL: function(cmp,event) {
        console.log('I am inside' );
            var searchKey = cmp.find("lookup").get("v.value"); // value of the object on which the event occured 	
           // cmp.set("v.searchKey", searchKey);
            if(searchKey == '') {
            cmp.set('v.sobjectList',null);
            console.log('I am coming back');
            var SObjectList = cmp.find("SObjectList"); 
            $A.util.removeClass(SObjectList, 'slds-show'); 
            $A.util.addClass(SObjectList, 'slds-hide'); 
            return;	
       
		}
        
		var action = cmp.get('c.findSObjectsBySOQL');
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
			console.log('Called to Sever Successfully');
			if (state === "SUCCESS") {		
                cmp.set('v.sobjectList',response.getReturnValue());
                console.log('::::: response value:');
                console.log(response.getReturnValue());
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
				}	else{
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
        console.log('::: We are in selectSObject');
        //console.log('Selected value : ' + event.target.value);
        console.log(':::: Event target:');
        console.log(event.target);
        var selectedRecord = '';
        var selectedId	   = '';
        //console.log(event.target);
        //console.log(event);
        //capture value of selected name
        if(typeof event.target == "undefined") {
            selectedRecord 	= cmp.get('v.selectedValue');
            selectedId		= cmp.get('v.selectedId');
        } else {
            selectedRecord = event.target.value;
            selectedId		=	event.target.id;
        }
        
        console.log(':::: Selected Id:'+selectedId);
        console.log('::::: selected Record:'+selectedRecord);
        // hide the sobjectlist
        var SObjectList = cmp.find("SObjectList");  
     	//   console.log('Selected SObjectList : ' + SObjectList);
        $A.util.removeClass(SObjectList, 'slds-show'); 
        $A.util.addClass(SObjectList, 'slds-hide');   
        // hide the input lookup
        var lookup = cmp.find("lookup");  
      	//  console.log('Selected lookup : ' + lookup);
        $A.util.removeClass(lookup, 'slds-show'); 
        $A.util.addClass(lookup, 'slds-hide');  
        // Set the value of Selected SObject Variable
        cmp.set('v.selSobject',selectedRecord);
        cmp.set('v.selectedValue',selectedRecord);
        cmp.set('v.value',selectedId);
        cmp.set('v.selectedId',selectedId);
        console.log(':::: Selected Id:'+cmp.get('v.selectedId'));
        // display the pill container with selected name
        var selectedSObject = cmp.find("selectedSObject");
       	console.log('Selected selectedSObject : ');
        console.log(selectedSObject);
        $A.util.removeClass(selectedSObject, 'slds-hide'); 
        $A.util.addClass(selectedSObject, 'slds-show');
    },
   	resetInput : function(cmp, event, helper) {
        var lookup = cmp.find("lookup");  
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