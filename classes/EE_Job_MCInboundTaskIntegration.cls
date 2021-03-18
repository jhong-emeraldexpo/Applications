/*
Dev: Spoorthy Teegala
Date:11/06/2020
Description:Scheduled batch job to handle MCInboundIntegration Tasks
*/
public class EE_Job_MCInboundTaskIntegration implements Database.Batchable<sObject>{
    private string query;
    public static String TaskOT = 'Task';
    
    public EE_Job_MCInboundTaskIntegration() {
         query='Select Id, Campaign__c, Campaign__r.Status, Campaign__r.Event_Code__c, Campaign__r.Short_Description__c, Campaign__r.Event__r.Show__c, Campaign__r.Event__r.Show__r.Attendee_Owner__c, Campaign__r.Product__c, Contact__c, Contact__r.Email, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, Event__c, Object_Name__c, Product__c, SubExpo__c, External_Id__c, SystemModstamp from EE_Integration_Queue__c where Object_Name__c = \'Task\' and (Campaign__r.Status = \'In Progress\' or Campaign__r.Status = \'Pending\') Order by LastModifiedDate ASC';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Task> insertTaskIdSet = new Set<Task>();
        List<Task> insertTaskList = new List<Task>();
        Set<EE_Integration_Archive__c> insertIASet = new Set<EE_Integration_Archive__c>();
        List<EE_Integration_Archive__c> insertIAList = new List<EE_Integration_Archive__c>();
        
        Map<Id, EE_Integration_Queue__c> intQueMap= new Map<Id, EE_Integration_Queue__c>();
        Set<String> objNameSet= new Set<String>();
        Set<Id> processedIQIdSet = new Set<Id>();
        Set<EE_Integration_Queue__c> processedIQArchiveRecordSet = new Set<EE_Integration_Queue__c>();

        for(EE_Integration_Queue__c mcque: (List<EE_Integration_Queue__c>) scope){
            intQueMap.put(mcque.Id, mcque);
            objNameSet.add(mcque.Object_Name__c);
        }

        //Retrieving attendee record type id without query
        Id taskAttendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();  
       
	   //If there are no existing opportunities or leads or CampaignMembers    
        if(intQueMap.Size() > 0 ){
            for(Id iq: intQueMap.keyset()){
				if(!processedIQIdSet.contains(iq)){
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == TaskOT){
						Task task = new Task();
						task.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
						task.WhoId = intQueMap.get(iq).Contact__c;
						task.Campaign__c = intQueMap.get(iq).Campaign__c;
						task.Event__c = intQueMap.get(iq).Event__c;
						task.RecordTypeId = taskAttendeeRecordTypeId;
						task.Priority = 'High';
						task.Status = 'Not Started';
						task.ActivityDate = System.today()+1;
						task.IQ_Source_Id__c = intQueMap.get(iq).Id;
						task.Description = string.valueof('SubExpo:'+intQueMap.get(iq).SubExpo__c);
						insertTaskIdSet.add(task);
						system.debug('task'+task);
					}
				}
            }
        }
        
        // Inserting the Task records and adding the history to EE_Integration_Archive
        if(insertTaskIdSet.size()>0){
            try{
                insertTaskList.addAll(insertTaskIdSet);
                insert insertTaskList;
                system.debug('insertTaskList****'+insertTaskList);
            }
            catch(exception e){
                alertEmeraldSFDCSupportTeam('Task','Insert', e.getMessage());
            }
            if(insertTaskList.size()>0){
                Set<String> IQIdSet = new Set<String>();
                List<Task> insertedTaskList = [Select Id, Event__c, Campaign__c, WhoId, IQ_Source_Id__c, SystemModstamp from Task where Id IN:insertTaskList];
                
                for(Task task2: insertedTaskList){
                    IQIdSet.add(task2.IQ_Source_Id__c);
                }
                List<EE_Integration_Queue__c> iqDataList = [Select Id, External_Id__c, Campaign__c, Contact__c, Event__c, Subexpo__c, Product__c, Object_Name__c, SystemModstamp from EE_Integration_Queue__c where Id IN: IQIdSet];
                system.debug('iqDataList'+iqDataList);

                for(Task task1: insertedTaskList){
                    for(EE_Integration_Queue__c IQ: iqDataList){
                        if(IQ.Id == task1.IQ_Source_Id__c){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = task1.Id;
                            IA.Contact__c = IQ.Contact__c;
                            IA.Event__c = IQ.Event__c;
                            IA.Product__c = IQ.Product__c;
                            IA.External_Id__c = IQ.External_Id__c;
                            IA.Source_Id__c = IQ.Id;
                            IA.Source_Created_Date__c = IQ.SystemModstamp;
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Target_Created_Date__c = task1.SystemModstamp;
                            IA.Name = IQ.Object_Name__c;
                            IA.Status__c = 'New';
                            IA.Campaign__c = task1.Campaign__c;
                            IA.Description__c = string.Valueof('Integration Queue Object Name'+IQ.Object_Name__c);
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                            system.debug('inserted Archive list'+IA);
                            system.debug('Del*********'+processedIQArchiveRecordSet);
                        }
                    }
                }
            }
        }
        //Insert processed records into EE_Integration_Archive 
        if(insertIASet.Size()>0){
            insertIAList.addAll(insertIASet);
            insert insertIAList;
            System.debug('insertIAList'+insertIAList);
            if(processedIQArchiveRecordSet.size()>0 && insertIAList.size()>0){
                List<EE_Integration_Queue__c> processedIQArchiveRecordList = new List<EE_Integration_Queue__c>();
                //Delete records in EE_Integration_Queue after adding them to EE_Integration_Archive
                processedIQArchiveRecordList.addAll(processedIQArchiveRecordSet);
                system.debug('Del*************'+processedIQArchiveRecordSet);
                delete processedIQArchiveRecordList;
            }  
        }

    }
    public void alertEmeraldSFDCSupportTeam(string objectName, string operation, string errorMessage){

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<string>();
        string subjectmsg = 'System Exception while processing MC Inbound Integation records';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        sendTo = EmailSplitter(System.Label.IT_Team_Email_Addresses);
        if(sendTo.size() > 0){
            email.setToAddresses(sendTo);
        }
        email.setSubject(subjectmsg);
        email.setHTMLBody('System Error <br/><br/>'+
        '<b> Received error while performing the following operation: '+operation+'<br/>'+
        '<b> For the following Object: '+objectName+'<br/>'+
        '<b> Error: <b/>'+errorMessage+'<br/>');

        emailList.add(email);
        if(emailList.size()>0){
            Messaging.sendEmail(emailList);
        }
    }

    public List<String> EmailSplitter(string stringValue){
        list<string> emailList = new List<string>();
        if(string.isNotBlank(stringValue)){
            if(stringValue.contains(',')){
                string[] afterSplit = stringValue.split(',');
                for(string s:afterSplit){
                    emailList.add(s);
                }
            }
            else{
                emailList.add(stringValue);
            }
        }
        return emailList;
    }

    public void finish(Database.BatchableContext BC){
        if(!Test.IsRunningTest()){
            EE_Job_MCInboundTaskIntegration b = new EE_Job_MCInboundTaskIntegration();
            System.scheduleBatch(b,'EE_Job_MCInboundTaskIntegration', 60, 100);
        }      
    } 
    
}