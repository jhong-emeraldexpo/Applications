@isTest
public class EE_AccountDetailsbyShowTriggerTest {
    static testmethod void EE_AccountDetailsbyShowTriggerTest() {
        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;
        
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

        //Create Account Details by Show
        Account_Details_by_Show__c ads = new Account_Details_by_Show__c();
        ads.Account__c =account.id;
        ads.Show__c = show.id;
        insert ads;
        
        test.startTest();

        try{
            Account_Details_by_Show__c ads1 = new Account_Details_by_Show__c();
            ads1.Account__c =account.id;
            ads1.Show__c = show.id;
            insert ads1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Account Details by Show Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        
        test.stopTest();

    }
}