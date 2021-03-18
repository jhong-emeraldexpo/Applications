<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Campaign_IsActive_Flag</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Campaign IsActive Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_Name_Update</fullName>
        <description>Event__r.Name &amp;'-'&amp; Short_Description__c &amp;'-'&amp; TEXT(Technique__c)</description>
        <field>Name</field>
        <formula>Event__r.Name &amp;'-'&amp; Short_Description__c &amp;'-'&amp; TEXT(Technique__c)</formula>
        <name>Campaign Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_isActive</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Set isActive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Active Campaign</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>contains</operation>
            <value>In Progress,Pending</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign IsActive Flag</fullName>
        <actions>
            <name>Campaign_IsActive_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(BEGINS(Short_Description__c,'P-'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign Name Update</fullName>
        <actions>
            <name>Campaign_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Active Campaign</fullName>
        <actions>
            <name>Set_isActive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>contains</operation>
            <value>In Progress,Pending</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
