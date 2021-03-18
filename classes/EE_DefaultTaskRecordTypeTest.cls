@isTest
public class EE_DefaultTaskRecordTypeTest {

    static testmethod void defaultTaskRecordType() {

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

        //
        Id attendeeRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();
        Id exhibitorRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Exhibitor').getRecordTypeId();
        
        //Create Campaign
		Campaign camp = new Campaign();
		camp.Name = 'Camp1';
		camp.Short_Description__c='Test Camp1';
        camp.Event__c=event.id;
        camp.Product__c='VIP Registration';
        camp.RecordTypeId = attendeeRecordTypeId;
        camp.Status='In Progress';
        camp.Technique__c= 'Call';
        camp.Target_Start_Date__c=myDate;
        camp.Target_End_Date__c =myDate;
        camp.Target_num_of_records__c = 20;	
        insert camp;
        
        //Create Campaign
		Campaign camp1 = new Campaign();
		camp1.Name = 'Camp2';
		camp1.Short_Description__c='Test Camp2';
        camp1.Event__c=event.id;
        camp1.Product__c='VIP Registration';
        camp1.RecordTypeId = exhibitorRecordTypeId;
        camp1.Status='In Progress';
        camp1.Technique__c= 'Call';
        camp1.Target_Start_Date__c=myDate;
        camp1.Target_End_Date__c =myDate;
        camp1.Target_num_of_records__c = 20;	
        insert camp1;

        //Create Task
        Task task = new Task();
        task.Event__c = event.id;
        task.Campaign__c = camp.id;
        task.WhoId = ct1.id;
        task.Activity_Result__c ='Replied to Email';
        task.Status ='Not Started';
        task.Priority ='Normal';
        task.OwnerId = UserInfo.getUserId();

        test.startTest();
        insert task;

        Task task1 = new Task();
        task1.id = task.id;
        task1.Campaign__c = camp1.id;
        update task1;
        test.stopTest();
    }
}