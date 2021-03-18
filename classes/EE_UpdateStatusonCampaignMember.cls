/*
Dev: Spoorthy Teegala
Date:05/15/2020
Description:Trigger handler to update status on CampaignMember based on task activity result field.
*/
public class EE_UpdateStatusonCampaignMember{

    public static void updateStatusOnCampaignMember(Set<ID> taskIds){
        
        List<CampaignMember> updateCampMemberList = new List<CampaignMember>();
        List<Task> taskList = new List<Task>();
        Set<Id> whoIdSet = new Set<Id>();
        Set<Id> whatIdSet = new Set<Id>();
        Set<Id> contIdSet = new Set<Id>();
        Set<String> productSet = new Set<String>();
        Set<Id> campIdSet = new Set<Id>();
        Set<Id> processedCampMemIdSet = new Set<Id>();
        Set<String> statusValueSet = new Set<String>();
        Set<String> ActResValueSet = new Set<String>();
        List<String> excludeValues = new List<String>();
        List<String> excludeStatusList = new List<String>();

        taskList = [Select Id,Activity_Result__c,Status,whatId,WhoId from Task where Id IN:taskIds AND Activity_Result__c != Null];
        system.debug('taskList'+taskList);
        for(Task task: taskList){
            whoIdSet.add(task.WhoId);
            whatIdSet.add(task.WhatId);
        }

        List<Contact> conList = [Select Id, Relationship_Type__c from Contact where Id IN: whoIdSet];
        system.debug('conList'+conList);
        for(Contact cont: conList){
            contIdSet.add(cont.Id);
        }
           
        List<Campaign> campList = [Select Id, Product__c from Campaign where Id IN:whatIdSet]; 
        system.debug('campList'+campList);
        for(Campaign c: campList){
            productSet.add(c.Product__c);
            campIdSet.add(c.Id);
        }

        Map<String, Activity_Result_Mapping__c> activityResultMappingMap = new Map<String, Activity_Result_Mapping__c>();
        List<Activity_Result_Mapping__c> activityResultMapList = [Select Id, Name, Product__c, Exclude_Statuses__c, Activity_Result__c, SortOrder__c, Campaign_Member_Status_Template__r.Name from Activity_Result_Mapping__c where Product__c IN: productSet AND Activity_Result__c != Null Order By SortOrder__c ASC];
        system.debug('activityResultMapList'+activityResultMapList);
        
		if(activityResultMapList.size() > 0){
            if(String.IsNotBlank(activityResultMapList[0].Exclude_Statuses__c)){
                excludeValues = activityResultMapList[0].Exclude_Statuses__c.split(',');
            }

            if(excludeValues.size() >0){
                for(string exv: excludeValues){
                    excludeStatusList.add(exv.trim());
                }

            }

            system.debug('excludeStatusList'+excludeStatusList);
		}
		
		for(Activity_Result_Mapping__c armmap: activityResultMapList){
			
            activityResultMappingMap.put(String.ValueOf(armmap.SortOrder__c)+armmap.Activity_Result__c,armmap);
			
            if(armmap.SortOrder__c == 4 || armmap.SortOrder__c == 5 || armmap.SortOrder__c == 6){
                statusValueSet.add(armmap.Campaign_Member_Status_Template__r.Name);
                ActResValueSet.add(armmap.Activity_Result__c);
                
            }
        }
        system.debug('statusValueSet'+statusValueSet);

        Id currentUserId = UserInfo.getUserId();
        
        Set<String> statusSet = new Set<String>();
        List<CampaignMember> cMList = [Select Id, CampaignId, Status, ContactId, Owner__c from CampaignMember where CampaignId IN: campIdSet AND ContactId IN: contIdSet AND Owner__c =: currentUserId AND Status NOT IN: excludeStatusList];
        system.debug('cMList'+cMList);
        
        for(Task t: taskList){
            for(Activity_Result_Mapping__c arm: activityResultMapList){
                for(CampaignMember cm: cMList){
					
                    String cmstName = activityResultMappingMap.get(String.ValueOf(arm.SortOrder__c)+arm.Activity_Result__c).Campaign_Member_Status_Template__r.Name;
                    
                    if(!processedCampMemIdSet.contains(cm.Id) && arm.Activity_Result__c.contains(t.Activity_Result__c) && !statusValueSet.contains(cmstName)){
                        CampaignMember campMem = new CampaignMember();
                        campMem.Id = cm.id;
                        campMem.Status = arm.Campaign_Member_Status_Template__r.Name;
                        updateCampMemberList.add(campMem);
                        processedCampMemIdSet.add(cm.id);
                    }
                    if(ActResValueSet.contains(t.Activity_Result__c)){
                        if(!processedCampMemIdSet.contains(cm.Id) && arm.Activity_Result__c.contains(t.Activity_Result__c) && !(cmstName.right(1)).equals((cm.status).right(1)) && ((cm.status).right(1)).isNumeric() == false ){
                            CampaignMember campMem = new CampaignMember();
                            campMem.Id = cm.id;
                            campMem.Status = activityResultMappingMap.get(String.ValueOf(arm.SortOrder__c)+arm.Activity_Result__c).Campaign_Member_Status_Template__r.Name;
                            updateCampMemberList.add(campMem);
                            processedCampMemIdSet.add(cm.id);
                            system.debug('Entered 4');
                        }

                        if(!processedCampMemIdSet.contains(cm.Id) && arm.Activity_Result__c.contains(t.Activity_Result__c) && statusValueSet.contains(cmstName) &&  (cmstName.right(1)).equals((cm.status).right(1)) && arm.SortOrder__c == 4){
                            CampaignMember campMem = new CampaignMember();
                            campMem.Id = cm.id;
                            campMem.Status = activityResultMappingMap.get(String.ValueOf(Integer.ValueOf(arm.SortOrder__c+1))+arm.Activity_Result__c).Campaign_Member_Status_Template__r.Name;
                            updateCampMemberList.add(campMem);
                            processedCampMemIdSet.add(cm.id);
                            system.debug('Entered 5');
                        }
                        if(!processedCampMemIdSet.contains(cm.Id) && arm.Activity_Result__c.contains(t.Activity_Result__c) && statusValueSet.contains(cmstName) && (cmstName.right(1)).equals((cm.status).right(1))  && arm.SortOrder__c == 5){                        
                            CampaignMember campMem = new CampaignMember();
                            campMem.Id = cm.id;
                            campMem.Status = activityResultMappingMap.get(String.ValueOf(Integer.ValueOf(arm.SortOrder__c+1))+arm.Activity_Result__c).Campaign_Member_Status_Template__r.Name;
                            updateCampMemberList.add(campMem);
                            processedCampMemIdSet.add(cm.id);
                            system.debug('Entered 6');
                        }
                    }
					
                }
            }
        }  
        
        if(updateCampMemberList.size()>0){
            update updateCampMemberList;
            System.debug('updateCampMemberList'+updateCampMemberList);
            
        }
    }

}