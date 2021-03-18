@isTest
private class EE_Job_BatchAccountsMergeTest {
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
        account1.Primary_Account_ID__c=account.Id;
        insert account1;

        //Account2
        Account account2 = new Account();
        account2.Name='Account2';
        insert account2;

        //Account3
        Account account3 = new Account();
        account3.Name='Account21';
        account3.Primary_Account_ID__c=account2.Id;
        insert account3;

        //Account4
        Account account4 = new Account();
        account4.Name ='Account3';
        insert account4;

        // Create contacts
        Contact ct1 = new Contact();
        ct1.FirstName = 'Emerald';
        ct1.LastName = 'Test';
        ct1.Email = 'EmeraldTest@ee.com';
        ct1.AccountId = account.Id;
        Insert ct1;   

        Contact ct2 = new Contact();
        ct2.FirstName = 'EE';
        ct2.LastName = 'TEST2';
        ct2.Email = 'EETEST2@ee.com';
        ct2.AccountId = account1.Id;
        Insert ct2;

        Contact ct3 = new Contact();
        ct3.FirstName = 'EE3';
        ct3.LastName = 'TEST3';
        ct3.Email = 'EETEST345@ee1.com';
        ct3.AccountId = account3.Id;
        Insert ct3;


        Contact ct4 = new Contact();
        ct4.FirstName = 'EE4';
        ct4.LastName = 'TEST4';
        ct4.Email = 'EETEST4@ee.com';
        ct4.AccountId = account2.Id;
        Insert ct4;

        Contact ct5 = new Contact();
        ct5.FirstName = 'EE5';
        ct5.LastName = 'TEST5';
        ct5.Email = 'EETEST3456@ee5.com';
        ct5.AccountId = account3.Id;
        Insert ct5;

        Contact ct6 = new Contact();
        ct6.FirstName = 'EE56';
        ct6.LastName = 'TEST56';
        ct6.Phone = '3452343452';
        ct6.Email = '';
        ct6.AccountId = account4.Id;
        Insert ct6;
    }
        
    static testmethod void test() {        
        Test.startTest();
        EE_Job_BatchAccountsMerge accmergetest = new EE_Job_BatchAccountsMerge();
        Id batchIdTEST = Database.executeBatch(accmergetest);
        Test.stopTest();
        List<Account> mergedAccList = [select Id from Account];
        system.assertequals(mergedAccList.size(), 3);
    }

}