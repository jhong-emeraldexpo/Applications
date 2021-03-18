/*


Developer: Spoorthy Teegala
Description: Trigger on Task

*/
trigger ee_tgr_Task on Task(Before insert, After insert, After update){

  Id attendeeRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attendee').getRecordTypeId(); 
  Id exhibitorRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Exhibitor').getRecordTypeId(); 
  if(Trigger.isBefore && Trigger.isInsert){
    List<Task> taskList = new List<Task>();
    for(Task t: Trigger.new){
      if(t.is_pardot_task__c == False && t.Campaign__c != Null && t.IQ_Source_Id__c == Null){
        taskList.add(t);
      }
    }
    if(taskList.size() > 0){
      //EE_DefaultTaskRelatedToCampaignHandler.defaultTaskRelatedToCampaignHandler(taskList);
       EE_DefaultTaskRecordType.defaultTaskRecordType(taskList);
    }
  }

  if(Trigger.isAfter && Trigger.isUpdate){    
    Set<Id> taskIds = new Set<Id>();
    for(ID taskId: Trigger.newMap.keySet()){
           
      if(Trigger.newMap.get(taskId).is_pardot_task__c == False && Trigger.newMap.get(taskId).Campaign__c != Null && Trigger.newMap.get(taskId).Campaign__c != Trigger.oldMap.get(taskId).Campaign__c && Trigger.newMap.get(taskId).RecordTypeId == attendeeRecordTypeId && Trigger.newMap.get(taskId).IQ_Source_Id__c == Null){
        taskIds.add(Trigger.newMap.get(taskId).Id);
      } 
    }
    //EE_DefaultTaskRelatedToCampaignHandler.updateTaskRelatedToCampaignHandler(taskIds);
    EE_DefaultTaskRecordType.updateTaskRelatedToCampaignHandler(taskIds);
    EE_UpdateStatusonCampaignMember.updateStatusOnCampaignMember(taskIds);
  }

  if(Trigger.isAfter && Trigger.isInsert){
    Set<Id> taskIds = new Set<Id>();
    List<Task> taskList = new List<Task>();

    for(ID t: Trigger.newMap.keySet()){
      Id whatid = Trigger.newMap.get(t).WhatId;  
      String sObjName;
          if(string.isnotBlank(whatid)){
              sObjName = whatid.getSObjectType().getDescribe().getName();
          }
      
      if(Trigger.newMap.get(t).is_pardot_task__c == True && Trigger.newMap.get(t).RecordTypeId == exhibitorRecordTypeId){
        taskList.add(Trigger.newMap.get(t));
      } 
      else if(Trigger.newMap.get(t).is_pardot_task__c == False && Trigger.newMap.get(t).WhoId != null && Trigger.newMap.get(t).WhatId != null && Trigger.newMap.get(t).RecordTypeId == attendeeRecordTypeId && sObjName == 'Campaign'){
        taskIds.add(Trigger.newMap.get(t).Id);
        system.System.debug('taskIds'+taskIds);
      }
    }
    if(taskList.size()>0){
      EE_Task.createOpportunityFromPardotTask(taskList);
    }
    if(taskIds.size()>0){
      EE_UpdateStatusonCampaignMember.updateStatusOnCampaignMember(taskIds);
    }
  }
  
}