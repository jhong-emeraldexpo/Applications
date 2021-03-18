@isTest
public class EE_DefaultLeadOwnerTest {

    static testmethod void EE_DefaultLeadOwnerTest() {

        date myDate = date.today();
        Date newDate = mydate.addDays(2);
        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

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
		
		Lead ld1= new Lead();
        ld1.FirstName = 'EE31';
        ld1.LastName = 'TEST31';
        ld1.Email = 'EETEST3451@ee11.com';
        ld1.Company = 'US Account31';
        ld1.OwnerId=tr1.OpportunityOwner__c;
        ld1.pi_ee_Event_Code__c = '2019-01';
        ld1.Should_Ignore_Assignment_Rule__c = False;
        ld1.CountryCode = 'US';
        insert ld1;

        Lead ld2= new Lead();
        ld2.FirstName = 'EEInvalid';
        ld2.LastName = 'TESTInvalid';
        ld2.Email = 'EETESTInvalid@ee11.com';
        ld2.Company = 'US AccountInvalid';
        ld2.OwnerId=UserInfo.getUserId();
        ld2.pi_ee_Event_Code__c = '1234-56';
        ld2.Should_Ignore_Assignment_Rule__c = False;
        ld2.CountryCode = 'HT';
        insert ld2;

        Lead ld3= new Lead();
        ld3.FirstName = 'EE31test';
        ld3.LastName = 'TEST31ee';
        ld3.Email = 'EE11@ee.com';
        ld3.Company = 'UScomptest';
        ld3.OwnerId= UserInfo.getUserId();
        ld3.pi_ee_Event_Code__c = '1234-20';
        ld3.CountryCode = 'US';
        ld3.StateCode = 'FL';
        insert ld3;

        Lead ld4= new Lead();
        ld4.FirstName = 'EE31test1';
        ld4.LastName = 'TEST31ee1';
        ld4.Email = 'EE11@1ee.com';
        ld4.Company = 'UScomptest1';
        ld4.OwnerId= UserInfo.getUserId();
        ld4.pi_ee_Event_Code__c = '1234-20';
        ld4.CountryCode = 'CN';
        insert ld4;

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

        //Create Sub Show
        SubShow__c subshow = new SubShow__c();
        subshow.Name = 'Blue';
        subshow.Show__c=showtr1.id; 
        insert subshow;
       
        // Create Sub Expo
        SubExpo__c subexpo = new SubExpo__c();
        subexpo.Name = 'Surf-Blue';
        subexpo.SubShow__c=subshow.id;
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

	
		test.startTest();

        Lead updLead = new Lead();
        updLead.id= ld1.id;
        updLead.Event__c = event1.Id;
        updLead.OwnerID = tr1.OpportunityOwner__c;
        updLead.Territory_Rule_ID__c=tr1.Territory_Rule_ID__c;
        update updLead;

        Lead updLead1 = new Lead();
        updLead1.id= ld1.id;
        updLead1.Event__c = eventtr.Id;
        updLead1.OwnerID = tr4.OpportunityOwner__c;
        update updLead1; 

        Lead updLead3 = new Lead();
        updLead3.id= ld1.id;
        updLead3.Event__c = eventtr2.Id;
        updLead3.Territory_Rule_ID__c = tr6.Territory_Rule_ID__c;
        updLead3.OwnerID = tr6.OpportunityOwner__c;
        update updLead3;

        Lead updLead4 = new Lead();
        updLead4.id= ld3.id;
        updLead4.Event__c = eventtr2.Id;
        updLead4.Territory_Rule_ID__c = tr7.Territory_Rule_ID__c;
        updLead4.OwnerID = tr7.OpportunityOwner__c;
        update updLead4; 

        Lead updLead5 = new Lead();
        updLead5.id= ld4.id;
        updLead5.Event__c = eventtr2.Id;
        updLead5.Territory_Rule_ID__c = tr8.Territory_Rule_ID__c;
        updLead5.OwnerID = tr8.OpportunityOwner__c;
        update updLead5; 

        Lead updLead2 = new Lead();
        updLead2.id= ld1.id;
        updLead2.Event__c = eventtr1.Id;
        updLead2.SubExpo__c = subexpo.Id;
        updLead2.Territory_Rule_ID__c = tr5.Territory_Rule_ID__c;
        updLead2.OwnerID = tr5.OpportunityOwner__c;
        update updLead2; 

        test.stopTest();

    }
}