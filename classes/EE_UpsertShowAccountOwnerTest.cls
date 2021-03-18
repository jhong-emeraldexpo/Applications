@isTest
public class EE_UpsertShowAccountOwnerTest {
    static testmethod void EE_UpsertShowAccountOwnerTest() {

        
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

        //Create Sub Show
        SubShow__c subshow = new SubShow__c();
        subshow.Name = ' Test subshow';
        subshow.Show__c=show.id; 
       
        insert subshow;
       
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
        
        // Create Sub Expo
        SubExpo__c subexpo = new SubExpo__c();
        subexpo.Name = 'Test SubExpo';
        subexpo.SubShow__c=subshow.id;
        subexpo.Event__c=event.id;
        insert subexpo;

        
        
        //Create Campaign
        Campaign camp = new Campaign();
        camp.Name = 'Camp1';
        camp.Short_Description__c='Short Description';
        camp.Event__c=event.id;
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
        
        //Create Lead
        Lead ld1= new Lead();
        ld1.FirstName = 'EE31';
        ld1.LastName = 'TEST31';
        ld1.Email = 'EETEST3451@ee11.com';
        ld1.Company = 'US Account31';
        ld1.OwnerId=UserInfo.getUserId();
        ld1.Event__c = event.id;
        ld1.LeadSource ='Booth Application';
        ld1.Product__c='Booth';
        ld1.CountryCode = 'US';
        insert ld1;

        // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Test';
        op1.AccountId=account.id;
        op1.CloseDate =  Date.today()+2;
        op1.StageName = 'No Contact Attempted';
        op1.Event__c = event.id;
        op1.CampaignId = camp.id;
        insert op1;

        // Create Opportunity
        Opportunity op2 = new Opportunity();
        op2.name = 'Opportunity Test';
        op2.AccountId=account.id;
        op2.CloseDate =  Date.today()+2;
        op2.StageName = 'No Contact Attempted';
        op2.Event__c = event.id;
        op2.CampaignId = camp.id;
        insert op2;

        //Account
        Account account1 = new Account();
        account1.Name='Test Account1';
        insert account1;

        //User
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'stest', 
                        Email='testuser@testorg.com', 
                        EmailEncodingKey='UTF-8', 
                        FirstName='s',
                        LastName='Test',  
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testuser@testorg.com');

        //Create Show 
        Show__c show1 = new Show__c();
        show1.Name='Test Show1';
        show1.Brand__c='TBrand1';
        show1.Market__c='TMarket1';
        show1.Rule_Set__c='ASD_SB1';
        show1.Segment__c='TSegment1';
        show1.Show_Code__c='TShowCode1';      
        show1.Show_Group__c='ShowGroup1';
        show1.ShowID__c=1245;
        insert show1;
        
        
        //Account Owners
        AccountOwners__c accOwner1 = new AccountOwners__c();
        accOwner1.Account__c=account.id;
        accOwner1.AccountOwner__c= u.id;
        accOwner1.Show__c=show1.id;
        //accOwner1.SubShow__c=subshow.id;
        insert accOwner1;
        

        //Create Sub Show
        SubShow__c subshow1 = new SubShow__c();
        subshow1.Name = ' Test subshow1';
        subshow1.Show__c=show1.id;   
        insert subshow1;

        //Account Owners
        AccountOwners__c accOwner2 = new AccountOwners__c();
        accOwner2.Account__c=account.id;
        accOwner2.AccountOwner__c= u.id;
        accOwner2.Show__c=show1.id;
        accOwner2.SubShow__c=subshow1.id;
        insert accOwner2;
        

        
       
       //Create Event
        Event__c event1 = new Event__c();
        event1.Name='Test Event1';
        event1.Show__c=show1.id;
        event1.Event_Year__c='2020';
        event1.Event_Code__c='2020-01';
        event1.Stage_Date__c=myDate;
        event1.Opportunity_Start_Date__c=myDate;
        event1.Booth_Last_Date__c=newDate;
        event1.Non_Booth_Last_Date__c=newDate;
        insert event1;
        
        // Create Sub Expo
        SubExpo__c subexpo1 = new SubExpo__c();
        subexpo1.Name = 'Test SubExpo1';
        subexpo1.SubShow__c=subshow1.id;
        subexpo1.Event__c=event1.id;
        insert subexpo1;

        
        
        //Create Campaign
        Campaign camp1 = new Campaign();
        camp1.Name = 'Camp11';
        camp1.Short_Description__c='Short Description1';
        camp1.Event__c=event1.id;
        Database.SaveResult campsr1 = Database.insert(Camp1, true);
        System.assert(campsr1.isSuccess());

        // Create Opportunity
        Opportunity op3 = new Opportunity();
        op3.name = 'Opportunity Test1';
        op3.AccountId = account1.id;
        op3.CloseDate =  Date.today()+2;
        op3.StageName = 'No Contact Attempted';
        op3.Event__c = event1.id;
        op3.CampaignId = camp1.id;
        op3.OwnerId = UserInfo.getUserId();
        insert op3;

        // Create Opportunity
        Opportunity op4 = new Opportunity();
        op4.name = 'Opportunity Test1';
        op4.AccountId = account1.id;
        op4.CloseDate =  Date.today()+2;
        op4.StageName = 'No Contact Attempted';
        op4.Event__c = event1.id;
        op4.CampaignId = camp1.id;
        op4.OwnerId = UserInfo.getUserId();
        insert op4;

        test.startTest();
 
        Opportunity updOpp = new Opportunity();
        updOpp.id = op1.id;
        updOpp.Lead_Id__c =ld1.id;
        update updOpp; 

        Opportunity updOpp1 = new Opportunity();
        updOpp1.id = op2.id;
        updOpp1.SubExpo__c = subexpo.id;
        updOpp1.Lead_Id__c =ld1.id;
        update updOpp1;

        Opportunity updOpp3 = new Opportunity();
        updOpp3.id = op3.id;
        updOpp3.Lead_Id__c =ld1.id;
        update updOpp3;

        Opportunity updOpp2 = new Opportunity();
        updOpp2.id = op4.id;
        updOpp2.SubExpo__c = subexpo1.id;
        updOpp2.Lead_Id__c =ld1.id;
        update updOpp2;

        test.stopTest();
    }
}