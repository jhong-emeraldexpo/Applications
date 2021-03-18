@isTest
public class EE_UtilityRelationShipTypeTest{
    static testmethod void EE_UtilityRelationShipTypeTest() {

        date myDate = date.today();
        Date newDate = mydate.addDays(2);
        //Account
        Account account = new Account();
        account.Name='Test Account';
        account.Relationship_Type__c = 'Attendee';
        insert account;

        // Create contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        ct1.ContactGUID__c = 'TEST-TEST-TEST20';
        ct1.Relationship_Type__c = 'Attendee';
        insert ct1;

        test.startTest();
        try{
            Contact con = new Contact();
            con.id = ct1.id;
            con.Title = 'Test';
            Update con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('******** You do not have access to edit Attendee records. ********')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        test.stopTest(); 
    }
}