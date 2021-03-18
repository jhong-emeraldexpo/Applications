public with sharing class OptyShowAccountContactsController 
{
    //Global Variables
    /* public List<Show_Account_Contact__c> showAccountContacts {get;set;}
    Opportunity opportunities {get;set;}    
    private String opId;  */
    
    //Constructor for standard page
    public OptyShowAccountContactsController(ApexPages.StandardController controller) 
    {      
        //opId = controller.getId();
        //doQuery();
    }
    /*
    //methods for getting list of showAccountContacts
    public void doQuery()
    {
        
        opportunities = [SELECT ID, Name, AccountId,Event__r.Show__r.Name FROM Opportunity where ID = :opId and Event__c <> null];        
        showAccountContacts = [SELECT ID, Name, Contact__r.Name, Contact__r.email, Contact__r.phone,Contact__r.Phone_Ext__c, Account__c,ContactRoles__c,        
                               Contact__c, Show__r.Name FROM Show_Account_Contact__c                   
                               where Account__c = :opportunities.AccountId   and (Show__r.Name = :opportunities.Event__r.Show__r.Name OR Show__r.Name =null)  order by Contact__r.Name              
                    LIMIT 100];
                /*    
                    if(showAccountContacts.size() <= 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.ERROR, 'There are no Show Account Contacts for this Account.'));
                    }
                    
    }   
    
     */

}