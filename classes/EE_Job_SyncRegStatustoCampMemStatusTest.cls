@isTest
public class EE_Job_SyncRegStatustoCampMemStatusTest {
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

        //Registration
        Registration__c reg = new Registration__c();
        reg.Contact__c =ct1.Id;
        reg.Event__c = event.Id;
        reg.Name = 'Regtest';
        reg.Promo_Code__c = 'TEST1';
        reg.Reg_Status__c = 'Registered';
        reg.ExternalID__c = '1234';
        insert reg;

        //Campaign Member
        CampaignMember cm = new CampaignMember();
        cm.CampaignId= camp.Id;
        cm.ContactId = ct1.Id;
        cm.Owner__c = UserInfo.getUserId();
        cm.Status='Follow Up Required';
        insert cm;
     
    }
    static testmethod void test(){        
        Test.startTest();
        
        EE_Job_SyncRegStatustoCampMemStatus syncregstatustocampmemstatustest = new EE_Job_SyncRegStatustoCampMemStatus();
        Database.executeBatch(syncregstatustocampmemstatustest);
        
        Test.stopTest();
    }
}