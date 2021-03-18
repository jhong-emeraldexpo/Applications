/*
Dev: Spoorthy Teegala
Date:05/25/2020
Description:Trigger to Create Contact Details byShow record when an Contact Segment is created.

Update/Changes: Line 19 to Line 61 (06/29/2020)
Description:Trigger to check duplicates before insert and after update on Contact Segments
*/
trigger ee_tgr_ContactSegments on Contact_Segment__c(before insert, after insert, before update){ 
    Set<Id> conSegIDs = new Set<Id>();
    if(Trigger.isAfter && Trigger.isInsert){
        
        for(Contact_Segment__c conSeg: Trigger.new){
            conSegIDs.add(conSeg.Id);
        }
        EE_CreateConDetailsbyShow.createConDetailsbyShowRec(conSegIDs);
    }
    
    //Trigger to check duplicates before insert and after update on Contact Segments
    if(Trigger.isBefore && Trigger.isInsert){
        Set<Id> segmentIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact_Segment__c conSeg : trigger.new){
            segmentIdSet.add(conSeg.Segment__c);
            contactIdSet.add(conSeg.Contact__c);
        }
    
        if(segmentIdSet.size()>0 && contactIdSet.size()>0){
            List<Contact_Segment__c> conSegmentList = [select Id, Segment__c, Contact__c from Contact_Segment__c where Segment__c IN: segmentIdSet and Contact__c IN: contactIdSet];
        
            for(Contact_Segment__c conSeg1: trigger.new){
                for(Contact_Segment__c conSeg2: conSegmentList){
                    if(conSeg1.Segment__c != Null && conSeg1.Contact__c != Null && conSeg2.Segment__c != Null && conSeg2.Contact__c != Null && conSeg1.Segment__c == conSeg2.Segment__c && conSeg1.Contact__c == conSeg2.Contact__c ){
                        conSeg1.addError('Contact Segment Record already exists');
                    }
                }
            }
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> segmentIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(ID conSegmentId: Trigger.newMap.keyset()){
            if(Trigger.oldMap.get(conSegmentId).Segment__c != Trigger.newMap.get(conSegmentId).Segment__c || Trigger.oldMap.get(conSegmentId).Contact__c != Trigger.newMap.get(conSegmentId).Contact__c){
                segmentIdSet.add(Trigger.newMap.get(conSegmentId).Segment__c);
                contactIdSet.add(Trigger.newMap.get(conSegmentId).Contact__c);
            }   
        }
    
        if(segmentIdSet.size()>0 && contactIdSet.size()>0){
            List<Contact_Segment__c> conSegmentList = [select Id, Segment__c, Contact__c from Contact_Segment__c where Segment__c IN: segmentIdSet and Contact__c IN: contactIdSet];
        
            for(Contact_Segment__c conSeg1: trigger.new){
                for(Contact_Segment__c conSeg2: conSegmentList){
                    if(conSeg1.Segment__c != Null && conSeg1.Contact__c != Null && conSeg2.Segment__c != Null && conSeg2.Contact__c != Null && conSeg1.Segment__c == conSeg2.Segment__c && conSeg1.Contact__c == conSeg2.Contact__c ){
                        conSeg1.addError('Contact Segment Record already exists');
                    }
                }
            }
        }
    }
}