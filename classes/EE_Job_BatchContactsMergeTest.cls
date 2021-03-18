@isTest
private class EE_Job_BatchContactsMergeTest {
    @testSetup 
    static void setup() {

        date myDate = date.today();
        Date newDate = mydate.addDays(2);

        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        //Account1
        Account account1 = new Account();
        account1.Name='Test Account1';
        insert account1;

        // Create contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1;  

        Contact ct2 = new Contact();
        ct2.FirstName = 'Emerald1';
        ct2.LastName = 'Test1';
        ct2.Email = 'EmeraldTest1@ee.com';
        ct2.AccountId = account.Id;
        ct2.Primary_Contact_ID__c = ct1.Id;
        Insert ct2;

        Contact ct3 = new Contact();
        ct3.FirstName = 'EE3';
        ct3.LastName = 'TEST3';
        ct3.Email = 'EETEST345@ee1.com';
        ct3.AccountId = account1.Id;
        Insert ct3;


        Contact ct4 = new Contact();
        ct4.FirstName = 'EE31';
        ct4.LastName = 'TEST31';
        ct4.Email = 'EETEST345@ee.com';
        ct4.AccountId = account1.Id;
        ct4.Primary_Contact_ID__c = ct3.Id;
        Insert ct4;

        Contact ct5 = new Contact();
        ct5.FirstName = 'EE32';
        ct5.LastName = 'TEST32';
        ct5.Email = 'EETEST345@ee.com';
        ct5.AccountId = account1.Id;
        ct5.Primary_Contact_ID__c = ct3.Id;
        Insert ct5;

    }
        
    static testmethod void test() {        
        Test.startTest();
        EE_Job_BatchContactsMerge conmergetest = new EE_Job_BatchContactsMerge();
        Id batchIdTEST = Database.executeBatch(conmergetest);

        Test.stopTest();
        List<Contact> mergedConList = [select Id from Contact];
        system.assertequals(mergedConList.size(), 2);
    }

}