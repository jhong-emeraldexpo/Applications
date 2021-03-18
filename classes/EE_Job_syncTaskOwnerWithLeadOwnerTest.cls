@isTest
public class EE_Job_syncTaskOwnerWithLeadOwnerTest {
    @testSetup 
    static void setup() {
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
        event.Event_Year__c='2020';
        event.Event_Code__c='2020-01';
        event.Stage_Date__c=myDate;
        event.Opportunity_Start_Date__c=myDate;
        event.Booth_Last_Date__c=newDate;
        event.Non_Booth_Last_Date__c=newDate;
       
        insert event;
      
        //Create Campaign
        Campaign camp = new Campaign();
        camp.Name = 'Camp1';
        camp.Short_Description__c='P-Test1';
        camp.Event__c=event.id;
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
        system.debug('Inserted new Campaign');

        //create datamigration user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user = new User();
        user.FirstName = 'Data';
        user.LastName = 'Migration';
        user.Alias = 'dmigr';
        user.Email='datamigration@ee.com';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.ProfileId = p.Id;
        user.TimeZoneSidKey='America/Los_Angeles';
        user.UserName='datamigration@ee.com';
        Insert user;


        User user2 = new User();
        user2.FirstName = 'Data';
        user2.LastName = 'user';
        user2.Alias = 'duser';
        user2.Email='duser@ee.com';
        user2.EmailEncodingKey='UTF-8';
        user2.LanguageLocaleKey='en_US';
        user2.LocaleSidKey='en_US';
        user2.ProfileId = p.Id;
        user2.TimeZoneSidKey='America/Los_Angeles';
        user2.UserName='duser@ee.com';
        Insert user2;

         //Create Lead
        Lead ld1 = new Lead();
        ld1.FirstName = 'EE3';
        ld1.LastName = 'TEST3';
        ld1.Email = 'Etest@e.com';
        ld1.Phone = '3452343452';
        ld1.Event__c = event.Id;
        ld1.LeadSource ='Inquiry Form';
        ld1.Company = 'Account3';
        //ld1.OwnerId =user2.Id;
        ld1.Status = 'Active';
        Insert ld1;

        //Create Task
        Task task = new Task();
        task.OwnerId = user.Id;
        task.WhoId = ld1.Id;
       // task.Subject ='P|2020-01|P-Test1';
        task.Status ='Not Started';
        Insert task;
        system.debug(task);

       
    }
    static testmethod void test(){        
        Test.startTest();
        
        EE_Job_syncTaskOwnerWithLeadOwner synctaskownerwithleadownertest = new EE_Job_syncTaskOwnerWithLeadOwner();
        Id batchIdTEST = Database.executeBatch(synctaskownerwithleadownertest);
        
        Test.stopTest();
    }
}