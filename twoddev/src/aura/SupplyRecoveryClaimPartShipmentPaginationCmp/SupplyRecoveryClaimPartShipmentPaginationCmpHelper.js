({
	resetTable: function(component, event, helper) {
		var limit = component.get("v.limit");
		var offset = component.get("v.offset");
		var rows = component.get("v.totalRows");
		var rowsOriginal = component.get("v.totalRowsOriginal");
		var visibleRows = component.get("v.visibleRowsIndex");
		//console.log(rows);

		for (var i = 0; i < visibleRows.length; i++) {
      rows[visibleRows[i]].classList.add("slds-hide");
    }
		var newVisbleRows = [];
		//console.log('Offset is : ' + offset);
		//console.log('Limit is : ' + limit);
		var looptill = Math.min(rows.length,(offset + limit));
		component.set("v.offsetLimit", looptill);
    for (var i = offset; i < looptill; i++) {
      rows[i].classList.remove("slds-hide");
			newVisbleRows.push(i);
    }
		component.set("v.visibleRowsIndex", newVisbleRows);
  },
	showNavigation: function(component, event, helper) {
		var totalRowsCount = (component.get("v.totalRows")).length;
		var limit = component.get("v.limit");
		var offset = component.get("v.offset");
		if(offset > 1){
			component.set("v.showPrevious","Yes");
		}else{
			component.set("v.showPrevious","No");
		}
		if((totalRowsCount - offset) > limit){
			component.set("v.showNext","Yes");
		}else{
			component.set("v.showNext","No");
		}
	},
	slugify: function(text){
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-')           // Replace spaces with -
    .replace(/[^\u0100-\uFFFF\w\-]/g,'-') // Remove all non-word chars ( fix for UTF-8 chars )
    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
    .replace(/^-+/, '')             // Trim - from start of text
    .replace(/-+$/, '');            // Trim - from end of text
	}
})