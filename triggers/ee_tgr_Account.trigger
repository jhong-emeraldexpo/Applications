trigger ee_tgr_Account on Account (After delete, Before update) {

    if(Trigger.isAfter && Trigger.isDelete){
        List <ObjectMergedHistory__c> omh  = new List <ObjectMergedHistory__c>();
 
        for(Account acct:trigger.old){
            if(String.isNotBlank(acct.MasterRecordID)){
                omh.add(new ObjectMergedHistory__c(name = acct.name,From_ID__c = acct.ID,
                To_ID__c = acct.masterRecordID,type__c = 'Account'));
            }
        }
        if(omh.size() > 0){
            insert omh;
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate){

        boolean isAccountAccessible = EE_UtilityRelationshipType.CurrentUserAccessLevel(UserInfo.getUserId());

        for(Account acc: Trigger.new){
            if(acc.Relationship_Type__c != Null && acc.Relationship_Type__c == 'Attendee' && isAccountAccessible == False){
                System.debug('acc.Relationship_Type__c'+acc.Relationship_Type__c);
                acc.addError('******** You do not have access to edit Attendee records. ********');
            }
        }
        
    }
    
}