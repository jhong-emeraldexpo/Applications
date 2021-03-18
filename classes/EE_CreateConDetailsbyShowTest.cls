@isTest
public class EE_CreateConDetailsbyShowTest {

    static testmethod void EE_CreateConDetailsbyShowTest() {
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

        // Create contacts
        Contact ct2 = new Contact();
        ct2.FirstName = 'Emerald';
        ct2.LastName = 'Test';
        ct2.Email = 'EmeraldTest@ee.com';
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
        
        //create Segment
        Segment__c segment = new Segment__c();
        segment.Name ='Test segment';
        segment.Show__c = show.id;
        segment.Type__c = 'Renewal';
        insert segment;

        //create Segment
        Segment__c segment1 = new Segment__c();
        segment1.Name ='Test segment1';
        segment1.Show__c = show.id;
        segment1.Type__c = 'Renewal';
        insert segment1;

        //Create contact details by Show
        Contact_Details_By_Show__c cds = new Contact_Details_By_Show__c();
        cds.Contact__c = ct1.id;
        cds.Show__c = show.id;
        insert cds;

        //Create contact Segment
        Contact_Segment__c conseg = new Contact_Segment__c();
        conseg.Contact__c= ct1.id;
        conseg.Segment__c= segment.id;

        //Create contact Segment
        Contact_Segment__c conseg1 = new Contact_Segment__c();
        conseg1.Contact__c= ct2.id;
        conseg1.Segment__c= segment1.id;


        test.startTest();
        insert conseg;
        insert conseg1;
        test.stopTest();
    }
}