/*
Dev: Spoorthy Teegala
Date:11/06/2020
Description:Scheduled batch job to handle MCInboundIntegration Opportunities
*/
public class EE_Job_MCInboundOpportunityIntegration implements Database.Batchable<sObject>{
    private string query;
    public static String OpportunityOT = 'Opportunity';
    public static String TaskOT = 'Task';
    public EE_Job_MCInboundOpportunityIntegration() {
        query='Select Id, Campaign__c, Campaign__r.Status, Campaign__r.Event_Code__c, Campaign__r.Short_Description__c, Campaign__r.Event__r.Show__c, Campaign__r.Event__r.Show__r.Attendee_Owner__c, Campaign__r.Product__c, Contact__c, Contact__r.Email, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, Event__c, Object_Name__c, Product__c, SubExpo__c, External_Id__c, SystemModstamp from EE_Integration_Queue__c where Object_Name__c = \'Opportunity\' and (Campaign__r.Status = \'In Progress\' or Campaign__r.Status = \'Pending\') Order by LastModifiedDate ASC';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Opportunity> insertOppIdSet = new Set<Opportunity>();
        List<Opportunity> insertOppsList = new List<Opportunity>();
        Set<Task> insertTaskIdSet = new Set<Task>();
        List<Task> insertTaskList = new List<Task>();
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
         //Query existing Opportunities
		Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> existingOppsList = [Select Id, OwnerId, Event__c, SubExpo__c, CampaignId, Product__c, AccountId, SystemModstamp from Opportunity where Event__c IN: eveIdSet and SubExpo__c IN: subexpoIdSet and Product__c IN: productSet and CampaignId IN: campIdSet and AccountId IN: accIdSet];
        system.debug('Existing Opportunites'+existingOppsList);
		for(Opportunity opp:existingOppsList){
			oppIdSet.add(opp.Id);
		}
		//Query OpportunityContactRole for existing opportunites
		List<OpportunityContactRole> existingOppContactRoles = [Select Id, ContactId, OpportunityId, Opportunity.OwnerId, Opportunity.CampaignId, Opportunity.AccountId, Opportunity.Product__c, Opportunity.SubExpo__c, Opportunity.Event__c, Role, IsPrimary, Opportunity.SystemModstamp from OpportunityContactRole where OpportunityId IN: oppIdSet];
        system.debug('Existing OCR'+existingOppContactRoles);

        //Retrieving attendee record type id without query
        Id taskAttendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId(); 

        // If the contact role exists on the opportunity add to archive and if the contact role exists and does not match existing contact role create task and contact role

        if(existingOppsList.size()>0 && existingOppContactRoles.size()>0 ){ 
            for(Id iq: intQueMap.keyset()){
                for(OpportunityContactRole ocr: existingOppContactRoles){
                system.debug('@@@@@OcrCOntact'+ocr.ContactId);
                system.debug('@@@@@QueueContact'+intQueMap.get(iq).Contact__c);
                    if(intQueMap.get(iq).Contact__c == ocr.ContactId ){
                        if(intQueMap.get(iq).Object_Name__c == OpportunityOT && ocr.Opportunity.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && ocr.Opportunity.CampaignId == intQueMap.get(iq).Campaign__c && ocr.Opportunity.Event__c == intQueMap.get(iq).Event__c && ocr.Opportunity.Product__c == intQueMap.get(iq).Product__c && ocr.Opportunity.SubExpo__c == intQueMap.get(iq).SubExpo__c && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = ocr.OpportunityId;
                            IA.Contact__c = intQueMap.get(iq).Contact__c;
                            IA.Event__c = intQueMap.get(iq).Event__c;
                            IA.Product__c = intQueMap.get(iq).Product__c;
                            IA.External_Id__c = intQueMap.get(iq).External_Id__c;
                            IA.Source_Id__c = intQueMap.get(iq).Id;
                            IA.Source_Created_Date__c = intQueMap.get(iq).SystemModstamp;
                            IA.Status__c = 'Duplicate';
                            IA.SubExpo__c = intQueMap.get(iq).SubExpo__c;
                            IA.Target_Created_Date__c = ocr.Opportunity.SystemModstamp;
                            IA.Campaign__c = ocr.Opportunity.CampaignId;
                            IA.Name = intQueMap.get(iq).Object_Name__c;
                            insertIASet.add(IA);
                            processedIQIdSet.add(iq);
                            processedIQArchiveRecordSet.add(intQueMap.get(iq)); 
                            system.debug('Del**'+processedIQArchiveRecordSet);
                        }
                        if(intQueMap.get(iq).Object_Name__c == OpportunityOT && ocr.Opportunity.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && ocr.Opportunity.CampaignId == intQueMap.get(iq).Campaign__c && ocr.Opportunity.Event__c == intQueMap.get(iq).Event__c && ocr.Opportunity.Product__c == intQueMap.get(iq).Product__c && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = ocr.OpportunityId;
                            IA.Contact__c = intQueMap.get(iq).Contact__c;
                            IA.Event__c = intQueMap.get(iq).Event__c;
                            IA.Product__c = intQueMap.get(iq).Product__c;
                            IA.External_Id__c = intQueMap.get(iq).External_Id__c;
                            IA.Source_Id__c = intQueMap.get(iq).Id;
                            IA.Source_Created_Date__c = intQueMap.get(iq).SystemModstamp;
                            IA.Status__c = 'Duplicate';
                            IA.SubExpo__c = intQueMap.get(iq).SubExpo__c;
                            IA.Target_Created_Date__c = ocr.Opportunity.SystemModstamp;
                            IA.Campaign__c = ocr.Opportunity.CampaignId;
                            IA.Name = intQueMap.get(iq).Object_Name__c;
                            insertIASet.add(IA);
                            processedIQIdSet.add(iq);
                            processedIQArchiveRecordSet.add(intQueMap.get(iq)); 
                            system.debug('Del**'+processedIQArchiveRecordSet);
                            system.debug('id'+processedIQIdSet);
                        }
                    }
                }
                for(OpportunityContactRole ocr: existingOppContactRoles){
                    if(ocr.ContactId != intQueMap.get(iq).Contact__c){
                        system.debug('id'+processedIQIdSet);
                        system.debug('Queueid'+intQueMap.get(iq).Id);
                        system.debug('id'+!processedIQIdSet.contains(iq));
                        if(intQueMap.get(iq).Object_Name__c == OpportunityOT  && !processedIQIdSet.contains(iq) && ocr.Opportunity.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && ocr.Opportunity.CampaignId == intQueMap.get(iq).Campaign__c && ocr.Opportunity.Event__c == intQueMap.get(iq).Event__c && ocr.Opportunity.Product__c == intQueMap.get(iq).Product__c && ocr.Opportunity.SubExpo__c == intQueMap.get(iq).SubExpo__c && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                            Task opptask = new Task();
                            opptask.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
                            opptask.WhatId = ocr.Opportunity.Id;
                            opptask.WhoId = intQueMap.get(iq).Contact__c;
                            opptask.OwnerId = ocr.Opportunity.OwnerId;
                            opptask.RecordTypeId = taskAttendeeRecordTypeId;
                            opptask.Priority = 'High';
                            opptask.Status = 'Completed';
                            opptask.ActivityDate = System.today()+1;
                            opptask.IQ_Source_Id__c = intQueMap.get(iq).Id;
                            opptask.Description = 'Existing Opp Record';
                            insertTaskIdSet.add(opptask);
                            processedIQIdSet.add(iq);
                            system.debug('opptask*'+opptask); 
                            if(insertTaskIdSet.size()>0){
                                if(ocr.IsPrimary == True && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                                    OpportunityContactRole ocr1 = new OpportunityContactRole();
                                    ocr1.OpportunityId = ocr.Opportunity.Id;
                                    ocr1.ContactId = intQueMap.get(iq).Contact__c;
                                    ocr1.Role = 'Attendee Contact';
                                    ocrSet.add(ocr1);
                                    system.debug('ocr!'+ocrSet);
                                }else if(ocr.IsPrimary == False && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                                    OpportunityContactRole ocr2 = new OpportunityContactRole();
                                    ocr2.OpportunityId = ocr.Opportunity.Id;
                                    ocr2.ContactId = intQueMap.get(iq).Contact__c;
                                    ocr2.Role = 'Attendee Contact';
                                    ocr2.IsPrimary = True;
                                    ocrSet.add(ocr2);
                                    system.debug('ocr!!'+ocrSet);
                                }
                            }
                        }
                        if(intQueMap.get(iq).Object_Name__c == OpportunityOT  && !processedIQIdSet.contains(iq) && ocr.Opportunity.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && ocr.Opportunity.CampaignId == intQueMap.get(iq).Campaign__c && ocr.Opportunity.Event__c == intQueMap.get(iq).Event__c && ocr.Opportunity.Product__c == intQueMap.get(iq).Product__c && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                            Task opptask = new Task();
                            opptask.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
                            opptask.WhatId = ocr.Opportunity.Id;
                            opptask.WhoId = intQueMap.get(iq).Contact__c;
                            opptask.OwnerId = ocr.Opportunity.OwnerId;
                            opptask.RecordTypeId = taskAttendeeRecordTypeId;
                            opptask.Priority = 'High';
                            opptask.Status = 'Completed';
                            opptask.ActivityDate = System.today()+1;
                            opptask.IQ_Source_Id__c = intQueMap.get(iq).Id;
                            opptask.Description = 'Existing Opp Record';
                            insertTaskIdSet.add(opptask);
                            processedIQIdSet.add(iq);
                            system.debug('opptask*'+opptask); 
                            if(insertTaskIdSet.size()>0){
                                if(ocr.IsPrimary == True && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                                    OpportunityContactRole ocr1 = new OpportunityContactRole();
                                    ocr1.OpportunityId = ocr.Opportunity.Id;
                                    ocr1.ContactId = intQueMap.get(iq).Contact__c;
                                    ocr1.Role = 'Attendee Contact';
                                    ocrSet.add(ocr1);
                                    system.debug('ocr!'+ocrSet);
                                }else if(ocr.IsPrimary == False && ocr.Opportunity.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                                    OpportunityContactRole ocr2 = new OpportunityContactRole();
                                    ocr2.OpportunityId = ocr.Opportunity.Id;
                                    ocr2.ContactId = intQueMap.get(iq).Contact__c;
                                    ocr2.Role = 'Attendee Contact';
                                    ocr2.IsPrimary = True;
                                    ocrSet.add(ocr2);
                                    system.debug('ocr!!'+ocrSet);
                                }
                            }
                        }
                    }       
                }
            }
        }
        //If there are existing opportunities without OpportunityContactRole create Task and contact role
        if(existingOppsList.size()>0 && existingOppContactRoles.size()==0 ){ 
            for(Id iq: intQueMap.keyset()){
                for(Opportunity opp2: existingOppsList){
                    if(intQueMap.get(iq).Object_Name__c == OpportunityOT && !processedIQIdSet.contains(iq) && opp2.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && opp2.CampaignId == intQueMap.get(iq).Campaign__c && opp2.Event__c == intQueMap.get(iq).Event__c && opp2.Product__c == intQueMap.get(iq).Product__c && opp2.SubExpo__c == intQueMap.get(iq).SubExpo__c && opp2.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                        Task opptask = new Task();
                        opptask.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
                        opptask.WhatId = opp2.Id;
                        opptask.WhoId = intQueMap.get(iq).Contact__c;
                        opptask.OwnerId = opp2.OwnerId;
                        opptask.RecordTypeId = taskAttendeeRecordTypeId;
                        opptask.Priority = 'High';
                        opptask.Status = 'Completed';
                        opptask.ActivityDate = System.today()+1;
                        opptask.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        opptask.Description = 'Existing Opp Record';
                        insertTaskIdSet.add(opptask);
                        processedIQIdSet.add(iq);
                        system.debug('opptask*'+opptask); 
                            
                        OpportunityContactRole ocr2 = new OpportunityContactRole();
                        ocr2.OpportunityId = opp2.Id;
                        ocr2.ContactId = intQueMap.get(iq).Contact__c;
                        ocr2.Role = 'Attendee Contact';
                        ocr2.IsPrimary = True;
                        ocrSet.add(ocr2);
                            
                    }
                    else if(intQueMap.get(iq).Object_Name__c == OpportunityOT && !processedIQIdSet.contains(iq) && opp2.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && opp2.CampaignId == intQueMap.get(iq).Campaign__c && opp2.Event__c == intQueMap.get(iq).Event__c && opp2.Product__c == intQueMap.get(iq).Product__c && opp2.AccountId == intQueMap.get(iq).Contact__r.AccountId){
                        Task opptask1 = new Task();
                        opptask1.Subject = String.Valueof('M|'+intQueMap.get(iq).Campaign__r.Event_Code__c+'|'+intQueMap.get(iq).Campaign__r.Short_Description__c+'|'+intQueMap.get(iq).Product__c );
                        opptask1.WhatId = opp2.Id;
                        opptask1.WhoId = intQueMap.get(iq).Contact__c;
                        opptask1.OwnerId = opp2.OwnerId;
                        opptask1.RecordTypeId = taskAttendeeRecordTypeId;
                        opptask1.Priority = 'High';
                        opptask1.Status = 'Completed';
                        opptask1.ActivityDate = System.today()+1;
                        opptask1.IQ_Source_Id__c = intQueMap.get(iq).Id;
                        opptask1.Description = 'Existing Opp Record';
                        insertTaskIdSet.add(opptask1);
                        processedIQIdSet.add(iq);
                        system.debug('opptask1*'+opptask1);  
                           
                        OpportunityContactRole ocr2 = new OpportunityContactRole();
                        ocr2.OpportunityId = opp2.Id;
                        ocr2.ContactId = intQueMap.get(iq).Contact__c;
                        ocr2.Role = 'Attendee Contact';
                        ocr2.IsPrimary = True;
                        ocrSet.add(ocr2);
                        system.debug('ocr!!!!!'+ocrSet);
                  
                    }
                }
            }
        }
        if(intQueMap.Size() > 0 ){
            for(Id iq: intQueMap.keyset()){
				if(!processedIQIdSet.contains(iq)){
                    if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == OpportunityOT){
                        Opportunity opp= new Opportunity();
                        if(intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c!= null){
                            opp.OwnerId = intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c;
                        }
						opp.Name = 'IntQue';
						opp.StageName = 'No Contact Attempted';
						opp.CloseDate = System.today()+30; //a month from created date
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
                List<EE_Integration_Queue__c> iqDataList = [Select Id, External_Id__c, Campaign__c, Contact__c, Contact__r.AccountId, Event__c, Subexpo__c, Product__c, Object_Name__c, SystemModstamp from EE_Integration_Queue__c where Id IN: IQIdSet];
                for(Opportunity opp1: insertedOppsList){
                    for(EE_Integration_Queue__c IQ: iqDataList){
                        //Add contact role for newly inserted opportunities
                        if(insertedOppsList.size()>0){
							OpportunityContactRole ocr3 = new OpportunityContactRole();
							ocr3.OpportunityId = opp1.Id;
							ocr3.ContactId = IQ.Contact__c;
							ocr3.Role = 'Attendee Contact';
							ocr3.IsPrimary = True;
							ocrSet.add(ocr3);
						}	
                        if(IQ.Event__c == opp1.Event__c && IQ.Campaign__c == opp1.CampaignId && IQ.Contact__r.AccountId == opp1.AccountId && IQ.Id == opp1.IQ_Source_Id__c){
                            EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                            IA.Target_Id__c = opp1.Id;
                            IA.Contact__c = IQ.Contact__c;
                            IA.Event__c = IQ.Event__c;
                            IA.Product__c = IQ.Product__c;
                            IA.External_Id__c = IQ.External_Id__c;
                            IA.Source_Id__c = IQ.Id;
                            IA.Source_Created_Date__c = IQ.SystemModstamp;
							IA.Status__c = 'New';
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Target_Created_Date__c = opp1.SystemModstamp;
                            IA.Campaign__c = opp1.CampaignId;
                            IA.Name = IQ.Object_Name__c;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                            system.debug('Del*******'+processedIQArchiveRecordSet);
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
            }catch(exception e){
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
        // Insert Opportunity Contact ROle
        if(ocrSet.size()>0){
            try{
                ocrList.addAll(ocrSet);
                insert ocrList;
                system.debug('ocrList'+ocrList);
            }catch(exception e){
                alertEmeraldSFDCSupportTeam('OpportunityContactRole','Insert', e.getMessage());
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

            for(CronTrigger ct: [select Id from CronTrigger where CronJobDetail.Name like 'EE_Job_MCInboundOpportunityIntegration%']){
                flgNewBatch = false;
            }

            for(AsyncApexJob aaj: [select Id from AsyncApexJob where ApexClass.Name like 'EE_Job_MCInboundOpportunityIntegration%' and Status!= 'Completed' and Status != 'Aborted' and Status!= 'Failed']){
                flgNewBatch = false;
            }

            if(flgNewBatch){
                EE_Job_MCInboundOpportunityIntegration b = new EE_Job_MCInboundOpportunityIntegration();
                try{
                    System.scheduleBatch( b, 'EE_Job_MCInboundOpportunityIntegration' + string.Valueof(datetime.now().getTime()), 60, 1);
                }
                catch(Exception e){
                }
                catch(UnexpectedException ue){
                }
            }
        }
    }
}