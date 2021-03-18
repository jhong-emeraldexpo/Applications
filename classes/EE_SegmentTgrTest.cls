@isTest
public class EE_SegmentTgrTest {
    static testmethod void EE_SegmentTgrTest() {
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

        Segment__c segment = new Segment__c();
        segment.Name ='Test segment';
        segment.Show__c = show.id;
        segment.SubShow__c = subshow.id;
        segment.Type__c = 'Renewal';
        insert segment;

        Segment__c segment2 = new Segment__c();
        segment2.Name ='Test segment1';
        segment2.Show__c = show.id;
        segment2.Type__c = 'Renewal';
        insert segment2;

        test.startTest();

        try{
            Segment__c segment1 = new Segment__c();
            segment1.Name ='Test segment';
            segment1.Show__c = show.id;
            segment1.SubShow__c = subshow.id;
            segment1.Type__c = 'Renewal';
            insert segment1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try{
            Segment__c segment3 = new Segment__c();
            segment3.Name ='Test segment1';
            segment3.Show__c = show.id;
            segment3.Type__c = 'Renewal';
            insert segment3;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Segment Record already exists')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.stopTest();

    }
}