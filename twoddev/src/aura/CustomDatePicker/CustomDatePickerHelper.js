({
	get_New_Month_Index : function(component, event, addMonths) {
		var currentMonthIndex = this.MONTH_NAMES.indexOf(component.get("v.selectedDate.month"));
		var newMonthIndex = (currentMonthIndex + addMonths) % this.MONTH_NAMES.length;
		if(newMonthIndex < 0){
			newMonthIndex = this.MONTH_NAMES.length + newMonthIndex;
		}
		return newMonthIndex;
	},
	MONTH_NAMES : ["January","February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ] ,
	set_Day_Date_Visibility : function(component, event) {
		//console.log('I am inside set_Day_Date_Visibility');
		//Get todays date
		var today = component.get('v.today');
		//Get selected value
		var value = component.get('v.value');
		//Get total days
		var days = component.get('v.days');
		//console.log('Days : ');
		//console.log(days);
		//Get the selected Date
		var selectedDate = component.get('v.selectedDate');
		//console.log('selectedDate : ');
		//console.log(selectedDate);
		//Get the days in current month
		var daysInMonth = this.daysInMonth(selectedDate.year, this.MONTH_NAMES.indexOf(selectedDate.month));
		//console.log('daysInMonth : ');
		//console.log(daysInMonth);
		//Get the days in previous month
		var daysInPreviousMonth = this.daysInMonth(selectedDate.year, this.MONTH_NAMES.indexOf(selectedDate.month) - 1);
		//console.log('daysInPreviousMonth : ');
		//console.log(daysInPreviousMonth);
		//Get the first day of month
		var firstDayOfMonth = this.firstDayOfMonth(selectedDate.year, this.MONTH_NAMES.indexOf(selectedDate.month));
		//console.log('firstDayOfMonth : ');
		//console.log(firstDayOfMonth);
		//Set the days in calander
		for(var i = firstDayOfMonth ; i < (daysInMonth + firstDayOfMonth) ; i++){
			//console.log('First Days of Month : ' + firstDayOfMonth );
			//console.log('i value : ' + i );
			days[i] = i - (firstDayOfMonth - 1) ;
			$A.util.removeClass(component.find("day" + i), 'slds-disabled-text');
			if((today.getDate() == days[i]) && (selectedDate.year == today.getFullYear()) && (selectedDate.month == this.MONTH_NAMES[today.getMonth()])){
				$A.util.addClass(component.find("day" + i), 'slds-is-today');
			} else {
				$A.util.removeClass(component.find("day" + i), 'slds-is-today');
			}
			if(value != null){
				//console.log('The value is set.');
			if((value.getDate() == days[i]) && (selectedDate.year == value.getFullYear()) && (selectedDate.month == this.MONTH_NAMES[value.getMonth()])){
				$A.util.addClass(component.find("day" + i), 'slds-is-selected');
				component.set('v.selectedDate.id','day' + i);
			} else {
				$A.util.removeClass(component.find("day" + i), 'slds-is-selected');
			}
		}
			//console.log(' Days value : ' +  days[i] );
		}
		for(var i = (daysInMonth + firstDayOfMonth) ; i < days.length ; i++){
			days[i] = i - (daysInMonth + firstDayOfMonth - 1) ;
			$A.util.removeClass(component.find("day" + i), 'slds-is-today');
		}
		for(var i = 0 ; i < firstDayOfMonth ; i++){
			days[i] = daysInPreviousMonth - (firstDayOfMonth - (i + 1)) ;
			$A.util.removeClass(component.find("day" + i), 'slds-is-today');
		}
		//Set the days attribute value
		component.set("v.days",days);
	},
	daysInMonth : function(year,month) {
    return new Date(year, month + 1, 0).getDate();
	},
	firstDayOfMonth : function(year,month) {
    return new Date(year, month, 1).getDay();
	},
	hideAllDaysVisibility : function(component) {
		var days = component.get('v.days');
		for(var i =0 ; i <= days.length ; i++){
			$A.util.addClass(component.find("day" + i), 'slds-disabled-text');
		}
	},
	populateDate : function(component){
	//	var dateCmp = component.find('date');
		var valueDate = component.get('v.value');
	//	var inputElement = dateCmp.getElement();
		////console.log(inputElement);
	//	inputElement.value = this.MONTH_NAMES[valueDate.getMonth()] + ' ' + valueDate.getDate() + ',' + valueDate.getFullYear();
	//console.log('The selected date is ');
	//console.log(valueDate);
	//console.log(this.MONTH_NAMES[valueDate.getMonth()] + ' ' + valueDate.getDate() + ',' + valueDate.getFullYear());
		//component.set("v.dateValueFormat",this.MONTH_NAMES[valueDate.getMonth()] + ' ' + valueDate.getDate() + ',' + valueDate.getFullYear());
		component.set('v.dateValue', valueDate.getFullYear() + '-' + (valueDate.getMonth() + 1) + '-' + valueDate.getDate()  );
	//	component.set('v.dateValue', '2016-03-10'  );
	}
})