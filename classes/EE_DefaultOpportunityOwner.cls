public class EE_DefaultOpportunityOwner {
    public static void DefaultOpportunityOwner(Set<ID> oppIds){
        String RT_AccountName = EE_UtilityValues.RT_AccountName;
        String RT_BillingState = EE_UtilityValues.RT_BillingState;
        String RT_Show = EE_UtilityValues.RT_Show;
        String RT_SubShow = EE_UtilityValues.RT_SubShow;
        String RT_ANBS = EE_UtilityValues.RT_ANBS;
        String International = EE_UtilityValues.International;
        String Country_US = EE_UtilityValues.Country_US;

        List<Opportunity> lstOppsToBeUpdated = new List<Opportunity>();
        Set<id> oPPIDSet = new Set<id>();
		
        
        List<Opportunity> oppList = new List<Opportunity>([Select Id,Should_Ignore_Assignment_Rule__c, Event__r.Show__c, Event__r.Show__r.Name, Event__r.Show__r.OwnerId, subexpo__r.subshow__r.rule_set__c, AccountID, AccountNameFirstChar__c, OwnerId,Show__c,SubExpo__r.SubShowName__c, BillingCountryandStateCode__c, Billing_Country_Code__c,Billing_State_Code__c,Rule_Set__c, 
                                                            SubExpo__r.Target_Booth_Revenue__c,SubExpo__r.Name, SubExpo__r.SubShow__c, SubExpo__r.SubShow__r.Name,SubExpo__r.Stage_Date__c,ShowObjectid__c,SubExpoObjectID__c,Pavilion__c
                                                            from Opportunity where Id IN :oppIds 
                                                            and Should_Ignore_Assignment_Rule__c = FALSE
                                                            and Rule_Set__c !='Disabled'
                                                            and Rule_Set__c != NULL
                                                            and Rule_Set__c != ''
                                                            ]);  
    
            //Set<String> TerritoryRulesSet = new Set<String>();
			Set<Id> AccountIds = new Set<Id>();
			Set<Id> ShowIds = new Set<Id>();
            for(opportunity op : oppList) {
                //TerritoryRulesSet.add(op.Rule_Set__c);
				AccountIds.add(op.AccountID);
				ShowIds.add(op.Event__r.Show__c);
            }
			//Account Owner
			List<AccountOwners__c> accOwnersList = new List<AccountOwners__c>([Select AccountOwner__c, AccountOwner__r.IsActive, Show__c, Account__c,SubShow__c,SubExpo__c,Pavilion__c from AccountOwners__c where Account__c IN:AccountIds and Show__c IN: ShowIds and AccountOwner__r.IsActive = TRUE]);
			List<Opportunity> updateOppwithAOList = new List<Opportunity>();
			Set<Id> UpdatedOppIds = new Set<Id>();
            
			if(accOwnersList.Size()>0){
				for(Opportunity opp: oppList){
					for(AccountOwners__c ao:accOwnersList){
                        system.debug('Account Owner Account' + ao.Account__c);
                        system.debug('Opp Account' + opp.AccountID);
                        system.debug('Account Owner Show' + ao.Show__c );
                        system.debug('Opp Show' + opp.Event__r.Show__c);
                        system.debug('ao.SubShow__c'+ ao.SubShow__c);
						if(ao.Account__c == opp.AccountID && ao.Show__c == opp.Event__r.Show__c && ao.SubShow__c == Null && opp.SubExpo__r.SubShow__c == Null ){
							Opportunity UpdateOpp = new Opportunity();
							UpdateOpp.Id = opp.Id;
							UpdateOpp.OwnerId = ao.AccountOwner__c;
							updateOppwithAOList.add(UpdateOpp);
							UpdatedOppIds.add(UpdateOpp.Id);
						}
						if(ao.Account__c == opp.AccountID && ao.Show__c == opp.Event__r.Show__c && ao.SubShow__c != Null && ao.SubShow__c == opp.SubExpo__r.SubShow__c){
							Opportunity UpdateOpp1 = new Opportunity();
							UpdateOpp1.Id = opp.Id;
							UpdateOpp1.OwnerId = ao.AccountOwner__c;
							updateOppwithAOList.add(UpdateOpp1);
							UpdatedOppIds.add(UpdateOpp1.Id);
						}
		
					}
				}
				if(updateOppwithAOList.Size()>0){
					update updateOppwithAOList;
				}
			}
		
			//
			
			List<Opportunity> oppList2 = new List<Opportunity>([Select Id,Should_Ignore_Assignment_Rule__c, Event__r.Show__c, Event__r.Show__r.Name, Event__r.Show__r.OwnerId, Event__r.Show__r.Owner.IsActive, subexpo__r.subshow__r.rule_set__c, AccountID, AccountNameFirstChar__c, OwnerId,Show__c,SubExpo__r.SubShowName__c, BillingCountryandStateCode__c, Billing_Country_Code__c,Billing_State_Code__c,Rule_Set__c, 
                                                            SubExpo__r.Target_Booth_Revenue__c,SubExpo__r.Name, SubExpo__r.SubShow__c, SubExpo__r.SubShow__r.Name,SubExpo__r.Stage_Date__c,ShowObjectid__c,SubExpoObjectID__c,Pavilion__c
                                                            from Opportunity where Id IN :oppIds and Id Not IN: UpdatedOppIds
                                                            and Should_Ignore_Assignment_Rule__c = FALSE
                                                            and Rule_Set__c !='Disabled'
                                                            and Rule_Set__c != NULL
                                                            and Rule_Set__c != ''
                                                            ]);  
    
            Set<String> TerritoryRulesSet = new Set<String>();
            for(opportunity op : oppList2) {
                TerritoryRulesSet.add(op.Rule_Set__c);
			}
			
            System.debug('ee_defaultOPPOwner::defaultOpportunityOwner:TerritoryRulesSet = ' + TerritoryRulesSet);             
            
            List<Territory_Rule__c> TerritoryRules  = new List<Territory_Rule__c>([Select Name__c,Key1__c,Key2__c, OpportunityOwner__c,Rule_Set__c,Territory_Rule_Type__c, Territory_Rule_ID__c from Territory_Rule__c where Rule_Set__c IN: TerritoryRulesSet and IsActiveUser__c = TRUE order by Name__c ASC]);
            
            System.debug('ee_defaultOPPOwner::defaultOpportunityOwner:found rules = ' + TerritoryRules);
            
            for(Opportunity oPP : oppList2) {
                
                if(oPPIDSet.contains(oPP.id))
                    continue;
                if(TerritoryRules.size() >0){
                    for(Territory_Rule__c tr: TerritoryRules){
                        if(oPPIDSet.contains(oPP.id))
                            continue;
                            //Account Name
                            if(oPP.Rule_Set__c == tr.Rule_Set__c){   
                                if(tr.Territory_Rule_Type__c == RT_AccountName ){
                                    if(tr.Key1__c.contains(oPP.AccountNameFirstChar__c) ){                             
                                        oPP.OwnerId=tr.OpportunityOwner__c;
                                        lstOppsToBeUpdated.add(oPP);
                                        oPPIDSet.add(oPP.id);
                                        System.debug('@@@@@@@@@@@@@@@@@@@@@' +oPP);
                                        continue;
                                    }
                                }     
                            }
                            
                            //Billing State
                            if(tr.Territory_Rule_Type__c == RT_BillingState){
                                if(String.IsNotBlank(tr.Key1__c) && tr.Key1__c.contains(oPP.Billing_Country_Code__c)){
                                    if(tr.Key2__c=='*') {
                                    // Territory Rules is for the entire country
                                    oPP.OwnerId=tr.OpportunityOwner__c;
                                    lstOppsToBeUpdated.add(oPP);
                                    oPPIDSet.add(oPP.id);
                                    System.debug('@@@@@@@@@@@@@@@@@@@@@11111' +oPP);
                                    continue;
                                    
                                    } else if ( tr.Key2__c.contains(oPP.Billing_State_Code__c)) {
                                    //Country and State match territory rule
                                    oPP.OwnerId=tr.OpportunityOwner__c;
                                    lstOppsToBeUpdated.add(oPP);
                                    oPPIDSet.add(oPP.id);
                                    System.debug('@@@@@@@@@@@@@@@@@@@@@2222222' +oPP);
                                    continue;
                                    }
                                } 
                                system.debug('############'+oPP.Billing_Country_Code__c);
                                system.debug('44444444444444'+tr.Key2__c);
                                if(tr.Key1__c== International  && String.IsNotBlank(tr.Key2__c) && oPP.Billing_Country_Code__c != 'NULL' && !tr.Key2__c.contains(oPP.Billing_Country_Code__c) && oPP.Billing_Country_Code__c!= Country_US) {
                                    //International rules except US and whatever countries listed in Key2__c.
                                    //Some times show don't consider Canada as part of international countries                 
                                    oPP.OwnerId=tr.OpportunityOwner__c;
                                    lstOppsToBeUpdated.add(oPP);
                                    oPPIDSet.add(oPP.id);
                                    System.debug('@@@@@@@@@@@@@@@@@@@@@333333' +oPP);
                                    continue;                                            
                                }
                            }
                    
                            //Show
                            if(tr.Territory_Rule_Type__c == RT_Show && tr.Key1__c.contains(oPP.Event__r.Show__r.Name)){
                                oPP.OwnerId=tr.OpportunityOwner__c;
                                lstOppsToBeUpdated.add(oPP);
                                oPPIDSet.add(oPP.id);
                                System.debug('@@@@@@@@@@@@@@@@@@@@@44444444444444' +oPP);
                                continue;                                            
                            }
                    
                            //Sub Show
                            if(tr.Territory_Rule_Type__c == RT_SubShow && oPP.SubExpo__r.SubShowName__c != null && tr.Key2__c.contains(oPP.SubExpo__r.SubShowName__c)){
                                oPP.OwnerId=tr.OpportunityOwner__c;
                                lstOppsToBeUpdated.add(oPP);
                                oPPIDSet.add(oPP.id);
                                System.debug('@@@@@@@@@@@@@@@@@@@@@5555' +oPP);
                                continue;                                            
                            }
                            system.debug('@@@@@@@@@@@@@@@@@oPP.BillingCountryandStateCode__c'+oPP.BillingCountryandStateCode__c);
                            //Account Name and Billing State
                            if(tr.Territory_Rule_Type__c == RT_ANBS && tr.Key1__c.contains(oPP.AccountNameFirstChar__c) && !string.isBlank(oPP.BillingCountryandStateCode__c) && tr.Key2__c.contains(oPP.BillingCountryandStateCode__c)){ 
                                oPP.OwnerId=tr.OpportunityOwner__c;
                                lstOppsToBeUpdated.add(oPP);
                                oPPIDSet.add(oPP.id);

                                System.debug('@@@@@@@@@@@@@@@@@@@@@66666' +oPP);
                                continue;                                            
                            }                   
                    }
                }

                if(TerritoryRules.size() == 0 || !oPPIDSet.contains(oPP.id)){
                    if(oPP.Event__r.Show__r.Owner.IsActive == True){
                        oPP.OwnerId = oPP.Event__r.Show__r.OwnerId;
                        lstOppsToBeUpdated.add(oPP);
                        oPPIDSet.add(oPP.id); 
                    }
                }
            }
            //Update Opportunity with udpated owner

            
            update lstOppsToBeUpdated;
            System.debug('ee_defaultOPPOwner::defaultOpportunityOwner:lstOppsToBeUpdated = '+lstOppsToBeUpdated);
    }
}