/*
Dev: Spoorthy Teegala
Date: 05/14/2020
Description: Trigger to add CampaignMemberStatus values based on product on campaign when a campaign record is inserted.
*/
trigger ee_tgr_campaign on Campaign (After insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        EE_AddCampaignMemberStatusTgrHandler.addCampaignMemberStatusonCampaign(Trigger.new);
    }  

}