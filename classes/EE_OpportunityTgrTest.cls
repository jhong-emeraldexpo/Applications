@isTest
private class EE_OpportunityTgrTest{
    /*static testmethod void EE_OpportunityTgrTest() {
    
    
      Test.startTest();
      date myDate = date.today();
      Date newDate = mydate.addDays(2);

      Map<Id, Id> optyAccountShow = new Map<Id, Id>();
      Map<String, String> TRIDAccountName = new Map<String, String>();
      List<Opportunity> oppWithRelFields; 
      List<AccountOwners__c> AccountOwner;
      List<Territory_Rule__c> TerritoryRules = new List<Territory_Rule__c>();
      Map<Id, String> accOwnUpd = new Map<Id, String>();
      Map<Id, Id> oppUpdateMap = new Map<Id, Id>();  
      Set<Id> oppIds = new Set<Id>();
      List<Opportunity> oppsUpd = new List<Opportunity>();
        
      //Account
      Account account = new Account();
      account.Name='Test Account';
      insert account;

      //Account
      Account account2 = new Account();
      account2.Name='Account2';
      insert account2;
//------------------------      
      //Create Show 
      Show__c show = new Show__c();
      show.Name='Test Show';
      show.Brand__c='TBrand';
      show.Market__c='TMarket';
      show.Rule_Set__c='ASD_SB';
      show.Segment__c='TSegment';
      show.Show_Code__c='TShowCode';      
      show.Show_Group__c='ShowGroup';
      show.ShowID__c=12345;
       
      insert show;
       
      //Create Event
      Event__c event = new Event__c();
      event.Name='Test Event';
      event.Show__c=show.id;
      event.Event_Year__c='2016';
      event.Event_Code__c='2016-TestEvent';
      event.Stage_Date__c=myDate;
      event.Opportunity_Start_Date__c=myDate;
      event.Booth_Last_Date__c=newDate;
      event.Non_Booth_Last_Date__c=newDate;
       
      insert event;
      
      //Create Sub Show
      SubShow__c subshow = new SubShow__c();
      subshow.Name = ' Test subshow';
      subshow.Show__c=show.id; 
       
      insert subshow;
       
       
      // Create Sub Expo
      SubExpo__c subexpo = new SubExpo__c();
      subexpo.Name = 'Test SubExpo';
      subexpo.SubShow__c=subShow.id;
      subexpo.Event__c=event.id;
      insert subexpo;
      
      
       
      // Create Account Owner
      AccountOwners__c accOwner1 = new AccountOwners__c();
      accOwner1.Account__c=account.id;
      accOwner1.AccountOwner__c=UserInfo.getUserId();
      accOwner1.Show__c=show.id;
      accOwner1.SubShow__c=subshow.id;
      insert accOwner1;
            
      AccountOwners__c accOwner2 = new AccountOwners__c();
      accOwner2.Account__c=account.id;
      accOwner2.AccountOwner__c=UserInfo.getUserId();
      accOwner2.Show__c=show.id;
      accOwner2.SubShow__c=subshow.id;
      insert accOwner2;
            
      List<AccountOwners__c> accOwners = new List<AccountOwners__c>();
      accOwners.add(accOwner1);
      //  accOwners.add(accOwner2);
      Territory_Rule__c tr1 = new Territory_Rule__c();
      tr1.Key1__c='B,E,G,I,M,O,P,Y,Z';
      tr1.Key2__c='';
      tr1.OpportunityOwner__c=UserInfo.getUserId();
      tr1.Rule_Set__c='ASD_SB';
      tr1.Territory_Rule_ID__c='ASD';
      tr1.Territory_Rule_Type__c='Account Name';
      insert tr1;
      
      TerritoryRules.add(tr1);
        
      
      // Create two contacts
      Contact ct1 = new Contact();
      Contact ct2 = new Contact();
      ct1.FirstName = 'Larrys';
      ct1.LastName = 'Page';
      ct1.Email = 'lp@ee.cpm';
      ct2.FirstName = 'Marc';
      ct2.LastName = 'Buymeoff';
      ct2.Email = 'mb@ee.cpm';
      Insert ct1;    
      Insert ct2;
      system.debug('Completed Contact Creation'); 
           
      //Create Campaign
      Campaign camp = new Campaign();
      camp.Name = 'Camp1';
      camp.Short_Description__c='Short Description';
      camp.Event__c=event.id;
      //camp.segment_type__c = 'Lost';
      Database.SaveResult campsr = Database.insert(Camp, true);
      System.assert(campsr.isSuccess());
      system.debug('Inserted new Campaign');
           
           
     
      // Create Opportunity
      Opportunity op1 = new Opportunity();
      op1.name = 'Opportunity Contact Insertion Test';
      op1.AccountId=account.id;
      op1.CloseDate =  Date.today()+2;
      op1.StageName = 'Prospecting';
      op1.contact__c= ct1.Id ;
      op1.Amount=1.00;
      op1.Event__c=event.id;
      op1.subexpo__c=subexpo.id;
      op1.Create_Task__c = True;
      op1.OwnerID = UserInfo.getUserId();
          
          
         
      Campaign camp1 = new Campaign();
      camp1 = [Select ID, Name from Campaign limit 1];
      if(camp1!=null) 
      op1.CampaignId = camp1.ID;
      // insert op1;
      Database.SaveResult sr1 = Database.insert(op1, true);
      System.assert(sr1.isSuccess());
      system.debug('Inserted new op1 opportunity');
          
      // Create Opportunity
      Opportunity op2 = new Opportunity();
      op2.name = 'Opportunity Contact Insertion Test';
      op2.AccountId=account.id;
      op2.CloseDate =  Date.today()+2;
      op2.StageName = 'Prospecting';
      op2.contact__c= ct1.Id ;
      op2.Amount=1.00;
      op2.Event__c=event.id;
      op2.subexpo__c=subexpo.id;
      op2.Create_Task__c = True;
      op2.OwnerID = UserInfo.getUserId();
          
      if(camp1!=null) 
      op2.CampaignId = camp1.ID;         
      Database.SaveResult sr2 = Database.insert(op2, true);
      System.assert(sr2.isSuccess());
      system.debug('Inserted new op2 opportunity');
          
      List<Opportunity> oppList = new List<Opportunity>();
          
      oppList.add(op1);
      oppList.add(op2);
          

      // Create Task
      Task t = new Task();
      if(op1.Create_Task__c == True){
      t.WhatId = Op1.Id;
      t.OwnerId = Op1.OwnerId;
      t.Subject = Op1.Name;
      t.Priority = 'Normal';
      t.Status = 'Not Started';
      t.ActivityDate = System.today () + 1;
      t.Activity_Type__c = 'Call';
      insert t;  
      }
     
       
          
      for(Opportunity opp :oppList ){
        optyAccountShow.put(opp.AccountID, opp.ShowObjectId__c); 
        TRIDAccountName.put(opp.Rule_Set__c, opp.AccountNameFirstChar__c);
        oppIds.add(opp.Id);
      }
        
      AccountOwner = new List<AccountOwners__c>([Select AccountOwner__c,Show__c, Account__c,SubShow__c,SubExpo__c,Pavilion__c from AccountOwners__c where Account__c   IN  :optyAccountShow.keyset()]);
        
        
        
      oppWithRelFields = new List<Opportunity>([Select AccountID, AccountNameFirstChar__c, OwnerId,Show__c,SubExpo__r.SubShowName__c, BillingCountryandStateCode__c, Billing_Country_Code__c,Billing_State_Code__c,Rule_Set__c, SubExpo__r.Target_Booth_Revenue__c,SubExpo__r.Name,SubExpo__r.SubShow__r.Name,SubExpo__r.Stage_Date__c,ShowObjectid__c,SubExpoObjectID__c,Pavilion__c
        from Opportunity where Id in :oppIds and Rule_Set__c !='Disabled']); 
        
      System.assertNotEquals(0,oppWithRelFields.size());
      //System.assertEquals(null,oppWithRelFields);
        
      TerritoryRules = new List<Territory_Rule__c>([Select Name__c,Key1__c,Key2__c, OpportunityOwner__c,Rule_Set__c,Territory_Rule_Type__c from Territory_Rule__c ]);
        
      for(Opportunity opp : oppWithRelFields ){      
        System.assertNotEquals('Disabled',Opp.Rule_Set__c);
        for(AccountOwners__c ao: AccountOwner){  
          System.assertNotEquals(0,AccountOwner.size());
          System.assertEquals(ao.Account__c,opp.AccountId);
          System.assertEquals(ao.Show__c,opp.ShowObjectid__c);
          System.assertEquals(ao.SubShow__c,opp.SubExpo__r.SubShow__c);
                    
          oppUpdateMap.put(opp.id,ao.AccountOwner__c);
                    /*  
                       if((ao.Account__c==opp.AccountId && ao.Show__c ==opp.ShowObjectid__c && ao.SubShow__c==opp.SubExpo__r.SubShow__c && ao.Pavilion__c==opp.Pavilion__c )|| (ao.Account__c==opp.AccountId && ao.Show__c ==opp.ShowObjectid__c && ao.SubShow__c==opp.SubExpo__r.SubShow__c ))
                        {
                             oppUpdateMap.put(opp.id,ao.AccountOwner__c);
                            
                        }
                        */
        /*}
      }
      System.assertNotEquals(0,oppUpdateMap.size());
      for(Opportunity oppUpd : oppList ){
        System.assertNotEquals(null,oppUpdateMap.get(oppUpd.id));
        oppUpd.OwnerId=oppUpdateMap.get(oppUpd.id);
        oppUpd.Named_Account_Executive__c=true;
        oppsUpd.add(oppUpd);
        accOwnUpd.put(oppUpd.id,'ACCOWNERUPD');
      }
        
      System.assertNotEquals(0,oppsUpd.size());       
      update oppsUpd;
            
      // Update Opportunity 
      op1.Contact__c = ct2.Id;  
          
      //update op1;
      Database.SaveResult sropUpd = Database.update(op1, true);
      System.assert(sropUpd.isSuccess());
      system.debug('Opportunity updated');
          
      //Create Contac Role and create Show Account Contact
      List<Show_Account_Contact__c> AccConRoleList = new List<Show_Account_Contact__c >();
      OpportunityContactRole conrol = new OpportunityContactRole (ContactId=ct1.id,OpportunityId=op1.id);  
      insert conrol;
      OpportunityContactRole ocr =  [SELECT ContactId, contact.Accountid, OpportunityId  
                                               FROM OpportunityContactRole where OpportunityId = :op1.ID ] ;   
      AccConRoleList.add(new Show_Account_Contact__c(
                        Contact__c        = ocr.ContactId,
                        Account__c        = ocr.contact.Accountid,
                        Opportunity__c    = ocr.OpportunityId ,
                        ContactRoles__c   = 'Sales'
                        ));           
              
          
      Test.stopTest();
      System.assert(sr2.isSuccess());
    }    
    
    
    static testmethod void TestTerritoryRules() {
        
      date myDate = date.today();
      Date newDate = mydate.addDays(2);

      Map<Id, Id> optyAccountShow = new Map<Id, Id>();
      Map<String, String> TRIDAccountName = new Map<String, String>();
      List<Opportunity> oppWithRelFields; 
      List<AccountOwners__c> AccountOwner;
      List<Territory_Rule__c> TerritoryRules = new List<Territory_Rule__c>();
      Map<Id, String> accOwnUpd = new Map<Id, String>();
      Map<Id, Id> oppUpdateMap = new Map<Id, Id>();  
      Set<Id> oppIds = new Set<Id>();
      List<Opportunity> oppsUpd = new List<Opportunity>();
        
      //Account
      Account account = new Account();
      account.Name='BAccount';
      account.BillingStateCode='LA';
      account.BillingCountryCode='US';
      insert account;
        
      Account account2 = new Account();
      account2.Name='CAccount';
      account2.BillingStateCode='LA';
      account2.BillingCountryCode='US';
      insert account2;

//------------------------      
      //Create Show 
      Show__c show = new Show__c();
      show.Name='Test Show';
      show.Brand__c='TBrand';
      show.Market__c='TMarket';
      show.Rule_Set__c='ASD_SB';
      show.Segment__c='TSegment';
      show.Show_Code__c='TShowCode';      
      show.Show_Group__c='ShowGroup';
      show.ShowID__c=12345;
       
      insert show;
       
      //Create Event
      Event__c event = new Event__c();
      event.Name='Test Event';
      event.Show__c=show.id;
      event.Event_Year__c='2016';
      event.Event_Code__c='2016-TestEvent';
      event.Stage_Date__c=myDate;
      event.Opportunity_Start_Date__c=myDate;
      event.Booth_Last_Date__c=newDate;
      event.Non_Booth_Last_Date__c=newDate;
      insert event;
      
      //Create Sub Show
      SubShow__c subshow = new SubShow__c();
      subshow.Name = ' Test subshow';
      subshow.Show__c=show.id; 
      insert subshow;
       
       
      // Create Sub Expo
      SubExpo__c subexpo = new SubExpo__c();
      subexpo.Name = 'Test SubExpo';
      subexpo.SubShow__c=subShow.id;
      subexpo.Event__c=event.id;
      insert subexpo;
      
      
      // Create Account Owner
      AccountOwners__c accOwner1 = new AccountOwners__c();
      accOwner1.Account__c=account2.id;
      accOwner1.AccountOwner__c=UserInfo.getUserId();
      accOwner1.Show__c=show.id;
      accOwner1.SubShow__c=subshow.id;
      insert accOwner1;
      
      AccountOwners__c accOwner2 = new AccountOwners__c();
      accOwner2.Account__c=account2.id;
      accOwner2.AccountOwner__c=UserInfo.getUserId();
      accOwner2.Show__c=show.id;
      accOwner2.SubShow__c=subshow.id;
      insert accOwner2;
            
      List<AccountOwners__c> accOwners = new List<AccountOwners__c>();
           
      accOwners.add(accOwner1);
      accOwners.add(accOwner2);
            
      Territory_Rule__c tr1 = new Territory_Rule__c();
      tr1.Key1__c='B,E,G,I,M,O,P,Y,Z';
      tr1.Key2__c='';
      tr1.OpportunityOwner__c=UserInfo.getUserId();
      tr1.Rule_Set__c='ASD_SB';
      tr1.Territory_Rule_ID__c='ASD';
      tr1.Territory_Rule_Type__c='Account Name';
            
      insert tr1;
     
      TerritoryRules.add(tr1);
           
      // Create two contacts
      Contact ct1 = new Contact();
      Contact ct2 = new Contact();
      ct1.FirstName = 'Larrys';
      ct1.LastName = 'Page';
      ct1.Email = 'lp@ee.cpm';
      ct2.FirstName = 'Marc';
      ct2.LastName = 'Buymeoff';
      ct2.Email = 'lmbp@ee.cpm';
      Insert ct1;    
      Insert ct2;
      system.debug('Completed Contact Creation'); 
           
      //Create Campaign
      Campaign camp = new Campaign();
      camp.Name = 'Camp1';
      camp.Short_Description__c='Short Description';
      camp.Event__c=event.id;
      //camp.segment_type__c = 'Lost';
      Database.SaveResult campsr = Database.insert(Camp, true);
      System.assert(campsr.isSuccess());
      system.debug('Inserted new Campaign');
           
      Test.startTest(); 
     
      // Create Opportunity
      Opportunity op1 = new Opportunity();
      op1.name = 'Opportunity Contact Insertion Test';
      op1.AccountId=account.id;
      op1.CloseDate =  Date.today()+2;
      op1.StageName = 'Prospecting';
      op1.contact__c= ct1.Id ;
      op1.Amount=1.00;
      op1.Event__c=event.id;
      op1.subexpo__c=subexpo.id;
      op1.Create_Task__c = True;
      op1.OwnerID = UserInfo.getUserId();
          
          
         
      Campaign camp1 = new Campaign();
      camp1 = [Select ID, Name from Campaign limit 1];
      if(camp1!=null) 
      op1.CampaignId = camp1.ID;
      // insert op1;
      Database.SaveResult sr1 = Database.insert(op1, true);
      System.assert(sr1.isSuccess());
      system.debug('Inserted new op1 opportunity');
          
      // Create Opportunity
      Opportunity op2 = new Opportunity();
      op2.name = 'Opportunity Contact Insertion Test';
      op2.AccountId=account.id;
      op2.CloseDate =  Date.today()+2;
      op2.StageName = 'Prospecting';
      op2.contact__c= ct1.Id ;
      op2.Amount=1.00;
      op2.Event__c=event.id;
      op2.subexpo__c=subexpo.id;
      op2.Create_Task__c = True;
      op2.OwnerID = UserInfo.getUserId();
          
      if(camp1!=null) 
        op2.CampaignId = camp1.ID;         
        Database.SaveResult sr2 = Database.insert(op2, true);
        System.assert(sr2.isSuccess());
        system.debug('Inserted new op2 opportunity');
          
      List<Opportunity> oppList = new List<Opportunity>();
          
      oppList.add(op1);
      oppList.add(op2);
         
      for(Opportunity opp :oppList ){
        optyAccountShow.put(opp.AccountID, opp.ShowObjectId__c); 
        TRIDAccountName.put(opp.Rule_Set__c, opp.AccountNameFirstChar__c);
        oppIds.add(opp.Id);
      }
       
      AccountOwner = new List<AccountOwners__c>([Select AccountOwner__c,Show__c, Account__c,SubShow__c,SubExpo__c,Pavilion__c from AccountOwners__c where Account__c   IN  :optyAccountShow.keyset()]);
        
      oppWithRelFields = new List<Opportunity>([Select AccountID, AccountNameFirstChar__c, OwnerId,Show__c,SubExpo__r.SubShowName__c, BillingCountryandStateCode__c, Billing_Country_Code__c,Billing_State_Code__c,Rule_Set__c, SubExpo__r.Target_Booth_Revenue__c,SubExpo__r.Name,SubExpo__r.SubShow__r.Name,SubExpo__r.Stage_Date__c,ShowObjectid__c,SubExpoObjectID__c,Pavilion__c
        from Opportunity where Id in :oppIds and Rule_Set__c !='Disabled']); 
        
      System.assertNotEquals(0,oppWithRelFields.size());
      //System.assertEquals(null,oppWithRelFields);
      for(Opportunity opp :oppWithRelFields ){
        TRIDAccountName.put(opp.Rule_Set__c, opp.AccountNameFirstChar__c);
      }
      System.assertNotEquals(null,TRIDAccountName.keyset());
      TerritoryRules = new List<Territory_Rule__c>([Select Name__c,Key1__c,Key2__c, OpportunityOwner__c,Rule_Set__c,Territory_Rule_Type__c from Territory_Rule__c where Rule_Set__c   IN  :TRIDAccountName.keyset()]);
        
      System.assertNotEquals(0,TerritoryRules.size());
          
      for(Opportunity Opp1: oppWithRelFields){   
        System.assertNotEquals('Disabled',Opp1.Rule_Set__c);
        System.assertNotEquals('ACCOWNERUPD',accOwnUpd.get(Opp1.Id));
        for(Territory_Rule__c tr: TerritoryRules){
          System.assertNotEquals(0,TerritoryRules.size());
          System.assertNotEquals(null,tr.OpportunityOwner__c);
          System.assertEquals(Opp1.Rule_Set__c,tr.Rule_Set__c);
          System.assertEquals('Account Name',tr.Territory_Rule_Type__c);
          System.assertEquals('Account Name',tr.Territory_Rule_Type__c);
                    
          if(tr.Key1__c.contains(Opp1.AccountNameFirstChar__c))
            Opp1.OwnerId=tr.OpportunityOwner__c;  
            oppsUpd.add(Opp1);
        }  
      } 
      System.assertNotEquals(0,oppsUpd.size());       
      update oppsUpd;
      Test.stopTest();
    } 

static testmethod void TestBillStateTerritoryRule() {
        
  date myDate = date.today();
  Date newDate = mydate.addDays(2);

  Map<Id, Id> optyAccountShow = new Map<Id, Id>();
  Map<String, String> TRIDAccountName = new Map<String, String>();
  List<Opportunity> oppWithRelFields; 
  List<AccountOwners__c> AccountOwner;
  List<Territory_Rule__c> TerritoryRules = new List<Territory_Rule__c>();
  Map<Id, String> accOwnUpd = new Map<Id, String>();
  Map<Id, Id> oppUpdateMap = new Map<Id, Id>();  
  Set<Id> oppIds = new Set<Id>();
  List<Opportunity> oppsUpd = new List<Opportunity>();
        
  //Account
  Account account = new Account();
  account.Name='BAccount';        
  account.BillingStateCode='LA';
  account.BillingCountryCode='US';
  insert account;
        
  Account account2 = new Account();
  account2.Name='CAccount';
  account2.BillingStateCode='LA';
  account2.BillingCountryCode='US';
  insert account2;

//------------------------      
  //Create Show 
  Show__c show = new Show__c();
  show.Name='Test Show';
  show.Brand__c='TBrand';
  show.Market__c='TMarket';
  show.Rule_Set__c='GLM';
  show.Segment__c='TSegment';
  show.Show_Code__c='TShowCode';      
  show.Show_Group__c='ShowGroup';
  show.ShowID__c=12345;
       
  insert show;
       
  Show__c show1 = new Show__c();
  show1.Name='Test Show 1';
  show1.Brand__c='TBrand';
  show1.Market__c='TMarket';
  show1.Rule_Set__c='ASD_SB';
  show1.Segment__c='TSegment';
  show1.Show_Code__c='TShowCode';      
  show1.Show_Group__c='ShowGroup';
  show1.ShowID__c=54321;
       
  insert show1;
       
  Show__c show2 = new Show__c();
  show2.Name='Test Show 1';
  show2.Brand__c='TBrand';
  show2.Market__c='TMarket';
  show2.Rule_Set__c='ASD_SB1';
  show2.Segment__c='TSegment';
  show2.Show_Code__c='TShowCode';      
  show2.Show_Group__c='ShowGroup';
  show2.ShowID__c=54321;
       
  insert show2;
       
  //Create Event
  Event__c event = new Event__c();
  event.Name='Test Event';
  event.Show__c=show.id;
  event.Event_Year__c='2016';
  event.Event_Code__c='2016-TestEvent';
  event.Stage_Date__c=myDate;
  event.Opportunity_Start_Date__c=myDate;
  event.Booth_Last_Date__c=newDate;
  event.Non_Booth_Last_Date__c=newDate;
       
  insert event;
       
  Event__c event1 = new Event__c();
  event1.Name='Test Event1';
  event1.Show__c=show1.id;
  event1.Event_Year__c='2016';
  event1.Event_Code__c='2016-TestEvent';
  event1.Stage_Date__c=myDate;
  event1.Opportunity_Start_Date__c=myDate;
  event1.Booth_Last_Date__c=newDate;
  event1.Non_Booth_Last_Date__c=newDate;
       
  insert event1;
      
  Event__c event2 = new Event__c();
  event2.Name='Test Event1';
  event2.Show__c=show2.id;
  event2.Event_Year__c='2016';
  event2.Event_Code__c='2016-TestEvent';
  event2.Stage_Date__c=myDate;
  event2.Opportunity_Start_Date__c=myDate;
  event2.Booth_Last_Date__c=newDate;
  event2.Non_Booth_Last_Date__c=newDate;
       
  insert event2;
      
  //Create Sub Show
  SubShow__c subshow = new SubShow__c();
  subshow.Name = ' Test subshow';
  subshow.Show__c=show.id; 
       
  insert subshow;
       
  //Create Sub Show
  SubShow__c subshow1 = new SubShow__c();
  subshow1.Name = 'Test subshow1';
  subshow1.rule_set__c ='ASD_SB1';
  subshow1.Show__c=show2.id; 
       
  insert subshow1;
       
       
  // Create Sub Expo
  SubExpo__c subexpo = new SubExpo__c();
  subexpo.Name = 'Test SubExpo';
  subexpo.SubShow__c=subShow.id;
  subexpo.Event__c=event.id;
  insert subexpo;
       
  SubExpo__c subexpo2 = new SubExpo__c();
  subexpo2.Name = 'Test SubExpo';
  subexpo2.SubShow__c=subShow1.id;
  subexpo2.Event__c=event2.id;
  insert subexpo2;
      
     
  // Create Account Owner
  AccountOwners__c accOwner1 = new AccountOwners__c();
  accOwner1.Account__c=account2.id;
  accOwner1.AccountOwner__c=UserInfo.getUserId();
  accOwner1.Show__c=show.id;
  accOwner1.SubShow__c=subshow.id;
  insert accOwner1;
            
  AccountOwners__c accOwner2 = new AccountOwners__c();
  accOwner2.Account__c=account2.id;
  accOwner2.AccountOwner__c=UserInfo.getUserId();
  accOwner2.Show__c=show.id;
  accOwner2.SubShow__c=subshow.id;
  insert accOwner2;
            
  List<AccountOwners__c> accOwners = new List<AccountOwners__c>();
           
  accOwners.add(accOwner1);
  accOwners.add(accOwner2);
           
  Territory_Rule__c tr1 = new Territory_Rule__c();
  tr1.Key1__c='Test Show 1';
  tr1.Key2__c='';
  tr1.OpportunityOwner__c=UserInfo.getUserId();
  tr1.Rule_Set__c='ASD_SB';
  tr1.Territory_Rule_ID__c='ASD';
  tr1.Territory_Rule_Type__c='Show';
            
  insert tr1;
             
  Territory_Rule__c tr2 = new Territory_Rule__c();
  tr2.Key1__c='Test Show 1';
  tr2.Key2__c='Test subshow';
  tr2.OpportunityOwner__c=UserInfo.getUserId();
  tr2.Rule_Set__c='ASD_SB1';
  tr2.Territory_Rule_ID__c='ISS - Mallett';
  tr2.Territory_Rule_Type__c='SubShow';
            
  insert tr2;
            
  Territory_Rule__c tr3 = new Territory_Rule__c();
  tr3.Key1__c='US';
  tr3.Key2__c='LA,TX,CA,OH';
  tr3.OpportunityOwner__c=UserInfo.getUserId();
  tr3.Rule_Set__c='GLM';
  tr3.Territory_Rule_ID__c='GLM-Dillman';
  tr3.Territory_Rule_Type__c='Billing State';
            
  insert tr3;
            
  TerritoryRules.add(tr1);

  TerritoryRules.add(tr3);

  // Create two contacts
  Contact ct1 = new Contact();
  Contact ct2 = new Contact();
  ct1.FirstName = 'Larrys';
  ct1.LastName = 'Page';
  ct1.Email = 'lp@ee.cpm';
  ct1.Show__c=show.id;
  ct1.Roles__c='Agency';
  ct2.FirstName = 'Marc';
  ct2.LastName = 'Buymeoff';
  ct2.Email = 'mb@ee.cpm';
  ct2.Show__c=show.id;
  ct2.Roles__c='Agency';
  Insert ct1;    
  Insert ct2;
  system.debug('Completed Contact Creation'); 
           
  //Create Campaign
  Campaign camp = new Campaign();
  camp.Name = 'Camp1';
  camp.Short_Description__c='Short Description';
  camp.Event__c=event.id;
  //camp.segment_type__c = 'Lost';
  Database.SaveResult campsr = Database.insert(Camp, true);
  System.assert(campsr.isSuccess());
  system.debug('Inserted new Campaign');
           
           
  //Create Campaign
  Campaign camp2 = new Campaign();
  camp2.Name = 'Camp2';
  camp2.Short_Description__c='Short1 Description';
  camp2.Event__c=event1.id;
  //camp2.segment_type__c = 'Lost';
  Database.SaveResult campsr1 = Database.insert(Camp2, true);
  System.assert(campsr1.isSuccess());
  system.debug('Inserted new Campaign');
           
  Campaign camp3 = new Campaign();
  camp3.Name = 'Camp3';
  camp3.Short_Description__c='Short3 Description';
  camp3.Event__c=event2.id;
  //camp3.segment_type__c = 'Lost';
  Database.SaveResult campsr2 = Database.insert(Camp3, true);
  System.assert(campsr2.isSuccess());
  system.debug('Inserted new Campaign');
           
  Test.startTest(); 
     
  // Create Opportunity
  Opportunity op1 = new Opportunity();
  op1.name = 'Opportunity Contact Insertion Test';
  op1.AccountId=account.id;
  op1.CloseDate =  Date.today()+2;
  op1.StageName = 'Prospecting';
  op1.contact__c= ct1.Id ;
  op1.Amount=1.00;
  op1.Event__c=event.id;
  op1.subexpo__c=subexpo.id;
  op1.Create_Task__c = True;
  op1.OwnerID = UserInfo.getUserId();
          
          
         
  Campaign camp1 = new Campaign();
  camp1 = [Select ID, Name from Campaign limit 1];
  if(camp1!=null) 
    op1.CampaignId = camp1.ID;
    // insert op1;
    Database.SaveResult sr1 = Database.insert(op1, true);
    System.assert(sr1.isSuccess());
    system.debug('Inserted new op1 opportunity');
          
  // Create Opportunity
  Opportunity op2 = new Opportunity();
  op2.name = 'Opportunity Contact Insertion Test';
  op2.AccountId=account.id;
  op2.CloseDate =  Date.today()+2;
  op2.StageName = 'Prospecting';
  op2.contact__c= ct1.Id ;
  op2.Amount=1.00;
  op2.Event__c=event.id;
  op2.subexpo__c=subexpo.id;
  op2.Create_Task__c = True;
  op2.OwnerID = UserInfo.getUserId();
          
  if(camp1!=null) 
  op2.CampaignId = camp1.ID;         
  Database.SaveResult sr2 = Database.insert(op2, true);
  System.assert(sr2.isSuccess());
  system.debug('Inserted new op2 opportunity');
          
  //added grant Test Show Criteria 
  Opportunity op3 = new Opportunity();
  op3.name = 'Opportunity Contact Insertion Test';
  op3.AccountId=account.id;
  op3.CloseDate =  Date.today()+2;
  op3.StageName = 'Prospecting';
  op3.contact__c= ct1.Id ;
  op3.Amount=1.00;
  op3.Event__c=event1.id;
  //op3.subexpo__c=subexpo.id;
  op3.Create_Task__c = True;
  op3.OwnerID = UserInfo.getUserId();
          
  //added by Grant Test SubShow Criteria
  camp2 = [Select ID, Name from Campaign where short_description__c = 'Short1 Description'  limit 1];
  if(camp2!=null) 
    op3.CampaignId = camp2.ID;         
    Database.SaveResult sr3 = Database.insert(op3, true);
    System.assert(sr3.isSuccess());
    system.debug('Inserted new op3 opportunity');
          
  Opportunity op4 = new Opportunity();
  op4.name = 'Opportunity Contact Insertion Test';
  op4.AccountId=account.id;
  op4.CloseDate =  Date.today()+2;
  op4.StageName = 'Prospecting';
  op4.contact__c= ct1.Id ;
  op4.Amount=1.00;
  op4.Event__c=event2.id;
  op4.subexpo__c=subexpo2.id;
  op4.Create_Task__c = True;
  op4.OwnerID = UserInfo.getUserId();
          
  camp3 = [Select ID, Name from Campaign where short_description__c = 'Short3 Description'  limit 1];
  if(camp3!=null) 
    op4.CampaignId = camp3.ID;         
    Database.SaveResult sr4 = Database.insert(op4, true);
    System.assert(sr4.isSuccess());
    system.debug('Inserted new op4 opportunity');
          
  List<Opportunity> oppList = new List<Opportunity>();
          
  oppList.add(op1);
  oppList.add(op2);
  oppList.add(op3);
  oppList.add(op4);
         
  //insert oppList;
  Test.stopTest();
  }
  //Michael Vo
  //02/11/2017
  static testmethod void testPardotTasks() {
    
    Profile p1 = [Select ID from profile where name = 'Data Migration'];
    User u1 = new user(alias = 'dmigr',email = 'gongstad@gmail.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='grantongstad@testorg.com');
        
      
    date myDate = date.today();
     
    system.runAs(u1){ 
        
      //Account
      Account account = new Account();
      account.Name='Pardot Test Account';
      insert account;
        
      Account account1 = new Account();
      account1.Name='Pardot Test Account1';
      insert account1;
        
      // Create two contacts
      Contact ct1 = new Contact();     
      ct1.FirstName = 'Larrys';
      ct1.LastName = 'Page';
      ct1.Email='larry@page.com';
      ct1.accountid = account.id;     
      Insert ct1;    
           
      Contact ct2 = new Contact();
      ct2.FirstName = 'Allen';
      ct2.LastName = 'Iverson';
      ct2.Email='Allen@inversion.com';
      ct2.accountid = account1.id;
      Insert ct2; 
      
      system.debug('Completed Contact Creation'); 
      //Show
      //    Create Show
      Show__c testShow = new Show__c();
      testshow.name = 'ASD March Gift and Toy';
      insert testShow;
           
      //Event
      //Create Event
      Event__c event = new Event__c();
      event.Name='Test Event';
      Event.show__c = testshow.id;
      event.Event_Year__c='2017';
      event.Event_Code__c='3012-17';
      event.Stage_Date__c=myDate;
      event.Opportunity_Start_Date__c=myDate;
      event.Booth_Last_Date__c=myDate ;
      event.Non_Booth_Last_Date__c=myDate ;
       
      Insert event;
                  
      //Create Campaign
      Campaign camp = new Campaign();
      camp.Name = 'Camp1';
      //camp.segment_type__c = 'Lost';
      camp.Short_Description__c='P-WS-Inbound Inquiry';
      camp.Event__c=event.id;
      Database.SaveResult campsr = Database.insert(Camp, true);
      System.assert(campsr.isSuccess());
      system.debug('Inserted new Campaign');
           
      //Create Existing Opportunity
      Opportunity op1 = new Opportunity();
      op1.name = 'x';
      op1.event__c = event.id;
      op1.stagename = 'No Contact Attempted';
      op1.closedate = system.today();
      op1.product__c = 'Booth';
      op1.accountid = account1.id;
      insert op1;
           
    
      // Create Task
      Task t = new Task();
      t.OwnerId = UserInfo.getUserId();
      t.Subject = 'P|3012-17|P-WS-Inbound Inquiry' ;
      t.Priority = 'Normal';
      t.Status = 'Not Started';
      t.ActivityDate = System.today () + 1;
      t.Activity_Type__c = 'Call';
      insert t;

             
      Task pt = new Task();
      // list <Task> ptTask = New List <Task>(); 
      pt.WhoID = Ct1.Id;
      pt.OwnerId = UserInfo.getUserId();
      pt.Subject = 'P|3012-17|P-WS-Inbound Inquiry' ;
      pt.Priority = 'Normal';
      pt.Status = 'Not Started';
      pt.ActivityDate = System.today () + 1;
      pt.Activity_Type__c = 'Call';
      //pt.is_pardot_task__c = TRUE; 
      // ptTask.add(pt);
        
                
      Task existingOppTask = new Task();
      // list<Task> nonptTask = New List <Task>();
      existingOppTask.WhatId = account1.Id;
      existingOppTask.OwnerId = UserInfo.getUserId();
      existingOppTask.Subject = 'P|3012-17|P-WS-Inbound Inquiry' ;
      existingOppTask.Priority = 'Normal';
      existingOppTask.Status = 'Not Started';
      existingOppTask.ActivityDate = System.today () + 1;
      existingOppTask.Activity_Type__c = 'Call';
      // nonptTask.add(nonpt);
                   
                  
      Test.startTest();  
      insert pt;
      insert existingOppTask;
         
      Opportunity op2 = new Opportunity();
      op2.name = 'x123';
      op2.event__c = event.id;
      op2.stagename = 'No Contact Attempted';
      op2.closedate = system.today();
      op2.product__c = 'Booth';
      op2.accountid = account1.id;
      op2.OwnerId = UserInfo.getUserId();
      //op2.Campaign__c = camp.Id;
      op2.Pardot_Task_ID__c = t.Id;

      insert op2;       
            
      Test.stopTest();  
    
    } 
  } */     
}