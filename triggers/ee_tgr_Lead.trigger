trigger ee_tgr_Lead on Lead (Before Insert, After insert, After update) 
{
    Set<Id> leadIDs = new Set<Id>();
    public static String Attendee = 'Attendee';
    if(Trigger.isBefore && Trigger.isInsert){
        List<Lead> newleadsList = new List<Lead>();
        for(Lead newLead: Trigger.new){
            if(String.IsNotBlank(newLead.pi_ee_Event_Code__c) && newLead.EE_Record_Type__c != Attendee){
                newleadsList.add(newLead);
            }
        }
        ee_defaultLeadOwner.addLeadsToQueue(newleadsList);
    }


    if(Trigger.isAfter && Trigger.isInsert) {  
        for(Lead ld: Trigger.new) {
            if(ld.EE_Record_Type__c != Attendee){
                leadIDs.add(ld.Id);
            } 
        } 
        System.debug('ee_tgr_Lead:: isInsert: leadIDs = ' + leadIDs);
        if ( leadIDs.size() > 0) {
            ee_defaultLeadValues.defaultValues(leadIDs);
            ee_defaultLeadOwner.defaultLeadOwner(leadIDs);
        }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        leadIDs.clear();
        Set<Id> OwnerForNewleadsIDSet = new Set<Id>();
        for(ID LID: Trigger.newMap.keySet()) {
            if (Trigger.newMap.get(LID).EE_Record_Type__c != Attendee && Trigger.oldMap.get(LID).Event__c != Trigger.newMap.get(LID).Event__c || Trigger.oldMap.get(LID).SubExpo__c != Trigger.newMap.get(LID).SubExpo__c  ) {
                System.debug('ee_tgr_Lead:: Event__c changed for Lead.ID = ' + LID);
                leadIDs.add(LID); 
            }
            
                //OwnerForNewleadsIDSet.add(LID);
        }

        /*if(EE_RecursiveTriggerHandler.isFirstTime){
            EE_RecursiveTriggerHandler.isFirstTime = false;
            ee_defaultLeadOwner.defaultLeadOwner(OwnerForNewleadsIDSet);
        } */
        System.debug('ee_tgr_Lead:: isUpdate: leadIDs = ' + leadIDs);
        if ( leadIDs.size() > 0) {
            ee_defaultLeadOwner.defaultLeadOwner(leadIDs);
        }


    }    
}