/*
Dev: Spoorthy Teegala
Description:
	If the Opportunity is new and is converted from the lead 
    1. Create Account Owner
    2. If the Account Owner already exists and the owner is different from opp owner, update Account owner ownerid

	When the Opportunity is sold then update the Account Owner with the Opportunity Owner and notify the previous owner

*/
public class EE_UpsertShowAccountOwner {
    Public static void AccountOwnerUpsert(Set<Id> oppIds ){
            
        Set<Id> AccountIds = new Set<Id>();
        
        Set<Id> ShowIds = new Set<Id>();
        Set<Id> SubShowIds = new Set<Id>();
        Set<Id> showsWithoutSubshows = new Set<Id>();
        Set<Id> showsWithSubshows = new Set<Id>();

        Set<Id> processedShowIds = new Set<Id>();
        Set<Id> processedSubShowIds = new Set<Id>();
        
        List<Opportunity> cleanOppsList = new List<opportunity>();

        List<AccountOwners__c> newAccountOwners = new List<AccountOwners__c>(); 
        List<AccountOwners__c> updateAccountOwners = new List<AccountOwners__c>();

        //List<Opportunity> OppList = [Select Id, OwnerId, Event__c, Event__r.Show__c, SubShow__c, SubExpo__c, SubExpo__r.SubShow__c, AccountId, ConvertedfromLead__c from Opportunity where Id IN: oppIds and ConvertedfromLead__c = True];
        //Id dmUserId = [select id, Name from user where Name = 'Data Migration'].Id;
        List<Opportunity> OppList = [Select Id, OwnerId, Owner.Name, Owner.IsActive, Event__c, Event__r.Show__c, Lead_Id__c, SubShow__c, SubExpo__c, SubExpo__r.SubShow__c, AccountId, StageName from Opportunity where Id IN: oppIds and Owner.Name != 'Data Migration' and Owner.IsActive = True];
        for(opportunity op: OppList){
            AccountIds.add(op.AccountId);

            if(string.IsNotBlank(op.Lead_Id__c)){
                opportunity tOpp = new Opportunity();
                tOpp.id = op.id;
                tOpp.Lead_Id__c = '';
                cleanOppsList.add(tOpp);
            }

        }
        system.debug('******************** OppList'+OppList);
        List<AccountOwners__c> existingAccountOwners = [SELECT Id, AccountOwner__c, AccountOwner__r.IsActive, Account__c, Show__c, SubShow__c FROM AccountOwners__c where Account__c IN: AccountIds];
        
        for(AccountOwners__c tempEAC: existingAccountOwners){
            if(tempEAC.Show__c != null){
                ShowIds.add(tempEAC.Show__c);
            }
            system.debug('@@@@@@@@@@ShowIds'+ShowIds);

            if(tempEAC.SubShow__c != null){
                SubShowIds.add(tempEAC.SubShow__c);
            }
            system.debug('@@@@@@@@@@SubShowIds'+SubShowIds);

            if(tempEAC.Show__c != null && tempEAC.SubShow__c == null){
                showsWithoutSubshows.add(tempEAC.Show__c);
            }
            if(tempEAC.Show__c != null && tempEAC.SubShow__c != null){
                showsWithSubshows.add(tempEAC.Show__c);
            }
            
        }

        for(Opportunity tempOpp: OppList){
            if(existingAccountOwners.size() > 0){
                for(AccountOwners__c eac: existingAccountOwners){
                    system.debug('tempOpp.AccountId'+tempOpp.AccountId);
                    system.debug('eac.Account__c'+eac.Account__c);
                    system.debug('tempOpp.Event__r.Show__c'+tempOpp.Event__r.Show__c); 
                    system.debug('tempOpp.SubExpo__r.SubShow__c '+tempOpp.SubExpo__r.SubShow__c ); 

                    if(tempOpp.AccountId == eac.Account__c && tempOpp.SubExpo__r.SubShow__c== null && (!ShowIds.contains(tempOpp.Event__r.Show__c) || !showsWithoutSubshows.contains(tempOpp.Event__r.Show__c) ) && !processedShowIds.contains(tempOpp.Event__r.Show__c)){
                        AccountOwners__c accOwnr = new AccountOwners__c();
                        accOwnr.Account__c= tempOpp.AccountId;
                        accOwnr.AccountOwner__c= tempOpp.OwnerId;
                        accOwnr.Show__c = tempOpp.Event__r.Show__c;
                        accOwnr.SubShow__c = tempOpp.SubExpo__r.SubShow__c;
                        newAccountOwners.add(accOwnr);

                        processedShowIds.add(tempOpp.Event__r.Show__c);
                        
                        if(tempOpp.SubExpo__r.SubShow__c != null){
                            processedSubShowIds.add(tempOpp.SubExpo__r.SubShow__c);
                        }
                        continue;
                        system.debug('@@@@@@@@@@'+accOwnr);
                    }
                    system.debug('ShowIds.contains(tempOpp.Event__r.Show__c)'+ShowIds.contains(tempOpp.Event__r.Show__c));
                    if(tempOpp.AccountId == eac.Account__c && tempOpp.Event__r.Show__c != null  && tempOpp.SubExpo__r.SubShow__c != null && !SubShowIds.contains(tempOpp.SubExpo__r.SubShow__c) && !processedSubShowIds.contains(tempOpp.SubExpo__r.SubShow__c)){
                        AccountOwners__c accOwnr = new AccountOwners__c();
                        accOwnr.Account__c= tempOpp.AccountId;
                        accOwnr.AccountOwner__c= tempOpp.OwnerId;
                        accOwnr.Show__c = tempOpp.Event__r.Show__c;
                        accOwnr.SubShow__c = tempOpp.SubExpo__r.SubShow__c;
                        newAccountOwners.add(accOwnr);

                        processedShowIds.add(tempOpp.Event__r.Show__c);
                        
                        if(tempOpp.SubExpo__r.SubShow__c != null){
                            processedSubShowIds.add(tempOpp.SubExpo__r.SubShow__c);
                        }
                        continue;
                        system.debug('@@@@@@@@@@!!!!'+accOwnr);
                    }
                    
                    if(tempOpp.AccountId == eac.Account__c && ShowIds.contains(tempOpp.Event__r.Show__c) && !processedShowIds.contains(tempOpp.Event__r.Show__c) && tempOpp.Event__r.Show__c == eac.Show__c && tempOpp.SubExpo__r.SubShow__c == null && eac.SubShow__c == null && tempOpp.OwnerID != eac.AccountOwner__c){
                        AccountOwners__c accOwnr = new AccountOwners__c();
                        accOwnr.id =  eac.id;
                        accOwnr.AccountOwner__c= tempOpp.OwnerId;
                        updateAccountOwners.add(accOwnr);

                        processedShowIds.add(tempOpp.Event__r.Show__c);
                        
                        if(tempOpp.SubExpo__r.SubShow__c != null){
                            processedSubShowIds.add(tempOpp.SubExpo__r.SubShow__c);
                        }
                        system.debug('@@@@@@@@@@tempOpp1'+tempOpp);
                        continue;
                    }

                    if(tempOpp.AccountId == eac.Account__c && ShowIds.contains(tempOpp.Event__r.Show__c) && SubShowIds.contains(tempOpp.SubExpo__r.SubShow__c) && !processedSubShowIds.contains(tempOpp.SubExpo__r.SubShow__c) && tempOpp.Event__r.Show__c == eac.Show__c && tempOpp.SubExpo__r.SubShow__c != null && tempOpp.SubExpo__r.SubShow__c == eac.SubShow__c && tempOpp.OwnerID != eac.AccountOwner__c){
                        AccountOwners__c accOwnr = new AccountOwners__c();
                        accOwnr.id =  eac.id;
                        accOwnr.AccountOwner__c = tempOpp.OwnerId;
                        updateAccountOwners.add(accOwnr);

                        processedShowIds.add(tempOpp.Event__r.Show__c);
                        
                        if(tempOpp.SubExpo__r.SubShow__c != null){
                            processedSubShowIds.add(tempOpp.SubExpo__r.SubShow__c);
                        }
                        system.debug('@@@@@@@@@@tempOpp2'+tempOpp);
                        continue;
                    }
                }
            }
            if(existingAccountOwners.size() == 0){
                AccountOwners__c accOwnr = new AccountOwners__c();
                accOwnr.Account__c = tempOpp.AccountId;
                accOwnr.AccountOwner__c= tempOpp.OwnerId;
                accOwnr.Show__c = tempOpp.Event__r.Show__c;
                accOwnr.SubShow__c = tempOpp.SubExpo__r.SubShow__c;
                newAccountOwners.add(accOwnr);
                system.debug('@@@@@@@@@@###'+accOwnr);
            }
        }
        
        if(newAccountOwners.size() > 0){ 
            insert newAccountOwners;
            system.debug('@@@@@@@@@@newAccountOwners'+newAccountOwners);
        }
        if(updateAccountOwners.size() > 0){
            update updateAccountOwners;
            system.debug('@@@@@@@@@@newAccountOwners'+updateAccountOwners);
        }

        if(cleanOppsList.size() > 0){
            update cleanOppsList;
        }
    }         
}