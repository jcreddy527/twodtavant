({
                visible : function(component,Element) {
                                var pageElement = component.find(Element);
                                console.log(pageElement);
                               // var elementClass = pageElement.get('v.class');
                               // console.log(elementClass);
                                 //elementClass = elementClass.replace("slds-hide","");
                               // pageElement.set('v.class',elementClass);
                               $A.util.removeClass(pageElement, 'slds-hide');
                },
                invisible: function(component,Element){
                                 var pageElement = component.find(Element);
                                 console.log(pageElement);
                                 // var elementClass = pageElement.get('v.class');
                                 //console.log(elementClass);
                                // elementClass = elementClass+' slds-hide';
                                 //pageElement.set('v.class',elementClass);
                                 $A.util.addClass(pageElement, 'slds-hide');
                }
})