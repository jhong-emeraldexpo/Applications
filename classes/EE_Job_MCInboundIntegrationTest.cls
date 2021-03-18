@isTest
public class EE_Job_MCInboundIntegrationTest {
    @testSetup 
    static void setup() {
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
        ct1.ContactGUID__c = 'TEST-TEST-TEST20';
        insert ct1;
        
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
        event.Event_Year__c='2020';
        event.Event_Code__c='2020-01';
        event.Stage_Date__c=myDate;
        event.Opportunity_Start_Date__c=myDate;
        event.Booth_Last_Date__c=newDate;
        event.Non_Booth_Last_Date__c=newDate;
        insert event;
      
        Id RecordTypeIdCampaign = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();
        
        //Create Campaign
		Campaign camp = new Campaign();
		camp.Name = 'Camp1';
		camp.Short_Description__c='Test Camp1';
        camp.Event__c=event.id;
        camp.Product__c='VIP Registration';
        camp.RecordTypeId = RecordTypeIdCampaign;
        camp.Status='In Progress';
        camp.Technique__c= 'Call';
        camp.Target_Start_Date__c=myDate;
        camp.Target_End_Date__c =myDate;
        camp.Target_num_of_records__c = 20;	
        insert camp;	

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

        //Create Integration Queue
        EE_Integration_Queue__c IQ = new EE_Integration_Queue__c();
        IQ.Campaign__c = camp.Id;
        IQ.Contact__c = ct1.Id;
        IQ.Event__c = event.Id;
        IQ.Object_Name__c = 'Lead';
        IQ.Product__c ='VIP Registration';
        IQ.SubExpo__c = subexpo.Id;
        insert IQ;

        //Create Integration Queue
        EE_Integration_Queue__c IQ1 = new EE_Integration_Queue__c();
        IQ1.Campaign__c = camp.Id;
        IQ1.Contact__c = ct1.Id;
        IQ1.Event__c = event.Id;
        IQ1.Object_Name__c = 'Opportunity';
        IQ1.Product__c ='VIP Registration';
        IQ1.SubExpo__c = subexpo.Id;
        insert IQ1;

        //Create Integration Queue
        EE_Integration_Queue__c IQ2 = new EE_Integration_Queue__c();
        IQ2.Campaign__c = camp.Id;
        IQ2.Contact__c = ct1.Id;
        IQ2.Event__c = event.Id;
        IQ2.Object_Name__c = 'CampaignMember';
        IQ2.Product__c ='VIP Registration';
        IQ2.SubExpo__c = subexpo.Id;
        insert IQ2;

        //Create Integration Queue
        EE_Integration_Queue__c IQ4 = new EE_Integration_Queue__c();
        IQ4.Campaign__c = camp.Id;
        IQ4.Contact__c = ct1.Id;
        IQ4.Event__c = event.Id;
        IQ4.Object_Name__c = 'Task';
        IQ4.Product__c ='VIP Registration';
        IQ4.SubExpo__c = subexpo.Id;
        insert IQ4;

        //Exsisting Records
        //Create Event
        Event__c event1 = new Event__c();
        event1.Name='Test Event2';
        event1.Show__c=show.id;
        event1.Event_Year__c='2020';
        event1.Event_Code__c='1234-01';
        event1.Stage_Date__c=myDate;
        event1.Opportunity_Start_Date__c=myDate;
        event1.Booth_Last_Date__c=newDate;
        event1.Non_Booth_Last_Date__c=newDate;
        insert event1;

        // Create Sub Expo
        SubExpo__c subexpo1 = new SubExpo__c();
        subexpo1.Name = 'Surf';
        subexpo1.SubShow__c=subshow.id;
        subexpo1.Event__c=event1.id;
        insert subexpo1;

        //Create Campaign
		Campaign camp1 = new Campaign();
		camp1.Name = 'Camp1';
		camp1.Short_Description__c = 'Test Camp1';
        camp1.Event__c = event1.id;
        camp1.Product__c ='VIP Registration';
        camp1.RecordTypeId = RecordTypeIdCampaign;
        camp1.Status ='In Progress';
        camp1.Technique__c = 'Call';
        camp.Target_Start_Date__c = myDate;
        camp1.Target_End_Date__c = myDate;
        camp1.Target_num_of_records__c = 20;	
        insert camp1;
        
        // Create Opportunity without subexpo
		Opportunity opp = new Opportunity();
		opp.name = 'Opportunity Test';
		opp.AccountId = account.id;
		opp.CloseDate =  Date.today()+2;
		opp.StageName = 'No Contact Attempted';
		opp.Event__c = event1.id;
        opp.CampaignId = camp1.id;
        opp.Product__c = 'VIP Registration';
        insert opp;

        // Create Opportunity with subexpo
		Opportunity opp1 = new Opportunity();
		opp1.name = 'Opportunity Test';
		opp1.AccountId=account.id;
		opp1.CloseDate =  Date.today()+2;
		opp1.StageName = 'No Contact Attempted';
		opp1.Event__c = event1.id;
        opp1.CampaignId = camp1.id;
        opp1.SubExpo__c = subexpo1.id;
        opp1.Product__c = 'VIP Registration';
        insert opp1;

        // Create Lead without subexpo
        Lead ld = new Lead();
        ld.FirstName = 'Emerald';
        ld.LastName = 'Test';
        ld.Email = 'EmeraldTest@ee.com';
        ld.Event__c = event1.Id;
        ld.EE_Campaign__c = camp1.id;
        ld.Product__c = 'VIP Registration';
        ld.Company = 'Test Account';
        Insert ld;

        // Create Lead with subexpo
        Lead ld1 = new Lead();
        ld1.FirstName = 'Emerald';
        ld1.LastName = 'Test';
        ld1.Email = 'EmeraldTest@ee.com';
        ld1.Event__c = event1.Id;
        ld1.SubExpo__c = subexpo1.Id;
        ld.EE_Campaign__c = camp1.id;
        ld.Product__c = 'VIP Registration';
        ld1.Company = 'Test Account';
        Insert ld1;

        // Create contacts
        Contact ct = new Contact();
        ct.FirstName = 'Emerald1';
        ct.LastName = 'Test1';
        ct.Email = 'EmeraldTest1@ee.com';
        ct.AccountId = account.Id;
        ct.ContactGUID__c = 'TEST-TEST-TEST20';
        insert ct;
         
        //Create CampaignMember
        CampaignMember cm = new CampaignMember();
        cm.CampaignId= camp1.Id;
        cm.ContactId = ct.Id;
        cm.Owner__c = UserInfo.getUserId();
        cm.Status='Follow Up Required';
        insert cm;

        //Create Integration Queue
        EE_Integration_Queue__c IQ5 = new EE_Integration_Queue__c();
        IQ5.Campaign__c = camp1.Id;
        IQ5.Contact__c = ct1.Id;
        IQ5.Event__c = event1.Id;
        IQ5.Object_Name__c = 'lead';
        IQ5.Product__c ='VIP Registration';
        IQ5.SubExpo__c = subexpo1.Id;
        insert IQ5;

        //Create Integration Queue
        EE_Integration_Queue__c IQ6 = new EE_Integration_Queue__c();
        IQ6.Campaign__c = camp1.Id;
        IQ6.Contact__c = ct1.Id;
        IQ6.Event__c = event1.Id;
        IQ6.Object_Name__c = 'Lead';
        IQ6.Product__c ='VIP Registration';
        insert IQ6;

        //Create Integration Queue
        EE_Integration_Queue__c IQ7 = new EE_Integration_Queue__c();
        IQ7.Campaign__c = camp1.Id;
        IQ7.Contact__c = ct1.Id;
        IQ7.Event__c = event1.Id;
        IQ7.Object_Name__c = 'Opportunity';
        IQ7.Product__c ='VIP Registration';
        IQ7.SubExpo__c = subexpo1.Id;
        insert IQ7;
        
        //Create Integration Queue
        EE_Integration_Queue__c IQ8 = new EE_Integration_Queue__c();
        IQ8.Campaign__c = camp1.Id;
        IQ8.Contact__c = ct1.Id;
        IQ8.Event__c = event1.Id;
        IQ8.Object_Name__c = 'Opportunity';
        IQ8.Product__c ='VIP Registration';
        insert IQ8;

        //Create Integration Queue
        EE_Integration_Queue__c IQ9 = new EE_Integration_Queue__c();
        IQ9.Campaign__c = camp1.Id;
        IQ9.Contact__c = ct.Id;
        IQ9.Event__c = event1.Id;
        IQ9.Object_Name__c = 'CampaignMember';
        IQ9.Product__c ='VIP Registration';
        insert IQ9;

        
    }
    static testmethod void test(){        
        Test.startTest();
        
        EE_Job_MCInboundIntegration mcInboundIntegrationtest = new EE_Job_MCInboundIntegration();
        Database.executeBatch(mcInboundIntegrationtest);
        
        Test.stopTest();
    }
}