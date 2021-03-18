/*
Dev: Spoorthy Teegala
Date: 03/23/2020
Desc: Trigger to check duplicate records on Show Account Owner
*/
trigger ee_tgr_ShowAccountOwners on AccountOwners__c (before insert) {
   
	Set<Id> AccountIdSet = new Set<Id>();
	Set<Id> ShowSet = new Set<Id>();
	Set<Id> SubShowSet = new Set<Id>();
	for(AccountOwners__c sao : trigger.new){
		AccountIdSet.add(sao.Account__c);
		ShowSet.add(sao.Show__c);
		SubShowSet.add(sao.SubShow__c);
	}
	
	if(AccountIdSet.size()>0 ) {
		List<AccountOwners__c> lstSAO = [select Id, AccountOwner__c, Account__c, Show__c, SubShow__c from AccountOwners__c where Account__c IN: AccountIdSet ];
		
		Map<Id, AccountOwners__c> AccountIdMap = new Map<Id, AccountOwners__c>();
		//Map<Id, Id> ShowMap = new Map<Id, Id>();
		//Map<Id, Id> SubShowMap = new Map<Id, Id>();
		
		
		for(AccountOwners__c SAO: lstSAO){
			AccountIdMap.put(SAO.Id, SAO);
			//ShowMap.put(SAO.Id, SAO.Show__c);
			//SubShowMap.put(SAO.Id,SAO.SubShow__c);
		}
		system.debug('AccountIdMap'+AccountIdMap);
		for(AccountOwners__c sao: trigger.new){
			for(AccountOwners__c sao1: AccountIdMap.values()){
				if(AccountIdMap.get(sao1.Id).Account__c == sao.Account__c && AccountIdMap.get(sao1.Id).Show__c == sao.Show__c  && sao1.SubShow__c != null && AccountIdMap.get(sao1.Id).SubShow__c == sao.SubShow__c){
					sao.addError('Show Account Owner Record already exists for the selected show and subshow combination');
				}
				else if(AccountIdMap.get(sao1.Id).Account__c== sao.Account__c && AccountIdMap.get(sao1.Id).Show__c == sao.Show__c && sao.SubShow__c == null && AccountIdMap.get(sao1.Id).SubShow__c == null){
                	sao.addError('Show Account Owner Record already exists for the selected show');
				}
			}
		}
		
	}
    

}