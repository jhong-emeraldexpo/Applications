/*
Dev: Spoorthy Teegala
Date:11/09/2020
Description:Scheduled batch job to handle MCInboundIntegration Leads
*/
public class EE_Job_MCInboundLeadIntegration implements Database.Batchable<sObject>{
    private string query;
    public static String LeadOT = 'Lead';
    public EE_Job_MCInboundLeadIntegration() {
        query='Select Id, Campaign__c, Campaign__r.Status, Campaign__r.Event_Code__c, Campaign__r.Short_Description__c, Campaign__r.Event__r.Show__c, Campaign__r.Event__r.Show__r.Attendee_Owner__c, Campaign__r.Product__c, Contact__c, Contact__r.Email, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.FirstName, Contact__r.LastName, Event__c, Object_Name__c, Product__c, SubExpo__c, External_Id__c, SystemModstamp from EE_Integration_Queue__c where Object_Name__c = \'Lead\' and (Campaign__r.Status = \'In Progress\' or Campaign__r.Status = \'Pending\') Order by LastModifiedDate ASC';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Scope:::'+scope);
        Set<Lead> insertLeadIdSet = new Set<Lead>();
        List<Lead> insertLeadsList = new List<Lead>();
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
        Set<Id> processedIQIdSet = new Set<Id>();
        Set<EE_Integration_Queue__c> processedIQArchiveRecordSet = new Set<EE_Integration_Queue__c>();

        for(EE_Integration_Queue__c mcque: (List<EE_Integration_Queue__c>) scope){
            intQueMap.put(mcque.Id, mcque);
            objNameSet.add(mcque.Object_Name__c);
            contIdSet.add(mcque.Contact__c);
            productSet.add(mcque.Product__c);
            eveIdSet.add(mcque.Event__c);
            subexpoIdSet.add(mcque.SubExpo__c);
            campIdSet.add(mcque.Campaign__c);
            conFNSet.add(mcque.Contact__r.FirstName);
            conLNSet.add(mcque.Contact__r.LastName);
            
        }
        
        //Query existing leads
        List<Lead> existingLeadsList = [Select Id, OwnerId, Event__c, SubExpo__c, EE_Campaign__c, Product__c, FirstName, LastName, SystemModstamp from Lead where Event__c IN: eveIdSet and SubExpo__c IN: subexpoIdSet and Product__c IN: productSet and EE_Campaign__c IN: campIdSet and FirstName IN: conFNSet and LastName IN: conLNSet];
        system.debug('Exixting Leads'+existingLeadsList);

        //Retrieving attendee record type id without query
        Id taskAttendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();  
		
		//If there are existing leads create task
        if(existingLeadsList.size()>0 ){ 
            for(Id iq: intQueMap.keyset()){
                for(Lead ld1: existingLeadsList){
                    if(intQueMap.get(iq).Object_Name__c == LeadOT && ld1.FirstName == intQueMap.get(iq).Contact__r.FirstName && ld1.LastName == intQueMap.get(iq).Contact__r.LastName && ld1.SubExpo__c != null && intQueMap.get(iq).SubExpo__c != null && ld1.EE_Campaign__c == intQueMap.get(iq).Campaign__c && ld1.Event__c == intQueMap.get(iq).Event__c && ld1.Product__c == intQueMap.get(iq).Product__c && ld1.SubExpo__c == intQueMap.get(iq).SubExpo__c){
                       	EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                        IA.Target_Id__c = ld1.Id;
                        IA.Contact__c = intQueMap.get(iq).Contact__c;
                        IA.Event__c = intQueMap.get(iq).Event__c;
                        IA.External_Id__c = intQueMap.get(iq).External_Id__c;
                        IA.Product__c = intQueMap.get(iq).Product__c;
                        IA.Source_Id__c = intQueMap.get(iq).Id;
                        IA.Source_Created_Date__c = intQueMap.get(iq).SystemModstamp;
                        IA.SubExpo__c = intQueMap.get(iq).SubExpo__c;
                        IA.Target_Created_Date__c = ld1.SystemModstamp;
						IA.Status__c = 'Duplicate';
                        IA.Name = intQueMap.get(iq).Object_Name__c;
                        IA.Campaign__c = intQueMap.get(iq).Campaign__c;
						IA.Description__c = 'Target Id field refers to existing Lead record';
                        insertIASet.add(IA);
                        processedIQIdSet.add(iq);
                        processedIQArchiveRecordSet.add(intQueMap.get(iq)); 
                        system.debug('Del*'+processedIQArchiveRecordSet);
                    }
                    if(intQueMap.get(iq).Object_Name__c == LeadOT && ld1.SubExpo__c == null && intQueMap.get(iq).SubExpo__c == null && ld1.FirstName == intQueMap.get(iq).Contact__r.FirstName && ld1.LastName == intQueMap.get(iq).Contact__r.LastName && ld1.EE_Campaign__c == intQueMap.get(iq).Campaign__c && ld1.Event__c == intQueMap.get(iq).Event__c && ld1.Product__c == intQueMap.get(iq).Product__c){
						EE_Integration_Archive__c IA = new EE_Integration_Archive__c();
                        IA.Target_Id__c = ld1.Id;
                        IA.Contact__c = intQueMap.get(iq).Contact__c;
                        IA.Event__c = intQueMap.get(iq).Event__c;
                        IA.External_Id__c = intQueMap.get(iq).External_Id__c;
                        IA.Product__c = intQueMap.get(iq).Product__c;
                        IA.Source_Id__c = intQueMap.get(iq).Id;
                        IA.Source_Created_Date__c = intQueMap.get(iq).SystemModstamp;
                        IA.SubExpo__c = intQueMap.get(iq).SubExpo__c;
                        IA.Target_Created_Date__c = ld1.SystemModstamp;
						IA.Status__c = 'Duplicate';
                        IA.Name = intQueMap.get(iq).Object_Name__c;
                        IA.Campaign__c = intQueMap.get(iq).Campaign__c;
						IA.Description__c = 'Target Id field refers to existing Lead record';
                        insertIASet.add(IA);
                        processedIQIdSet.add(iq);
                        processedIQArchiveRecordSet.add(intQueMap.get(iq)); 
                        system.debug('Del*'+processedIQArchiveRecordSet);
                    }
                }
            }
        }
        //If there are no existing leads    
        if(intQueMap.Size() > 0 ){
            for(Id iq: intQueMap.keyset()){
				if(!processedIQIdSet.contains(iq)){
					if(objNameSet.size()>0 && intQueMap.get(iq).Object_Name__c == LeadOT){
                        Lead ld= new Lead();
                        if(intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c != Null){
                            ld.OwnerId = intQueMap.get(iq).Campaign__r.Event__r.Show__r.Attendee_Owner__c;
                        }
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
							IA.Status__c = 'New';
                            IA.SubExpo__c = IQ.SubExpo__c;
                            IA.Campaign__c = leadMap.get(lead).EE_Campaign__c;
                            IA.Target_Created_Date__c = leadMap.get(lead).SystemModstamp;
                            IA.Name = IQ.Object_Name__c;
                            insertIASet.add(IA);
                            processedIQArchiveRecordSet.add(IQ);
                            system.debug('Del******'+processedIQArchiveRecordSet);
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

            for(CronTrigger ct: [select Id from CronTrigger where CronJobDetail.Name like 'EE_Job_MCInboundLeadIntegration%']){
                flgNewBatch = false;
            }

            for(AsyncApexJob aaj: [select Id from AsyncApexJob where ApexClass.Name like 'EE_Job_MCInboundLeadIntegration%' and Status!= 'Completed' and Status != 'Aborted' and Status!= 'Failed']){
                flgNewBatch = false;
            }

            if(flgNewBatch){
                EE_Job_MCInboundLeadIntegration b = new EE_Job_MCInboundLeadIntegration();
                try{
                    System.scheduleBatch(b,'EE_Job_MCInboundLeadIntegration' + string.Valueof(datetime.now().getTime()), 60, 1);
                }
                catch(Exception e){
                }
                catch(UnexpectedException ue){
                }
            }
        }      
    } 

}