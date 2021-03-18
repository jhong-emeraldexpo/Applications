@isTest
public class EE_AccountSegmentsTgrTest {
    static testMethod void EE_AccountSegmentsTgrTest() {
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

        //Create contact segment
        Segment__c segment = new Segment__c();
        segment.Name ='Test segment1';
        segment.Show__c = show.id;
        segment.Type__c = 'Renewal';
        insert segment;

        //Create contact segment
        Segment__c segment1 = new Segment__c();
        segment1.Name ='Testsegment';
        segment1.Show__c = show.id;
        segment1.Type__c = 'Renewal';
        insert segment1;

        //Create Account Segment
        Account_Segment__c accseg = new Account_Segment__c();
        accseg.Account__c= account.id;
        accseg.Segment__c= segment.id;
        insert accseg;
        
        test.startTest();

        try{
            //Create Account Segment
            Account_Segment__c accseg1 = new Account_Segment__c();
            accseg1.Account__c= account.id;
            accseg1.Segment__c= segment.id;
            insert accseg1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Account Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try{
            //Update Account Segment
            Account_Segment__c accseg2 = new Account_Segment__c();
            accseg2.Id= accseg.Id;
            accseg2.Segment__c= segment1.id;
            Update accseg2;
        }
        catch(Exception e1){
            Boolean expectedExceptionThrown =  e1.getMessage().contains('Account Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();
    
    }
}