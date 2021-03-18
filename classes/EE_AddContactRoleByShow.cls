public class EE_AddContactRoleByShow {
    // 06/12/19 Spoorthy Teegala - addContactRoleByShow - This method is used for adding/creating 
    // Opportunity Contact Roles from Contact Role by Show recrds from associated Account for a given opporunity
    public void addContactRoleByShow(Map<id,Opportunity> newOppMap){
        
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> AccIdSet = new Set<Id>();
        Map<Id, Opportunity> oppAccMap = new Map<Id, Opportunity>();
        List<Show_Account_Contact__c> CRBSList = new List<Show_Account_Contact__c>();
        List<OpportunityContactRole>  OppCRList = new List<OpportunityContactRole>();
        
        oppList = [Select Id, AccountID,Event__r.Show__r.Name from Opportunity where Id IN :newOppMap.keySet()];
        
        for(Opportunity opp :oppList ){
                oppAccMap.put(opp.ID, opp); 
                AccIdSet.add(opp.AccountID);      
        }
        
        List<String> ValidCRbyShowList = new List<String>{'A2Z Invoice Contact', 'Contract Contact', 'Marketing Contact', 'Sales Contact','Contract Contact (Secondary)', 'Sponsorship contact'};
        CRBSList = [select id, Account__c, Contact__c, ContactRoles__c,Show__r.Name from Show_Account_Contact__c where Account__c IN: AccIdSet and ContactRoles__c IN: ValidCRbyShowList]; 
        
        if(CRBSList.size() > 0){
            for(id OppId: oppAccMap.keyset()) {
                for(Show_Account_Contact__c crbs: CRBSList ){
                    if(crbs.Account__c == oppAccMap.get(OppId).AccountID && crbs.Show__r.Name == oppAccMap.get(OppId).Event__r.Show__r.Name) {
                        OpportunityContactRole ocr= new OpportunityContactRole();
                        ocr.ContactId = crbs.Contact__c;
                        ocr.OpportunityId = OppId;
                        ocr.Role = crbs.ContactRoles__c;
                        OppCRList.add(ocr);
                    }
                }
            }
            
            insert OppCRList;
        }
    }
}