/*
Dev: Spoorthy Teegala
Date: 03/23/2020
Desc: Trigger to check duplicate records on Segment Object
*/
trigger ee_tgr_Segment on Segment__c (before insert) {
    Set<String> SegNameSet = new Set<String>();
    Set<Id> ShowSet = new Set<Id>();
	Set<Id> SubShowSet = new Set<Id>();
	for(Segment__c segment : trigger.new){
        SegNameSet.add(segment.Name);
		ShowSet.add(segment.Show__c);
		SubShowSet.add(segment.SubShow__c);
	}
	
	if(ShowSet.size()>0 ){
		List<Segment__c> SegmentList = [select Id, Name, Show__c, SubShow__c from Segment__c where Show__c IN: ShowSet];
		Map<Id,Segment__c> SegNameMap = new Map<Id,Segment__c>();
		Map<Id, Id> ShowMap = new Map<Id,Id>();
		Map<Id, Id> SubShowMap = new Map<Id,Id>();
		
		
		for(Segment__c segment: SegmentList){
            SegNameMap.put(Segment.Id, segment);
			ShowMap.put(segment.Id, segment.Show__c);
			SubShowMap.put(segment.Id, segment.SubShow__c);
		}
		system.debug('SegNameMap'+SegNameMap);
		for(Segment__c segment1 : trigger.new){
			for(Segment__c seg: SegNameMap.values()){
				if(SegNameMap.get(seg.id).Name == segment1.Name  && SegNameMap.get(seg.id).Show__c == segment1.Show__c && segment1.SubShow__c != null && SegNameMap.get(seg.id).SubShow__c == segment1.SubShow__c ){
					segment1.addError('Segment Record already exists');
				}else if(SegNameMap.get(seg.id).Name == segment1.Name  && SegNameMap.get(seg.id).Show__c == segment1.Show__c && segment1.SubShow__c == null && SegNameMap.get(seg.id).SubShow__c == null ){
					segment1.addError('Segment Record already exists');
				}
			}
		}
		
	}

}