@isTest
public class EE_AddCampaignMemberStatusTgrHandlerTest{
    static testmethod void EE_AddCampaignMemberStatusTgrHandlerTest() {

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
		event.Event_Year__c='2019';
		event.Event_Code__c='2019-01';
		event.Stage_Date__c=myDate;
		event.Opportunity_Start_Date__c=myDate;
		event.Booth_Last_Date__c=newDate;
        event.Non_Booth_Last_Date__c=newDate;
        event.Registration_Event_Code__c ='ASD20';
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

        //CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst = new CampaignMemberStatusTemplate__c();
        cmst.Label__c= 'Test1';
        cmst.HasResponded__c = False;
        cmst.SortOrder__c = 3; 
        cmst.IsDefault__c = True;
        cmst.Product__c = 'VIP Registration';
        insert cmst;

        //CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst1 = new CampaignMemberStatusTemplate__c();
        cmst1.Label__c= 'Test2';
        cmst1.HasResponded__c = True;
        cmst1.SortOrder__c = 4; 
        cmst1.IsDefault__c = False;
        cmst1.Product__c = 'VIP Registration';
        insert cmst1;

        test.startTest();
        insert camp;	
        test.stopTest(); 
    }
}