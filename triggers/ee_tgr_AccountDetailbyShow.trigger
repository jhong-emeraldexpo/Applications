/*
Dev: Spoorthy Teegala
Date: 6/15/2020
Desc: Trigger to check duplicate records on Account Details by Show Object
*/
trigger ee_tgr_AccountDetailbyShow on Account_Details_by_Show__c (before insert) {
	
	if(Trigger.isBefore && Trigger.isInsert){
    	Set<Id> showIdSet = new Set<Id>();
		Set<Id> accountIdSet = new Set<Id>();
		for(Account_Details_by_Show__c accDetailbyShow : trigger.new){
        	showIdSet.add(accDetailbyShow.Show__c);
			accountIdSet.add(accDetailbyShow.Account__c);
		}
	
		if(showIdSet.size()>0 && accountIdSet.size()>0){
			List<Account_Details_by_Show__c> accDetailbyShowList = [select Id, Show__c, Account__c from Account_Details_by_Show__c where Show__c IN: showIdSet and Account__c IN: accountIdSet];
		
			for(Account_Details_by_Show__c accDetailbyShow2 : trigger.new){
				for(Account_Details_by_Show__c accDetailbyShow3: accDetailbyShowList){
					if(accDetailbyShow2.Show__c != Null && accDetailbyShow2.Account__c != Null && accDetailbyShow3.Show__c != Null && accDetailbyShow3.Account__c != Null && accDetailbyShow2.Show__c == accDetailbyShow3.Show__c && accDetailbyShow2.Account__c == accDetailbyShow3.Account__c ){
						accDetailbyShow2.addError('Account Details by Show Record already exists');
					}
				}
			}
		}
	}

}