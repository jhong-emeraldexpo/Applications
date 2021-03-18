public class EE_Job_BatchAccountsMerge implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([select Id, Primary_Account_ID__c from Account where Primary_Account_ID__c != '' limit 50]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        
        Map<Id,Account> AccountMap = new Map<Id,Account>();
        Map<Id,Account> ParentAccountMap = new Map<Id,Account>();
        Set<Id> ParentAccountIds = new Set<Id>();
        for(sobject s : scope) {
            Account Acc = new Account();
            Acc = (Account)s;
            AccountMap.put(acc.Id, Acc);
            ParentAccountIds.add(acc.Primary_Account_ID__c);
        }
        if(ParentAccountIds.size() > 0){
            for(Account pAcc: [Select Id, Name from Account where Id IN: ParentAccountIds and Primary_Account_ID__c = '']){
                ParentAccountMap.put(pAcc.id,pAcc);
            }
        }

        if(ParentAccountMap.size() >0){
            for(Account c: AccountMap.values()) {
                try {
                    if(ParentAccountMap.containsKey(c.Primary_Account_ID__c)){
                        Database.Merge(ParentAccountMap.get(c.Primary_Account_ID__c) , c.ID);
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
            EE_Job_BatchAccountsMerge b = new EE_Job_BatchAccountsMerge (); 
            System.scheduleBatch(b, 'EE_Job_BatchAccountsMerge'+System.now(), 02, 10);
        }
    }
}