({
  doneWaiting: function(component, event, helper) {
		window.setTimeout(function(){ //console.log(component.getElements());
			//var allElements = component.getElements();
	  //  var rows = document.getElementsByTagName("tr");
			var rows = (component.getElements())[1].rows;
	    var visbleRows = [];
	    component.set("v.totalRows", rows);
	    component.set("v.totalRowsOriginal", rows);
	    component.set("v.totalRowsOriginalCount", rows.length);
	    var limit = component.get("v.limit");
            console.log(rows);
	    for (var i = 1; i < rows.length; i++) {
            console.log('------------1-------------------------rows',rows[i]);
	      rows[i].classList.add("slds-hide");
	    }
        console.log('limitttttttttttttttttt',limit+1);
        console.log(rows);   
            for (var i = 1; i < rows.length; i++) {
                console.log('------------2------------------------rows',rows[i]);
                rows[i].classList.remove("slds-hide");
                visbleRows.push(i);
            }    
            
            
            
	 /*   for (var i = 1; i < (limit+1); i++) {
            console.log('------------2------------------------rows',rows[i]);
	      rows[i].classList.remove("slds-hide");
	      visbleRows.push(i);
	    }*/
	    component.set("v.visibleRowsIndex", visbleRows);
	    component.set("v.offsetLimit", limit + 1);
	    helper.showNavigation(component, event, helper);
        helper.resetTable(component, event, helper)  ;     
	    //console.log('Limit has changed : ');
	    //console.log(limit);
	    //console.log(component.get("v.visibleRowsIndex"));
		}, 1000);
	/*	//console.log(component.getElements());
		var allElements = component.getElements();
  //  var rows = document.getElementsByTagName("tr");
		var rows = allElements[1].rows;
    var visbleRows = [];
    component.set("v.totalRows", rows);
    component.set("v.totalRowsOriginal", rows);
    component.set("v.totalRowsOriginalCount", rows.length);
    var limit = component.get("v.limit");
    for (var i = 1; i < rows.length; i++) {
    console.log('---------------------------------------- inside commented');
      rows[i].classList.add("slds-hide");
    }
    for (var i = 1; i < (limit + 1); i++) {
    console.log('---------------------------------------- inside commented');
      rows[i].classList.remove("slds-hide");
      visbleRows.push(i);
    }
    component.set("v.visibleRowsIndex", visbleRows);
    component.set("v.offsetLimit", limit + 1);
    helper.showNavigation(component, event, helper);
    //console.log('Limit has changed : ');
    //console.log(limit);
    //console.log(component.get("v.visibleRowsIndex")); */
  },
  updateView: function(component, event, helper) {
    var limit = parseInt((component.find("limitId")).get("v.value"));
    component.set("v.limit", limit);
    helper.showNavigation(component, event, helper);
    helper.resetTable(component, event, helper);
  },
  goNext: function(component, event, helper) {
    var limit = component.get("v.limit");
    var offset = component.get("v.offset");
    component.set("v.offset", offset + limit);
    helper.showNavigation(component, event, helper);
    helper.resetTable(component, event, helper);
  },
  goPrevious: function(component, event, helper) {
    var limit = component.get("v.limit");
    var offset = component.get("v.offset");
    var res = offset - limit;
    if (res < 1) {
      res = 1
    }
    component.set("v.offset", res);
    helper.showNavigation(component, event, helper);
    helper.resetTable(component, event, helper);
  },
  searchRows: function(component, event, helper) {
    var searchString = (component.find("searchString")).get("v.value");
    //console.log(searchString);
    //	searchString = helper.slugify(searchString);
    var re = new RegExp(searchString);
    var rowsFound = [];
    var totalRowsOriginal = component.get("v.totalRowsOriginal");
    for (var i = 1; i < totalRowsOriginal.length; i++) {
      if (re.test(totalRowsOriginal[i].textContent)) {
        rowsFound.push(totalRowsOriginal[i]);
      }
    }
    //console.log(rowsFound.length);
    if (rowsFound.length > 0) {
			var rowsOld = component.get("v.totalRows");
      var visibleRows = component.get("v.visibleRowsIndex");
      for (var i = 0; i < visibleRows.length; i++) {
          console.log('------------3-------------------------rows',rowsOld[visibleRows[i]]);
        rowsOld[visibleRows[i]].classList.add("slds-hide");
      }
      component.set("v.offset", 1);
      var limit = component.get("v.limit");
      var offset = component.get("v.offset");
      if (searchString != '') {
				//console.log('Search String is not blank : ' + searchString);
        component.set("v.totalRows", rowsFound);
        component.set("v.offsetLimit", Math.min(rowsFound.length, (offset + limit)));
      } else {
				//console.log('Search String is blank : ' + searchString);
        component.set("v.totalRows", totalRowsOriginal);
        component.set("v.offsetLimit", (offset + limit));
      }

    }
    helper.showNavigation(component, event, helper);
		var newVisbleRows = [];
		var rows = component.get("v.totalRows");
		//console.log('Offset is : ' + offset);
		//console.log('Limit is : ' + limit);
    for (var i = offset; i < component.get("v.offsetLimit"); i++) {
         console.log('------------4------------------------rows',rows[i]);
      rows[i].classList.remove("slds-hide");
			newVisbleRows.push(i);
    }
		component.set("v.visibleRowsIndex", newVisbleRows);
  },
})