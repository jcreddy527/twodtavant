@isTest(SeeAllData=false)
private class SchedulerRuleEngineTest{
    private static testMethod void TestRunEligibityRules(){
    
      
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList;
        
        WOD__c wc=new WOD__c();
        wc.name='Enable WarrantyRuleCriteriaTrigger';
        wc.Trigger_Value__c='true';
        wc.isTriggered__c=true;
        insert wc;
        
        Account tempAccountRecords = new Account();
        tempAccountRecords.Name='Test01';
        tempAccountRecords.Warranty_Account_Type__c='Dealer';
        insert tempAccountRecords;
              
        Warranty_Product__c TestWarrantyProduct = new Warranty_Product__c ();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        insert TestWarrantyProduct;
                     
        Inventory__c inv = new Inventory__c();
        inv.Account__c= tempAccountRecords.Id;
        inv.Item__c = TestWarrantyProduct.id;
        inv.Install_Date__c= system.today();
        inv.Serial_Number__c='test123';
        insert inv;
                  
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='OR';
        wr.Object_API_Name__c ='inventory__c';
        //wr.Enabled__c=true;
        insert wr;
        
        Warranty_Rule_Criteria__c wrc=new Warranty_Rule_Criteria__c();
        wrc.Criteria_Type__c='Equals';
        wrc.Field_Name__c='Warranty Product';
        wrc.Field_API_Name__c='Item__c';
        wrc.Criteria_Value__c=TestWarrantyProduct.id;
        wrc.Warranty_Rule__c=wr.id;
        wrc.Sequence__c=1;
        wrc.Field_Type__c='REFERENCE';
        wrc.Related_Object__c='Warranty_Product__c';
        insert wrc; 
        
        //wr.Enabled__c=true;
        //update wr;
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 34;
        insert m;
               
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
        //TestCreateMaster(wr.id);
               
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();

      }
      
