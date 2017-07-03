({
    doInit:function(component, event, helper){
        var picklistElement = component.get('v.picklistElements');
        var movedPicklistElement = component.get('v.MovedPicklistElements');
        for( var i =picklistElement.length - 1; i>=0; i--){
          for( var j=0; j<movedPicklistElement.length; j++){
            if(picklistElement[i] === movedPicklistElement[j]){
              picklistElement.splice(i, 1);
            }
          }
        }
        component.set('v.picklistElements',picklistElement);
        
    },
    goright : function(component, event, helper) {
        console.log('---------- inside gorigfht');
		console.log(component.get('v.selectedValue'));
        var selectedValue = component.get('v.selectedValue');
        var index = component.get('v.picklistElements').indexOf(selectedValue);
        console.log('Index Selected : ' + index);
        var picklistElement = component.get('v.picklistElements');
        var movedPicklistElement = component.get('v.MovedPicklistElements');
        console.log(index);
        
        if (index > -1) {
            movedPicklistElement.push(picklistElement.splice(index, 1)[0]);
            component.set('v.picklistElements',picklistElement);
            component.set('v.MovedPicklistElements',movedPicklistElement);
            console.log('-------picklistElements---------------------');
            console.log(component.get('v.picklistElements'));
            console.log('-------MovedPicklistElements---------------------');
            console.log(component.get('v.MovedPicklistElements'));
        }
	},
    goleft : function(component, event, helper) {
        console.log('---------- inside goleft');
		console.log(component.get('v.selectedValue'));
        var selectedValue = component.get('v.selectedValue');
        var index = component.get('v.MovedPicklistElements').indexOf(selectedValue);
        console.log('Index Selected : ' + index);
        var picklistElement = component.get('v.picklistElements');
        var movedPicklistElement = component.get('v.MovedPicklistElements');
        console.log(index);
        
        if (index > -1) {
            picklistElement.push(movedPicklistElement.splice(index, 1)[0]);
            component.set('v.MovedPicklistElements',movedPicklistElement);
            component.set('v.picklistElements',picklistElement);
            console.log('-------MovedPicklistElements---------------------');
            console.log(component.get('v.MovedPicklistElements'));
            console.log('-------picklistElements---------------------');
            console.log(component.get('v.picklistElements'));
        }        
	},
    goup : function(component, event, helper) {
        console.log('---------- inside goup');
        var selectedValue = component.get('v.selectedValue');
        console.log('--------selectedValue---------'+selectedValue); 
        var index = component.get('v.MovedPicklistElements').indexOf(selectedValue);
        console.log('=======index======='+index);      
        if (index > 0) {
            var movedPicklistElement = helper.changeindexposition(index,index-1,component.get('v.MovedPicklistElements'));
            component.set('v.MovedPicklistElements',movedPicklistElement);
            console.log('---------------MovedPicklistElements----------'+component.get('v.MovedPicklistElements'));
        }       
    },
    godown : function(component, event, helper) {
        console.log('---------- inside godown');
        var selectedValue = component.get('v.selectedValue');
        console.log('--------selectedValue---------'+selectedValue); 
        var index = component.get('v.MovedPicklistElements').indexOf(selectedValue);
        console.log('=======index======='+index);  
        console.log('----------length-1------------------------'+component.get('v.MovedPicklistElements').length-1);
        if (index < component.get('v.MovedPicklistElements').length-1) {
            var movedPicklistElement = helper.changeindexposition(index,index+1,component.get('v.MovedPicklistElements'));
            component.set('v.MovedPicklistElements',movedPicklistElement);
            console.log('---------------MovedPicklistElements----------'+component.get('v.MovedPicklistElements'));
        }  
    },
    onDragOver : function(component, event, helper) {
        console.log('-----------------------  I am in Drag over');
        event.preventDefault();
    },
    dragStarted : function(component, event, helper) {
        console.log('-----------------------  dragStarted');
        component.set('v.selectedValue',event.target.id) ;
        
    },    
    picklistElementSelected: function(component, event, helper) {
        console.log(event.target);
        console.log(event.target.textContent);
        //console.log(event);
        //console.log(event.getSource());
        component.set('v.selectedValue',event.target.textContent);
		
	}
})