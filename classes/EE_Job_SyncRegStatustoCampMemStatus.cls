public class EE_Job_SyncRegStatustoCampMemStatus implements Database.Batchable<sObject>{
    private string query;

    public EE_Job_SyncRegStatustoCampMemStatus(){
        query = 'Select Id, Registration__c from EE_Registration_Queue__c Order by LastModifiedDate DESC limit 50000';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,Registration__c> regMap = new Map<Id,Registration__c>();
        Set<Id> regcontIdSet = new Set<Id>();
        Set<Id> regeveIdSet = new Set<Id>();
        List<CampaignMember> cmList = new List<CampaignMember>();
        Set<CampaignMember> campMemUpdateSet = new Set<CampaignMember>();
        List<Registration__c> updateRegList = new List<Registration__c>();
        
        Set<Id> regIdsSet = new Set<Id>();
        List<EE_Registration_Queue__c> reqQueueIdsList = new List<EE_Registration_Queue__c>();
        for(EE_Registration_Queue__c regque: (List<EE_Registration_Queue__c>) scope){
            regIdsSet.add(regque.Registration__c);
            reqQueueIdsList.add(regque);
        }
        
        List<Registration__c> regList = [Select Id, Contact__c, Event__c, Promo_Code__c, Reg_Status__c from Registration__c Where Id IN: regIdsSet];
        for(Registration__c reg: regList){
            regMap.put(reg.Id,reg);
            system.debug('regMap'+regMap);
            regcontIdSet.add(reg.Contact__c);
            regeveIdSet.add(reg.Event__c);
        }

        cmList = [Select Id, ContactId, Campaign.Event__c, Promo_Code__c, Status from CampaignMember where ContactId IN: regcontIdSet AND Campaign.Event__c IN: regeveIdSet AND (Status != 'Registered' OR Status != 'Cancelled' )];
        system.debug('cmList'+cmList);
        
        for(ID reg: regMap.keyset()){
            for(CampaignMember campMem: cmList){
                if(regMap.get(reg).Contact__c == campMem.ContactId && regMap.get(reg).Event__c == campMem.Campaign.Event__c && regMap.get(reg).Reg_Status__c == 'Cancelled'){
                    CampaignMember campaignmem = new CampaignMember();
                    campaignmem.Id = campMem.Id;
                    campaignmem.Status = regMap.get(reg).Reg_Status__c;
                    campaignmem.Registration_Promo_Code__c = regMap.get(reg).Promo_Code__c;
                    campMemUpdateSet.add(campaignmem);

                } 
                
                else if(regMap.get(reg).Contact__c == campMem.ContactId && regMap.get(reg).Event__c == campMem.Campaign.Event__c && regMap.get(reg).Reg_Status__c != 'Cancelled'){
                    CampaignMember campaignmem1 = new CampaignMember();
                    campaignmem1.Id = campMem.Id;
                    campaignmem1.Status = 'Registered';
                    campaignmem1.Registration_Promo_Code__c = regMap.get(reg).Promo_Code__c;
                    campMemUpdateSet.add(campaignmem1);

                }
            }
        }
        if(campMemUpdateSet.size()>0){
            list<CampaignMember> campMemUpdateList = new List<CampaignMember>();
            campMemUpdateList.addAll(campMemUpdateSet);
            update campMemUpdateList;  
            
            if(campMemUpdateList.size()>0 && reqQueueIdsList.size()>0){
                delete reqQueueIdsList;
            }  
        }


    }
    public void finish(Database.BatchableContext BC){
        if(!Test.IsRunningTest()){
            EE_Job_SyncRegStatustoCampMemStatus b = new EE_Job_SyncRegStatustoCampMemStatus(); 
            System.scheduleBatch(b, 'EE_Job_SyncRegStatustoCampMemStatus', 60, 100);
        }      
    }       
}