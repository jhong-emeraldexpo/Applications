/*
Dev: Spoorthy Teegala
Date:05/25/2020
Description:Trigger handler to Create Account Details byShow record when an Account Segment is created.
*/
public class EE_CreateAccDetailsbyShow{

    public static void createAccDetailsbyShowRec(Set<ID> accSegIds){

        List<Account_Segment__c> updateAccSegList = new List<Account_Segment__c>();
        List<Account_Details_by_Show__c> insertAccDetailsbyShowList = new List<Account_Details_by_Show__c>();
        Set<Account_Segment__c> updateAccSegSet = new Set<Account_Segment__c>();
        Set<Account_Details_by_Show__c> insertAccDetailsbyShowSet = new Set<Account_Details_by_Show__c>();

        Set<Id> accIdSet = new Set<Id>();
        Set<String> showSet = new Set<String>();
        List<Account_Segment__c> newlyInsertedAccSegsList = [Select Id, Account__c, Account__r.Name, Segment__r.Show__c, Segment__r.Show__r.Name, Account_Details_by_Show__c from Account_Segment__c where Id IN:accSegIds];
        system.debug('newlyInsertedAccSegsList'+newlyInsertedAccSegsList);
        for(Account_Segment__c accSeg: newlyInsertedAccSegsList){
            accIdSet.add(accSeg.Account__c);
            showSet.add(accSeg.Segment__r.Show__c);
        }
        
        List<Account_Details_by_Show__c> accDetailsbyShowList =[Select Id, Account__c, Show__c from Account_Details_by_Show__c where Account__c IN:accIdSet and Show__c IN:showSet];
        system.debug('accDetailsbyShowList'+accDetailsbyShowList);

        if(accDetailsbyShowList.size() > 0){
            for(Account_Segment__c accSegment: newlyInsertedAccSegsList){
                for(Account_Details_by_Show__c accDetailsbyShow: accDetailsbyShowList){
                    if(accSegment.Account__c != Null && accSegment.Segment__r.Show__c != Null && accSegment.Account_Details_by_Show__c == Null && accSegment.Account__c == accDetailsbyShow.Account__c && accSegment.Segment__r.Show__c == accDetailsbyShow.Show__c){
                        Account_Segment__c aseg = new Account_Segment__c();
                        aseg.Id = accSegment.Id;
                        aseg.Account_Details_by_Show__c = accDetailsbyShow.Id;
                        updateAccSegSet.add(aseg);
                        system.debug('updateAccSegSet'+updateAccSegSet);
                    }
                }
            }
            
        }
        if(updateAccSegSet.Size() > 0){
            updateAccSegList.addAll(updateAccSegSet);
            update updateAccSegList;
        }

        if(accDetailsbyShowList.size() == 0){
            for(Account_Segment__c accSegment1: newlyInsertedAccSegsList){
                if(accSegment1.Account__c != Null && accSegment1.Segment__r.Show__c != Null && accSegment1.Account_Details_by_Show__c == Null){
                    Account_Details_by_Show__c ads = new Account_Details_by_Show__c();
                    //ads.Name = string.valueof(accSegment1.Segment__r.Show__r.Name+'-'+accSegment1.Account__r.Name);
                    ads.Account__c = accSegment1.Account__c;
                    ads.Show__c = accSegment1.Segment__r.Show__c;
                    insertAccDetailsbyShowSet.add(ads);
                    system.debug('insertAccDetailsbyShowSet'+insertAccDetailsbyShowSet);
                }
            }
            
        }
        if(insertAccDetailsbyShowSet.Size()>0){
            insertAccDetailsbyShowList.addAll(insertAccDetailsbyShowSet);
            insert insertAccDetailsbyShowList;
        }
        
        List<Id> adbsIdList = new List<Id>();
        for(Account_Details_by_Show__c adbs: insertAccDetailsbyShowList){
            adbsIdList.add(adbs.id);
        }

        List<Account_Details_by_Show__c> newlyInsertedAccDetailsbyShowList = [Select Id, Account__c, Show__c from Account_Details_by_Show__c where Id IN:adbsIdList];
        if(newlyInsertedAccDetailsbyShowList.size() > 0){
            for(Account_Segment__c accSegment2: newlyInsertedAccSegsList){
                for(Account_Details_by_Show__c accDetailsbyShow1: newlyInsertedAccDetailsbyShowList){
                    if(accSegment2.Account__c != Null && accSegment2.Segment__r.Show__c != Null && accSegment2.Account_Details_by_Show__c == Null && accSegment2.Account__c == accDetailsbyShow1.Account__c && accSegment2.Segment__r.Show__c == accDetailsbyShow1.Show__c){
                        Account_Segment__c aseg1 = new Account_Segment__c();
                        aseg1.Id = accSegment2.Id;
                        aseg1.Account_Details_by_Show__c = accDetailsbyShow1.Id;
                        updateAccSegSet.add(aseg1);
                        system.debug('updateAccSegSet'+updateAccSegSet);
                    }
                }
            }
            if(updateAccSegSet.Size() > 0){
                updateAccSegList.addAll(updateAccSegSet);
                update updateAccSegList;
            } 
        }

    }
}