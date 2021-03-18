trigger ee_tgr_ContactRoleByShow on Show_Account_Contact__c (after Insert, After Update) {

    if(EE_RecursiveTriggerHandler.isFirstTime){
        EE_RecursiveTriggerHandler.isFirstTime = false;
        if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> crbsSet = new Set<Id>();
        for(Show_Account_Contact__c  crbs: Trigger.new){
            crbsSet.add(crbs.Id); 
        }
        EE_ContactRoleByShowTriggerHandler crbshTrHandler = new EE_ContactRoleByShowTriggerHandler();
        crbshTrHandler.InsertOpportunityContactRoles(crbsSet);
        }
        if(Trigger.isAfter && Trigger.isUpdate){
            EE_ContactRoleByShowTriggerHandler crbshTrHandler = new EE_ContactRoleByShowTriggerHandler();
            crbshTrHandler.UpdateOpportunityContactRoles(Trigger.newMap, Trigger.oldMap);
        } 
    }  
    if(Test.isRunningTest()){
        if(EE_RecursiveTriggerHandler.isFirstTime){
            EE_RecursiveTriggerHandler.isFirstTime = false;
            if(Trigger.isAfter && Trigger.isInsert){
            Set<Id> crbsSet = new Set<Id>();
            for(Show_Account_Contact__c  crbs: Trigger.new){
                crbsSet.add(crbs.Id); 
            }
            EE_ContactRoleByShowTriggerHandler crbshTrHandler = new EE_ContactRoleByShowTriggerHandler();
            crbshTrHandler.InsertOpportunityContactRoles(crbsSet);
            }
            if(Trigger.isAfter && Trigger.isUpdate){
                EE_ContactRoleByShowTriggerHandler crbshTrHandler = new EE_ContactRoleByShowTriggerHandler();
                crbshTrHandler.UpdateOpportunityContactRoles(Trigger.newMap, Trigger.oldMap);
            } 
        }  
    } 
}