trigger ee_tgr_contact on Contact (After insert, Before Update, After Update, After Delete) 
{
    if(Trigger.isbefore && Trigger.isUpdate){
        EE_ContactTgrHandler ContTgrHandler = new EE_ContactTgrHandler();
        ContTgrHandler.UpdateContactEmailHygiene(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isDelete)
    {
        List <ObjectMergedHistory__c> omh = new List <ObjectMergedHistory__c>();
        for(Contact cont:trigger.old){
            if(String.isNotBlank(cont.MasterRecordID)){
                omh.add(new ObjectMergedHistory__c(name = cont.FirstName,From_ID__C = cont.ID,
                To_ID__C = cont.masterRecordID,type__c = 'Contact'));
            }
        }
        if(omh.size() > 0){
            insert omh;
        }
    } 
    if(Trigger.isBefore && Trigger.isUpdate){
        boolean isContactAccessible = EE_UtilityRelationshipType.CurrentUserAccessLevel(UserInfo.getUserId());
        
        for(Contact con: Trigger.new){
            if(con.Relationship_Type__c != Null && con.Relationship_Type__c == 'Attendee' && isContactAccessible == False){
                System.debug('con.Relationship_Type__c'+con.Relationship_Type__c);
                System.debug('isContactAccessible'+isContactAccessible);
                con.addError('******** You do not have access to edit Attendee records. ********');
            }
        }
    }
}