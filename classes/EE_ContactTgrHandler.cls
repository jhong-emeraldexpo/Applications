public without sharing class EE_ContactTgrHandler {
    public void UpdateContactEmailHygiene(Map<Id,Contact> newContMap, Map<Id,Contact> oldContMap ) {
       
        List<Contact> ConList = new List<Contact>();
        
        if((newContMap.Values()).size() > 0){
            for(Contact Cont: newContMap.Values()){
                Boolean Entered = False;
                if(Cont.a2z_Contact_ID__c != Null){
                    cont.Hygiene_Status__c= 'Customer';
                    ConList.add(cont);
                    Entered = True;
                    System.debug('***** Entered 1 ****');
                }
                
                if( Entered == False && Cont.Hygiene_Status__c == 'Undeliverable' && newContMap.get(Cont.Id).Email != oldContMap.get(Cont.Id).Email){
                    System.debug('***** Entered 2 ****');
                    
                    cont.Hygiene_Status__c = 'Prospect';
                    cont.EmailBouncedDate = Null;
                    cont.EmailBouncedReason = Null;
                    ConList.add(cont);
                }

            }
        }
    }
}