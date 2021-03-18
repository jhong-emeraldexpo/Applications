/*
Dev: Spoorthy Teegala
Date:11/06/2020
Description:Scheduled batch job to handle MCInboundIntegration CampaignMembers
*/
public class EE_Job_MCInboundCampMemIntegration implements Database.Batchable<sObject>{
    private string query;
    public static String CMOT = 'CampaignMember';
    public static String TaskOT = 'Task';
    
    public EE_Job_MCInboundCampMemIntegration() {
         query='Select Id, Campaign__c, Campaign__r.Status, Campaign__r.Event_Code__c, Campaign__r.Short_Description__c, Campaign__r.Event__r.Show__c, Campaign__r.Event__r.Show__r.Attendee_Owner__c, Campaign__r.Product__c, Contact__c, Contact__r.Email, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, Event__c, Object_Name__c, Product__c, SubExpo__c, External_Id__c, SystemModstamp from EE_Integration_Queue__c where Object_Name__c = \'CampaignMember\' and (Campaign__r.Status = \'In Progress\' or Campaign__r.Status = \'Pending\') Order by LastModifiedDate ASC';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Task> insertTaskIdSet = new Set<Task>();
        List<Task> insertTaskList = new List<Task>();
        Set<Opportunity> insertOppIdSet = new Set<Opportunity>();
        List<Opportunity> insertOppsList = new List<Opportunity>();
        Set<Lead> insertLeadIdSet = new Set<Lead>();
        List<Lead> insertLeadsList = new List<Lead>();
        Set<CampaignMember> insertCMIdSet = new Set<CampaignMember>();
        List<CampaignMember> insertCMList = new List<CampaignMember>();
        Set<EE_Integration_Archive__c> insertIASet = new Set<EE_Integration_Archive__c>();
        List<EE_Integration_Archive__c> insertIAList = new List<EE_Integration_Archive__c>();
        Set<OpportunityContactRole> ocrSet = new Set<OpportunityContactRole>();
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        
        Map<Id, EE_Integration_Queue__c> intQueMap= new Map<Id, EE_Integration_Queue__c>();
        Set<String> objNameSet= new Set<String>();
        Set<Id> campIdSet = new Set<Id>();
        Set<Id> eveIdSet = new Set<Id>();
        Set<Id> subexpoIdSet = new Set<Id>();
        Set<String> productSet = new Set<String>();
        Set<Id> contIdSet = new Set<Id>();
        Set<String> conFNSet = new Set<String>();
        Set<String> conLNSet = new Set<String>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> processedIQIdSet = new Set<Id>();
        Set<EE_Integration_Queue__c> processedIQArchiveRecordSet = new Set<EE_Integration_Queue__c>();


        for(EE_Integration_Queue__c mcque: (List<EE_Integration_Queue__c>) scope){
            intQueMap.put(mcque.Id, mcque);
            objNameSet.add(mcque.Object_Name__c);
            //intQueIdList.add(mcque);
            contIdSet.add(mcque.Contact__c);
            productSet.add(mcque.Product__c);
            eveIdSet.add(mcque.Event__c);
            subexpoIdSet.add(mcque.SubExpo__c);
            campIdSet.add(mcque.Campaign__c);
            conFNSet.add(mcque.Contact__r.FirstName);
            conLNSet.add(mcque.Contact__r.LastName);
            accIdSet.add(mcque.Contact__r.AccountId);
        }

        
        //Query existing CampaignMember records
        List<CampaignMember> existingCMList = [Select Id, Owner__c, CampaignId, ContactId, Campaign.Event__c, Campaign.Product__c, SystemModstamp from CampaignMember where Campaign.Event__c IN: eveIdSet and ContactId IN: contIdSet];
        system.debug('Existing CampaignMembers'+existingCMList);

        //Retrieving attendee record type id without query
        Id taskAttendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();  
        
        
        //If there is an existing CampaignMember create task on contact 
        if(existingCMList.size()>0){
            for(Id iq: intQueMap.keyset()){
                for(CampaignMember campMem: existingCMList){
                    if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == CMOT && intQueMap.get(iq).Event__c == campMem.Campaign.Event__c  && intQueMap.get(iq).Contact__c == campMem.ContactId ){
                        Task cmtask = new Task();
                        cmtask.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
                        cmtask.WhoId = intQueMap.get(iq).Contact__c;
                        cmtask.Event__c = intQueMap.get(iq).Campaign__r.Event__c;
                        cmtask.Campaign__c = intQueMap.get(iq).Campaign__c;
                        if(campMem.Owner__c != Null){
                            cmtask.OwnerId = campMem.Owner__c;
                        }
                        cmtask.RecordTypeId = taskAttendeeRecordTypeId;
                        cmtask.Priority = 'High';
                        cmtask.Status = 'Not Started';
                        cmtask.ActivityDate = System.today()+1;
                        cmtask.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        cmtask.Description = 'Existing CampaignMember Record';
                        insertTaskIdSet.add(cmtask);
                        processedIQIdSet.add(iq);
                        //processedIQArchiveRecordSet.add(intQueMap.get(iq));
                        system.debug('Del****'+processedIQArchiveRecordSet);
                        system.debug('cmtask*'+cmtask);
                    }
                }
            }
        }
        
