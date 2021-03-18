// Spoorthy Teegala - This Class is used for storing all the static variables
public Class EE_UtilityValues {
    public static String RT_AccountName = 'Account Name';
    public static String RT_BillingState = 'Billing State';
    public static String RT_Show = 'Show';
    public static String RT_SubShow = 'SubShow';
    public static String RT_ANBS = 'Account Name & Billing State';
    public static String International = 'International';
    public static String Country_US = 'US';
    
    
    public static Id getActiveEventID (String EventCode){
        
        Id ActiveEventId = null;
        List<Event__c> nextEventList = new List<Event__c>();
        List<Event__c> currentEvents = [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c,Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c where Event_Code__c =: EventCode ];
        
        //
        if(currentEvents.size() >0 && currentEvents[0].Stage_Date__c < date.Today() ) {
             
            nextEventList =  [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c, Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c where Show__c =: currentEvents[0].Show__c and Stage_Date__c >= Today ORDER BY Stage_Date__c ASC Limit 1  ]; //    
        }
        
        if(nextEventList.size() > 0) {
            ActiveEventId = nextEventList[0].Id;
        }
        else{
            ActiveEventId = currentEvents[0].Id;
        }

        return ActiveEventId;
    }

    public static String getActiveEventCode (String EventCode){
        
        String ActiveEventCode = '';
        List<Event__c> nextEventList = new List<Event__c>();
        List<Event__c> currentEvents = [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c,Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c where Event_Code__c =: EventCode ];
        
        if(currentEvents.size() >0 && currentEvents[0].Stage_Date__c < date.today()) {
             
            nextEventList =  [select Id, Name,Event_Code__c,Event_ID__c,Event_Year__c,NextYear_Event_ID__c,NextYear_Event_ID__r.Stage_Date__c,Show_Code__c,Show__c, Stage_Date__c,Upcoming_Event_ID__c, Upcoming_Event_ID__r.Stage_Date__c from Event__c where Show__c =: currentEvents[0].Show__c and Stage_Date__c >= Today ORDER BY Stage_Date__c ASC Limit 1  ]; //    
        }
        
        if(nextEventList.size() > 0) {
            ActiveEventCode = nextEventList[0].Event_Code__c;
        }
        else{
            ActiveEventCode = EventCode;
        }

        return ActiveEventCode;
    } 
    
}