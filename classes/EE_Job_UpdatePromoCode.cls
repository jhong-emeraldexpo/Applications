public class EE_Job_UpdatePromoCode implements Database.Batchable<sObject>{
    public static string Duplicate = 'Duplicate PromoCodes';
    private string query;
    public EE_Job_UpdatePromoCode() {
       
        query='Select Id, Event__c, Promo_Code__c, User__c, Event_User__c, Event__r.Stage_Date__c from PromoCode_by_Event__c where Event__c != Null and User__c != Null and Promo_Code__c != Null and Event__r.Stage_Date__c >= Today';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<CampaignMember> updateCMSet = new Set<CampaignMember>();
        List<CampaignMember> updateCMList = new List<CampaignMember>();
        Set<OpportunityContactRole> updateOCRSet = new Set<OpportunityContactRole>();
        List<OpportunityContactRole> updateOCRList = new List<OpportunityContactRole>();

        Map<Id, PromoCode_by_Event__c> pceMap= new Map<Id, PromoCode_by_Event__c>();
        Set<String> pcSet= new Set<String>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> eveIdSet = new Set<Id>();
        set<String> pceEventUserSet = new set<String>();
        for(PromoCode_by_Event__c pce: (List<PromoCode_by_Event__c>) scope){
            pceMap.put(pce.Id,pce);
            pcSet.add(pce.Promo_Code__c);
            userIdSet.add(pce.User__c);
            eveIdSet.add(pce.Event__c);
            pceEventUserSet.add(pce.Event_User__c);

        }

        List<CampaignMember> cMList = [Select Id, ContactId, Owner__c, Promo_Code__c, Event__c, Registered_Event_Code__c, Contact.ContactGUID__c from CampaignMember where Owner__c != Null and Event__c != Null and Owner__c IN: userIdSet and Event__c IN: eveIdSet];
        system.debug('cMList'+cMList);

        List<OpportunityContactRole> oCRList = [Select Id, ContactId, Owner__c, Event__c, Registered_Event_Code__c, ContactGUID__c, Promo_Code__c from OpportunityContactRole where Owner__c != Null and Event__c != Null and Owner__c IN: userIdSet and Event__c IN: eveIdSet];
        system.debug('oCRList'+oCRList);


        //Need to compare if the promocode by event id and count is >1
        Map<String,Integer> pceEventUserCountMap = new Map<String,Integer>();
        for(AggregateResult ar:[select Event_User__c, count(Id) countId from PromoCode_by_Event__c GROUP BY ROLLUP(Event_User__c) HAVING Event_User__c IN: pceEventUserSet ]){
            if((String)ar.get('Event_User__c') != null){
                pceEventUserCountMap.put((String)ar.get('Event_User__c'),(Integer)ar.get('countId'));
                system.debug('pceCountMap'+pceEventUserCountMap);
            }
        }
        

        for(Id pcbe: pceMap.Keyset()){
            if(cMList.size()>0){
                for(CampaignMember cm: cMList){
                    //system.debug('pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c)'+pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c));
                    if(cm.Event__c == pceMap.get(pcbe).Event__c && pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c) <= 1  && cm.Owner__c == pceMap.get(pcbe).User__c ){
                        CampaignMember cm1 = new CampaignMember();
                        cm1.Id = cm.Id;
                        cm1.Promo_Code__c = pceMap.get(pcbe).Promo_Code__c;
                        updateCMSet.add(cm1);
                    }else if(cm.Event__c == pceMap.get(pcbe).Event__c && pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c) > 1  && cm.Owner__c == pceMap.get(pcbe).User__c ){
                        CampaignMember cm1 = new CampaignMember();
                        cm1.Id = cm.Id;
                        cm1.Promo_Code__c = Duplicate;
                        updateCMSet.add(cm1);
                    }
                }
            }
            if(oCRList.size()>0){
                for(OpportunityContactRole ocr: oCRList){
                    if(ocr.Event__c == pceMap.get(pcbe).Event__c && pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c) <= 1 && ocr.Owner__c == pceMap.get(pcbe).User__c ){
                        OpportunityContactRole ocr1 = new OpportunityContactRole();
                        ocr1.Id = ocr.Id;
                        ocr1.Promo_Code__c = pceMap.get(pcbe).Promo_Code__c;
                        updateOCRSet.add(ocr1);
                    }else if(ocr.Event__c == pceMap.get(pcbe).Event__c && pceEventUserCountMap.get(pceMap.get(pcbe).Event_User__c) > 1 && ocr.Owner__c == pceMap.get(pcbe).User__c ){
                        OpportunityContactRole ocr1 = new OpportunityContactRole();
                        ocr1.Id = ocr.Id;
                        ocr1.Promo_Code__c = Duplicate;
                        updateOCRSet.add(ocr1);
                    } 
                }
            }
        }
        if(updateCMSet.size()>0){
            try{
                updateCMList.addAll(updateCMSet);
                update updateCMList;
                system.debug('updateCMList'+updateCMList);
            }
            catch(exception e){
                alertEmeraldSFDCSupportTeam('CampaignMember','Update', e.getMessage()); 
            }
        }
        if(updateOCRSet.size()>0){
            try{
                updateOCRList.addAll(updateOCRSet);
                update updateOCRList;
                system.debug('updateOCRList'+updateOCRList);
            }
            catch(exception e){
               alertEmeraldSFDCSupportTeam('OpportunityContactRole','Update', e.getMessage());
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!Test.IsRunningTest()){
            EE_Job_UpdatePromoCode b = new EE_Job_UpdatePromoCode();
            System.scheduleBatch(b,'EE_Job_UpdatePromoCode', 60, 100);
        }      
    }
    public void alertEmeraldSFDCSupportTeam(string objectName, string operation, string errorMessage){

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<string>();
        string subjectmsg = 'System Exception while processing MC Inbound Integation records';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        sendTo = EmailSplitter(System.Label.IT_Team_Email_Addresses);
        if(sendTo.size() > 0){
            email.setToAddresses(sendTo);
        }
        email.setSubject(subjectmsg);
        email.setHTMLBody('System Error <br/><br/>'+
        '<b> Received error while performing the following operation: '+operation+'<br/>'+
        '<b> For the following Object: '+objectName+'<br/>'+
        '<b> Error: <b/>'+errorMessage+'<br/>');

        emailList.add(email);
        if(emailList.size()>0){
            Messaging.sendEmail(emailList);
        }
    }

    public List<String> EmailSplitter(string stringValue){
        list<string> emailList = new List<string>();
        if(string.isNotBlank(stringValue)){
            if(stringValue.contains(',')){
                string[] afterSplit = stringValue.split(',');
                for(string s:afterSplit){
                    emailList.add(s);
                }
            }
            else{
                emailList.add(stringValue);
            }
        }
        return emailList;
    }
 
}