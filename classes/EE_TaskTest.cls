@isTest
public class EE_TaskTest {

    static testmethod void TaskInsertionMethod() {

        date myDate = date.today();
        Date newDate = mydate.addDays(2);

        
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
       event.Event_Year__c='2019';
       event.Event_Code__c='2019-01';
       event.Stage_Date__c=myDate;
       event.Opportunity_Start_Date__c=myDate;
       event.Booth_Last_Date__c=newDate;
       event.Non_Booth_Last_Date__c=newDate;
       
       insert event;
      
      //Create Sub Show
       SubShow__c subshow = new SubShow__c();
       subshow.Name = 'subshow';
       subshow.Show__c=show.id; 
       
       insert subshow;
       
       
       // Create Sub Expo
       SubExpo__c subexpo = new SubExpo__c();
       subexpo.Name = 'Test SubExpo';
       subexpo.SubShow__c=subShow.id;
       subexpo.Event__c=event.id;
       insert subexpo;

        
        //Create Show 
       Show__c show2 = new Show__c();
       show2.Name='Test Show2';
       show2.Brand__c='TBrand2';
       show2.Market__c='TMarket2';
       show2.Rule_Set__c='ASD_SB2';
       show2.Segment__c='TSegment2';
       show2.Show_Code__c='TShowCode2';      
       show2.Show_Group__c='ShowGroup2';
       show2.ShowID__c=123456;
       insert show2;
       
       //Create Event
       Event__c event2 = new Event__c();
       event2.Name='Test Event2';
       event2.Show__c=show2.id;
       event2.Event_Year__c='2020';
       event2.Event_Code__c='1234-01';
       event2.Stage_Date__c=myDate;
       event2.Opportunity_Start_Date__c=myDate;
       event2.Booth_Last_Date__c=newDate;
       event2.Non_Booth_Last_Date__c=newDate;
       
       insert event2;
      
      //Create Sub Show
       SubShow__c subshow2 = new SubShow__c();
       subshow2.Name = 'subshow2';
       subshow2.Show__c=show2.id; 
       
       insert subshow2;
       
       
       // Create Sub Expo
       SubExpo__c subexpo2 = new SubExpo__c();
       subexpo2.Name = 'Test SubExpo2';
       subexpo2.SubShow__c=subShow2.id;
       subexpo2.Event__c=event2.id;
       insert subexpo2;

       //Create Campaign
        Campaign camp = new Campaign();
        camp.Name = 'Camp1';
        camp.Short_Description__c='P-Test3';
        camp.Event__c=event.id;
        //camp.segment_type__c = 'Lost';
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
        system.debug('Inserted new Campaign');

        Campaign camp2 = new Campaign();
        camp2.Name = 'Camp2';
        camp2.Short_Description__c='P-Test1234';
        camp2.Event__c=event2.id;
        //camp2.segment_type__c = 'Lost';
        Database.SaveResult campsr2 = Database.insert(Camp2, true);
        System.assert(campsr2.isSuccess());
        system.debug('Inserted new Campaign');

        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        //Account Owner
        AccountOwners__c accOwner = new AccountOwners__c();
        accOwner.Account__c=account.id;
        accOwner.AccountOwner__c= UserInfo.getUserId();
        accOwner.Show__c=show.id;
        accOwner.SubShow__c=subshow.id;
        insert accOwner;

        //Account
        Account account2 = new Account();
        account2.Name='Account2';
        insert account2;

        //Account
        Account account3 = new Account();
        account3.Name ='Account3';
        insert account3;

        // Create contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1;   
      
        Contact ct2 = new Contact();
        ct2.FirstName = 'EE';
        ct2.LastName = 'TEST2';
        ct2.Email = 'EETEST2@ee.com';
        ct2.AccountId = account2.Id;
        Insert ct2;

        Contact ct3 = new Contact();
        ct3.FirstName = 'EE3';
        ct3.LastName = 'TEST3';
        ct3.Email = 'EETEST345@ee1.com';
        ct3.AccountId = account3.Id;
        Insert ct3;

        Contact ct6 = new Contact();
        ct6.FirstName = 'EE56';
        ct6.LastName = 'TEST56';
        ct6.Phone = '3452343452';
        ct6.Email = '';
        ct6.AccountId = account3.Id;
        Insert ct6;

        Lead ld = new Lead();
        ld.FirstName = 'EE3';
        ld.LastName = 'TEST3';
        ld.Email = 'EETEST345@ee1.com';
        ld.Event__c = event.Id;
        ld.Company = 'Account3';
        Insert ld;
      
        // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Contact Insertion Test';
        op1.AccountId=account.id;
        op1.CloseDate =  Date.today()+2;
        op1.StageName = 'No Contact Attempted';
        op1.Product__c = 'Booth';
        op1.contact__c= ct1.Id ;
        op1.Amount=1.00;
        op1.Event__c=event.id;
        op1.subexpo__c=subexpo.id;
        op1.Create_Task__c = True;
        op1.OwnerID = UserInfo.getUserId();
        insert op1;
         
        List<Task> TaskList = new List<Task>();

        //with sub expo - Existing Lead
        Task taskEXLdwithsubexpo = new Task();
        taskEXLdwithsubexpo.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth|subshow';
        taskEXLdwithsubexpo.WhoId = ct3.Id;
        //TaskList.add(taskEXLdwithsubexpo);

       //Existing Lead
        Task taskContactwithPhone = new Task();
        taskContactwithPhone.Status = 'Not Started';
        taskContactwithPhone.whoId = ct6.Id;
        taskContactwithPhone.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth';
        //TaskList.add(taskContactwithPhone);

        //with sub expo - New Lead
        Task taskLeadwithsubexpo = new Task();
        taskLeadwithsubexpo.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth|subshow';
        taskLeadwithsubexpo.WhoId = ld.Id;
        TaskList.add(taskLeadwithsubexpo);

        //with Lead
        Task taskwithLead = new Task();
        taskwithLead.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth';
        taskwithLead.WhoId = ld.Id;
        TaskList.add(taskwithLead);
      
        //Invalid Event
        Task InvalidEventTask = new Task();
        InvalidEventTask.Subject = 'P|2021-01|P-Test3|AE Prospecting|Booth';
        InvalidEventTask.WhoId = ct2.Id;
        //TaskList.add(InvalidEventTask);
        
        Insert TaskList;

       test.startTest();
          EE_Task.createOpportunityFromPardotTask(TaskList);
       test.stopTest();

    }
    static testmethod void TaskInsertionMethod1() {

      date myDate = date.today();
      Date newDate = mydate.addDays(2);

      
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
     event.Event_Year__c='2019';
     event.Event_Code__c='2019-01';
     event.Stage_Date__c=myDate;
     event.Opportunity_Start_Date__c=myDate;
     event.Booth_Last_Date__c=newDate;
     event.Non_Booth_Last_Date__c=newDate;
     
     insert event;
    
    //Create Sub Show
     SubShow__c subshow = new SubShow__c();
     subshow.Name = 'subshow';
     subshow.Show__c=show.id; 
     
     insert subshow;
     
     
     // Create Sub Expo
     SubExpo__c subexpo = new SubExpo__c();
     subexpo.Name = 'Test SubExpo';
     subexpo.SubShow__c=subShow.id;
     subexpo.Event__c=event.id;
     insert subexpo;

      
      //Create Show 
     Show__c show2 = new Show__c();
     show2.Name='Test Show2';
     show2.Brand__c='TBrand2';
     show2.Market__c='TMarket2';
     show2.Rule_Set__c='ASD_SB2';
     show2.Segment__c='TSegment2';
     show2.Show_Code__c='TShowCode2';      
     show2.Show_Group__c='ShowGroup2';
     show2.ShowID__c=123456;
     insert show2;
     
     //Create Event
     Event__c event2 = new Event__c();
     event2.Name='Test Event2';
     event2.Show__c=show2.id;
     event2.Event_Year__c='2020';
     event2.Event_Code__c='1234-01';
     event2.Stage_Date__c=myDate;
     event2.Opportunity_Start_Date__c=myDate;
     event2.Booth_Last_Date__c=newDate;
     event2.Non_Booth_Last_Date__c=newDate;
     
     insert event2;
    
    //Create Sub Show
     SubShow__c subshow2 = new SubShow__c();
     subshow2.Name = 'subshow2';
     subshow2.Show__c=show2.id; 
     
     insert subshow2;
     
     
     // Create Sub Expo
     SubExpo__c subexpo2 = new SubExpo__c();
     subexpo2.Name = 'Test SubExpo2';
     subexpo2.SubShow__c=subShow2.id;
     subexpo2.Event__c=event2.id;
     insert subexpo2;

     //Create Campaign
      Campaign camp = new Campaign();
      camp.Name = 'Camp1';
      camp.Short_Description__c='P-Test3';
      camp.Product__c ='Booth';
      camp.Event__c=event.id;
      //camp.segment_type__c = 'Lost';
      Database.SaveResult campsr = Database.insert(Camp, true);
      System.assert(campsr.isSuccess());
      system.debug('Inserted new Campaign');

      Campaign camp2 = new Campaign();
      camp2.Name = 'Camp2';
      camp2.Short_Description__c='P-Test1234';
      camp2.Event__c=event2.id;
      camp.Product__c ='Booth';
      //camp2.segment_type__c = 'Lost';
      Database.SaveResult campsr2 = Database.insert(Camp2, true);
      System.assert(campsr2.isSuccess());
      system.debug('Inserted new Campaign');

      //Account
      Account account = new Account();
      account.Name='Test Account';
      insert account;

      //Account Owner
      AccountOwners__c accOwner = new AccountOwners__c();
      accOwner.Account__c=account.id;
      accOwner.AccountOwner__c= UserInfo.getUserId();
      accOwner.Show__c=show.id;
      accOwner.SubShow__c=subshow.id;
      insert accOwner;

      //Account
      Account account2 = new Account();
      account2.Name='Account2';
      insert account2;

      //Account
      Account account3 = new Account();
      account3.Name ='Account3';
      insert account3;

      // Create contacts
      Contact ct1 = new Contact();
      ct1.FirstName = 'Emerald';
      ct1.LastName = 'Test';
      ct1.Email = 'EmeraldTest@ee.com';
      ct1.AccountId = account.Id;
      Insert ct1;   
    
      Contact ct2 = new Contact();
      ct2.FirstName = 'EE';
      ct2.LastName = 'TEST2';
      ct2.Email = 'EETEST2@ee.com';
      ct2.AccountId = account2.Id;
      Insert ct2;

      Contact ct3 = new Contact();
      ct3.FirstName = 'EE3';
      ct3.LastName = 'TEST3';
      ct3.Email = 'EETEST345@ee1.com';
      ct3.AccountId = account3.Id;
      Insert ct3;

      
      Lead ld = new Lead();
      ld.FirstName = 'EE3';
      ld.LastName = 'TEST3';
      ld.Email = 'EETEST345@ee1.com';
      ld.Event__c = event.Id;
      ld.Product__c ='Booth';
      //ld.SubExpo__c = subexpo.Id;
      ld.Company = 'Account3';
      Insert ld;
 
      // Create Opportunity
      Opportunity op1 = new Opportunity();
      op1.name = 'Opportunity Contact Insertion Test';
      op1.AccountId=account.id;
      op1.CloseDate =  Date.today()+2;
      op1.StageName = 'No Contact Attempted';
      op1.Product__c = 'Booth';
      op1.contact__c= ct1.Id ;
      op1.Amount=1.00;
      op1.Event__c=event.id;
      op1.subexpo__c=subexpo.id;
      op1.Create_Task__c = True;
      op1.OwnerID = UserInfo.getUserId();
      insert op1;

      // Create Opportunity 
      Opportunity op2 = new Opportunity();
      op2.name = 'Opportunity Contact Insertion Test';
      op2.AccountId=account.id;
      op2.CloseDate =  Date.today()+2;
      op2.StageName = 'No Contact Attempted';
      op2.Product__c = 'Booth';
      op2.contact__c= ct1.Id ;
      op2.Amount=1.00;
      op2.Event__c=event2.id;
      op2.Create_Task__c = True;
      op2.OwnerID = UserInfo.getUserId();
      insert op2;
       
      List<Task> TaskList = new List<Task>();
      
      //with opportunity
      Task taskwithopp = new Task();
      taskwithopp.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth|subshow';
      taskwithopp.WhatId = account.Id;
      //taskwithopp.AccountId = account.Id;
      taskwithopp.WhoId = ct1.id;
      TaskList.add(taskwithopp);

      //with opportunity
      Task taskwithopp1 = new Task();
      taskwithopp1.Subject = 'P|1234-01|P-Test3|AE Prospecting|Booth';
      taskwithopp1.WhatId = op2.Id;
      taskwithopp1.WhoId = ct1.id;
    //TaskList.add(taskwithopp1);

      //with sub expo - Existing Lead
      Task taskEXLdwithsubexpo = new Task();
      taskEXLdwithsubexpo.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth';
      taskEXLdwithsubexpo.WhoId = ct3.Id;
     // taskEXLdwithsubexpo.AccountId = account3.Id;
      TaskList.add(taskEXLdwithsubexpo);

       //with sub expo - New Lead
      Task taskLeadwithsubexpo = new Task();
      taskLeadwithsubexpo.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth';
      taskLeadwithsubexpo.WhoId = ct2.Id;
      TaskList.add(taskLeadwithsubexpo); 

      //with Lead
      Task taskwithLead = new Task();
      taskwithLead.Subject = 'P|2019-01|P-Test3|AE Prospecting|Booth|subshow';
      taskwithLead.WhoId = ld.Id;
      TaskList.add(taskwithLead);
         
      Insert TaskList;

      test.startTest();
        EE_Task.createOpportunityFromPardotTask(TaskList);
      test.stopTest();

  }
}