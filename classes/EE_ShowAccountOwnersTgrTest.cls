@isTest
public class EE_ShowAccountOwnersTgrTest {
    static testmethod void EE_ShowAccountOwnersTgrTest(){
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

        //Create Sub Show
        SubShow__c subshow = new SubShow__c();
        subshow.Name = 'subshow';
        subshow.Show__c=show.id; 
        insert subshow;
        
        //User
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'stest', 
                        Email='testuser@testorg.com', 
                        EmailEncodingKey='UTF-8', 
                        FirstName='s',
                        LastName='Test',  
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='testuser@testorg.com');
    
       
        AccountOwners__c AO = new AccountOwners__c();
        AO.Account__c = account.Id;
        AO.AccountOwner__c = u.Id;
        AO.Show__c = show.Id;
        AO.SubShow__c = subshow.Id;
        Insert AO;

        AccountOwners__c AO2 = new AccountOwners__c();
        AO2.Account__c = account.Id;
        AO2.AccountOwner__c = u.Id;
        AO2.Show__c = show.Id;
        Insert AO2;

        test.startTest();

        try{
            AccountOwners__c AO1 = new AccountOwners__c();
            AO1.Account__c = account.Id;
            AO1.AccountOwner__c = u.Id;
            AO1.Show__c = show.Id;
            AO1.SubShow__c = subshow.Id;
            Insert AO1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Show Account Owner Record already exists for the selected show and subshow combination')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        try{
            AccountOwners__c AO3 = new AccountOwners__c();
            AO3.Account__c = account.Id;
            AO3.AccountOwner__c = u.Id;
            AO3.Show__c = show.Id;
            Insert AO3;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Show Account Owner Record already exists for the selected show')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();

        
    }
}