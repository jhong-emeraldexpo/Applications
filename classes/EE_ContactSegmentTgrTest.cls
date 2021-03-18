@isTest
public class EE_ContactSegmentTgrTest {
    static testmethod void EE_ContactSegmentTgrTest() {
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

        //Create contact segment
        Segment__c segment = new Segment__c();
        segment.Name ='Test segment1';
        segment.Show__c = show.id;
        segment.Type__c = 'Renewal';
        insert segment;

        //Create contact segment
        Segment__c segment1 = new Segment__c();
        segment1.Name ='Test segment';
        segment1.Show__c = show.id;
        segment1.Type__c = 'Renewal';
        insert segment1;

        //Create contact Segment
        Contact_Segment__c conseg = new Contact_Segment__c();
        conseg.Contact__c= ct1.id;
        conseg.Segment__c= segment.id;
        insert conseg;

        test.startTest();

        try{
            //Create contact Segment
            Contact_Segment__c conseg1 = new Contact_Segment__c();
            conseg1.Contact__c= ct1.id;
            conseg1.Segment__c= segment.id;
            insert conseg1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Contact Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try{
            //Update contact Segment
            Contact_Segment__c conseg2 = new Contact_Segment__c();
            conseg2.Id = conseg.id;
            conseg2.Segment__c = segment1.id;
            Update conseg2;
        }
        catch(Exception e1){
            Boolean expectedExceptionThrown =  e1.getMessage().contains('Contact Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
             
    }
}