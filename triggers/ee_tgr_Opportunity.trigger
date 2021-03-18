trigger ee_tgr_Opportunity on Opportunity ( After insert, After Update) {
  public static String Attendee = 'Attendee';
  if(Trigger.isAfter && Trigger.isInsert) {  
    Set<Id> oppIds = new Set<Id>();
    Set<Id> ConvOppIds = new Set<Id>();
    // 06/12/19 Spoorthy Teegala - to pass Opportunity Ids to addContactRoleByShow method of OpportunityTgr class
    Map<Id,Opportunity> AddCRonOppIds = new Map<Id,Opportunity>();
    
    for(Opportunity op: Trigger.new) {
      system.debug('op.Lead id'+op.Lead_Id__c);
      if(op.EE_Record_Type__c != Attendee){
        if(op.Lead_Id__c == null){
          oppIds.add(op.Id); 
        }

        if(op.Lead_Id__c != null){
          ConvOppIds.add(op.Id); 
        }
        //Add Contact roles on Opportunity
        AddCRonOppIds.put(op.Id,op);
      }
    } 
    if(oppIds.size() > 0){
      EE_DefaultOpportunityOwner.DefaultOpportunityOwner(oppIds);  
      system.debug('oppid'+oppIds);
    }

    if(ConvOppIds.size() > 0 ){
      EE_UpsertShowAccountOwner.AccountOwnerUpsert(ConvOppIds);
      system.debug('ConvOppIds'+ConvOppIds);
    }

    if(AddCRonOppIds.size() > 0){
      EE_AddContactRoleByShow addContactRoleByShow = new EE_AddContactRoleByShow();
      addContactRoleByShow.addContactRoleByShow(AddCRonOppIds);
    }
  }   

  if(Trigger.isAfter && Trigger.isUpdate){
    Set<Id> oppIdSet = new Set<Id>();

    for(ID OPPID: Trigger.newMap.keySet()) {
      if(Trigger.newMap.get(OPPID).EE_Record_Type__c != Attendee){

        system.debug('Trigger.newMap.get(OPPID).Lead_Id__c'+Trigger.newMap.get(OPPID).Lead_Id__c);
        system.debug('Trigger.oldMap.get(OPPID).Lead_Id__c'+Trigger.oldMap.get(OPPID).Lead_Id__c );
        if(Trigger.newMap.get(OPPID).Lead_Id__c != Trigger.oldMap.get(OPPID).Lead_Id__c ||(Trigger.newMap.get(OPPID).Lead_Id__c != Trigger.oldMap.get(OPPID).Lead_Id__c && Trigger.newMap.get(OPPID).ownerID != Trigger.oldMap.get(OPPID).ownerID )|| (Trigger.oldMap.get(OPPID).stageName != 'Sold' && Trigger.newMap.get(OPPID).stageName == 'Sold')){
          oppIdSet.add(OPPID);
        }
      }
    }
    if(oppIdSet.size()>0) {
      EE_UpsertShowAccountOwner.AccountOwnerUpsert(oppIdSet);
    }
  } 
}