/*
Dev: Spoorthy Teegala
Date: 05/15/2020
Description: Trigger handler to default task related to to Campaign.
*/

public class EE_DefaultTaskRecordType{

    public static void defaultTaskRecordType(List<Task> tastEventList){

        //Id attendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId();
        //Id exhibitorRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Exhibitor').getRecordTypeId();
        Map<string, Id> taskRTMap = new Map<string, Id>();
        Map<Id, String> campaignRTMap = new Map<Id, String>();
        Set<Id> recordTypeIds = new Set<Id>();

        for(RecordType RecordType: [select Id, Name, sObjectType from RecordType where sObjectType='Task' or sObjectType='Campaign']){
            if(RecordType.sObjectType == 'Task'){
                taskRTMap.put(RecordType.Name,RecordType.Id);
            }
            if(RecordType.sObjectType == 'Campaign'){
                campaignRTMap.put(RecordType.Id,RecordType.Name);
            }
            recordTypeIds.add(RecordType.Id);
        }

        List<Id> campaignIdList = new List<Id>();
        Map<Id,Id> campaignRecordTypeMap = new Map<Id,Id>();

        for(Task T: tastEventList){
            if(T.Event__c != null && T.Campaign__c != null){
                campaignIdList.add(t.Campaign__c);
            }
        }
        List<Campaign> campaignList = [select Id, RecordtypeId, RecordType.name FROM Campaign where Id IN: campaignIdList];
        if(campaignList.size()> 0){
            for(Campaign cmpn: campaignList){
                campaignRecordTypeMap.put(cmpn.id,cmpn.RecordtypeId);

            }
        }

        for(Task Tk: tastEventList){
            if(Tk.Event__c != null && Tk.Campaign__c != null){
                for(Id RTID: recordTypeIds){
                    if(campaignRecordTypeMap.get(Tk.Campaign__c) == RTID){
                        String RTName = campaignRTMap.get(RTID);
                        if(Tk.WhatId == Null){
                            Tk.WhatId = Tk.Campaign__c;
                        }
                        Tk.RecordtypeId = taskRTMap.get(RTName);
                    }
                }
            }
        }
    }
    public static void updateTaskRelatedToCampaignHandler(Set<Id> tastIds){
        List<Task> updateTaskList = new List<Task>();
        List<Task> taskList =[Select Id, Campaign__c, WhatId from Task where Id IN:tastIds];
        for(Task t:taskList){
            if(t.Campaign__c != Null && t.Campaign__c != t.WhatId ){
                Task task = new Task();
                task.Id = t.Id;
                if(task.WhatId == Null){
                    task.WhatId = t.Campaign__c;
                }
                updateTaskList.add(task);
                system.debug('updateTaskList'+updateTaskList);
            }
        }
        if(updateTaskList.Size()>0){
            update updateTaskList;
        }
    }
}