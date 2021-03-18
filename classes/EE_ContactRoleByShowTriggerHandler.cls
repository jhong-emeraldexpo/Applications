/*****************************************************************************************

Developer :: Spoorthy Teegala
Description :: This class acts as a trigger handler for Show_Account_Contact__c aka Contact Role By Show
Created Date :: 06/15/19

*****************************************************************************************/
public class EE_ContactRoleByShowTriggerHandler{

    public void InsertOpportunityContactRoles(Set<id> crbsSet){
        
        Map<Id,Opportunity> OppAccMap = new Map<Id,Opportunity>();
        Set<OpportunityContactRole>  newOppCRSet = new Set<OpportunityContactRole>();
        List<OpportunityContactRole>  newOppCRList = new List<OpportunityContactRole>();
        Set<Show_Account_Contact__c> sacNewSet = new Set<Show_Account_Contact__c>();

        List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Contract Contact (Secondary)','Marketing Contact', 'Sales Contact', 'Sponsorship contact'};
        List<Show_Account_Contact__c> ContactRolesByShowList = [SELECT Id, Account__c, ContactRoles__c, Contact__c, Show__c, LastModifiedDate  FROM Show_Account_Contact__c where Id IN: crbsSet and ContactRoles__c IN: ValidCRbyShowList];
        system.debug('ContactRolesByShowList'+ContactRolesByShowList);
        
        Set<Id> AccIds = new Set<Id>();
        Set<Id> ShowIds = new Set<Id>();
        for(Show_Account_Contact__c sac: ContactRolesByShowList){
            AccIds.add(sac.Account__c);
            ShowIds.add(sac.Show__c);
        }
        
        for(Opportunity opp: [select Id, AccountID, Event__r.Show__c from Opportunity where AccountID IN: AccIds and Event__r.Show__c IN:ShowIds]){
            system.debug('opp results'+opp);
            OppAccMap.put(opp.Id, opp);
        }

        List<OpportunityContactRole> existingOCRList = [select Id, OpportunityId, Opportunity.AccountId, Event__c, Opportunity.Event__r.Show__c, ContactId, Role from OpportunityContactRole where Opportunity.AccountId IN: AccIds and Opportunity.Event__r.Show__c IN: ShowIds];
      
        if(ContactRolesByShowList.size() > 0){
            for(Show_Account_Contact__c crbs: ContactRolesByShowList ){   
                for(OpportunityContactRole ocr: existingOCRList) {
                    if(crbs.Account__c == ocr.Opportunity.AccountId && crbs.Show__c == ocr.Opportunity.Event__r.Show__c && crbs.Contact__c == ocr.ContactId && crbs.ContactRoles__c == ocr.Role) {
                        sacNewSet.add(crbs);
                    }   
                }
                if(!(sacNewSet.Contains(crbs))){
                    for(Id OppId: OppAccMap.keyset()){
                        if(crbs.Account__c == oppAccMap.get(OppId).AccountID && crbs.Show__c == oppAccMap.get(OppId).Event__r.Show__c) {
                            OpportunityContactRole ocr= new OpportunityContactRole();
                            ocr.ContactId = crbs.Contact__c;
                            ocr.OpportunityId = OppId;
                            ocr.Role = crbs.ContactRoles__c;
                            newOppCRSet.add(ocr);
                        }
                    }    
                }
            } 
        }
        if(newOppCRSet.size()>0){
            newOppCRList.addAll(newOppCRSet);
            insert newOppCRList;   
        }
    }

