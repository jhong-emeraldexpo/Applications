//This Class was redesigned 6/16/2020  by Tom Lopilato to address certain issues - ee_UtilityValues.

public class EE_Task {
    
    public static String CaretSign = '^';   
    public static String PlusSign = '+';
    Public Static Void createOpportunityFromPardotTask(List <Task> newTaskList){
        
        list<Task> pardotTaskList = new list<Task>();
        set<id> taskAccIdset = new set<id>();
        Set<Lead> pardotLeadId = new Set<Lead>();
        List<Lead> pardotLeadIdList = new List<Lead>();
        map<string, Task> leadIdTaskMap = new map<string, Task>();
        set<id> contactIdSet = new set<id>();
        
        for(Task t : newTaskList){
            if(t.is_pardot_task__c == TRUE){
                pardotTaskList.add(t);
                taskAccIdset.add(t.AccountId);
                String Lead_prefix = Schema.SObjectType.lead.getKeyPrefix();
                String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
                if(t.whoId !=null && ((String)t.WhoId).startsWith(Lead_prefix))
                    leadIdTaskMap.put(t.WhoId, t);
                if(t.whoId !=null && ((String)t.WhoId).startsWith(contact_prefix))
                    contactIdSet.add(t.whoId);
            }
        }
        
        system.debug('# newTaskList : '+newTaskList);
        map<string, Event__c> eventCodeToEventMap = new map<string, Event__c>();
        map<string, Event__c> showEventMap = new map<string, Event__c>();
        Set<string> eventCodeSet = new set<string>();   
        map<string, string> taskIdEventCodeMap = new map<string, string>();
        map<string, string> taskIdCampShortDescMap = new map<string, string>();
        map<string, string> taskIdProductMap = new map<string, string>();
        map<string, string> taskIdSubShowNameMap = new map<string, string>();
        map<string, string> taskIdLeadSourceMap = new map<string, string>();
        map<string, SubExpo__c> subExpoMap = new map<string, SubExpo__c>();
        Set<String> subShowNameSet = new Set<String>();
        
        if(!pardotTaskList.isEmpty()){
            for(Event__c event : [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c, Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c ORDER BY Stage_Date__c ASC Limit 49999 ]){
                if(event.Stage_Date__c >= System.Today() && !showEventMap.keySet().Contains(event.Show__c))
                    showEventMap.put(event.Show__c, event);
                eventCodeToEventMap.put(event.Event_Code__c, event);
            }           
            for(Task t : pardotTaskList){
                String pSubShowName = '_None';
                String pSubShowName1 = '_None';
                List<String> TempTaskParams = t.Subject.split('\\|',-1);
                if (TempTaskParams.size() > 2){
                    eventCodeSet.add(getEventCode(eventCodeToEventMap, showEventMap,TempTaskParams[1]));
                    taskIdEventCodeMap.put(t.Id, getEventCode(eventCodeToEventMap, showEventMap,TempTaskParams[1]));
                    taskIdCampShortDescMap.put(t.Id, TempTaskParams[2]);
                }
                if (TempTaskParams.size() > 4){
                    taskIdProductMap.put(t.Id, TempTaskParams[4]);
                }
                if (TempTaskParams.size() > 5){
                    if(TempTaskParams[5].Contains(CaretSign)){
                        subShowNameSet.add(TempTaskParams[5]);
                        system.debug('&&&&&&&'+subShowNameSet);
                        pSubShowName = TempTaskParams[5];
                        pSubShowName1 = pSubShowName.Replace(CaretSign,PlusSign);
                       
                        taskIdSubShowNameMap.put(t.Id, pSubShowName1);
                        system.debug('&&&&&&&'+taskIdSubShowNameMap);
                    }else{
                        taskIdSubShowNameMap.put(t.Id,TempTaskParams[5]);
                        system.debug('!!!!!!!!!!!!'+taskIdSubShowNameMap);
                    }
                }
                if (TempTaskParams.size() > 3){
                    taskIdLeadSourceMap.put(t.Id, TempTaskParams[3]);
                }
            }
        }
        System.debug('# eventCodeSet : '+eventCodeSet);
        if(!eventCodeSet.isEmpty() && !taskIdSubShowNameMap.isEmpty()){
            for(SubExpo__c subExpo : [select id,Event_code__c,subshow__r.name, subshow__r.show__c, subshow__c from SubExpo__c where subshow__r.name IN:taskIdSubShowNameMap.Values() and Event_Code__c IN: eventCodeSet]){
                subExpoMap.put(''+subExpo.Event_Code__c+subExpo.subshow__r.name.toLowerCase(), subExpo);
            }
        }
        
        System.debug('# subExpoMap : '+subExpoMap);
        Set<Id> accountIdWithoutOppSet = new Set<Id>();
        Set<Id> accountIdWithOppSet = new Set<Id>();
        Map<Id, Opportunity> oppsWithSubShowMap = new map<Id, Opportunity>();
        Map<Id, Opportunity> oppsWithoutSubShowMap = new map<Id, Opportunity>();
        list<Task> pardotTasksWithoutOppList = new List<Task>();
        map<string, lead> insertedLeadMap = new map<string,lead >();
        
        String pEventCode = '';
        String pCampaignShortDesc = '';
        String pLeadSource = '';
        String pProduct = '';
        String pSubShowName = '_None';
        
        //For Task with Opportunity
        if(!taskAccIdset.isEmpty()){
            for(Opportunity opp : [Select ID, OwnerId, Owner.IsActive, accountId, Event_code__c, event__c, SubExpo__c, SubExpo__r.SubShow__r.Name, 
                                        SubShow__c, Product__c, Stage_order__c, lastmodifiedDate from opportunity where Accountid IN: taskAccIdset AND Event_code__c IN: eventCodeSet AND  Owner.IsActive = true order by Stage_order__c ASC, lastmodifiedDate Desc]){
                accountIdWithOppSet.add(opp.accountId);
                if(opp.SubExpo__c != null && !oppsWithSubShowMap.KeySet().Contains(opp.accountId))
                    oppsWithSubShowMap.put(opp.accountId, opp);
                if(opp.SubExpo__c == null && !oppsWithoutSubShowMap.KeySet().Contains(opp.accountId))
                    oppsWithoutSubShowMap.put(opp.accountId, opp);
            }
            system.debug('# accountIdWithOppSet : '+accountIdWithOppSet);
            for(Id accId : taskAccIdset){
                if(!accountIdWithOppSet.Contains(accId))
                    accountIdWithoutOppSet.add(accId);
            }
        }
        System.debug('# oppsWithoutSubShowMap : '+oppsWithoutSubShowMap);
        System.debug('# oppsWithSubShowMap : '+oppsWithSubShowMap);
        System.debug('# accountIdWithoutOppSet : '+accountIdWithoutOppSet);
        for(Task t : newTaskList){
            if(t.AccountId != null && accountIdWithoutOppSet.Contains(t.AccountId))
                pardotTasksWithoutOppList.add(t);
        }
        System.debug('# pardotTasksWithoutOppList : '+pardotTasksWithoutOppList);
        
        Opportunity tempOpp = new Opportunity();
        list<Task> pardotTasksWithOpps = new list<Task>();
        list<Task> pardotTasksWithoutOpps = new list<Task>();
        set<Id> ProcessedOpportunityTaskIdSet = new set<Id>();
        list<Opportunity> addPardotCommentsOppList = new list<Opportunity>();
        Map<string, Opportunity> addPardotCommentsOppMap = new map<string, Opportunity>();
        system.debug('# pardotTaskList : '+pardotTaskList);
        for(task pardotTask : pardotTaskList){
            system.debug('# Opp pardotTask : '+pardotTask);
            pEventCode = taskIdEventCodeMap != null && taskIdEventCodeMap.keySet().Contains(pardotTask.Id) ? taskIdEventCodeMap.get(pardotTask.Id) : '';
            pCampaignShortDesc = taskIdCampShortDescMap != null && taskIdCampShortDescMap.keySet().Contains(pardotTask.Id) ? taskIdCampShortDescMap.get(pardotTask.Id) : '';
            pProduct = taskIdProductMap != null && taskIdProductMap.keySet().Contains(pardotTask.Id) ? taskIdProductMap.get(pardotTask.Id) : '';
            pSubShowName = taskIdSubShowNameMap != null && taskIdSubShowNameMap.keySet().Contains(pardotTask.Id) ? taskIdSubShowNameMap.get(pardotTask.Id) : '_None';
            pSubShowName = pSubShowName.Contains(CaretSign) && subShowNameSet.Contains(pSubShowName)? pSubShowName.Replace(CaretSign,PlusSign):pSubShowName;
            String pardotActiveEventCode = getEventCode(eventCodeToEventMap, showEventMap,pEventCode);
            tempOpp = new Opportunity();
            Opportunity currentOpp = new Opportunity();
            if(pardotTask.AccountId != null && oppsWithSubShowMap.KeySet().Contains(pardotTask.AccountId)){
                currentOpp = oppsWithSubShowMap.get(pardotTask.AccountId);
                if(pardotActiveEventCode == currentOpp.Event_Code__c && currentOpp.SubExpo__r.SubShow__r.Name == pSubShowName && currentOpp.Product__c != '' && (currentOpp.Product__c == pProduct || currentOpp.Product__c != pProduct)){
                    Task ta = new task(id = pardotTask.Id);
                    ta.OwnerId = currentOpp.ownerid;
                    ta.whatid = currentOpp.ID;
                    //Save the original subject from Pardot before overriding it.
                    ta.pi_ee_Subject__c = pardotTask.Subject;
                    ta.Subject = pCampaignShortDesc;
                    System.debug('# Task__EE: Task ID (Subject) = ' + pardotTask.Id + ',Subject = ' + ta.Subject + ',pi_ee_Subject__c = ' + ta.pi_ee_Subject__c );
                    pardotTasksWithOpps.add(ta);
                    //processedPardotTaskSet1.add(pardotTask.id);
                    ProcessedOpportunityTaskIdSet.add(pardotTask.id);
                    //Opportunity tempOpp = new Opportunity();
                    tempOpp.Id = currentOpp.ID;
                    tempOpp.pi_ee_comments__c = pardotTask.Subject;
                    addPardotCommentsOppList.add(tempOpp);
                    addPardotCommentsOppMap.put(tempOpp.Id, tempOpp);
                }
            }
            
            tempOpp = new Opportunity();
            if(pardotTask.AccountId != null && oppsWithoutSubShowMap.KeySet().Contains(pardotTask.AccountId)){
                currentOpp = oppsWithoutSubShowMap.get(pardotTask.AccountId);
                system.debug('# pardotActiveEventCode : '+pardotActiveEventCode);
                if(pardotActiveEventCode == currentOpp.Event_Code__c && currentOpp.Product__c != '' && (currentOpp.Product__c == pProduct || currentOpp.Product__c != pProduct ) ){
                    Task ta = new task(id = pardotTask.Id);
                    ta.OwnerId = currentOpp.ownerid;
                    ta.whatid = currentOpp.ID;
                    //Save the original subject from Pardot before overriding it.
                    ta.pi_ee_Subject__c = pardotTask.Subject;
                    ta.Subject = pCampaignShortDesc;
                    System.debug('Task__EE: Task ID (Subject) = ' + pardotTask.Id + ',Subject = ' + ta.Subject + ',pi_ee_Subject__c = ' + ta.pi_ee_Subject__c );
                    pardotTasksWithOpps.add(ta);
                    // processedPardotTaskSet2.add(pardotTask.Id);
                    ProcessedOpportunityTaskIdSet.add(pardotTask.id);
                    //Opportunity tempOpp = new Opportunity();
                    tempOpp.Id = currentOpp.ID;
                    tempOpp.pi_ee_comments__c = pardotTask.Subject;

                    addPardotCommentsOppList.add(tempOpp);
                    addPardotCommentsOppMap.put(tempOpp.Id, tempOpp);
                }   
            }           
            system.debug('# pardotTasksWithoutOpps : '+pardotTasksWithoutOpps);
            if(!ProcessedOpportunityTaskIdSet.contains(pardotTask.Id))
                pardotTasksWithoutOpps.add(pardotTask);
        }
        
        map<id, Lead> leadMap = new map<Id, Lead>();
        for(Lead ld: [Select Id, LeadToEvent__c, Event__r.event_code__c, LeadToEvent__r.Event_Code__c, FirstName,LastName, Email, phone, Company, status, ownerId, Event__c, pi_ee_Event_Code__c, SubExpo__c, Street, City, State, PostalCode, Country, LeadSource, Product__c, pi__url__c  from Lead where Id IN: leadIdTaskMap.KeySet() ]){
                leadMap.put(ld.id, ld);
        }
        system.debug('# leadMap : '+leadMap);
        list<Lead> leadUpdateList = new list<Lead>();
        if(!leadIdTaskMap.Keyset().isEmpty()){
            for(Task t : leadIdTaskMap.Values()){
                pEventCode = taskIdEventCodeMap != null && taskIdEventCodeMap.keySet().Contains(t.Id) ? taskIdEventCodeMap.get(t.Id) : '';
                pCampaignShortDesc = taskIdCampShortDescMap != null && taskIdCampShortDescMap.keySet().Contains(t.Id) ? taskIdCampShortDescMap.get(t.Id) : '';
                pProduct = taskIdProductMap != null && taskIdProductMap.keySet().Contains(t.Id) ? taskIdProductMap.get(t.Id) : '';
                pSubShowName = taskIdSubShowNameMap != null && taskIdSubShowNameMap.keySet().Contains(t.Id) ? taskIdSubShowNameMap.get(t.Id) : '_None';
                pSubShowName = pSubShowName.Contains(CaretSign) && subShowNameSet.Contains(pSubShowName)? pSubShowName.Replace(CaretSign,PlusSign):pSubShowName;
                Lead tlead = new Lead();
                
                if(eventCodeToEventMap.KeySet().Contains(pEventCode) && subExpoMap.keySet().Contains(''+pEventCode+pSubShowName.toLowerCase()) && leadMap.keySet().Contains(t.WhoId) && (pEventCode != leadMap.get(t.WhoId).Event__r.event_code__c || leadMap.get(t.WhoId).status != 'Active' || subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()).Id  != leadMap.get(t.WhoId).SubExpo__c )){
                    Lead taskLead = new Lead();
                    taskLead.Id = leadMap.get(t.whoId).Id;
                    taskLead.SubExpo__c = subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()).Id;
                    taskLead.Ref__c = leadMap.get(t.whoId).Id;
                    leadUpdateList.add(taskLead);
                }else if(eventCodeToEventMap.KeySet().Contains(pEventCode) && leadMap.keySet().Contains(t.WhoId) && (pEventCode != leadMap.get(t.WhoId).Event__r.event_code__c || leadMap.get(t.WhoId).status != 'Active'  ) ){
                    Lead taskLead = new Lead();
                    taskLead.Id = leadMap.get(t.whoId).Id;
                    taskLead.Ref__c = leadMap.get(t.whoId).Id;
                    leadUpdateList.add(taskLead);
                }
            }
        }
        
        if(!leadUpdateList.isEmpty()){
            Update leadUpdateList;
            system.debug('##### : '+leadUpdateList);
            
            set<id> leadIdSet = new set<Id>();
            List<Task> TasksToLinktoNewLeads = new List<Task>();
            for(Lead l : leadUpdateList)
                leadIdSet.add(l.Id);
            
            for(Lead le : [Select Id, FirstName, LastName, Email, phone, pi_ee_Event_Code__c,pi_ee_Campaign_Short_Desc__c, ownerId, Ref__c from Lead where Id IN: leadIdSet])
                insertedLeadMap.put(''+le.ref__c, le);   
                system.debug('##### : '+insertedLeadMap);
            
            for(Task tmpTask : leadIdTaskMap.Values()){
                system.debug('# leadIdTaskMap : '+leadIdTaskMap);
                system.debug('##### : '+insertedLeadMap.get(tmpTask.whoId));
                if(insertedLeadMap.get(tmpTask.whoId) != Null){
                    Task task2Close = new Task();
                    
                    task2Close.Id = tmpTask.Id;
                    task2Close.OwnerId = insertedLeadMap.get(tmpTask.whoId).OwnerId;
                    task2Close.Status = 'Completed';
                    task2Close.Activity_Result__c = 'Lead Created';
                    task2Close.whoId = insertedLeadMap.keySet().contains(''+tmpTask.whoId) ? insertedLeadMap.get(''+tmpTask.whoId).Id : tmpTask.whoId; 
                    task2Close.whatId = null;
                    task2Close.pi_ee_Subject__c = tmpTask.Subject;
                    task2Close.Subject = insertedLeadMap.get(tmpTask.whoId).pi_ee_Campaign_Short_Desc__c;
                    system.debug('# task2Close : '+task2Close);
                    TasksToLinktoNewLeads.add(task2Close); 
                    
                }
            }
            if(!TasksToLinktoNewLeads.isEmpty())
                update TasksToLinktoNewLeads;
        }
        
        list<Lead> newLeads = new list<Lead>();
        set<string>InvalidEventCodes = new set<string>();
        list<Task> existingLeadTasks = new list<Task>();
        list<Task> ErrorStatusTasksList = new list<Task>();
        if(!pardotTasksWithoutOpps.isEmpty()){
            set<id> whoIdSet = new set<Id>();
            set<string> contactEmailIdSet = new set<string>();
            set<string> contactPhoneSet = new set<string>();
            map<string, Contact> contactMap = new map<string, Contact>();
            set<string> contactAccntIdSet = new set<string>();
            
            
            if(!contactIdSet.isEmpty()){
                for(Contact con : [select Id, FirstName, LastName, AccountId, Account.Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,  pi__url__c  from contact where ID IN:contactIdSet]){
                    contactEmailIdSet.add(con.email);
                    contactPhoneSet.add(con.phone);
                    contactMap.put(con.Id,con);
                    contactAccntIdSet.add(con.AccountId);
                }
            }
            
            Set<Id> AccountOwnerIds =new Set<Id>();
            Set<Id> ShowIds = new Set<Id>();
            Set<Id> SubshowIds =new Set<Id>();
            Map<Id,AccountOwners__c> aoWithShowandSubShowMap = new Map<Id,AccountOwners__c>();
            Map<Id,AccountOwners__c> aoWithonlyShowMap = new Map<Id,AccountOwners__c>();
            Map<Id,AccountOwners__c> aoAccountIdMap = new Map<Id,AccountOwners__c>();
            map<string, Lead> existingLeadMap = new map<string, Lead>();
            if(!ContactAccntIdSet.isEmpty()){
                for(AccountOwners__c AO: [ SELECT Id, AccountOwner__c, AccountOwner__r.IsActive, Account__c,Show__c, Show__r.Id, SubShow__c, SubShow__r.Name, SubShow__r.Id FROM AccountOwners__c where AccountOwner__r.IsActive = True and Account__c IN: ContactAccntIdSet]){
                    AccountOwnerIds.add(AO.AccountOwner__c);
                    ShowIds.add(AO.Show__c);
                    SubshowIds.add(AO.SubShow__c);
                    aoAccountIdMap.put(AO.Account__c, AO);
                    if(ao.Show__c != null && ao.SubShow__c == null){
                        aoWithonlyShowMap.put(ao.show__c, ao);
                    }
                    if(ao.Show__c != null && ao.SubShow__c != null){
                        aoWithShowandSubShowMap.put(ao.show__c, ao);
                    }
                }
            }
            
            if(!ContactEmailIdSet.isEmpty() && !eventCodeSet.isEmpty()){
                for(Lead l: [Select Id, FirstName, LastName, Event__r.Event_Code__c, SubExpo__r.SubShow__r.Name, Email, Phone, OwnerId from Lead where Event__r.Event_Code__c IN: eventCodeSet and (Email IN: ContactEmailIdSet OR Phone IN: ContactPhoneSet)]){
                    existingLeadMap.put(l.Id, l);                    
                    /*if(!string.isBlank(l.email)){
                        existingLeadsEmailSet.add(l.email);
                    }
                    if(!string.isBlank(l.phone)){
                        existingLeadsPhoneSet.add(l.phone);
                    }
                    */
                }
            }
            
            Set<id> ErrorContactIdSet = new set<id>();
            
            for(task taskup : pardotTasksWithoutOpps){
                pEventCode = taskIdEventCodeMap != null && taskIdEventCodeMap.keySet().Contains(taskup.Id) ? taskIdEventCodeMap.get(taskup.Id) : '';
                pCampaignShortDesc = taskIdCampShortDescMap != null && taskIdCampShortDescMap.keySet().Contains(taskup.Id) ? taskIdCampShortDescMap.get(taskup.Id) : '';
                pProduct = taskIdProductMap != null && taskIdProductMap.keySet().Contains(taskup.Id) ? taskIdProductMap.get(taskup.Id) : '';
                pSubShowName = taskIdSubShowNameMap != null && taskIdSubShowNameMap.keySet().Contains(taskup.Id) ? taskIdSubShowNameMap.get(taskup.Id) : '_None';
                pSubShowName = pSubShowName.ContainsAny(CaretSign) && subShowNameSet.Contains(pSubShowName)? pSubShowName.Replace(CaretSign,PlusSign):pSubShowName;
                pLeadSource = taskIdLeadSourceMap != null && taskIdLeadSourceMap.keySet().Contains(taskup.Id) ? taskIdLeadSourceMap.get(taskup.Id) : '';                
                
                if(contactMap.keySet().Contains(taskup.WhoId)){
                    if(taskup.Status == 'Not Started' && contactMap.get(taskup.WhoId).email == null && contactMap.get(taskup.WhoId).email == null){
                        Task ErrorTask = new Task();
                        ErrorTask.Id = taskup.Id;
                        ErrorTask.status = 'error';
                        ErrorStatusTasksList.add(ErrorTask);                           
                        ErrorContactIdSet.add(contactMap.get(taskup.WhoId).Id);
                    }
                }
                boolean hasLead = false;
                
                if(existingLeadMap.size() > 0){
                    for(Lead currentLead: existingLeadMap.Values()){                                     
                        if(ContactMap.get(taskup.WhoId) != null && ContactMap.get(taskup.WhoId).LastName == currentLead.LastName && !ErrorContactIdSet.contains(ContactMap.get(taskup.WhoId).Id) && (String.isNotBlank(currentLead.Email) || String.isNotBlank(currentLead.phone)) && (ContactMap.get(taskup.WhoId).Email == currentLead.Email || ContactMap.get(taskup.WhoId).phone == currentLead.phone) && String.isNotBlank(currentLead.Event__r.Event_Code__c) && pEventCode == currentLead.Event__r.Event_Code__c && String.isNotBlank(currentLead.SubExpo__r.SubShow__r.Name) && currentLead.SubExpo__r.SubShow__r.Name == pSubShowName) {
                            Task ta = new task(id = taskup.Id);
                            ta.OwnerId = currentLead.ownerId;
                            ta.Status = 'Not Started';
                            ta.Activity_Result__c = '';
                            ta.whoId = currentLead.Id;
                            ta.pi_ee_Subject__c = taskup.Subject;
                            ta.Subject = pCampaignShortDesc;
                            existingLeadTasks.add(ta);
                            hasLead = true;
                            break;
                        }
                        if(ContactMap.get(taskup.WhoId) != null && ContactMap.get(taskup.WhoId).LastName == currentLead.LastName && !ErrorContactIdSet.contains(ContactMap.get(taskup.WhoId).Id) && (String.isNotBlank(currentLead.Email) || String.isNotBlank(currentLead.phone)) && (ContactMap.get(taskup.WhoId).Email == currentLead.Email || ContactMap.get(taskup.WhoId).phone == currentLead.phone) && String.isNotBlank(currentLead.Event__r.Event_Code__c) && pEventCode == currentLead.Event__r.Event_Code__c && String.isBlank(currentLead.SubExpo__r.SubShow__r.Name) && pSubShowName == '_None') {
                            Task ta = new task(id = taskup.Id);
                            ta.OwnerId = currentLead.ownerId;
                            ta.Status = 'Not Started';
                            ta.Activity_Result__c = '';
                            ta.whoId = currentLead.Id;
                            ta.pi_ee_Subject__c = taskup.Subject;
                            ta.Subject = pCampaignShortDesc;
                            existingLeadTasks.add(ta);
                            hasLead = true;
                            break;
                        }
                    }
                }
                
                if(eventCodeToEventMap.keySet().Contains(pEventCode) && subExpoMap.keySet().Contains(''+pEventCode+pSubShowName.toLowerCase()) && ContactMap.get(taskup.WhoId) != null && !ErrorContactIdSet.contains(taskup.WhoId) && !hasLead){ //&& (!existingLeadsEmailSet.Contains(ContactMap.get(taskup.WhoId).Email) || !existingLeadsEmailSet.Contains(ContactMap.get(taskup.WhoId).phone) )
                    Lead newLead = new Lead();
                    newLead = createLeadFromContact(ContactMap.get(taskup.WhoId),eventCodeToEventMap.get(pEventCode), subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()), pLeadSource, pProduct, pCampaignShortDesc, pSubShowName,  pEventCode);
                    if(aoWithShowandSubShowMap.size() > 0 && aoWithShowandSubShowMap.containsKey(eventCodeToEventMap.get(pEventCode).show__c) && aoAccountIdMap.containsKey(ContactMap.get(taskup.WhoId).AccountId)){
                        if(aoWithShowandSubShowMap.get(eventCodeToEventMap.get(pEventCode).show__c).show__c == eventCodeToEventMap.get(pEventCode).show__c && aoWithShowandSubShowMap.get(subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()).subshow__r.show__c).subshow__c == subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()).subshow__c ){
                            newLead.OwnerId = aoWithShowandSubShowMap.get(subExpoMap.get(''+pEventCode+pSubShowName.toLowerCase()).subshow__r.show__c).AccountOwner__c;
                            newLead.Should_Ignore_Assignment_Rule__c = True;
                        }
                    }
                    newLeads.add(newLead);
                    InvalidEventCodes.remove(String.ValueOf(eventCodeToEventMap.get(pEventCode).Event_code__c));
                }else if(eventCodeToEventMap.keySet().Contains(pEventCode)  && ContactMap.get(taskup.WhoId) != null && !ErrorContactIdSet.contains(taskup.WhoId) && !hasLead){
                    Lead newLead = new Lead();
                    newLead = createLeadFromContact(ContactMap.get(taskup.WhoId),eventCodeToEventMap.get(pEventCode), null, pLeadSource, pProduct, pCampaignShortDesc, pSubShowName,  pEventCode);
                    if(aoWithonlyShowMap.size() >0 && aoWithonlyShowMap.containsKey(eventCodeToEventMap.get(pEventCode).show__c) && aoAccountIdMap.containsKey(ContactMap.get(taskup.WhoId).AccountId)){
                        if(aoWithonlyShowMap.get(eventCodeToEventMap.get(pEventCode).show__c).show__c == eventCodeToEventMap.get(pEventCode).show__c ){
                            newLead.OwnerId = aoWithonlyShowMap.get(eventCodeToEventMap.get(pEventCode).show__c).AccountOwner__c;
                            newLead.Should_Ignore_Assignment_Rule__c = True;
                        }
                    }
                    newLeads.add(newLead);
                    InvalidEventCodes.remove(String.ValueOf(eventCodeToEventMap.get(pEventCode).Event_code__c));
                }
                
                if(InvalidEventCodes.size() > 0 && ContactMap.get(taskup.WhoId) != null && !ErrorContactIdSet.contains(taskup.WhoId)  && !hasLead) { 
                    Lead newLead = new Lead();
                    newLead = createLeadFromContact(ContactMap.get(taskup.WhoId),null, null, pLeadSource, pProduct, pCampaignShortDesc, pSubShowName,  pEventCode);
                    newLead.pi_ee_Event_Code__c = String.ValueOf((new list<string>(InvalidEventCodes))[0]);
                    newLead.Description = 'Invalid event Code is:' +String.ValueOf((new list<string>(InvalidEventCodes))[0]);
                    newLeads.add(newLead);
                    InvalidEventCodes.remove(String.ValueOf((new list<string>(InvalidEventCodes))[0]));
                }
                
            }
        }
        
        if(!pardotTasksWithOpps.IsEmpty()){
            list<task> tempPardotTasksWithOpps = new List<Task>();
            tempPardotTasksWithOpps.addAll(pardotTasksWithOpps);
            system.debug('# tempPardotTasksWithOpps '+tempPardotTasksWithOpps);
            update tempPardotTasksWithOpps;
            system.debug('# addPardotCommentsOppList '+addPardotCommentsOppList);
            //Update addPardotCommentsOppList;
            Update addPardotCommentsOppMap.values();
            system.debug('# addPardotCommentsOppMap : '+addPardotCommentsOppMap);
        }
    system.debug('# pardotTasksWithoutOpps : '+pardotTasksWithoutOpps);
        if(newLeads.size() > 0){
            insert newLeads;
            List<string> LeadIdsList = new List<string>();
            for(lead tmpld: newLeads){
                LeadIdsList.add(tmpld.Id);
            }

            for(Lead le : [Select Id, FirstName, LastName, ref__c, Email, phone, pi_ee_Event_Code__c,pi_ee_Campaign_Short_Desc__c, ownerId from Lead where Id IN: LeadIdsList])
                insertedLeadMap.put(le.ref__c, le);
            list<task> taskToCloseForWithoutOpp = new list<Task>();
      system.debug('# insertedLeadMap : '+insertedLeadMap);
      
            for(Task tmpTask : pardotTasksWithoutOpps){
                Task task2Close = new Task();
                task2Close.Id = tmpTask.Id;
                task2Close.OwnerId = insertedLeadMap!= null && insertedLeadMap.keySet().Contains(tmpTask.whoId) ? insertedLeadMap.get(tmpTask.whoId).OwnerId : tmpTask.OwnerId;
                task2Close.Status = 'Completed';
                task2Close.Activity_Result__c = 'Lead Created';
                task2Close.whoId = insertedLeadMap.keySet().contains(tmpTask.whoId) ? insertedLeadMap.get(tmpTask.whoId).Id : tmpTask.whoId;
                task2Close.pi_ee_Subject__c = tmpTask.Subject;
                task2Close.Subject = insertedLeadMap!= null && insertedLeadMap.keySet().Contains(tmpTask.whoId) ? insertedLeadMap.get(tmpTask.whoId).pi_ee_Campaign_Short_Desc__c : tmpTask.Subject ;
        system.debug('# task2Close 2 : '+task2Close);
                taskToCloseForWithoutOpp.add(task2Close);   
            }
      
            if(!taskToCloseForWithoutOpp.isEmpty()){
                update taskToCloseForWithoutOpp;
        system.debug('# taskToCloseForWithoutOpp : '+taskToCloseForWithoutOpp);
      }
        }   
        
        if(existingLeadTasks.size() > 0){  
      update existingLeadTasks;
      system.debug('# existingLeadTasks : '+existingLeadTasks);
        }

        if(ErrorStatusTasksList.size() > 0){
            update ErrorStatusTasksList;
      system.debug('# ErrorStatusTasksList : '+ErrorStatusTasksList);
        }
        
        
        

    }
    
    
    public static Lead createLeadFromContact(Contact con, Event__c event, SubExpo__c subExpo, string pLeadSource, string pProduct, string pCampaignShortDesc, string pSubShowName, string pEventCode ){
        Lead tempLead = new Lead();
        tempLead.FirstName = con.FirstName;
        tempLead.LastName = con.LastName;
        tempLead.Company = con.Account.Name;
        tempLead.Email = con.Email;
        tempLead.Phone = con.Phone;
        tempLead.Street = con.MailingStreet;
        tempLead.City = con.MailingCity;
        tempLead.State = con.MailingState;
        tempLead.PostalCode = con.MailingPostalCode;
        tempLead.Country = con.MailingCountry;
        tempLead.Status = 'Active';
        if(event != null)
            tempLead.Event__c = event.Id; 
        if(subExpo != null)
            tempLead.SubExpo__c = subExpo != null ? subExpo.Id : null;
        tempLead.LeadSource = pLeadSource;
        tempLead.Product__c = pProduct;
        tempLead.pi_ee_Campaign_Short_Desc__c = pCampaignShortDesc;
        tempLead.pi_ee_SubShowName__c = pSubShowName;
        tempLead.pi__url__c = con.pi__url__c;
        tempLead.pi_ee_Event_Code__c = pEventCode;
        tempLead.Ref__c = con.Id;
        return tempLead;
    
    }
    
    public static string getEventCode(map<string, Event__c> eventCodeToEventMap, map<string, Event__c> showEventMap, string eventCode){
        string activeEventCode = '';        
        if(eventCodeToEventMap.keySet().Contains(eventCode) && eventCodeToEventMap.get(eventCode).Stage_Date__c < System.Today()){
            if(showEventMap.keySet().Contains(eventCodeToEventMap.get(eventCode).Show__c))
                activeEventCode = showEventMap.get(eventCodeToEventMap.get(eventCode).Show__c).Event_Code__c;           
        }
        if(activeEventCode == '')
            activeEventCode = eventCode;            
        return activeEventCode;
    }

}