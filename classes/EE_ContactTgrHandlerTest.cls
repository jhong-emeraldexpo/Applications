@isTest
public with sharing class EE_ContactTgrHandlerTest {
    
    @isTest
    static void EE_ContactTgrHandlerTest() {
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
        ct2.Hygiene_Status__c= 'Undeliverable';
        ct2.EmailBouncedReason ='test';
        Insert ct2;  

        List<Contact> ConList = new List<Contact>();
        contact tempcon1 =new contact();
        tempcon1.Id = ct1.Id;
        tempcon1.a2z_Contact_ID__c='12345';
        tempcon1.Email='con1ee123@test.com';
        ConList.add(tempcon1);

        contact tempcon2 =new contact();
        tempcon2.Id = ct2.Id;
        tempcon2.Email='con2ee123@test.com';
        ConList.add(tempcon2);
    
        
        test.startTest();
        update ConList;
        test.stopTest();


    }
}