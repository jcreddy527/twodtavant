({
	showHideSpinner : function(component) {
		var svg = component.find(component.get("v.type"));
        console.log(':::::::: SVG value:');
        console.log(svg);
        if(component.get('v.show')) {
           svg.getElement().style.display = 'block'; 
        } else {
           svg.getElement().style.display = 'none'; 
        } 
	}
})