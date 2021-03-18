trigger ee_tgr_OpportunityContactRole on OpportunityContactRole (after insert, after Update) {
    
        if(EE_RecursiveTriggerHandler.isFirstTime){
            EE_RecursiveTriggerHandler.isFirstTime = false;
            if(Trigger.isAfter && Trigger.isInsert){
                Set<Id> OcrIDSet = new Set<Id>();
                Set<Id> oppcrIdSet = new Set<Id>();
                for(OpportunityContactRole  Ocr: Trigger.new){
                    OcrIDSet.add(Ocr.ID); 
                    if(Ocr.IsPrimary != null){
                        oppcrIdSet.add(Ocr.Id);
                    }
                }
                EE_OpportunityContactRoleTriggerHandler ocrTrHandler = new EE_OpportunityContactRoleTriggerHandler();
                ocrTrHandler.InsertContactRoleByShow(OcrIDSet);
                ocrTrHandler.UpsertIsPrimaryonOcr(oppcrIdSet);
            }

            if(Trigger.isAfter && Trigger.isUpdate ){
                Set<Id> oppcrIdSet = new Set<Id>();
                for(OpportunityContactRole  Ocr: Trigger.new){
                    if(Ocr.IsPrimary != null){
                        oppcrIdSet.add(Ocr.Id);
                    }
                }
                EE_OpportunityContactRoleTriggerHandler ocrTrHandler1 = new EE_OpportunityContactRoleTriggerHandler();
                ocrTrHandler1.UpdateContactRoleByShow(Trigger.newMap, Trigger.oldMap);
                ocrTrHandler1.UpsertIsPrimaryonOcr(oppcrIdSet);
            }
        }

        if(Test.isRunningTest()){
            EE_RecursiveTriggerHandler.isFirstTime = false;
            if(Trigger.isAfter && Trigger.isInsert){
                Set<Id> OcrIDSet = new Set<Id>();
                for(OpportunityContactRole  Ocr: Trigger.new){
                    OcrIDSet.add(Ocr.ID); 
                }
                EE_OpportunityContactRoleTriggerHandler ocrTrHandler = new EE_OpportunityContactRoleTriggerHandler();
                ocrTrHandler.InsertContactRoleByShow(OcrIDSet);
            }

            if(Trigger.isAfter && Trigger.isUpdate ){
                EE_OpportunityContactRoleTriggerHandler ocrTrHandler1 = new EE_OpportunityContactRoleTriggerHandler();
                ocrTrHandler1.UpdateContactRoleByShow(Trigger.newMap, Trigger.oldMap);
            }
        }

}