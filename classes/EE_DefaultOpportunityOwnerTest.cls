@isTest
public class EE_DefaultOpportunityOwnerTest {
    static testmethod void EE_DefaultOpportunityOwnerTest() {
        date myDate = date.today();
        Date newDate = mydate.addDays(2);
        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        //Account
        Account account1 = new Account();
        account1.Name ='Test1';
        account1.BillingCountryCode ='CN';
        insert account1;

        // Create contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1;
        
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
        
        //AccountOwners
        AccountOwners__c AO = new AccountOwners__c();
        AO.Account__c = account.Id;
        AO.AccountOwner__c = UserInfo.getUserId();
        AO.Show__c = show.Id;
        Insert AO;
       
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
        
        //Create Campaign
        Campaign camp = new Campaign();
        camp.Name = 'Camp1';
        camp.Short_Description__c='Short Description';
        camp.Event__c=event.id;
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
      

        //Account
        Account account2 = new Account();
        account2.Name ='Test1';
        insert account2;

        //Account
        Account account3 = new Account();
        account3.Name ='Test12';
        insert account3;

        //Create Show 
        Show__c show1 = new Show__c();
        show1.Name='Test Show2';
        show1.Brand__c='TBrand2';
        show1.Market__c='TMarket2';
        show1.Rule_Set__c='ASD_SB2';
        show1.Segment__c='TSegment2';
        show1.Show_Code__c='TShowCode2';      
        show1.Show_Group__c='ShowGroup2';
        show1.ShowID__c=123456;
        insert show1;

        //Create Sub Show
        SubShow__c subshow1 = new SubShow__c();
        subshow1.Name = 'Blue';
        subshow1.Show__c=show1.id; 
        insert subshow1;
       
        //Create Event
        Event__c event1 = new Event__c();
        event1.Name='Test Event2';
        event1.Show__c=show1.id;
        event1.Event_Year__c='2020';
        event1.Event_Code__c='1234-01';
        event1.Stage_Date__c=myDate;
        event1.Opportunity_Start_Date__c=myDate;
        event1.Booth_Last_Date__c=newDate;
        event1.Non_Booth_Last_Date__c=newDate;
        insert event1;

        // Create Sub Expo
        SubExpo__c subexpo1 = new SubExpo__c();
        subexpo1.Name = 'Surf-Blue';
        subexpo1.SubShow__c=subshow1.id;
        subexpo1.Event__c=event1.id;
        insert subexpo1;

        //Account Owners
        AccountOwners__c accOwner1 = new AccountOwners__c();
        accOwner1.Account__c=account2.id;
        accOwner1.AccountOwner__c= UserInfo.getUserId();
        accOwner1.Show__c=show1.id;
        insert accOwner1;

        //Account Owners
        AccountOwners__c accOwner2 = new AccountOwners__c();
        accOwner2.Account__c=account3.id;
        accOwner2.AccountOwner__c= UserInfo.getUserId();
        accOwner2.Show__c=show1.id;
        accOwner2.SubShow__c= subshow1.id;
        insert accOwner2;
  
        //Create Campaign
        Campaign camp1 = new Campaign();
        camp1.Name = 'Camp2';
        camp1.Short_Description__c='Short Description';
        camp1.Event__c = event1.id;
        Database.SaveResult campsr1 = Database.insert(Camp1, true);
        System.assert(campsr1.isSuccess());
        
        // Create Opportunity
        Opportunity op5 = new Opportunity();
        op5.name = 'Opportunity Test';
        op5.AccountId=account1.id;
        op5.CloseDate =  Date.today()+2;
        op5.StageName = 'No Contact Attempted';
        op5.Event__c = event1.id;
        op5.CampaignId = camp1.id;

        // Create Opportunity
        Opportunity op6 = new Opportunity();
        op6.name = 'Opportunity Test';
        op6.AccountId=account3.id;
        op6.CloseDate =  Date.today()+2;
        op6.StageName = 'No Contact Attempted';
        op6.Event__c = event1.id;
        op6.CampaignId = camp1.id;
        op6.SubExpo__c = subexpo1.id;
        

      
        
        //Create Territory Rule
        Territory_Rule__c tr1 = new Territory_Rule__c();
        tr1.Key1__c='US';
        tr1.Key2__c='LA,TX,CA,OH';
        tr1.OpportunityOwner__c=UserInfo.getUserId();
        tr1.Rule_Set__c='ASD_SB2';
        tr1.Territory_Rule_ID__c='GLM-Dillman';
        tr1.Territory_Rule_Type__c='Account Name';
        insert tr1;
        
        Territory_Rule__c tr2 = new Territory_Rule__c();
        tr2.Key1__c='US';
        tr2.Key2__c= '*';
        tr2.OpportunityOwner__c=UserInfo.getUserId();
        tr2.Rule_Set__c='ASD_SB';
        tr2.Territory_Rule_ID__c='GLM-Dillman';
        tr2.Territory_Rule_Type__c='Billing State';
        insert tr2;
        
        Territory_Rule__c tr3 = new Territory_Rule__c();
        tr3.Key1__c='US';
        tr3.Key2__c= 'LA,TX,CA,OH';
        tr3.OpportunityOwner__c=UserInfo.getUserId();
        tr3.Rule_Set__c='ASD_SB';
        tr3.Territory_Rule_ID__c='GLM-Dillman';
        tr3.Territory_Rule_Type__c='Billing State';
        insert tr3;
        
        

        // Show
        //Create Show 
        Show__c showtr = new Show__c();
        showtr.Name='Active Collective';
        showtr.Brand__c='Active';
        showtr.Rule_Set__c='ACTIVE';
        showtr.Show_Code__c='6312';      
        insert showtr;
       
        //Create Event
        Event__c eventtr = new Event__c();
        eventtr.Name='2020 Active';
        eventtr.Show__c = showtr.id;
        eventtr.Event_Year__c='2020';
        eventtr.Event_Code__c='6313-20';
        eventtr.Stage_Date__c=myDate;
        eventtr.Opportunity_Start_Date__c=myDate;
        eventtr.Booth_Last_Date__c=newDate;
        eventtr.Non_Booth_Last_Date__c=newDate;
       
        insert eventtr;
        
        //Create Campaign
        Campaign camptr = new Campaign();
        camptr.Name = 'Camptr';
        camptr.Short_Description__c='Short Description';
        camptr.Event__c = eventtr.id;
        Database.SaveResult campsr2 = Database.insert(camptr, true);
        System.assert(campsr2.isSuccess());
        
        // Create Opportunity
        Opportunity op7 = new Opportunity();
        op7.name = 'Opportunity Test';
        op7.AccountId=account1.id;
        op7.CloseDate =  Date.today()+2;
        op7.StageName = 'No Contact Attempted';
        op7.Event__c = eventtr.id;
        op7.CampaignId = camptr.id;
        
      
      
        Territory_Rule__c tr4 = new Territory_Rule__c();
        tr4.Key1__c='Active Collective';
        tr4.Key2__c= '';
        tr4.OpportunityOwner__c=UserInfo.getUserId();
        tr4.Rule_Set__c='ACTIVE';
        tr4.Territory_Rule_ID__c='ACTIVE-DAMELIO';
        tr4.Territory_Rule_Type__c='Show';
        insert tr4;
        //

        //SubShow
        //Create Show 
        Show__c showtr1 = new Show__c();
        showtr1.Name='Surf';
        showtr1.Brand__c='Surf';
        showtr1.Rule_Set__c='SURF';
        showtr1.Show_Code__c='1416';      
        insert showtr1;
       
        //Create Event
        Event__c eventtr1 = new Event__c();
        eventtr1.Name='2020 Surf';
        eventtr1.Show__c = showtr1.id;
        eventtr1.Event_Year__c='2020';
        eventtr1.Event_Code__c='1416-20';
        eventtr1.Stage_Date__c=myDate;
        eventtr1.Opportunity_Start_Date__c=myDate;
        eventtr1.Booth_Last_Date__c=newDate;
        eventtr1.Non_Booth_Last_Date__c=newDate;
        insert eventtr1;
        
        //Create Campaign
        Campaign camptr1 = new Campaign();
        camptr1.Name = 'Camptr1';
        camptr1.Short_Description__c='Short Description';
        camptr1.Event__c = eventtr1.id;
        Database.SaveResult campsr3 = Database.insert(camptr1, true);
        System.assert(campsr3.isSuccess());

        //Create Sub Show
        SubShow__c subshowtr1 = new SubShow__c();
        subshowtr1.Name = 'Blue';
        subshowtr1.Show__c=showtr1.id; 
        insert subshowtr1;
       
        // Create Sub Expo
        SubExpo__c subexpo = new SubExpo__c();
        subexpo.Name = 'Surf-Blue';
        subexpo.SubShow__c=subshowtr1.id;
        subexpo.Event__c=eventtr1.id;
        insert subexpo;
      
        Territory_Rule__c tr5 = new Territory_Rule__c();
        tr5.Key1__c='Surf-Blue';
        tr5.Key2__c= 'Blue';
        tr5.OpportunityOwner__c=UserInfo.getUserId();
        tr5.Rule_Set__c='SURF';
        tr5.Territory_Rule_ID__c='Surf-Blue-Test';
        tr5.Territory_Rule_Type__c='SubShow';
        insert tr5;

        //Billing Country and State
        Show__c showtr2 = new Show__c();
        showtr2.Name='Imp';
        showtr2.Brand__c='Imp';
        showtr2.Rule_Set__c='IMP';
        showtr2.Show_Code__c='1231';      
        insert showtr2;


       
        //Create Event
        Event__c eventtr2 = new Event__c();
        eventtr2.Name='ImpTest';
        eventtr2.Show__c = showtr2.id;
        eventtr2.Event_Year__c='2020';
        eventtr2.Event_Code__c='1234-20';
        eventtr2.Stage_Date__c=myDate;
        eventtr2.Opportunity_Start_Date__c=myDate;
        eventtr2.Booth_Last_Date__c=newDate;
        eventtr2.Non_Booth_Last_Date__c=newDate;
        insert eventtr2;

        
        
        //Create Campaign
        Campaign camptr2 = new Campaign();
        camptr2.Name = 'Camptr1';
        camptr2.Short_Description__c='Short Description';
        camptr2.Event__c = eventtr2.id;
        Database.SaveResult campsr4 = Database.insert(camptr2, true);
        System.assert(campsr4.isSuccess());

        Territory_Rule__c tr6 = new Territory_Rule__c();
        tr6.Key1__c='M,U,N';
        tr6.Key2__c= 'US-CA';
        tr6.OpportunityOwner__c=UserInfo.getUserId();
        tr6.Rule_Set__c='IMP';
        tr6.Territory_Rule_ID__c='IMP-Lee';
        tr6.Territory_Rule_Type__c='Account Name & Billing State';
        insert tr6;

        
        Territory_Rule__c tr7 = new Territory_Rule__c();
        tr7.Key1__c='US';
        tr7.Key2__c= 'FL';
        tr7.OpportunityOwner__c=UserInfo.getUserId();
        tr7.Rule_Set__c='IMP';
        tr7.Territory_Rule_ID__c='Or-Lee';
        tr7.Territory_Rule_Type__c='Billing State';
        insert tr7; 

        //International
        Territory_Rule__c tr8 = new Territory_Rule__c();
        tr8.Key1__c='International';
        tr8.Key2__c= 'US';
        tr8.OpportunityOwner__c=UserInfo.getUserId();
        tr8.Rule_Set__c='IMP';
        tr8.Territory_Rule_ID__c='Or-Lee';
        tr8.Territory_Rule_Type__c='Billing State';
        insert tr8; 

        
        // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Test';
        op1.AccountId=account.id;
        op1.CloseDate =  Date.today()+2;
        op1.StageName = 'No Contact Attempted';
        op1.Event__c = eventtr1.id;
        op1.CampaignId = camptr1.id;
        op1.SubExpo__c = subexpo.id;
        
        
        // Create Opportunity
        Opportunity op2 = new Opportunity();
        op2.name = 'Opportunity Test';
        op2.AccountId=account.id;
        op2.CloseDate =  Date.today()+2;
        op2.StageName = 'No Contact Attempted';
        op2.Event__c=event.id;
        op2.CampaignId = camp.id;
        
        
        // Create Opportunity
        Opportunity op3 = new Opportunity();
        op3.name = 'Opportunity Test';
        op3.AccountId=account.id;
        op3.CloseDate =  Date.today()+2;
        op3.StageName = 'No Contact Attempted';
        op3.Event__c = eventtr2.id;
        op3.CampaignId = camptr2.id;

        // Create Opportunity
        Opportunity op4 = new Opportunity();
        op4.name = 'Opportunity Test';
        op4.AccountId=account1.id;
        op4.CloseDate =  Date.today()+2;
        op4.StageName = 'No Contact Attempted';
        op4.Event__c = eventtr2.id;
        op4.CampaignId = camptr2.id;
        
        

        //Account
        Account account4 = new Account();
        account4.Name ='Test4';
        insert account4;

        //Create Show 
        Show__c show12 = new Show__c();
        show12.Name='Test Show2';
        show12.Brand__c='TBrand2';
        show12.Market__c='TMarket2';
        show12.Rule_Set__c='ASD_SB2';
        show12.Segment__c='TSegment2';
        show12.OwnerId = UserInfo.getUserId();
        insert show12;

              
        //Create Event
        Event__c event12 = new Event__c();
        event12.Name='Test Event2';
        event12.Show__c=show12.id;
        event12.Event_Year__c='2020';
        event12.Event_Code__c='1234-01';
        event12.Stage_Date__c=myDate;
        event12.Opportunity_Start_Date__c=myDate;
        event12.Booth_Last_Date__c=newDate;
        event12.Non_Booth_Last_Date__c=newDate;
        insert event12;

         
        //Create Campaign
        Campaign camp12 = new Campaign();
        camp12.Name = 'Camp2';
        camp12.Short_Description__c='Short Description';
        camp12.Event__c = event12.id;
        Database.SaveResult campsr12 = Database.insert(Camp12, true);
        System.assert(campsr12.isSuccess());
        
        // Create Opportunity
        Opportunity op8 = new Opportunity();
        op8.name = 'Opportunity Test';
        op8.AccountId=account4.id;
        op8.CloseDate =  Date.today()+2;
        op8.StageName = 'No Contact Attempted';
        op8.Event__c = event12.id;
        op8.CampaignId = camp12.id;
        

        
        
        test.startTest();
        insert op2;
        insert op1;
        insert op3;
        insert op4;
        insert op5;
        insert op6;
        insert op7;
        insert op8;
        test.stopTest();
    }
}