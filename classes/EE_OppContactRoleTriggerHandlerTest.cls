@isTest
public with sharing class EE_OppContactRoleTriggerHandlerTest {
    @isTest
    static Void EE_OppContactRoleTriggerHandlerTest() {
        date myDate = date.today();
        Date newDate = mydate.addDays(2);

        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        // Create two contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1;   

        Contact ct2 = new Contact();
        ct2.FirstName = 'Emerald2';
        ct2.LastName = 'Test2';
        ct2.Email = 'EmeraldTest2@ee.com';
        ct2.AccountId = account.Id;
        Insert ct2;   
        

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
      
        //Create Campaign
        Campaign camp = new Campaign();
        camp.Name = 'Camp1';
        camp.Short_Description__c='P-Test3';
        camp.Event__c=event.id;
        //camp.segment_type__c = 'Lost';
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
        system.debug('Inserted new Campaign');

        // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Contact Insertion Test';
        op1.AccountId=account.id;
        op1.CloseDate =  Date.today()+2;
        op1.StageName = 'Prospecting';
        op1.contact__c= ct1.Id ;
        op1.Amount=1.00;
        op1.Event__c=event.id;
        op1.CampaignId=camp.id;
        op1.Create_Task__c = True;
        op1.OwnerID = UserInfo.getUserId();
        insert op1;

        // create OpportunityContactRole
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId=op1.id;
        ocr.ContactId=ct1.Id; 
        ocr.Role='Sales Contact';
        insert ocr;

        // create OpportunityContactRole
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId=op1.id;
        ocr1.ContactId=ct2.Id; 
        ocr1.Role='Sponsorship Contact';
        insert ocr1;


        test.startTest();
                      
            OpportunityContactRole ocr2 = new OpportunityContactRole();
            ocr2.Id = ocr.id;
            ocr2.ContactId=ct2.Id; 
            ocr2.Role='Contract Contact';
            update ocr2;

            OpportunityContactRole ocr3 = new OpportunityContactRole();
            ocr3.Id = ocr1.id;
            ocr3.ContactId=ct1.Id; 
            update ocr3;

            OpportunityContactRole ocr4 = new OpportunityContactRole();
            ocr4.Id = ocr1.id;
            ocr4.ContactId=ocr1.ContactId; 
            ocr4.Role='Marketing Contact'; 
            update ocr4;
            
                      
            
        test.stopTest();

    }
    
}