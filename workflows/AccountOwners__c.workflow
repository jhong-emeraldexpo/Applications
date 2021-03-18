<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_previous_owner</fullName>
        <description>Notify previous Account Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Previous_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Notification_for_Account_Owner_Change</template>
    </alerts>
</Workflow>
