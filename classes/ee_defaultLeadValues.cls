//This Class was redesigned 6/16/2020 by Tom Lopilato to address ee_UtilityValues

public class ee_defaultLeadValues {
    public static void defaultValues(Set<ID> leadIDs) {
        List<Lead> lstLeadsToBeUpdated = new List<Lead>();
        List<Event__c> events = new List<Event__c>();
        List<SubExpo__c> subExpo = new List<SubExpo__c>();
        List<Campaign> targetedCampaign = new List<Campaign>();

        Set<String> pardotEventCodes = new Set<String>();
        Set<String> pardotSubShowCodes = new Set<String>();
        Set<String> PardotInvalidSubShowCodes = new Set<String>();
        Set<String> PardotCampaignShortDescs = new Set<String>();
        Set<String> PardotInvalidCampaignShortDescs = new Set<String>();

        Set<Id> EventIds = new Set<Id>();

        List <Lead> lstLeads = [Select ID, pi_ee_Event_Code__c, Event__c, pi_ee_SubShowName__c, SubExpo__c, 
                                EE_Campaign__c, pi_ee_Campaign_Short_Desc__c, Description  from Lead where Id IN :leadIDs];
        
        
        map<string, Event__c> eventCodeToEventMap = new map<string, Event__c>();
        map<string, Event__c> showEventMap = new map<string, Event__c>();
        for(Event__c event : [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c, Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c ORDER BY Stage_Date__c ASC Limit 49999 ]){
                if(event.Stage_Date__c >= System.Today() && !showEventMap.keySet().Contains(event.Show__c))
                    showEventMap.put(event.Show__c, event);
                eventCodeToEventMap.put(event.Event_Code__c, event);
                //if(pardotEventCodes.contains(event.Event_Code__c))
                //  events.add(event);
        }
        for(Lead ld: lstLeads){
            //pardotEventCodes.add(EE_UtilityValues.getActiveEventCode(ld.pi_ee_Event_Code__c));
            pardotEventCodes.add(EE_Task.getEventCode(eventCodeToEventMap, showEventMap,ld.pi_ee_Event_Code__c));

            pardotSubShowCodes.add(ld.pi_ee_SubShowName__c);
            PardotInvalidSubShowCodes.add(ld.pi_ee_SubShowName__c);

            PardotCampaignShortDescs.add(ld.pi_ee_Campaign_Short_Desc__c);
            PardotInvalidCampaignShortDescs.add(ld.pi_ee_Campaign_Short_Desc__c);
        }
        
        
        /*
        if(pardotEventCodes.size() > 0){
            events = [SELECT  Id, Event_Code__c,show__c from Event__c where Event_Code__c IN: pardotEventCodes];
        }
        */
        for(Event__c ev: eventCodeToEventMap.Values()){
            system.debug('----------------Entered -----------------------------');
            if(pardotEventCodes.Contains(ev.Event_Code__c)){
                EventIds.add(ev.Id);
                events.add(ev);
            }
        }
        system.debug('# EventIds : '+EventIds);
        if(pardotSubShowCodes.size() > 0 && EventIds.size() >0 ){
            subExpo = [SELECT Id,Name,Event__c,Event_Code__c, SubShowName__c from SubExpo__c where Event__c IN: EventIds and SubShowName__c IN: pardotSubShowCodes];
        }

        if(PardotCampaignShortDescs.size() > 0 && EventIds.size() >0 ){
            targetedCampaign = [SELECT Short_Description__c, Event__c, Event__r.Event_Code__c  FROM Campaign WHERE Event__c IN: EventIds and Short_Description__c IN:PardotCampaignShortDescs];
        }

        for(Lead l : lstLeads ) {
            System.debug('ee_defaultLeadValues::defaultValues:processing lead = ' + l);
            //String leadActiveEventCode = EE_UtilityValues.getActiveEventCode(l.pi_ee_Event_Code__c);
             String leadActiveEventCode = EE_Task.getEventCode(eventCodeToEventMap, showEventMap,l.pi_ee_Event_Code__c);
             system.debug('# leadActiveEventCode : '+leadActiveEventCode);
            for(Event__c e: events){
                System.debug('------------------Entered Events-----------------');

                //Update Targeted Event
                if( string.isNotBlank(leadActiveEventCode) && leadActiveEventCode == e.Event_Code__c) { //l.Event__c == NULL &&
                    l.Event__c = e.Id;

                    //Look for Targeted SubExpo
                    if(subExpo.size() > 0  && l.SubExpo__c == NULL) {
                        for(SubExpo__c subEx: subExpo) {
                            System.debug('ee_defaultLeadValues::defaultValues:SubExpo__c = ' + subEx.Id + '-' + subEx.Name); 
                            if(l.pi_ee_SubShowName__c == subEx.SubShowName__c && leadActiveEventCode == e.Event_Code__c ){
                                l.SubExpo__c = subEx.Id;
                                PardotInvalidSubShowCodes.remove(subEx.SubShowName__c);
                            }
                        }
                    }
                     
                    if(PardotInvalidSubShowCodes.size() > 0 && l.SubExpo__c == NULL) {
                        for(String invalidSE: PardotInvalidSubShowCodes) {
                            if(l.pi_ee_SubShowName__c != null && l.pi_ee_SubShowName__c == invalidSE && leadActiveEventCode == e.Event_Code__c ){
                                l.Description = 'Invalid SubShow Code is:' +l.pi_ee_SubShowName__c+'; \n';
                            }
                        }
                    }


                    //Lookup campaign
                    System.debug('ee_defaultLeadValues::defaultValues:EE_Campaign__c = ' + l.EE_Campaign__c + '-' + l.pi_ee_Campaign_Short_Desc__c + '- targetedCampaign = ' + targetedCampaign ); 
                          
                    if (targetedCampaign.size() > 0 && l.EE_Campaign__c == NULL) {

                        for(Campaign c: targetedCampaign) {    
                            if(String.isNotBlank(leadActiveEventCode) && leadActiveEventCode == e.Event_Code__c && leadActiveEventCode == c.Event__r.Event_Code__c && l.pi_ee_Campaign_Short_Desc__c == c.Short_Description__c ){
                                l.EE_Campaign__c = c.Id; 
                                System.debug('**************'+l.EE_Campaign__c);
                                PardotInvalidCampaignShortDescs.remove(c.Short_Description__c);
                            }
                        }
                    }

                    if(PardotInvalidCampaignShortDescs.size()> 0 && l.EE_Campaign__c == NULL){
                        for(String InvalidCampaingCode: PardotInvalidCampaignShortDescs) {    
                            if(l.pi_ee_Event_Code__c == e.Event_Code__c && l.pi_ee_Campaign_Short_Desc__c == InvalidCampaingCode ){
                                if(l.Description != null){
                                    l.Description += 'Invalid Campaign Short Description is:' +l.pi_ee_Campaign_Short_Desc__c+';';
                                }
                                else {
                                    l.Description = 'Invalid Campaign Short Description is:' +l.pi_ee_Campaign_Short_Desc__c+';';
                                }
                            }
                        }
                    }
                           
                    lstLeadsToBeUpdated.add(l);
                }
            }
                
            update lstLeadsToBeUpdated;
        }
    }
}