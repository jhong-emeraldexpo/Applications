public class ee_defaultLeadOwner {
     
     public static void defaultLeadOwner(Set<ID> leadIDs){
          String RT_AccountName = EE_UtilityValues.RT_AccountName;
          String RT_BillingState = EE_UtilityValues.RT_BillingState;
          String RT_Show = EE_UtilityValues.RT_Show;
          String RT_SubShow = EE_UtilityValues.RT_SubShow;
          String RT_ANBS = EE_UtilityValues.RT_ANBS;
          String International = EE_UtilityValues.International;
          String Country_US = EE_UtilityValues.Country_US;
          //new changes to the territory rule assignment will assign the lead owner based on the territory rule name in ASC order
          List <Lead>lstLeadsToBeUpdated = new List<Lead>();
          Set<id> LeadIDSet = new Set<id>();
        
          List <Lead> lstLeads = new List<Lead>([Select ID,Company, Name,Email,AccountNameFirstChar__c,BillingCountryandStateCode__c, Billing_Country_Code__c,Billing_State_Code__c,Rule_Set__c, Event__r.Show__r.Name, Event__r.Show__r.OwnerId, Event__r.Show__r.Owner.IsActive, SubExpo__r.SubShowName__c  from Lead where Id IN :leadIDs
                                                and Should_Ignore_Assignment_Rule__c = FALSE
                                                and Rule_Set__c != 'Disabled' 
                                                and Rule_Set__c != NULL
                                                and Rule_Set__c != '']
                                                );
  
          Set<String> TerritoryRulesSet = new Set<String>();
          for(Lead l : lstLeads ) {
               TerritoryRulesSet.add(l.Rule_Set__c);
          }
          System.debug('ee_defaultLeadOwer::defaultLeadOwner:TerritoryRulesSet = ' + TerritoryRulesSet);             
         
          List<Territory_Rule__c> TerritoryRules  = new List<Territory_Rule__c>([Select Name__c,Key1__c,Key2__c, OpportunityOwner__c,Rule_Set__c,Territory_Rule_Type__c, Territory_Rule_ID__c from Territory_Rule__c where Rule_Set__c   IN  : TerritoryRulesSet and IsActiveUser__c = TRUE order by Name__c ASC]);
          
          System.debug('ee_defaultLeadOwer::defaultLeadOwner:found rules = ' + TerritoryRules);
         
          for(Lead l : lstLeads ) {
               
               
               if(TerritoryRules.size() >0){
                    for(Territory_Rule__c tr: TerritoryRules){
                         if(LeadIDSet.contains(l.id))
                              continue;
                         //Account Name
                         if(l.Rule_Set__c == tr.Rule_Set__c){   
                              if(tr.Territory_Rule_Type__c == RT_AccountName ){
                                   if(tr.Key1__c.contains(l.AccountNameFirstChar__c) ){                             
                                        l.OwnerId=tr.OpportunityOwner__c;
                                        l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                                        lstLeadsToBeUpdated.add(l);
                                        LeadIDSet.add(l.id);
                                        System.debug('@@@@@@@@@@@@@@@@@@@@@' +l);
                                        continue;
                                   }
                              }     
                         }
                         
                         //Billing State
                         if(tr.Territory_Rule_Type__c == RT_BillingState){
                              if(String.IsNotBlank(tr.Key1__c) && tr.Key1__c.contains(l.Billing_Country_Code__c)){
                                   if(tr.Key2__c=='*') {
                                   // Territory Rules is for the entire country
                                   l.OwnerId=tr.OpportunityOwner__c;
                                   l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                                   lstLeadsToBeUpdated.add(l);
                                   LeadIDSet.add(l.id);
                                   System.debug('@@@@@@@@@@@@@@@@@@@@@11111' +l);
                                   continue;
                                   
                                   } else if ( tr.Key2__c.contains(l.Billing_State_Code__c)) {
                                   //Country and State match territory rule
                                   l.OwnerId=tr.OpportunityOwner__c;
                                   l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                                   lstLeadsToBeUpdated.add(l);
                                   LeadIDSet.add(l.id);
                                   System.debug('@@@@@@@@@@@@@@@@@@@@@2222222' +l);
                                   continue;
                                   }
                              } 
                              system.debug('############'+l.Billing_Country_Code__c);
                              system.debug('44444444444444'+tr.Key2__c);
                              if(tr.Key1__c== International  && String.IsNotBlank(tr.Key2__c) && l.Billing_Country_Code__c != 'NULL' && !tr.Key2__c.contains(l.Billing_Country_Code__c) && l.Billing_Country_Code__c!= Country_US) {
                                   //International rules except US and whatever countries listed in Key2__c.
                                   //Some times show don't consider Canada as part of international countries                 
                                   l.OwnerId=tr.OpportunityOwner__c;
                                   l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                                   lstLeadsToBeUpdated.add(l);
                                   LeadIDSet.add(l.id);
                                   System.debug('@@@@@@@@@@@@@@@@@@@@@333333' +l);
                                   continue;                                            
                              }
                         }
                    
                         //Show
                         if(tr.Territory_Rule_Type__c == RT_Show && tr.Key1__c.contains(l.Event__r.Show__r.Name)){
                              l.OwnerId=tr.OpportunityOwner__c;
                              lstLeadsToBeUpdated.add(l);
                              LeadIDSet.add(l.id);
                              System.debug('@@@@@@@@@@@@@@@@@@@@@44444444444444' +l);
                              continue;                                            
                         }
                    
                         //Sub Show
                         if(tr.Territory_Rule_Type__c == RT_SubShow && l.SubExpo__r.SubShowName__c != null && tr.Key2__c.contains(l.SubExpo__r.SubShowName__c)){
                              l.OwnerId=tr.OpportunityOwner__c;
                              l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                              lstLeadsToBeUpdated.add(l);
                              LeadIDSet.add(l.id);
                              System.debug('@@@@@@@@@@@@@@@@@@@@@5555' +l);
                              continue;                                            
                         }
                         system.debug('@@@@@@@@@@@@@@@@@l.BillingCountryandStateCode__c'+l.BillingCountryandStateCode__c);
                         //Account Name and Billing State
                         if(tr.Territory_Rule_Type__c == RT_ANBS && tr.Key1__c.contains(l.AccountNameFirstChar__c) && !string.isBlank(l.BillingCountryandStateCode__c) && tr.Key2__c.contains(l.BillingCountryandStateCode__c)){ 
                              l.OwnerId=tr.OpportunityOwner__c;
                              l.Territory_Rule_ID__c = tr.Territory_Rule_ID__c;
                              lstLeadsToBeUpdated.add(l);
                              LeadIDSet.add(l.id);

                              System.debug('@@@@@@@@@@@@@@@@@@@@@66666' +l);
                              continue;                                            
                         }                   
                    }
               }

               if(TerritoryRules.size() == 0 || !LeadIDSet.contains(l.id)){
                    if(l.Event__r.Show__r.Owner.IsActive == True){
                         l.OwnerId = l.Event__r.Show__r.OwnerId;
                         lstLeadsToBeUpdated.add(l);
                         LeadIDSet.add(l.id);
                    } 
               }
          }
          //Update Leads with udpated owner

          
          update lstLeadsToBeUpdated;
          System.debug('ee_defaultLeadOwer::defaultLeadOwner:lstLeadsToBeUpdated = '+lstLeadsToBeUpdated);
     }

     // Spoorthy Teegala - addLeadsToQueue() is used for assigning leads to Sales Rep Queue if Event Code is not Valid
     public static void addLeadsToQueue(List<Lead> newleadsList){
          
          Set<String> pLEventCodes = new Set<String>();
          Set<String> InvalidEventCodes = new Set<String>();

          //Group SalesOpsQueue = [Select Id from Group where Type = 'Queue' AND Name = 'Sales Ops' LIMIT 1];

          for(Lead nl: newleadsList){
               if(nl.pi_ee_Event_Code__c != ''){
                    pLEventCodes.add(nl.pi_ee_Event_Code__c);
               }
          }

          if(pLEventCodes.size()> 0){
               List <Event__c> pardotEventList =[Select id,Event_code__c from Event__c where Event_code__c IN: pLEventCodes];
               
               if(pardotEventList.size()>0){
                    InvalidEventCodes.addAll(pLEventCodes);
                    for(Event__c e: pardotEventList){
                         if(pLEventCodes.contains(e.Event_code__c) ){
                              //Removing valid event codes to filterout invalid event codes
                              InvalidEventCodes.remove(e.Event_code__c);
                         }
                    }  
               }
               if(pardotEventList.size() == 0){
                    // add leads event codes directly to invalid code set if query on event codes returns 0 items
                    InvalidEventCodes.addAll(pLEventCodes);
               }
          }

          if(InvalidEventCodes.size() > 0){
               for(Lead l: newleadsList){
                    for(String invalidCode:InvalidEventCodes){
                         if(l.pi_ee_Event_Code__c == invalidCode){
                              //assigning the lead owner as Sales Rep queue if a given lead as invalid pardot event code
                              //l.OwnerId = SalesOpsQueue.ID;
                              l.Description = 'Invalid Event Code is:' +l.pi_ee_Event_Code__c;
                         }
                    }
               }
          }
     }

}