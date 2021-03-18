/*
Dev: Spoorthy Teegala
Date: 05/14/2020
Description: Trigger handler to add CampaignMemberStatus values based on product on campaign when a campaign record is inserted.
*/
public class EE_AddCampaignMemberStatusTgrHandler {
    
    public static void addCampaignMemberStatusonCampaign(List<Campaign> campIds){
        
        List<CampaignMemberStatus> addCampaignMemberStatusList = new List<CampaignMemberStatus>();
        List<Campaign> campaignList =new List<Campaign>();
        List<CampaignMemberStatusTemplate__c> campaignMemberStatusTemplateList = new List<CampaignMemberStatusTemplate__c>();
        

        Set<String> productSet = new Set<String>();
        campaignList = [Select Id, Product__c from Campaign where Id IN: campIds];
        for(Campaign C: campaignList){
            productSet.add(C.Product__c);
        }

        campaignMemberStatusTemplateList = [Select Id, Product__c, HasResponded__c, IsDefault__c, Label__c, SortOrder__c from CampaignMemberStatusTemplate__c where Product__c IN: productSet];
        system.debug('CampaignMemberStatusTemplateList' +campaignMemberStatusTemplateList);
        
        for(Campaign camp: campaignList){
            for(CampaignMemberStatusTemplate__c cst: campaignMemberStatusTemplateList){
                if(camp.Product__c != Null && cst.Product__c != Null && camp.Product__c == cst.Product__c){
                    CampaignMemberStatus cms = new CampaignMemberStatus();
                    cms.CampaignId = camp.Id;
                    cms.Label = (cst.Label__c).trim();
                    cms.HasResponded = cst.HasResponded__c;
                    cms.SortOrder = Integer.valueOf(cst.SortOrder__c);
                    cms.IsDefault = cst.IsDefault__c;
                    addCampaignMemberStatusList.add(cms);
                    system.debug('CampaignMemberStatus' +cms);
                }
            }

        }
        system.debug('AddCampaignMemberStatusList' +addCampaignMemberStatusList);
        if(addCampaignMemberStatusList.size()>0){
            insert addCampaignMemberStatusList;
        }
        
        if(addCampaignMemberStatusList.size()>0){
            List<CampaignMemberStatus> cMSListToDelete = [Select id from CampaignMemberStatus where CampaignId IN: campIds and (SortOrder = 1 or SortOrder = 2) ];
            system.debug('cMSListToDelete::'+cMSListToDelete);

            if(cMSListToDelete.size() > 0){
                delete cMSListToDelete;
            }
        }

    }

}