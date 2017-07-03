/**********************************************************************
Name:  claimResponseController
Copyright ? 2016  Tavant Technology Inc
=====================================================================
=====================================================================
Purpose: This class is used to parse the generated response                                                                                                               
=====================================================================
=====================================================================
History                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
   1.0 -    Aditya         5/12/2016      INITIAL DEVELOPMENT            
***********************************************************************/


public class claimResponseController {

    public List<reponsewraper> reponseList;
    public String JsonResponse ='';
    //This method is used to parse the reponse. 
    public String reponseGenerator(List<schemasQadComXmlServices.TtPriceInquiryResType> resp,List<schemasQadComXmlServices.TtPriceInquiryReqType> request,String claimId) {
     try{
      reponseList = new List<reponsewraper>();
     
      List<Error_Parts__c> errorPartsList = new List<Error_Parts__c>();
      if(resp.size()>0) {    
        for(schemasQadComXmlServices.TtPriceInquiryResType result : resp) {
            reponsewraper  rw = new reponsewraper ();
            System.debug(result+'&&^^%%$$##@@');
            rw.ttPriceval = result.ttPrice;
            rw.ttPartVal = result.ttPart;
            rw.ttResultVal = result.ttResult;
            rw.ttMessageVal = result.ttMessage;
            reponseList.add(rw);
           
            if(result.ttResult!= 'SUCCESS') {
               
                Error_Parts__c tep = new Error_Parts__c();
                tep.Name ='Exception Record';
                tep.Date__c = System.now();
                tep.request__c =  JSON.serialize(request);
                tep.response__c = JSON.serialize(resp);
                tep.Claim_Number__c = claimId;
                errorPartsList.add(tep);
            }            
            
        }
        
        if(errorPartsList.size()>0) {
        
            insert errorPartsList;
        }
         
     }  JsonResponse = JSON.serialize(reponseList);
        return JsonResponse; 
  } catch(Exception e) {
         System.debug(e.getMessage()+'********');
         return e.getMessage();     
    }   
   }
      
   //response wrapper 
      
   public class reponsewraper {
       public Decimal ttPriceVal;
       public String  ttPartVal;
       public String  ttResultVal;
       public String  ttMessageVal;    
   }
   
  
    
}