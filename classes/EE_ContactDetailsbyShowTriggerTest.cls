@isTest
public class EE_ContactDetailsbyShowTriggerTest {
    static testmethod void EE_ContactDetailsbyShowTriggerTest() {
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

        //Create contact details by Show
        Contact_Details_By_Show__c cds = new Contact_Details_By_Show__c();
        cds.Contact__c = ct1.id;
        cds.Show__c = show.id;
        insert cds;

        
        test.startTest();

        try{
            Contact_Details_By_Show__c cds1 = new Contact_Details_By_Show__c();
            cds1.Contact__c = ct1.id;
            cds1.Show__c = show.id;
            insert cds1;
    
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Contact Details by Show record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        
        test.stopTest();

    }
}