       private static testMethod void TestRunEligibityRules2(){
       // Inventory__c inv = TestCustomsett(); 
       
        list<Country__c> TestCountryList = new list<Country__c>();
        TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
        TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
        TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
        insert TestCountryList; 
    
        WOD__c wc=new WOD__c();
        wc.name='Enable WarrantyRuleCriteriaTrigger';
        //wc.Trigger_Value__c='true';
        //wc.isTriggered__c=true;
        insert wc;
        
        
        Account tempAccountRecords = new Account();
        tempAccountRecords.Name='Test01';
        tempAccountRecords.Warranty_Account_Type__c='Dealer';
        insert tempAccountRecords;
        
        Warranty_Product__c TestWarrantyProduct = new Warranty_Product__c ();
        TestWarrantyProduct.Item_Type__c = 'Machine';
        TestWarrantyProduct.Type__c = 'Item';
        TestWarrantyProduct.Track_Type__c = 'Serialized';
        insert TestWarrantyProduct;
              
        Inventory__c inv = new Inventory__c();
        inv.Account__c= tempAccountRecords.Id;
        inv.Item__c = TestWarrantyProduct.id;
        inv.Install_Date__c= system.today();
        inv.Serial_Number__c='test123';
        inv.Units_Run__c=25;
        insert inv;
                               
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='AND';
        wr.Object_API_Name__c ='inventory__c';
        //wr.Enabled__c=true;
        insert wr;
        
        Warranty_Rule_Criteria__c wrc=new Warranty_Rule_Criteria__c();
        wrc.Criteria_Type__c='Not Equal To  ';
        wrc.Field_Name__c='Units Usage';
        wrc.Field_API_Name__c='Units_Run__c';
        wrc.Criteria_Value__c='25';
        wrc.Warranty_Rule__c=wr.id;
        wrc.Sequence__c=1;
        wrc.Field_Type__c='DOUBLE';
        insert wrc; 
        
        Warranty_Rule_Criteria__c wrc1=new Warranty_Rule_Criteria__c();
        wrc1.Criteria_Type__c='Equals';
        wrc1.Field_Name__c='Units Usage';
        wrc1.Field_API_Name__c='Units_Run__c';
        wrc1.Criteria_Value__c='20';
        wrc1.Warranty_Rule__c=wr.id;
        wrc1.Sequence__c=2;
        wrc1.Field_Type__c='DOUBLE';
        insert wrc1;
        
         
        Warranty_Rule_Criteria__c wrc2=new Warranty_Rule_Criteria__c();
        wrc2.Criteria_Type__c='Greater Than';
        wrc2.Field_Name__c='Units Usage';
        wrc2.Field_API_Name__c='Units_Run__c';
        wrc2.Criteria_Value__c='24';
        wrc2.Warranty_Rule__c=wr.id;
        wrc2.Sequence__c=3;
        wrc2.Field_Type__c='DOUBLE';
        insert wrc2;
        
        Warranty_Rule_Criteria__c wrc3=new Warranty_Rule_Criteria__c();
        wrc3.Criteria_Type__c='Greater Or Equal';
        wrc3.Field_Name__c='Units Usage';
        wrc3.Field_API_Name__c='Units_Run__c';
        wrc3.Criteria_Value__c='24';
        wrc3.Warranty_Rule__c=wr.id;
        wrc3.Sequence__c=4;
        wrc3.Field_Type__c='DOUBLE';
        insert wrc3;
        
        Warranty_Rule_Criteria__c wrc6=new Warranty_Rule_Criteria__c();
        wrc6.Criteria_Type__c='Less Than';
        wrc6.Field_Name__c='Units Usage';
        wrc6.Field_API_Name__c='Units_Run__c';
        wrc6.Criteria_Value__c='26';
        wrc6.Warranty_Rule__c=wr.id;
        wrc6.Sequence__c=7;
        wrc6.Field_Type__c='DOUBLE';
        insert wrc6;
        
        Warranty_Rule_Criteria__c wrc7=new Warranty_Rule_Criteria__c();
        wrc7.Criteria_Type__c='Less Or Equal';
        wrc7.Field_Name__c='Units Usage';
        wrc7.Field_API_Name__c='Units_Run__c';
        wrc7.Criteria_Value__c='26';
        wrc7.Warranty_Rule__c=wr.id;
        wrc7.Sequence__c=8;
        wrc7.Field_Type__c='DOUBLE';
        insert wrc7;
        
        Warranty_Rule_Criteria__c wrc8=new Warranty_Rule_Criteria__c();
        wrc8.Criteria_Type__c='Between';
        wrc8.Field_Name__c='Units Usage';
        wrc8.Field_API_Name__c='Units_Run__c';
        wrc8.Minimum_Value__c='20';
        wrc8.Maximum_Value__c='26';
        wrc8.Warranty_Rule__c=wr.id;
        wrc8.Sequence__c=9;
        wrc8.Field_Type__c='DOUBLE';
        insert wrc8;
        
        
        wr.Enabled__c=true;
        update wr;
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 19;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
        //TestCreateMaster(wr.id);
               
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
       }
       
        private static testMethod void TestRunEligibityRules3(){
        Inventory__c inv = TestCustomsett(); 
             
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='AND';
        wr.Object_API_Name__c ='inventory__c';
        insert wr;
        
        Warranty_Rule_Criteria__c wrc8=new Warranty_Rule_Criteria__c();
        wrc8.Criteria_Type__c='Between';
        wrc8.Field_Name__c='Created Date';
        wrc8.Field_API_Name__c='CreatedDate';
        wrc8.Minimum_Value__c=String.valueOf(system.today() - 1);
        wrc8.Maximum_Value__c=String.valueOf(system.today() + 1);
        wrc8.Warranty_Rule__c=wr.id;
        wrc8.Sequence__c=9;
        wrc8.Field_Type__c='DATETIME';
        insert wrc8;
        
        wr.Enabled__c=true;
        update wr;
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 6;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
        //TestCreateMaster(wr.id);
               
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
       }

