@isTest
public class EE_Job_UpdatePromoCodeTest {
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

        //Create CampaignMember
        CampaignMember cm = new CampaignMember();
        cm.CampaignId= camp.Id;
        cm.ContactId = ct1.Id;
        cm.Owner__c = UserInfo.getUserId();
        cm.Status='Follow Up Required';
        insert cm; 

        // Create Opportunity without subexpo
        Opportunity opp = new Opportunity();
        opp.name = 'Opportunity Test';
        opp.AccountId = account.id;
        opp.CloseDate =  Date.today()+2;
        opp.StageName = 'No Contact Attempted';
        opp.Event__c = event.id;
        opp.CampaignId = camp.id;
        opp.Product__c = 'VIP Registration';
        opp.OwnerId = UserInfo.getUserId();
        insert opp;

        //Create OportunityContactRole
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = ct1.Id;
        ocr.Role = 'Attendee Contact';
        insert ocr;

        //Create PromoCodebyEvent
        PromoCode_by_Event__c pce = new PromoCode_by_Event__c();
        pce.Event__c = event.Id;
        pce.Promo_Code__c = 'TestUPC';
        pce.User__c =  UserInfo.getUserId();
        insert pce;

        //Duplicate promocode Records
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

        //Create CampaignMember
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId= camp1.Id;
        cm1.ContactId = ct1.Id;
        cm1.Owner__c = UserInfo.getUserId();
        cm1.Status='Follow Up Required';
        insert cm1; 

        // Create Opportunity with subexpo
        Opportunity opp1 = new Opportunity();
        opp1.name = 'Opportunity Test';
        opp1.AccountId=account.id;
        opp1.CloseDate =  Date.today()+2;
        opp1.StageName = 'No Contact Attempted';
        opp1.Event__c = event1.id;
        opp1.CampaignId = camp1.id;
        opp1.OwnerId = UserInfo.getUserId();
        opp1.Product__c = 'VIP Registration';
        insert opp1;

        //Create OportunityContactRole
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = opp1.Id;
        ocr1.ContactId = ct1.Id;
        ocr1.Role = 'Attendee Contact';
        insert ocr1;
 
        //Create PromoCodebyEvent
        PromoCode_by_Event__c pce1 = new PromoCode_by_Event__c();
        pce1.Event__c = event1.Id;
        pce1.Promo_Code__c = 'TestUPC';
        pce1.User__c =  UserInfo.getUserId();
        insert pce1;

        //Create PromoCodebyEvent
        PromoCode_by_Event__c pce2 = new PromoCode_by_Event__c();
        pce2.Event__c = event1.Id;
        pce2.Promo_Code__c = 'TestUPC';
        pce2.User__c =  UserInfo.getUserId();
        insert pce2;
       
    }
    static testmethod void test(){        
        Test.startTest();
        
        EE_Job_UpdatePromoCode updatepromocodetest = new EE_Job_UpdatePromoCode();
        Database.executeBatch(updatepromocodetest);
        updatepromocodetest.alertEmeraldSFDCSupportTeam('CampaignMember','Update', 'Test Message');
        
        Test.stopTest();
    }
}