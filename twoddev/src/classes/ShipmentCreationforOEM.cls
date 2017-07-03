/**********************************************************************
Name: ShipmentCreation
Copyright @ 2016  Tavant Technology Inc
==============================================================
===============================================================
Purpose:    To create shipment records                                                  -------
===============================================================
===============================================================
History
-------
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    AKR              25/11/2016         INITIAL DEVELOPMENT
***********************************************************************/
global class ShipmentCreationforOEM{

    //fetch all remove parts which not yet completly shipped.
    @AuraEnabled
    global static string getpartsTobeReturn(String claimId,Boolean isInitialLoad){
        List<ClaimWrapper> cws= new list<ClaimWrapper>();
        Map<String, List<RemovePartWrapper>> claimRemoveMap= new Map<String, List<RemovePartWrapper>>();
        String returnalbeJSON;
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [select Id,IsPortalEnabled from User where Id=:currentUserId];
        String queryForRemovedParts = '';
        List<Removed_Claim_Part__c> removedPartList = null;

        if(currentUser.IsPortalEnabled==true){

          queryForRemovedParts = 'select Id,Remaining_Quantity__c,'+
          'Inventory__r.Item__r.Name,Inventory__r.Name,Warranty_Product__r.name, '+
          'Quantity__c,Return_Location__r.Id,Return_Location__r.Name, Claim__c, Claim__r.Name from '+
          'Removed_Claim_Part__c where  Return_Location__c!=null and Claim__c!=null '+
          'and Remaining_Quantity__c!=0 and (Claim__r.twod_Is_Primary_Dealer__c=true OR '+
          'Claim__r.twod_Is_Primary_Distributor__c=true) ';

        }else{

          queryForRemovedParts = 'select Id,Remaining_Quantity__c,'+
          'Inventory__r.Item__r.Name,Inventory__r.Name,Warranty_Product__r.name, '+
          'Quantity__c,Return_Location__r.Id,Return_Location__r.Name, Claim__c, Claim__r.Name from '+
          'Removed_Claim_Part__c where  Return_Location__c!=null and Claim__c!=null '+
          'and Remaining_Quantity__c!=0 ';

        }


        if(claimId==null){

          removedPartList = Database.query(queryForRemovedParts);

          for( Removed_Claim_Part__c remClaimParts : removedPartList ){

              if(claimRemoveMap.ContainsKey(remClaimParts.Claim__r.Name)){

                  RemovePartWrapper rpw = new RemovePartWrapper();
                  rpw.isSelected = false;
                  rpw.shippedQty = Integer.valueOf(remClaimParts.Remaining_Quantity__c);
                  rpw.removePartWr = remClaimParts;
                  claimRemoveMap.get(remClaimParts.Claim__r.Name).add(rpw);
                  claimRemoveMap.put(remClaimParts.Claim__r.Name,claimRemoveMap.get(remClaimParts.Claim__r.Name));

              }else{

                  RemovePartWrapper rpw = new RemovePartWrapper();
                  rpw.isSelected = false;
                  rpw.shippedQty = Integer.valueOf(remClaimParts.Remaining_Quantity__c);
                  rpw.removePartWr = remClaimParts;
                  list<RemovePartWrapper> newRemovePartWrap = new list<RemovePartWrapper>();
                  newRemovePartWrap.add(rpw);
                  claimRemoveMap.put(remClaimParts.Claim__r.Name,newRemovePartWrap);

              }
          }

        }else{

            queryForRemovedParts +=' and Claim__c= :claimId';
            removedPartList = Database.query(queryForRemovedParts);
            
            for( Removed_Claim_Part__c remClaimParts : removedPartList ){
                
                if(claimRemoveMap.ContainsKey(remClaimParts.Claim__r.Name)){
                    
                    RemovePartWrapper rpw = new RemovePartWrapper();
                    rpw.isSelected = false;
                    rpw.shippedQty = Integer.valueOf(remClaimParts.Remaining_Quantity__c);
                    rpw.removePartWr = remClaimParts;
                    claimRemoveMap.get(remClaimParts.Claim__r.Name).add(rpw);
                    claimRemoveMap.put(remClaimParts.Claim__r.Name,claimRemoveMap.get(remClaimParts.Claim__r.Name));
                    
                }else{
                    
                    RemovePartWrapper rpw = new RemovePartWrapper();
                    rpw.isSelected = false;
                    rpw.shippedQty = Integer.valueOf(remClaimParts.Remaining_Quantity__c);
                    rpw.removePartWr = remClaimParts;
                    list<RemovePartWrapper> newRemovePartWrap = new list<RemovePartWrapper>();
                    newRemovePartWrap.add(rpw);
                    claimRemoveMap.put(remClaimParts.Claim__r.Name,newRemovePartWrap);
                    
                }
          }


        }


        //iterate over map to fill the final ClaimWrapper
        Integer count = 0;
        Integer maxCount = 3;
        for(String s:claimRemoveMap.keyset()){
            if(count==maxCount){
              break;
            }else{
              ClaimWrapper cw = new ClaimWrapper();
              cw.claimNumber = s;
              cw.isSelected = false;
              cw.removePartListWrap = claimRemoveMap.get(s);
              cws.add(cw);
              count++;
            }
        }

        MainWrapper mainWrapper = new MainWrapper();
        mainWrapper.claimWrapperList = cws;
        if(isInitialLoad){
            mainWrapper.validClaimListForSearch = new List<String>(claimRemoveMap.keyset());
        }else{
            mainWrapper.validClaimListForSearch = null;
        }
        
        returnalbeJSON = JSON.serialize(mainWrapper);
        
        return returnalbeJSON;

    }
    global class RemovePartWrapper{
        @AuraEnabled
        global boolean isSelected{get;set;}
        @AuraEnabled
        global Removed_Claim_Part__c removePartWr{get;set;}
        @AuraEnabled
        global integer shippedQty{get;set;}

    }

    global class ClaimWrapper{

        @AuraEnabled
        global list<RemovePartWrapper> removePartListWrap{get;set;}
        @AuraEnabled
        global string claimNumber{get;set;}
        @AuraEnabled
        global boolean isSelected{get;set;}

    }
    
    global class MainWrapper{
        
        @AuraEnabled
        global list<ClaimWrapper> claimWrapperList{get;set;}
        
        @AuraEnabled
        global list<String> validClaimListForSearch{get;set;}
        
    }
    
}