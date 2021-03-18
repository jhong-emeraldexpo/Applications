/*
Dev: Spoorthy Teegala
Date:05/25/2020
Description:Trigger handler to Create Contact Details byShow record when an Contact Segment is created.
*/
public class EE_CreateConDetailsbyShow{

    public static void createConDetailsbyShowRec(Set<ID> conSegIds){

        List<Contact_Segment__c> updateConSegList = new List<Contact_Segment__c>();
        List<Contact_Details_By_Show__c> insertConDetailsbyShowList = new List<Contact_Details_By_Show__c>();
        Set<Contact_Segment__c> updateConSegSet = new Set<Contact_Segment__c>();
        Set<Contact_Details_By_Show__c> insertConDetailsbyShowSet = new Set<Contact_Details_By_Show__c>();


        Set<Id> conIdSet = new Set<Id>();
        Set<String> showSet = new Set<String>();
        List<Contact_Segment__c> newlyInsertedConSegsList = [Select Id, Contact__c, Contact__r.Name, Segment__r.Show__c, Segment__r.Show__r.Name, Contact_Details_By_Show__c from Contact_Segment__c where Id IN:conSegIds];
        system.debug('newlyInsertedConSegsList'+newlyInsertedConSegsList);
        for(Contact_Segment__c conSeg: newlyInsertedConSegsList){
            conIdSet.add(conSeg.Contact__c);
            showSet.add(conSeg.Segment__r.Show__c);
        }
        
        List<Contact_Details_By_Show__c> conDetailsbyShowList =[Select Id, Contact__c, Show__c from Contact_Details_By_Show__c where Contact__c IN:conIdSet and Show__c IN:showSet];
        system.debug('conDetailsbyShowList'+conDetailsbyShowList);

        if(conDetailsbyShowList.size() > 0){
            for(Contact_Segment__c conSegment: newlyInsertedConSegsList){
                for(Contact_Details_By_Show__c conDetailsbyShow: conDetailsbyShowList){
                    if(conSegment.Contact__c != Null && conSegment.Segment__r.Show__c != Null && conSegment.Contact_Details_By_Show__c == Null && conSegment.Contact__c == conDetailsbyShow.Contact__c && conSegment.Segment__r.Show__c == conDetailsbyShow.Show__c){
                        Contact_Segment__c conseg = new Contact_Segment__c();
                        conseg.Id = conSegment.Id;
                        conseg.Contact_Details_By_Show__c = conDetailsbyShow.Id;
                        updateConSegSet.add(conseg);
                    }
                }
            }
            
        }
        if(updateConSegSet.Size() > 0){
            updateConSegList.addAll(updateConSegSet);
            update updateConSegList;
        }

        if(conDetailsbyShowList.size() == 0){
            for(Contact_Segment__c conSegment1: newlyInsertedConSegsList){
                if(conSegment1.Contact__c != Null && conSegment1.Segment__r.Show__c != Null && conSegment1.Contact_Details_By_Show__c == Null){
                    Contact_Details_By_Show__c condbs = new Contact_Details_By_Show__c();
                    condbs.Contact__c = conSegment1.Contact__c;
                    condbs.Show__c = conSegment1.Segment__r.Show__c;
                    insertConDetailsbyShowSet.add(condbs);
                }
            }
            
        }
        if(insertConDetailsbyShowSet.Size()>0){
            insertConDetailsbyShowList.addAll(insertConDetailsbyShowSet);        
            insert insertConDetailsbyShowList;
        }
        
        List<Id> condbsIdList = new List<Id>();
        for(Contact_Details_By_Show__c condbs: insertConDetailsbyShowList){
            condbsIdList.add(condbs.id);
        }

        List<Contact_Details_By_Show__c> newlyInsertedConDetailsbyShowList = [Select Id, Contact__c, Show__c from Contact_Details_By_Show__c where Id IN:condbsIdList];
        if(newlyInsertedConDetailsbyShowList.size() > 0){
            for(Contact_Segment__c conSegment2: newlyInsertedConSegsList){
                for(Contact_Details_By_Show__c conDetailsbyShow1: newlyInsertedConDetailsbyShowList){
                    if(conSegment2.Contact__c != Null && conSegment2.Segment__r.Show__c != Null && conSegment2.Contact_Details_By_Show__c == Null && conSegment2.Contact__c == conDetailsbyShow1.Contact__c && conSegment2.Segment__r.Show__c == conDetailsbyShow1.Show__c){
                        Contact_Segment__c conseg1 = new Contact_Segment__c();
                        conseg1.Id = conSegment2.Id;
                        conseg1.Contact_Details_By_Show__c = conDetailsbyShow1.Id;
                        updateConSegSet.add(conseg1);
                    }
                }
            }
            if(updateConSegSet.Size() > 0){
                updateConSegList.addAll(updateConSegSet);
                update updateConSegList;
            } 
        }

    }
}