    public void UpdateOpportunityContactRoles(Map<Id,Show_Account_Contact__c> newCRBS, Map<Id,Show_Account_Contact__c> oldCRBS ){

        //Map<Id,Opportunity> OppAccMap = new Map<Id,Opportunity>();
        Set<OpportunityContactRole>  UpdateOppCRRoleSet = new Set<OpportunityContactRole>();
        List<OpportunityContactRole>  UpdateOppCRRoleList = new List<OpportunityContactRole>();
        Set<OpportunityContactRole>  UpdateOppCRContactSet = new Set<OpportunityContactRole>();
        List<OpportunityContactRole>  UpdateOppCRContactList = new List<OpportunityContactRole>();

        List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Marketing Contact', 'Sales Contact','Contract Contact (Secondary)', 'Sponsorship contact'};
        List<Show_Account_Contact__c> ContactRolesByShowList = [SELECT Id, Account__c, ContactRoles__c, Contact__c, Show__c, LastModifiedDate  FROM Show_Account_Contact__c where Id IN: newCRBS.KeySet() ];

        Set<Id> AccIds = new Set<Id>();
        Set<Id> ShowIds = new Set<Id>();
        for(Show_Account_Contact__c sac: ContactRolesByShowList){
            AccIds.add(sac.Account__c);
            ShowIds.add(sac.Show__c);
        }

        /* for(Opportunity opp: [select Id, AccountID, Event__r.Show__r.Name from Opportunity where AccountID IN: AccIds]){
            OppAccMap.put(opp.Id, opp);
        } */

        List<OpportunityContactRole> OCRList = [select Id, OpportunityId, Opportunity.AccountId, Event__c, Opportunity.Event__r.Show__c, ContactId, role from OpportunityContactRole where Opportunity.AccountId IN: AccIds and Opportunity.Event__r.Show__c IN: ShowIds and role IN: ValidCRbyShowList];

        if(ContactRolesByShowList.size() > 0){
            
            for(Show_Account_Contact__c crbs: ContactRolesByShowList ){
                //for(id OppId: OppAccMap.keyset()) {
                    for (OpportunityContactRole OCR: OCRList){
                        system.debug('crbs Account:'+crbs.Account__c);
                        system.debug('ocr Account:'+OCR.Opportunity.AccountId);
                        system.debug('crbs Contact:'+crbs.Contact__c);
                        system.debug('ocr Contact:'+OCR.ContactId);
                        system.debug('crbs show:'+crbs.Show__c);
                        system.debug('ocr show:'+OCR.Opportunity.Event__r.Show__c);
                        system.debug('new role:'+OCR.Role);
                        system.debug('previous Role:'+oldCRBS.get(crbs.id).ContactRoles__c);
                        if(crbs.Account__c == OCR.Opportunity.AccountId  && OCR.ContactId == crbs.Contact__c &&  OCR.Role == oldCRBS.get(crbs.id).ContactRoles__c && crbs.Show__c == OCR.Opportunity.Event__r.Show__c){
                            OpportunityContactRole upOCR = new OpportunityContactRole();
                            upOCR.Id = OCR.Id;
                            upOCR.Role = crbs.ContactRoles__c;
                            UpdateOppCRRoleSet.add(upOCR);
                            system.debug('UpdateOppCRRoleSet'+UpdateOppCRRoleSet);
                        }
                        if(crbs.Account__c == OCR.Opportunity.AccountId && OCR.Role == crbs.ContactRoles__c  && OCR.ContactID == oldCRBS.get(crbs.id).Contact__c && crbs.Show__c == OCR.Opportunity.Event__r.Show__c) { 
                            OpportunityContactRole upOCR = new OpportunityContactRole();
                            upOCR.Id = OCR.Id;
                            upOCR.ContactID = crbs.Contact__c;
                            UpdateOppCRContactSet.add(upOCR);  
                        }
                    }
                //}
            }
                      
        }
        if(UpdateOppCRRoleSet.size()>0){
            UpdateOppCRRoleList.addAll(UpdateOppCRRoleSet);
            update UpdateOppCRRoleList; 
            system.debug('UpdateOppCContactList'+UpdateOppCRRoleList);
        }
        if(UpdateOppCRContactSet.size()>0){
            UpdateOppCRContactList.addAll(UpdateOppCRContactSet);
            update UpdateOppCRContactList;  
            system.debug('UpdateOppCContactList'+UpdateOppCRContactList);
        }
    } 
}