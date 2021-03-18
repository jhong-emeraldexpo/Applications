/**
* @author Spoorthy Teegala
* @date January 24 2020
* @group Task
* @description Batch job runs every 1 hour to check if the task ownerid is in sync with the associated lead owner id
*/
/**
* @Update by Tom
* @date May 25 2020
* @Add email notification
* @Stop Group Leads from being reassigned.
*/
public class EE_Job_syncTaskOwnerWithLeadOwner implements Database.Batchable<sObject> {
    private string query;

    public EE_Job_syncTaskOwnerWithLeadOwner() {
        query= 'SELECT Id, WhoId, OwnerId, Owner.Name, Status FROM Task WHERE Status = \'Not Started\' and Owner.Name = \'Data Migration\' ';
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        map<Id,Task> taskMap = new map<Id,Task>();
        List<Task> taskOwnerUpdateList = new List<Task>();
	
		List<Id> newOwnerIds = new List<Id>();
    
        for (Task task: (list<Task>)scope) {
            taskMap.put(task.WhoId, task);
        }
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>([Select Id, Name, OwnerId, Owner.name, Status from Lead where Status = 'Active' and Id IN: taskMap.keyset()]);
        
        // Find all tasks that need to be updated
        for (Lead l : leadMap.values()) {
            for(ID taskId: taskMap.keyset()){
                if (l.Id == taskMap.get(taskId).WhoId && l.Status == 'Active' && taskMap.get(taskId).OwnerId != l.OwnerId && !String.valueOf(l.OwnerId).startsWith('00G')){
                    Task t1= new Task();
                    t1.Id = taskMap.get(taskId).Id;
                    t1.OwnerId = l.OwnerId;
                    t1.WhoId = taskMap.get(taskId).WhoId;
                    taskOwnerUpdateList.add(t1);
		    		newOwnerIds.add(l.OwnerId);
                }
            }
        }
        
        if(taskOwnerUpdateList.size() > 0){
            
            // Grab all of the New Task Owner emails from SOQL
            Map<Id, User> users = new Map<Id, User>([SELECT id, email FROM User WHERE id=:newOwnerIds]);
            
            Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[] {};
            
            // Write out custom emails for each new task owner
            for(Task t : taskOwnerUpdateList) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
           	 	
                // Send to the new Owner's email.
                String[] to = new String[]{users.get(t.OwnerId).email}; 
    	        email.setToAddresses(to);
                
                // Set the Email Subject
                email.setSubject('New Task Assignment');
                
                // Set the Email Body
                string body = 'The Data Migration User has assigned you a new task that is associated to a New Lead' +
                    '<br/>Lead Name: ' + leadMap.get(t.WhoId).Name +  
                    '<br/><br/>' + 
                    Url.getSalesforceBaseUrl().toExternalForm() +
                    '/' + t.WhoId;
                
                // Add the template and custom Lead Link
                email.setHtmlBody(body);
                emails.add(email);
            } // end Task Update List loop
            
            // Send the emails in a single batch.
            try {
                Messaging.sendEmail(emails);
            } catch(exception e) {
                // Do we want any custom error handling?
                System.debug(e.getMessage());
            }
            
            // Update the owners in SOQL
            Update taskOwnerUpdateList;
        }

    } 
    public void finish(Database.BatchableContext BC) {
        if(!Test.IsRunningTest()){
            EE_Job_syncTaskOwnerWithLeadOwner b = new EE_Job_syncTaskOwnerWithLeadOwner (); 
            System.scheduleBatch(b, 'EE_Job_syncTaskOwnerWithLeadOwner',60, 100);
        }
        
    }       
}