/*
Dev: Spoorthy Teegala
Date:08/19/2020
Description:Scheduled batch job to handle MCInboundIntegration
*/
public class EE_Job_MCInboundIntegration implements Database.Batchable<sObject>{
    private string query;
    public static String LeadOT = 'Lead';
    public static String OpportunityOT = 'Opportunity';
    public static String CMOT = 'CampaignMember';
    public static String TaskOT = 'Task';
    
    public EE_Job_MCInboundIntegration() {
        query='Select Id, Campaign__c, Campaign__r.Product__c, Contact__c, Contact__r.Email, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, Event__c, Object_Name__c, Product__c, SubExpo__c, External_Id__c, SystemModstamp from EE_Integration_Queue__c Order by LastModifiedDate ASC limit 10000';
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

        //Query existing leads
        List<Lead> existingLeadsList = [Select Id, OwnerId, Event__c, SubExpo__c, EE_Campaign__c, Product__c, FirstName, LastName from Lead where Event__c IN: eveIdSet and SubExpo__c IN: subexpoIdSet and Product__c IN: productSet and EE_Campaign__c IN: campIdSet and FirstName IN: conFNSet and LastName IN: conLNSet];
        system.debug('Exixting Leads'+existingLeadsList);
        
        //Query existing Opportunities
        List<Opportunity> existingOppsList = [Select Id, OwnerId, Event__c, SubExpo__c, CampaignId, Product__c, AccountId from Opportunity where Event__c IN: eveIdSet and SubExpo__c IN: subexpoIdSet and Product__c IN: productSet and CampaignId IN: campIdSet and AccountId IN: accIdSet];
        system.debug('Existing Opportunites'+existingOppsList);

        //Query existing CampaignMember records
        List<CampaignMember> existingCMList = [Select Id, CampaignId, ContactId, Campaign.Event__c, Campaign.Product__c, SystemModstamp from CampaignMember where Campaign.Event__c IN: eveIdSet and CampaignId IN: campIdSet and Campaign.Product__c IN: productSet and ContactId IN: contIdSet];
        system.debug('Existing CampaignMembers'+existingCMList);

        //Retrieving attendee record type id without query
        Id taskAttendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();  
		
		//If there are existing leads create task
        if(existingLeadsList.size()>0 ){ 
            for(Id iq: intQueMap.keyset()){
                for(Lead ld1: existingLeadsList){
                    if(intQueMap.get(iq).Object_Name__c == LeadOT && ld1.FirstName == intQueMap.get(iq).Contact__r.FirstName && ld1.LastName == intQueMap.get(iq).Contact__r.LastName && ld1.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && ld1.EE_Campaign__c == intQueMap.get(iq).Campaign__c && ld1.Event__c == intQueMap.get(iq).Event__c && ld1.Product__c == intQueMap.get(iq).Product__c && ld1.SubExpo__c == intQueMap.get(iq).SubExpo__c){
                        Task task1 = new Task();
                        task1.WhoId = ld1.Id;
                        task1.OwnerId=ld1.OwnerId;
                        task1.RecordTypeId = taskAttendeeRecordTypeId;
                        task1.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        task1.Description = 'Existing Lead Record';
                        insertTaskIdSet.add(task1);
                        processedIQIdSet.add(iq);
                        system.debug('task1*'+task1);
                    }
                    if(intQueMap.get(iq).Object_Name__c == LeadOT && ld1.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && ld1.FirstName == intQueMap.get(iq).Contact__r.FirstName && ld1.LastName == intQueMap.get(iq).Contact__r.LastName && ld1.EE_Campaign__c == intQueMap.get(iq).Campaign__c && ld1.Event__c == intQueMap.get(iq).Event__c && ld1.Product__c == intQueMap.get(iq).Product__c){
                        Task task1 = new Task();
                        task1.WhoId = ld1.Id;
                        task1.OwnerId=ld1.OwnerId;
                        task1.RecordTypeId = taskAttendeeRecordTypeId;
                        task1.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        task1.Description = 'Existing Lead Record';
                        insertTaskIdSet.add(task1);
						processedIQIdSet.add(iq);
                        system.debug('task1**'+task1);
                    }
                }
            }
        }
        //If there are existing opportunities create Task
        if(existingOppsList.size()>0 ){ 
            for(Id iq: intQueMap.keyset()){
                for(Opportunity opp2: existingOppsList){
                    if(intQueMap.get(iq).Object_Name__c == OpportunityOT && opp2.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && opp2.CampaignId == intQueMap.get(iq).Campaign__c && opp2.Event__c == intQueMap.get(iq).Event__c && opp2.Product__c == intQueMap.get(iq).Product__c && opp2.SubExpo__c == intQueMap.get(iq).SubExpo__c && opp2.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                        Task task2 = new Task();
                        task2.WhatId = opp2.Id;
                        task2.OwnerId = opp2.OwnerId;
                        task2.RecordTypeId = taskAttendeeRecordTypeId;
                        task2.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        task2.Description = 'Existing Opp Record';
                        insertTaskIdSet.add(task2);
						processedIQIdSet.add(iq);
                        system.debug('task2*'+task2);
                    }
                    if(intQueMap.get(iq).Object_Name__c == OpportunityOT && opp2.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && opp2.CampaignId == intQueMap.get(iq).Campaign__c && opp2.Event__c == intQueMap.get(iq).Event__c && opp2.Product__c == intQueMap.get(iq).Product__c && opp2.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                        Task task2 = new Task();
                        task2.WhatId = opp2.Id;
                        task2.OwnerId = opp2.OwnerId;
                        task2.RecordTypeId = taskAttendeeRecordTypeId;
                        task2.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        task2.Description = 'Existing Opp Record';
                        insertTaskIdSet.add(task2);
						processedIQIdSet.add(iq);
                        system.debug('task2**'+task2);
                    }
                }
            }
        }
        //If there is an existing CampaignMember add it to archive
        if(existingCMList.size()>0){
			for(Id iq: intQueMap.keyset()){
				for(CampaignMember campMem: existingCMList){
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == CMOT && intQueMap.get(iq).Campaign__c == campMem.CampaignId && intQueMap.get(iq).Event__c == campMem.Campaign.Event__c  && intQueMap.get(iq).Contact__c == campMem.ContactId ){
						EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                        IA.Target_Id__c = campMem.Id;
                        IA.Contact__c = intQueMap.get(iq).Contact__c;
                        IA.Event__c = intQueMap.get(iq).Event__c;
                        IA.External_Id__c = intQueMap.get(iq).External_Id__c;
                        IA.Product__c = intQueMap.get(iq).Product__c;
                        IA.Source_Id__c = intQueMap.get(iq).Id;
                        IA.Source_Created_Date__c = intQueMap.get(iq).SystemModstamp;
                        IA.SubExpo__c = intQueMap.get(iq).SubExpo__c;
                        IA.Target_Created_Date__c = campMem.SystemModstamp;
                        IA.Name = intQueMap.get(iq).Object_Name__c;
                        IA.Campaign__c = intQueMap.get(iq).Campaign__c;
						IA.Description__c = 'Target Id field refers to existing CampaignMember record';
                        insertIASet.add(IA);
                        processedIQIdSet.add(iq);
                        processedIQArchiveRecordSet.add(intQueMap.get(iq));
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
						cm.IQ_Source_Id__c = intQueMap.get(iq).Id;
						insertCMIdSet.add(cm);
						system.debug('cm'+cm);
					}
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == LeadOT){
						Lead ld= new Lead();
						ld.Event__c = intQueMap.get(iq).Event__c;
						ld.EE_Campaign__c = intQueMap.get(iq).Campaign__c;
						ld.Company = intQueMap.get(iq).Contact__r.Account.Name;
						ld.FirstName  = intQueMap.get(iq).Contact__r.FirstName;
						ld.LastName = intQueMap.get(iq).Contact__r.LastName;
						ld.Product__c = intQueMap.get(iq).Product__c;
						ld.SubExpo__c = intQueMap.get(iq).SubExpo__c;
						ld.should_Ignore_Assignment_Rule__c = True;
                        ld.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        ld.Email = intQueMap.get(iq).Contact__r.Email;
						insertLeadIdSet.add(ld);
						system.debug('ld'+ld);
					}
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == OpportunityOT){
						Opportunity opp= new Opportunity();
						opp.Name = 'IntQue';
						opp.StageName = 'No Contact Attempted';
						opp.CloseDate = System.today()+5;
						opp.Event__c = intQueMap.get(iq).Event__c;
						opp.CampaignId = intQueMap.get(iq).Campaign__c;
						opp.AccountId = intQueMap.get(iq).Contact__r.AccountId;
						opp.Product__c = intQueMap.get(iq).Product__c;
						opp.SubExpo__c = intQueMap.get(iq).SubExpo__c;
						opp.should_Ignore_Assignment_Rule__c = True;
						opp.IQ_Source_Id__c = intQueMap.get(iq).Id;
						insertOppIdSet.add(opp);
						system.debug('opp'+opp);
					}
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == TaskOT){
						Task task = new Task();
						task.WhoId = intQueMap.get(iq).Contact__c;
						task.Campaign__c = intQueMap.get(iq).Campaign__c;
						task.Event__c = intQueMap.get(iq).Event__c;
						task.RecordTypeId = taskAttendeeRecordTypeId;
						task.IQ_Source_Id__c = intQueMap.get(iq).Id;
						task.Description = string.valueof('SubExpo:'+intQueMap.get(iq).SubExpo__c+'Product:'+intQueMap.get(iq).Product__c);
						insertTaskIdSet.add(task);
						system.debug('task'+task);
					}
				}
            }
        }
        
        // Inserting the Lead records and adding the history to EE_Integration_Archive 
        if(insertLeadIdSet.size()>0){
            try{
                insertLeadsList.addAll(insertLeadIdSet);
                insert insertLeadsList;
                system.debug('insertLeadsList***************'+insertLeadsList);
            }
            catch(exception e){
                alertEmeraldSFDCSupportTeam('Lead','Insert', e.getMessage());
            }

            if(insertLeadsList.size()>0){
                Set<String> IQIdSet = new Set<String>();
                Map<Id,Lead> leadMap = new Map<Id,Lead>();
                List<Lead> insertedLeadIdList = [Select Id, IQ_Source_Id__c, Product__c, FirstName, LastName, EE_Campaign__c, Event__c, Subexpo__c, SystemModstamp from Lead where Id IN:insertLeadsList];
                for(Lead l: insertedLeadIdList){
                    IQIdSet.add(l.IQ_Source_Id__c);
                    leadMap.put(l.Id,l);
                }
                List<EE_Integration_Queue__c> iqDataList = [Select Id, External_Id__c, Campaign__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Event__c, Subexpo__c, Product__c, Object_Name__c, SystemModstamp from EE_Integration_Queue__c where Id IN: IQIdSet];
                for(ID lead: leadMap.Keyset()){
                    for(EE_Integration_Queue__c IQ: iqDataList){
                        if(IQ.Event__c == leadMap.get(lead).Event__c && IQ.Campaign__c == leadMap.get(lead).EE_Campaign__c && IQ.Product__c == leadMap.get(lead).Product__c && IQ.Id == leadMap.get(lead).IQ_Source_Id__c){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = leadMap.get(lead).Id;
                            IA.Contact__c = IQ.Contact__c;
                            IA.Event__c= IQ.Event__c;
                            IA.Product__c = IQ.Product__c;
                            IA.External_Id__c = IQ.External_Id__c;
                            IA.Source_Id__c = IQ.Id;
                            IA.Source_Created_Date__c = IQ.SystemModstamp;
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Campaign__c = leadMap.get(lead).EE_Campaign__c;
                            IA.Target_Created_Date__c = leadMap.get(lead).SystemModstamp;
                            IA.Name = IQ.Object_Name__c;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                        }
                    }
                }
            }
        }
        // Inserting the Opportunity records and adding the history to EE_Integration_Archive 
        if(insertOppIdSet.size()>0){
            try{
                insertOppsList.addAll(insertOppIdSet);
                insert insertOppsList;
                system.debug('insertOppsList'+insertOppsList);
            }
            catch(exception e){
                alertEmeraldSFDCSupportTeam('Opportunity','Insert', e.getMessage());
            }

            Set<String> IQIdSet = new Set<String>();
            if(insertOppsList.size()>0){
                List<Opportunity> insertedOppsList = [Select Id, IQ_Source_Id__c, Event__c, Subexpo__c, CampaignId, AccountId, SystemModstamp from Opportunity where Id IN:insertOppsList];
                for(Opportunity OPP: insertedOppsList){
                    IQIdSet.add(OPP.IQ_Source_Id__c);
                }
                List<EE_Integration_Queue__c> iqDataList = [Select Id, External_Id__c, Campaign__c, Contact__r.AccountId, Event__c, Subexpo__c, Product__c, Object_Name__c, SystemModstamp from EE_Integration_Queue__c where Id IN: IQIdSet];
                for(Opportunity opp1: insertedOppsList){
                    for(EE_Integration_Queue__c IQ: iqDataList){
                        if(IQ.Event__c == opp1.Event__c && IQ.Campaign__c == opp1.CampaignId && IQ.Contact__r.AccountId == opp1.AccountId && IQ.Id == opp1.IQ_Source_Id__c){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = opp1.Id;
                            IA.Contact__c = IQ.Contact__c;
                            IA.Event__c= IQ.Event__c;
                            IA.Product__c = IQ.Product__c;
                            IA.External_Id__c = IQ.External_Id__c;
                            IA.Source_Id__c = IQ.Id;
                            IA.Source_Created_Date__c = IQ.SystemModstamp;
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Target_Created_Date__c = opp1.SystemModstamp;
                            IA.Campaign__c = opp1.CampaignId;
                            IA.Name = IQ.Object_Name__c;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                        }
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
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Target_Created_Date__c = cm1.SystemModstamp;
                            IA.Name = IQ.Object_Name__c;
                            IA.Campaign__c= cm1.CampaignId;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
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
                            IA.Name = 'Task';
                            IA.Campaign__c = task1.Campaign__c;
                            IA.Description__c = string.Valueof('Integration Queue Object Name'+IQ.Object_Name__c);
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                            system.debug('inserted Archive list'+IA);
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
            EE_Job_MCInboundIntegration b = new EE_Job_MCInboundIntegration();
            System.scheduleBatch(b,'EE_Job_MCInboundIntegration', 60, 100);
        }      
    } 
    
}