global class FetchBusinessRuleErrorList {
    @InvocableMethod
    global static List<String> getErrorList(List<errorList> requests){
        List<List<errorList>> test = new List<List<errorList>>();
        system.debug('requests-->'+requests);
        test.add(requests);
        system.debug('test-->'+test);
        return null;
    }
    
    global class errorList {
        
        @InvocableVariable(required=true)
        public List<String> errorList;
    }
}