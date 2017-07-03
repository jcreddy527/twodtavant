/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
global abstract class StickyParametersController {

    global String[] stickyParams = null;
    global Map<String,String> savedParams = new Map<String,String>();
    
    global StickyParametersController(String[] stickyParams){
        this.stickyParams = stickyParams;
        if(this.stickyParams == null){
            this.stickyParams = new String[]{};
        }
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if(!this.stickyParams.isEmpty() && params != null){
            for(String stickyParam : stickyParams){
                savedParams.put(stickyParam,params.get(stickyParam));
            }
        }
    }

    global PageReference standardRedirect(PageReference newPage){
        return standardRedirect(newPage,null);
    }    
    
    global PageReference standardRedirect(PageReference newPage, Map<String,String> params){
        if(newPage == null){
            return null;
        }
        if(params == null || params.isEmpty()){
            params = savedParams;
        } else {
            Map<String,String> params2 = savedParams.clone();
            for(String key : params.keySet()){
                params2.put(key,params.get(key));
            }
            params = params2;
        }
        
        if(params == null || params.isEmpty()){
            return PageUtils.redirect(newPage.getUrl());
        }
        Map<String,String> urlEncodedParams = new Map<String,String>();
        String value = null;
        for(String key : params.keySet()){
            value = params.get(key);
            if(StringUtils.isBlank(key) || StringUtils.isBlank(value)){
                continue;
            }
            urlEncodedParams.put(key,EncodingUtil.urlEncode(value, 'UTF-8'));
        }
        if(urlEncodedParams.isEmpty()){
            return PageUtils.redirect(newPage.getUrl());
        }
        return PageUtils.redirect(newPage.getUrl() + '?' + MapUtils.joinMap(urlEncodedParams,'=','&'));
    }
    

}