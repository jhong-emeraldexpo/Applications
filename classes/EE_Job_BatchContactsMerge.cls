public class EE_Job_BatchContactsMerge implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([select Id, Primary_Contact_ID__c from Contact where Primary_Contact_ID__c != '' limit 50]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope) {
		
		Map<Id,Contact> ContactMap = new Map<Id,Contact>();
        Map<Id,Contact> ParentContactMap = new Map<Id,Contact>();
        Set<Id> ParentContactIds = new Set<Id>();
		for(sobject s : scope) {
            Contact Con = new Contact();
            Con = (Contact)s;
            ContactMap.put(con.Id, Con);
            ParentContactIds.add(con.Primary_Contact_ID__c);
        }
        if(ParentContactIds.size() > 0){
            for(Contact pCon: [Select Id, FirstName, LastName from Contact where Id IN: ParentContactIds and Primary_Contact_ID__c = '']){
                ParentContactMap.put(pCon.Id,pCon);
            }
        }

        if(ParentContactMap.size() >0){
            for(Contact c: ContactMap.values()) {
                try {
                    if(ParentContactMap.containsKey(c.Primary_Contact_ID__c)){
                        Database.Merge(ParentContactMap.get(c.Primary_Contact_ID__c) , c.ID);
                        System.debug('Entered and Merged');
                    }
                } catch(exception e) {
                
                }
            }
        }
    }
    public void finish(Database.BatchableContext context) {
        if(!Test.IsRunningTest()){
		    //Schedule the next run for every 2 min's time
            EE_Job_BatchContactsMerge b = new EE_Job_BatchContactsMerge (); 
            System.scheduleBatch(b, 'EE_Job_BatchContactsMerge'+System.now(), 02, 50);
        }
    }
}