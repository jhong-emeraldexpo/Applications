/*
Dev: Spoorthy Teegala
Date:05/25/2020
Description:Trigger to Create Account Details byShow record when an Account Segment is created.

Update/Changes: Line 19 to Line 61 (06/26/2020)
Description:Trigger to check duplicates before insert and after update on Account Segments
*/
trigger ee_tgr_AccountSegment on Account_Segment__c(before insert, before update, after insert){ 
    Set<Id> accSegIDs = new Set<Id>();
    if(Trigger.isAfter && Trigger.isInsert){
        
        for(Account_Segment__c accSeg: Trigger.new){
            accSegIDs.add(accSeg.Id);
        }
        EE_CreateAccDetailsbyShow.createAccDetailsbyShowRec(accSegIDs);
    }
    
    //Trigger to check duplicates before insert and after update on Account Segments
    if(Trigger.isBefore && Trigger.isInsert){
        Set<Id> segmentIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Account_Segment__c accSegment : trigger.new){
            segmentIdSet.add(accSegment.Segment__c);
            accountIdSet.add(accSegment.Account__c);
        }
    
        if(segmentIdSet.size()>0 && accountIdSet.size()>0){
            List<Account_Segment__c> accSegmentList = [select Id, Segment__c, Account__c from Account_Segment__c where Segment__c IN: segmentIdSet and Account__c IN: accountIdSet];
        
            for(Account_Segment__c accSegment1 : trigger.new){
                for(Account_Segment__c accSegment2: accSegmentList){
                    if(accSegment1.Segment__c != Null && accSegment1.Account__c != Null && accSegment2.Segment__c != Null && accSegment2.Account__c != Null && accSegment1.Segment__c == accSegment2.Segment__c && accSegment1.Account__c == accSegment2.Account__c ){
                        accSegment1.addError('Account Segment Record already exists');
                    }
                }
            }
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> segmentIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(ID accSegmentId: Trigger.newMap.keyset()){
            if(Trigger.oldMap.get(accSegmentId).Segment__c != Trigger.newMap.get(accSegmentId).Segment__c || Trigger.oldMap.get(accSegmentId).Account__c != Trigger.newMap.get(accSegmentId).Account__c){
                segmentIdSet.add(Trigger.newMap.get(accSegmentId).Segment__c);
                accountIdSet.add(Trigger.newMap.get(accSegmentId).Account__c);
            }   
        }
    
        if(segmentIdSet.size()>0 && accountIdSet.size()>0){
            List<Account_Segment__c> accSegmentList = [select Id, Segment__c, Account__c from Account_Segment__c where Segment__c IN: segmentIdSet and Account__c IN: accountIdSet];
        
            for(Account_Segment__c accSegment1 : trigger.new){
                for(Account_Segment__c accSegment2: accSegmentList){
                    if(accSegment1.Segment__c != Null && accSegment1.Account__c != Null && accSegment2.Segment__c != Null && accSegment2.Account__c != Null && accSegment1.Segment__c == accSegment2.Segment__c && accSegment1.Account__c == accSegment2.Account__c ){
                        accSegment1.addError('Account Segment Record already exists');
                    }
                }
            }
        }
    }

}