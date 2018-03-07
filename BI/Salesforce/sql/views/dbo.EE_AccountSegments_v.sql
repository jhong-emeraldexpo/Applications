USE [SFDC]
GO

/****** Object:  View [dbo].[EE_AccountSegments_v]    Script Date: 3/6/2018 5:24:22 PM ******/
DROP VIEW [dbo].[EE_AccountSegments_v]
GO

/****** Object:  View [dbo].[EE_AccountSegments_v]    Script Date: 3/6/2018 5:24:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[EE_AccountSegments_v] as 
SELECT [Account_Segment__c].Id as [AccountSegment ID]
      ,[Account__c]
	  ,Segment__c.Id as [Segment Id]
      ,Segment__c.Description__c,
	   Segment__c.Type__c as SegmentType
      ,Segment__c.Name as SegmentName
      ,[Account_Segment__c].[Name]
      ,Show__c.Id as [Show ID]
	  ,Show__c.name as [Show Name]
      ,Segment__c.SubShow__c as [SubShow ID]
	   ,SubShow__c.Name as Subshow
	   ,[Account_Segment__c].NSF__c
	   ,[Account_Segment__c].IsNewExhibitor__c
      ,Account.[BillingStreet]
      ,Account.[BillingCity]
      ,Account.[BillingState]
      ,Account.[BillingCountry]
      ,Account.[Email_Main__c] as Email
      ,Account.[FirstName__c] as FirstName
      ,Account.[LastName__c] as LastName
      ,Account.Id as [Account ID]
      ,Account.Name as [Account Name]
	  ,Account.DBA__c as [DBA]
	  ,Account.DBA2__c as [DBA 2]
      ,Account.External_Account_ID_Text__c  as [A2Z CoID]
	  ,Account.DM_ID__c
	  ,Case When Substring(Account.DM_ID__c,1,3) = 'USI'  then Substring(Account.DM_ID__c,4,len(Account.DM_ID__c)-3) else '' end [USI Account Code]
  FROM [dbo].[Account_Segment__c] with (nolock)
  join [dbo].Account with (nolock) on [Account_Segment__c].Account__c = Account.Id
  join [dbo].Segment__c with (nolock) on Segment__c.Id = [Segment__c]
  left outer join [dbo].Show__c with (nolock) on Segment__c.Show__c = Show__c.Id
  left outer join [dbo].SubShow__c with (nolock) on Segment__c.SubShow__c = SubShow__c.Id


GO


