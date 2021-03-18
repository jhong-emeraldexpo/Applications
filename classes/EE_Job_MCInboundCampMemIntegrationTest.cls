@isTest
public class EE_Job_MCInboundCampMemIntegrationTest{
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
        IQ.Object_Name__c = 'CampaignMember';
        IQ.Product__c ='VIP Registration';
        IQ.SubExpo__c = subexpo.Id;
        insert IQ;


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
        EE_Integration_Queue__c IQ1 = new EE_Integration_Queue__c();
        IQ1.Campaign__c = camp1.Id;
        IQ1.Contact__c = ct.Id;
        IQ1.Event__c = event1.Id;
        IQ1.Object_Name__c = 'CampaignMember';
        IQ1.Product__c ='VIP Registration';
        insert IQ1;

        
    }
    static testmethod void test(){        
        Test.startTest();
        
        EE_Job_MCInboundCampMemIntegration mcInboundCampMemIntegrationtest = new EE_Job_MCInboundCampMemIntegration();
        Database.executeBatch(mcInboundCampMemIntegrationtest);
        mcInboundCampMemIntegrationtest.alertEmeraldSFDCSupportTeam('CampaignMember','Insert', 'Test Message');
        
        Test.stopTest();
    }
}