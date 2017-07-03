({
	doInit : function(component, event, helper) {
		var selectedDate = component.get('v.selectedDate');
		var startDate = component.get('v.startDate');
		var endDate = component.get('v.endDate');
		var dateValue = component.get('v.dateValue');
		var today = new Date();
		component.set('v.today',today);
		console.log('The date value is : ');
		console.log(dateValue);
		if((dateValue != '') && typeof dateValue != 'undefined'){
			console.log('The date value is not null at init. ');
			//console.log(dateValue);
			console.log(new Date(dateValue));
			component.set('v.value',new Date(dateValue));
			//helper.populateDate(component);
			var value = component.get('v.value');
			component.set("v.dateValueFormat",helper.MONTH_NAMES[value.getMonth()] + ' ' + value.getDate() + ',' + value.getFullYear());
			var selectedDate = component.get('v.selectedDate');
			selectedDate.month = helper.MONTH_NAMES[value.getMonth()];
			selectedDate.year = value.getFullYear();
			selectedDate.day = value.getDay();
			selectedDate.date = value.getDate();
			helper.hideAllDaysVisibility(component);
			helper.set_Day_Date_Visibility(component, event);
		}
		//console.log( (new Date(startDate)).getFullYear());
		//console.log('The selected Date is ');
		if(!selectedDate.month){
			//console.log('The selected date is null');

			//component.set('v.value',today);
			selectedDate.month = helper.MONTH_NAMES[today.getMonth()];
			selectedDate.year = today.getFullYear();
			selectedDate.day = today.getDay();
			selectedDate.date = today.getDate();
			//console.log(selectedDate);
			//console.log(component.get("v.days"));
			////console.log('Today date is : ');
			////console.log(component.get('v.today'));
			component.set('v.selectedDate',selectedDate);
		}
		var opts = [];
		for(var i = (new Date(startDate)).getFullYear() ; i <= (new Date(endDate)).getFullYear() ; i++)
		{
			if(i != today.getFullYear() ){
				opts.push({ class: "optionClass", label: i, value: i});
			} else {
				opts.push({ class: "optionClass", label: i, value: i, selected: "true"});
			}
		}
		component.find("InputSelectDynamic").set("v.options", opts);
		helper.hideAllDaysVisibility(component);
		helper.set_Day_Date_Visibility(component, event);
		//console.log(component.get("v.days"));
	},
	selectDate : function(component, event, helper) {
		//console.log(event.target.parentNode.className);
		if(typeof event.target.value != 'undefined' && (!(event.target.parentNode.className).match('slds-disabled-text'))){
		var days = component.get('v.days');
		$A.util.removeClass(component.find(component.get('v.selectedDate.id')), "slds-is-selected");
		$A.util.addClass(component.find('day' + event.target.value), "slds-is-selected");
		component.set('v.selectedDate.date',days[event.target.value]);
		component.set('v.selectedDate.id','day' + event.target.value);
		var selectedDate = component.get('v.selectedDate');
		//console.log('The selected Date is ');
		//console.log(selectedDate);
		var value = new Date(selectedDate.year, helper.MONTH_NAMES.indexOf(selectedDate.month), selectedDate.date);
		//console.log(value);
		component.set('v.value',value);
		helper.populateDate(component);
		//console.log('The selected Date is : ');
		//console.log(component.get('v.value').getFullYear());
	}
	},
	previousMonth : function(component, event, helper) {
		var newMonthIndex = helper.get_New_Month_Index(component, event, -1);
		component.set('v.selectedDate.month',helper.MONTH_NAMES[newMonthIndex]);
		helper.hideAllDaysVisibility(component);
		helper.set_Day_Date_Visibility(component, event);
	},
	nextMonth : function(component, event, helper) {
		var newMonthIndex = helper.get_New_Month_Index(component, event, 1);
		component.set('v.selectedDate.month',helper.MONTH_NAMES[newMonthIndex]);
		helper.hideAllDaysVisibility(component);
		helper.set_Day_Date_Visibility(component, event);
	},
	selectYear : function(component, event, helper) {
		////console.log('The year event has fired.');
		////console.log(event);
		////console.log(component.find('InputSelectDynamic').get("v.value"));
		component.set('v.selectedDate.year',component.find('InputSelectDynamic').get("v.value"));
		helper.hideAllDaysVisibility(component);
		helper.set_Day_Date_Visibility(component, event);
	},
	setValueAsToday : function(component, event, helper) {
		////console.log('The year event has fired.');
		////console.log(event);
		////console.log(component.find('InputSelectDynamic').get("v.value"));
		var selectedDate = component.get('v.selectedDate');
		var today = new Date();
		component.set('v.today',today);
		component.set('v.value',today);
		selectedDate.month = helper.MONTH_NAMES[today.getMonth()];
		selectedDate.year = today.getFullYear();
		selectedDate.day = today.getDay();
		selectedDate.date = today.getDate();
		//console.log(selectedDate);
		//console.log(component.get("v.days"));

		////console.log('Today date is : ');
		////console.log(component.get('v.today'));
		$A.util.removeClass(component.find(component.get('v.selectedDate.id')), "slds-is-selected");

		component.set('v.selectedDate',selectedDate);
		//helper.hideAllDaysVisibility(component);
		//helper.set_Day_Date_Visibility(component, event);
		//set the year
		var yearCmp = component.find('InputSelectDynamic');
		//console.log('The year component is: ');
		//console.log(yearCmp.getElements());
		var selectOptions = yearCmp.getElements()[0];
		//console.log(selectOptions[2]);
		for(var i = 0; i < selectOptions.length ;  i++){
			if(selectOptions[i].value == today.getFullYear()){
				selectOptions[i].selected = true ;
			}else{
				selectOptions[i].selected = false ;
			}
		}
		helper.populateDate(component);
		//yearCmp.set('v.value',2016);
		//component.set('v.InputSelectDynamic',yearCmp);
	},
	handleDateValueChange : function(component, event, helper) {
		//console.log('The date change has been handled:');
		var dateValue = component.get('v.dateValue');
		//console.log(dateValue);
		if(dateValue != ''){
			//console.log('The date change has been handled:');
			//console.log(dateValue);
			//console.log(new Date(dateValue));
			component.set('v.value',new Date(dateValue));
			var value = component.get('v.value');
			component.set("v.dateValueFormat",helper.MONTH_NAMES[value.getMonth()] + ' ' + value.getDate() + ',' + value.getFullYear());
			var selectedDate = component.get('v.selectedDate');
			selectedDate.month = helper.MONTH_NAMES[value.getMonth()];
			selectedDate.year = value.getFullYear();
			selectedDate.day = value.getDay();
			selectedDate.date = value.getDate();
			helper.hideAllDaysVisibility(component);
			helper.set_Day_Date_Visibility(component, event);
		//	helper.populateDate(component);
		} else {
			//console.log('The date change has been handled I am returning:');
			return;
		}
		//	var inputElement = dateCmp.getElement();
		////console.log(inputElement);
		//	inputElement.value = this.MONTH_NAMES[valueDate.getMonth()] + ' ' + valueDate.getDate() + ',' + valueDate.getFullYear();

	},

})