        //If there are no existing opportunities or leads or CampaignMembers    
        if(intQueMap.Size() > 0 ){
            for(Id iq: intQueMap.keyset()){
                if(!processedIQIdSet.contains(iq)){
                    if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == CMOT && intQueMap.get(iq).Campaign__r.Product__c == intQueMap.get(iq).Product__c){
                        CampaignMember cm = new CampaignMember();
                        cm.ContactId = intQueMap.get(iq).Contact__c;
                        cm.CampaignId = intQueMap.get(iq).Campaign__c;
                        if(intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c!= null){
                            cm.Owner__c = intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c;
                        }
                        cm.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        insertCMIdSet.add(cm);
                        system.debug('cm'+cm);
                    }
                    
                }
            }
        }
        

        // Inserting the CampaignMember records and adding the history to EE_Integration_Archive
        if(insertCMIdSet.size()>0){
            try{
                insertCMList.addAll(insertCMIdSet);
                insert insertCMList;
                system.debug('insertCMList'+insertCMList);
            }
            catch(exception e){
                alertEmeraldSFDCSupportTeam('Campaign Member','Insert', e.getMessage());
            }
            if(insertCMList.size()>0){
                Set<String> IQIdSet = new Set<String>();
                List<CampaignMember> insertedCMList = [Select Id, Campaign.Event__c, CampaignId, ContactId, IQ_Source_Id__c, SystemModstamp from CampaignMember where Id IN:insertCMList];
                for(CampaignMember CM: insertedCMList){
                    IQIdSet.add(CM.IQ_Source_Id__c);
                }
                List<EE_Integration_Queue__c> iqDataList = [Select Id, External_Id__c, Campaign__c, Contact__c, Event__c, Subexpo__c, Product__c, Object_Name__c, SystemModstamp from EE_Integration_Queue__c where Id IN: IQIdSet];
                for(CampaignMember cm1: insertedCMList){
                    for(EE_Integration_Queue__c IQ: iqDataList){
                        if(IQ.Event__c == cm1.Campaign.Event__c && IQ.Contact__c ==cm1.ContactId && IQ.Campaign__c == cm1.CampaignId && IQ.Id == cm1.IQ_Source_Id__c){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = cm1.Id;
                            IA.Contact__c = IQ.Contact__c;
                            IA.Event__c= IQ.Event__c;
                            IA.External_Id__c = IQ.External_Id__c;
                            IA.Product__c = IQ.Product__c;
                            IA.Source_Id__c = IQ.Id;
                            IA.Source_Created_Date__c = IQ.SystemModstamp;
                            IA.Status__c = 'New';
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Target_Created_Date__c = cm1.SystemModstamp;
                            IA.Name = IQ.Object_Name__c;
                            IA.Campaign__c= cm1.CampaignId;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                            system.debug('Del********'+processedIQArchiveRecordSet);
                        }
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
                            IA.Name = TaskOT;
                            IA.Status__c = 'Duplicate';
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
            Boolean flgNewBatch = True;

            for(CronTrigger ct: [select Id from CronTrigger where CronJobDetail.Name like 'EE_Job_MCInboundCampMemIntegration%']){
                flgNewBatch = false;
            }

            for(AsyncApexJob aaj: [select Id from AsyncApexJob where ApexClass.Name like 'EE_Job_MCInboundCampMemIntegration%' and Status!= 'Completed' and Status != 'Aborted' and Status!= 'Failed']){
                flgNewBatch = false;
            }

            if(flgNewBatch){
                EE_Job_MCInboundCampMemIntegration b = new EE_Job_MCInboundCampMemIntegration();
                try{
                    System.scheduleBatch(b,'EE_Job_MCInboundCampMemIntegration' + string.Valueof(datetime.now().getTime()), 60, 1);
                }
                catch(Exception e){
                }
                catch(UnexpectedException ue){
                }
            }
        }      
    } 
    
}