       private static testMethod void TestRunEligibityRules4(){
        Inventory__c inv = TestCustomsett(); 
             
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='OR';
        wr.Object_API_Name__c ='inventory__c';
        insert wr;
        
        Warranty_Rule_Criteria__c wrc8=new Warranty_Rule_Criteria__c();
        wrc8.Criteria_Type__c='Between';
        wrc8.Field_Name__c='Created Date';
        wrc8.Field_API_Name__c='Install_Date__c';
        wrc8.Minimum_Value__c=String.valueOf(system.today() - 1);
        wrc8.Maximum_Value__c=String.valueOf(system.today() + 1);
        wrc8.Warranty_Rule__c=wr.id;
        wrc8.Sequence__c=9;
        wrc8.Field_Type__c='DATE';
        insert wrc8;
        
        Warranty_Rule_Criteria__c wrc1=new Warranty_Rule_Criteria__c();
        wrc1.Criteria_Type__c='Equals';
        wrc1.Field_Name__c='Created Date';
        wrc1.Field_API_Name__c='Install_Date__c';
        wrc1.Criteria_Value__c=String.valueOf(system.today());
        wrc1.Warranty_Rule__c=wr.id;
        wrc1.Sequence__c=2;
        wrc1.Field_Type__c='DATE';
        insert wrc1;
        
        wr.Enabled__c=true;
        update wr;
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 15;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
        //TestCreateMaster(wr.id);
               
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
       }
         private static testMethod void TestRunEligibityRules5(){
         Inventory__c inv = TestCustomsett(); 
             
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='OR';
        wr.Object_API_Name__c ='inventory__c';
        insert wr;
        
        Warranty_Rule_Criteria__c wrc7=new Warranty_Rule_Criteria__c();
        wrc7.Criteria_Type__c='Less Or Equal';
        wrc7.Field_Name__c='Created Date';
        wrc7.Field_API_Name__c='CreatedDate';
        wrc7.Criteria_Value__c=String.valueOf(system.today());
        wrc7.Warranty_Rule__c=wr.id;
        wrc7.Sequence__c=8;
        wrc7.Field_Type__c='DATETIME';
        insert wrc7;
        
        Warranty_Rule_Criteria__c wrc6=new Warranty_Rule_Criteria__c();
        wrc6.Criteria_Type__c='Less Than';
        wrc6.Field_Name__c='Created Date';
        wrc6.Field_API_Name__c='Install_Date__c';
        wrc6.Criteria_Value__c=String.valueOf(system.today() + 10);
        wrc6.Warranty_Rule__c=wr.id;
        wrc6.Sequence__c=7;
        wrc6.Field_Type__c='DATE';
        insert wrc6;
        
        /* wr.Enabled__c=true;
        update wr;*/
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 30;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
         //TestCreateMaster(wr.id);
               
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
       }
       
