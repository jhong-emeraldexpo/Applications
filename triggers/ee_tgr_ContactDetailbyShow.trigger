/*
Dev: Spoorthy Teegala
Date: 6/18/2020
Desc: Trigger to check duplicate records on Contactt Details by Show Object
*/
trigger ee_tgr_ContactDetailbyShow on Contact_Details_By_Show__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        Set<Id> showIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact_Details_By_Show__c conDetailbyShow : trigger.new){
            showIdSet.add(conDetailbyShow.Show__c);
            contactIdSet.add(conDetailbyShow.Contact__c);
        }
    
        if(showIdSet.size()>0 && contactIdSet.size()>0){
            List<Contact_Details_By_Show__c> contDetailbyShowList = [select Id, Show__c, Contact__c from Contact_Details_By_Show__c where Show__c IN: showIdSet and Contact__c IN: contactIdSet];
        
            for(Contact_Details_By_Show__c conDetailbyShow1 : trigger.new){
                for(Contact_Details_By_Show__c conDetailbyShow2: contDetailbyShowList){
                    if(conDetailbyShow1.Show__c != Null && conDetailbyShow1.Contact__c != Null && conDetailbyShow2.Show__c != Null && conDetailbyShow2.Contact__c != Null && conDetailbyShow1.Show__c == conDetailbyShow2.Show__c && conDetailbyShow1.Contact__c == conDetailbyShow2.Contact__c ){
                        conDetailbyShow1.addError('Contact Details by Show record already exists');
                    }
                }
            }
        }
    }

}