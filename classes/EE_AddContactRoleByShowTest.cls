@isTest
public class EE_AddContactRoleByShowTest {
    static testmethod void EE_AddContactRoleByShowTest() {
        date myDate = date.today();
        Date newDate = mydate.addDays(2);

        Territory_Rule__c trOne = new Territory_Rule__c();
        trOne.Key1__c='Test Show 1';
        trOne.Key2__c='Test subshow';
        trOne.OpportunityOwner__c=UserInfo.getUserId();
        trOne.Rule_Set__c='ASD_SB';
        trOne.Territory_Rule_ID__c='ISS - Mallett';
        trOne.Territory_Rule_Type__c='SubShow'; 
        insert trOne;

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
        camp.Product__c='Sponsorship';
        //camp.segment_type__c = 'Lost';
        Database.SaveResult campsr = Database.insert(Camp, true);
        System.assert(campsr.isSuccess());
        system.debug('Inserted new Campaign');

         //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        // Create contact
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1; 


        test.startTest();

        // create show account contacts
        Show_Account_Contact__c sac = new Show_Account_Contact__c();
        List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Marketing Contact', 'Sales Contact','Contract Contact (Secondary)', 'Sponsorship contact'};
        sac.Account__c=account.id;
        sac.Contact__c=ct1.Id; 
        sac.Show__c= show.id;
        sac.ContactRoles__c='Sales Contact';
        insert sac;

         // Create Opportunity
        Opportunity op1 = new Opportunity();
        op1.name = 'Opportunity Contact Insertion Test';
        op1.AccountId= account.id;
        op1.CloseDate =  Date.today()+2;
        op1.StageName = 'No Contact Attempted';
        op1.product__c = 'Sponsorship';
        op1.Amount=1.00;
        op1.Event__c=event.id;
        op1.CampaignId=camp.id;
        op1.Create_Task__c = True;
        op1.OwnerID = UserInfo.getUserId();
        insert op1;
        
         //Create OpportunityContactRoles
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId =sac.Contact__c;
        ocr.OpportunityId =op1.id;
        ocr.Role =sac.ContactRoles__c; 
        insert ocr; 
       
        test.stopTest();

    }
}