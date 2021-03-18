@isTest
public class EE_UpdateStatusonCampaignMemberTest{
    static testmethod void EE_UpdateStatusonCampaignMemberTest() {

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
        insert camp;		

        //Campaign Member
        CampaignMember cm = new CampaignMember();
        cm.CampaignId= camp.Id;
        cm.ContactId = ct1.Id;
        cm.Owner__c = UserInfo.getUserId();
        cm.Status='Follow Up Required ';
        insert cm;

        //Create CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst = new CampaignMemberStatusTemplate__c();
        cmst.ActivityResult__c = 'Replied to Email';
        cmst.Label__c = 'Test1';
        cmst.Name = 'Test1';
        cmst.Product__c = 'VIP Registration';
        cmst.SortOrder__c = 4;
        insert cmst;

        //Create CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst2 = new CampaignMemberStatusTemplate__c();
        cmst2.ActivityResult__c = 'Replied to Email';
        cmst2.Label__c = 'Test2';
        cmst2.Name = 'Test2';
        cmst2.Product__c = 'VIP Registration';
        cmst2.SortOrder__c = 5;
        insert cmst2;

        //Create CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst3 = new CampaignMemberStatusTemplate__c();
        cmst3.ActivityResult__c = 'Replied to Email';
        cmst3.Label__c = 'Test3';
        cmst3.Name = 'Test3';
        cmst3.Product__c = 'VIP Registration';
        cmst3.SortOrder__c = 6;
        insert cmst3;

        //Create CampaignMemberStatusTemplate
        CampaignMemberStatusTemplate__c cmst1 = new CampaignMemberStatusTemplate__c();
        cmst1.ActivityResult__c = 'No answer';
        cmst1.Label__c = 'No Answer';
        cmst1.Name = 'No Answer';
        cmst1.Product__c = 'VIP Registration';
        cmst1.SortOrder__c = 3;
        insert cmst1;

        //Create Activity Result Mapping
        Activity_Result_Mapping__c arm = new Activity_Result_Mapping__c();
        arm.Activity_Result__c ='Replied to Email';
        arm.Campaign_Member_Status_Template__c	= cmst.id;
        arm.Product__c ='VIP Registration';
        arm.Exclude_Statuses__c = 'Registered, Commitment Made, Follow Up Required, Not Interested';
        insert arm;

        //Create Activity Result Mapping
        Activity_Result_Mapping__c arm2 = new Activity_Result_Mapping__c();
        arm2.Activity_Result__c ='Replied to Email';
        arm2.Campaign_Member_Status_Template__c	= cmst2.id;
        arm2.Product__c ='VIP Registration';
        arm2.Exclude_Statuses__c = 'Registered, Commitment Made, Follow Up Required, Not Interested';
        insert arm2;

        //Create Activity Result Mapping
        Activity_Result_Mapping__c arm3 = new Activity_Result_Mapping__c();
        arm3.Activity_Result__c ='Replied to Email';
        arm3.Campaign_Member_Status_Template__c	= cmst3.id;
        arm3.Product__c ='VIP Registration';
        arm3.Exclude_Statuses__c = 'Registered, Commitment Made, Follow Up Required, Not Interested';
        insert arm3;

        //Create Activity Result Mapping
        Activity_Result_Mapping__c arm1 = new Activity_Result_Mapping__c();
        arm1.Activity_Result__c ='No answer';
        arm1.Campaign_Member_Status_Template__c	= cmst1.id;
        arm1.Product__c ='VIP Registration';
        arm1.Exclude_Statuses__c = 'Registered, Commitment Made, Follow Up Required, Not Interested';
        insert arm1;

        // Create Task
        Task task = new Task();
        task.Event__c = event.id;
        task.Campaign__c = camp.id;
        task.WhoId = ct1.id;
        task.Activity_Result__c ='Replied to Email';
        task.Status ='Not Started';
        task.Priority ='Normal';
        task.OwnerId = UserInfo.getUserId();

        // Create Task
        Task task1 = new Task();
        task1.Event__c = event.id;
        task1.Campaign__c = camp.id;
        task1.WhoId = ct1.id;
        task1.Activity_Result__c ='Replied to Email';
        task1.Status ='Not Started';
        task1.Priority ='Normal';
        task1.OwnerId = UserInfo.getUserId();

        // Create Task
        Task task3 = new Task();
        task3.Event__c = event.id;
        task3.Campaign__c = camp.id;
        task3.WhoId = ct1.id;
        task3.Activity_Result__c ='Replied to Email';
        task3.Status ='Not Started';
        task3.Priority ='Normal';
        task3.OwnerId = UserInfo.getUserId();

        // Create Task
        Task task2 = new Task();
        task2.Event__c = event.id;
        task2.Campaign__c = camp.id;
        task2.WhoId = ct1.id;
        task2.Activity_Result__c ='No answer';
        task2.Status ='Not Started';
        task2.Priority ='Normal';
        task2.OwnerId = UserInfo.getUserId();

        test.startTest();
        insert task;
        insert task1;
        insert task3;
        insert task2;
        test.stopTest(); 
    }
}