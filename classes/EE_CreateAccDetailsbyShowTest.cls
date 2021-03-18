@isTest
public class EE_CreateAccDetailsbyShowTest {

    static testmethod void EE_CreateAccDetailsbyShowTest() {
        date myDate = date.today();
        Date newDate = mydate.addDays(2);
        //Account
        Account account = new Account();
        account.Name='Test Account';
        insert account;

        //Account
        Account account1 = new Account();
        account1.Name='Test Account1';
        insert account1; 

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
        
        //create Segment
        Segment__c segment = new Segment__c();
        segment.Name ='Test segment';
        segment.Show__c = show.id;
        segment.Type__c = 'Renewal';
        insert segment;

        //create Segment
        Segment__c segment1 = new Segment__c();
        segment1.Name ='Test segment1';
        segment1.Show__c = show.id;
        segment1.Type__c = 'Renewal';
        insert segment1;

        //Create Account details by Show
        Account_Details_by_Show__c ads = new Account_Details_by_Show__c();
        ads.Account__c =account1.id;
        ads.Show__c = show.id;
        insert ads;

        //Create Account Segment
        Account_Segment__c accseg = new Account_Segment__c();
        accseg.Account__c= account.id;
        accseg.Segment__c= segment.id;

        //Create Account Segment
        Account_Segment__c accseg1 = new Account_Segment__c();
        accseg1.Account__c= account1.id;
        accseg1.Segment__c= segment1.id;


        test.startTest();
        insert accseg;
        insert accseg1;
        test.stopTest();
    }
}