       private static testMethod void TestRunEligibityRules6(){
           
        Inventory__c inv = TestCustomsett();     
        
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='OR';
        wr.Object_API_Name__c ='inventory__c';
        insert wr;
        
        Warranty_Rule_Criteria__c wrc6=new Warranty_Rule_Criteria__c();
        wrc6.Criteria_Type__c='Less Than';
        wrc6.Field_Name__c='Created Date';
        wrc6.Field_API_Name__c='Install_Date__c';
        wrc6.Criteria_Value__c=String.valueOf(system.today() + 10);
        wrc6.Warranty_Rule__c=wr.id;
        wrc6.Sequence__c=7;
        wrc6.Field_Type__c='DATE';
        insert wrc6;
        
        /* wr.Enabled__c=true;
        update wr;
        */
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        m.Priority__c = 18;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
       
       // TestCreateMaster(wr.id);      
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
       }
        private static testMethod void TestRunEligibityRules7(){
        
        Inventory__c inv = TestCustomsett();  
        
        Warranty_Rule__c wr=new Warranty_Rule__c();
        wr.name='test';
        wr.Object_Type__c='INVENTORY__C';
        wr.Logical_Grouping__c='OR';
        wr.Object_API_Name__c ='inventory__c';
        insert wr;
                
        Warranty_Rule_Criteria__c wrc3=new Warranty_Rule_Criteria__c();
        wrc3.Criteria_Type__c='Greater Or Equal';
        wrc3.Field_Name__c='Created Date';
        wrc3.Field_API_Name__c='Install_Date__c';
        wrc3.Criteria_Value__c= String.valueOf(system.today());
        wrc3.Warranty_Rule__c=wr.id;
        wrc3.Sequence__c=4;
        wrc3.Field_Type__c='DATE';
        insert wrc3;
        /*
        wr.Enabled__c=true;
        update wr;*/
        
        Master__c m=new Master__c();
        m.name='Master Scheduler 1';
        m.Warranty_Rule__c=wr.ID;
        m.Active_From__c = system.today() - 1;  
        m.Active_Until__c = system.today() + 1; 
        m.Active__c = true;
        
        m.Priority__c = 10;
        insert m;
                
        Scheduler_Timeline__c st =new Scheduler_Timeline__c();
        st.name='test';
        st.Description__c='test';
        st.Master_Scheduler__c=m.id;
        st.Time_Unit__c='Months';
        st.Scheduler_Time__c=3;
        insert st; 
        
        //TestCreateMaster(wr.id);      
        List<Inventory__c>  invLst = new List<Inventory__c>();
        invLst.add(inv);
        
        test.startTest();
        SchedulerTimeLineCreationForInventory.createUpcoming_Completed(invLst);
        test.stopTest();
        
       }
       /*private static void TestCreateMaster(id wrID){
               Master__c m=new Master__c();
                m.name='Master Scheduler 1';
                m.Warranty_Rule__c=wrID;
                m.Active_From__c = system.today() - 1;  
                m.Active_Until__c = system.today() + 1; 
                m.Active__c = true;
                m.Priority__c = 1;
                insert m;
                        
                Scheduler_Timeline__c st =new Scheduler_Timeline__c();
                st.name='test';
                st.Description__c='test';
                st.Master_Scheduler__c=m.id;
                st.Time_Unit__c='Months';
                st.Scheduler_Time__c=3;
                insert st; 
       }*/
         private static Inventory__c TestCustomsett(){
            list<Country__c> TestCountryList = new list<Country__c>();
            TestCountryList.add(new Country__c(Name = 'India',Currency_Code__c = 'INR'));
            TestCountryList.add(new Country__c(Name = 'USA',Currency_Code__c = 'Dollar'));
            TestCountryList.add(new Country__c(Name = 'Japan',Currency_Code__c = 'Yen'));
            insert TestCountryList; 
        
            WOD__c wc=new WOD__c();
            wc.name='Enable WarrantyRuleCriteriaTrigger';
            wc.Trigger_Value__c='true';
            wc.isTriggered__c=true;
            insert wc;
            
            
            Account tempAccountRecords = new Account();
            tempAccountRecords.Name='Test01';
            tempAccountRecords.Warranty_Account_Type__c='Dealer';
            insert tempAccountRecords;
            
            Warranty_Product__c TestWarrantyProduct = new Warranty_Product__c ();
            TestWarrantyProduct.Item_Type__c = 'Machine';
            TestWarrantyProduct.Type__c = 'Item';
            TestWarrantyProduct.Track_Type__c = 'Serialized';
            insert TestWarrantyProduct;
                  
            Inventory__c inv = new Inventory__c();
            inv.Account__c= tempAccountRecords.Id;
            inv.Item__c = TestWarrantyProduct.id;
            inv.Install_Date__c= system.today();
            inv.Serial_Number__c='test123';
            inv.Units_Run__c=25;
            insert inv;
            return inv;
         }
       
 }