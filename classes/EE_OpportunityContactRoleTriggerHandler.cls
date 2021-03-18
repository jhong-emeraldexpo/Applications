public class EE_OpportunityContactRoleTriggerHandler {
    public void InsertContactRoleByShow(Set<id> OcrIDSet){
        
        Set<OpportunityContactRole> ocrNewSet = new Set<OpportunityContactRole>(); 
        Map<Id,Account> AccMap = new Map<Id,Account>();
        List<Show_Account_Contact__c> insertsacList = new List<Show_Account_Contact__c>();
		Set<Show_Account_Contact__c> insertsacSet = new Set<Show_Account_Contact__c>();

        List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Marketing Contact', 'Sales Contact','Contract Contact (Secondary)', 'Sponsorship contact'};
        List<OpportunityContactRole> oppcrInsertList = [Select Id, OpportunityId, Opportunity.AccountId, Opportunity.Event__r.Show__c, Role, ContactId, Contact.AccountId FROM OpportunityContactRole where Id IN: OcrIDSet and Role IN: ValidCRbyShowList];
        		
		Set<Id> AccIdSet = new Set<Id>();
		Set<Id> ShowIdSet = new Set<Id>();
        for(OpportunityContactRole Ocr: oppcrInsertList){
            AccIdSet.add(Ocr.Opportunity.AccountId);
			ShowIdSet.add(Ocr.Opportunity.Event__r.Show__c);
            system.debug('@@@@@@@@@@@@@@@@@'+AccIdSet);
        }
        
        List<Show_Account_Contact__c> ExistingCRBSList = [select Id, Account__c, Contact__c, ContactRoles__c, Show__c from Show_Account_Contact__c where Account__c IN: AccIdSet and Show__c IN: ShowIdSet]; 
		
        if(oppcrInsertList.size() > 0){
            for(OpportunityContactRole Ocr1: oppcrInsertList ){
                for(Show_Account_Contact__c excrbs: ExistingCRBSList){
                    if(Ocr1.Opportunity.AccountId == excrbs.Account__c && Ocr1.ContactId == excrbs.Contact__c && Ocr1.Role == excrbs.ContactRoles__c && Ocr1.Opportunity.Event__r.Show__c == excrbs.Show__c) {
                        ocrNewSet.add(Ocr1);
                        system.debug('ocrNewSet'+ocrNewSet);
                    }
                }  
                if(!(ocrNewSet.Contains(Ocr1))){
                    system.debug('ocrNewSet'+!(ocrNewSet.Contains(Ocr1)));
                    Show_Account_Contact__c sac = new Show_Account_Contact__c();
                    sac.Contact__c = Ocr1.ContactId;
                    sac.ContactRoles__c = Ocr1.Role;
                    sac.Account__c= Ocr1.Opportunity.AccountId;
                    sac.Show__c= Ocr1.Opportunity.Event__r.Show__c;
                    insertsacSet.add(sac);
                    system.debug('insertsacSet'+insertsacSet);    
                }
            }
        }
        if(insertsacSet.size() > 0){
			insertsacList.addAll(insertsacSet);
            insert insertsacList;
            system.debug('insertsacSet'+insertsacList);
        }
    }
    public void UpdateContactRoleByShow(Map<Id,OpportunityContactRole> newOCRMap, Map<Id,OpportunityContactRole> oldOCRMap ){

        Set<Show_Account_Contact__c>  UpdateSacRoleSet = new Set<Show_Account_Contact__c>();
		List<Show_Account_Contact__c>  UpdateSacRoleList = new List<Show_Account_Contact__c>();
        Set<Show_Account_Contact__c>  UpdateSacContactSet = new Set<Show_Account_Contact__c>();
        List<Show_Account_Contact__c>  UpdateSacContactList = new List<Show_Account_Contact__c>();
		
		List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Marketing Contact', 'Sales Contact','Contract Contact (Secondary)', 'Sponsorship contact'};
		List<OpportunityContactRole> oppcrUpdateList = [Select Id, OpportunityId, Opportunity.AccountID, Opportunity.Event__r.Show__c, Role, ContactId, Contact.AccountID FROM OpportunityContactRole where Id IN: newOCRMap.keyset()];
        
		Set<Id> AccIdSet = new Set<Id>();
		Set<Id> ShowIdSet = new Set<Id>();
        for(OpportunityContactRole Ocr: oppcrUpdateList){
            AccIdSet.add(Ocr.Opportunity.AccountID);
			ShowIdSet.add(Ocr.Opportunity.Event__r.Show__c);
            system.debug('@@@@@@@@@@@@@@@@@'+AccIdSet);
        }

        List<Show_Account_Contact__c> SACList = [select Id, Account__c, ContactRoles__c, Contact__c,Contact__r.Name, Show__c from  Show_Account_Contact__c where Account__c IN: AccIdSet and Show__c IN: ShowIdSet and ContactRoles__c IN: ValidCRbyShowList];

        if(oppcrUpdateList.size() > 0){
            for(OpportunityContactRole ocr: oppcrUpdateList ){
                for (Show_Account_Contact__c sac: SACList){
                    if(sac.Account__c == ocr.Opportunity.AccountID && sac.Contact__c == ocr.ContactId &&  sac.ContactRoles__c== oldOCRMap.get(ocr.id).Role && sac.ContactRoles__c != newOCRMap.get(ocr.id).Role ){
                        Show_Account_Contact__c tempSAC =new Show_Account_Contact__c();
						tempSAC.Id = sac.Id;
						tempSAC.ContactRoles__c= newOCRMap.get(ocr.Id).Role;
						UpdateSacRoleSet.add(tempSAC);
					}
                    if(sac.Account__c == ocr.Opportunity.AccountID  && sac.ContactRoles__c == ocr.Role &&  sac.Contact__c== oldOCRMap.get(ocr.id).ContactId && sac.Contact__c != newOCRMap.get(ocr.id).ContactId ){
						Show_Account_Contact__c tempSAC2 =new Show_Account_Contact__c();
						tempSAC2.Id = sac.Id;
						tempSAC2.Contact__c = newOCRMap.get(ocr.Id).ContactId;
						UpdateSacContactSet.add(tempSAC2);
					}
                    
                }
            }
            if(UpdateSacRoleSet.size() > 0){
				UpdateSacRoleList.addAll(UpdateSacRoleSet);
                Update UpdateSacRoleList;
            }
            if(UpdateSacContactSet.size() >0){
				UpdateSacContactList.addAll(UpdateSacContactSet);
                Update UpdateSacContactList;
            }
        }
    } 
    public void UpsertIsPrimaryonOcr(Set<id> OppcrIDSet){
        
        Set<OpportunityContactRole>  UpdateoppCRoleSet = new Set<OpportunityContactRole>();
		List<OpportunityContactRole>  UpdateoppCRoleList = new List<OpportunityContactRole>();

        List<OpportunityContactRole> oppcrList = [Select Id, OpportunityId, Role, ContactId, IsPrimary, Is_Primary__c FROM OpportunityContactRole where Id IN: OppcrIDSet];
        if(oppcrList.size() > 0){
            for(OpportunityContactRole ocr: oppcrList){
                OpportunityContactRole ocr1=new OpportunityContactRole();
                ocr1.id=ocr.id;
                ocr1.Is_Primary__c=ocr.IsPrimary;
                UpdateoppCRoleSet.add(ocr1);
            }
        }
        if(UpdateoppCRoleSet.size()>0){
            UpdateoppCRoleList.addAll(UpdateoppCRoleSet);
            update UpdateoppCRoleList;
        }
    }
}