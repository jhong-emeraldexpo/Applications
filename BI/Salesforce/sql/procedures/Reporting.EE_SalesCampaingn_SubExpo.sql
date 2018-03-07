USE [SFDC]
GO

/****** Object:  StoredProcedure [Reporting].[EE_SalesCampaign_SubExpo]    Script Date: 3/6/2018 5:21:34 PM ******/
DROP PROCEDURE [Reporting].[EE_SalesCampaign_SubExpo]
GO

/****** Object:  StoredProcedure [Reporting].[EE_SalesCampaign_SubExpo]    Script Date: 3/6/2018 5:21:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ===================================================================================================
-- Author:		Irene Chan
-- Create date: 5/26/16
-- Description:	Refresh EE_SalesCampaign_SubExpo 'Rod Tomlinson','1415-16,1415-15',null,null,null, null,'Surf'
-- ===================================================================================================
CREATE Procedure [Reporting].[EE_SalesCampaign_SubExpo] 
	@pAccountExecutive  nvarchar(122)=null,
	@pEventCode  nvarchar(900)=null,
	@pCampaignShort  nvarchar(900)=null,
	@pProduct  nvarchar(855)=null,
	@pStage  nvarchar(400)=null,
	@pSubExpo nvarchar(855)=null
as
Begin
/*
drop table #tmp

declare @pAccountExecutive as nvarchar(122),
	@pEventCode as nvarchar(900),
	@pCampaign as nvarchar(900),
	@pCampaignShort as nvarchar(900),
	@pProduct as nvarchar(855),
	@pStage as nvarchar(400),
	@pSubExpo nvarchar(max)
--set @pAccountExecutive='Ryan Nettleton,Randi Mohr,grant ongstad,Doog Becker,Debbie Puccio'
set @pEventCode='3012-17'
if @pEventCode is null
set @pEventCode='None'
set @pCampaign='No Campaign,2016 GLM Test Event-Call-2x-2016-03-16,2016 NY NOW Summer-Call-1x-2016-02-24,2016 GLM Test Event-Call-2x-2016-03-16,2016 GLM Test Event-Call-1x-2016-02-22'
set @pCampaignShort='Inquiry, Win-back'
set @pProduct='Booth,Other,Sponsorship'
set @pStage='(30) Too Early,(50) Somewhat Likely,(70) Highly Likely,(90) Verbal Commitment'
set @pSubExpo='_None, New Exhibitor Pavilion, Home Furnishings + Textiles, Gift, Personal Accessories, Accent on Design®, Handmade® Designer Maker, Tabletop + Gourmet Housewares, Artisan Resource®, Baby + Child, Handmade® Global Design, Personal Care + Wellness'
--*/
DECLARE @SQL VARCHAR(max)

/*
declare @pAccountExecutive as nvarchar(122),
	@pEventCode as nvarchar(900),
	@pCampaign as nvarchar(900),
	@pCampaignShort as nvarchar(900),
	@pProduct as nvarchar(855),
	@pStage as nvarchar(400),
	@pSubExpo as nvarchar(400)
DECLARE @SQL NVARCHAR(max)
--*/

if @pEventCode is null
	set @pEventCode='None'
if @pCampaignShort is null
	set @pCampaignShort='None'
if @pProduct is null
	set @pProduct='None'
if @pStage is null
	set @pStage='None'
if @pAccountExecutive is null
	set @pAccountExecutive='None'
if @pSubExpo is null
	set @pSubExpo='None'
set @pSubExpo=replace(@pSubExpo,', ',',')

SET @SQL='

    SELECT      a.External_Account_ID__c AS [A2Z CoID], 
				a.Name AS [Account Name], 
				a.Id AS [AccountId],
				o.Name AS [Opportunity Name], 
				o.Id AS [OpportunityId], 
                u.Name AS [Account Executive],
				isnull(b.[Probability__c],o.[Probability]) as [Probability],
				o.CloseDate AS [Close Date], 
                isnull(b.[ForecastedAmount__c],o.[Amount]) as [Amount], 
				isnull(o.[ExpectedRevenue],0.00) as [Expected Revenue],
				case when o.[Goldmine_Created_Date__c] is not null then [Goldmine_Created_Date__c] else o.CreatedDate end  [Forecast Create Date],
				e.Name as [EventName], 
				e.[Event_Code__c] as [EventID],
				e.Event_Year__c as [Event Year],
				o.StageName as Stage,
				isnull(b.Product__c,o.Product__c) as Product , 
			    o.[Forecast_NSF__c] as [Forecast NSF],
				o.[NSF_Weighted__c] as [NSF Weighted]
				,case when o.Product__c=''TR Package'' then ''true'' else ''false'' end as TRPackage
				,o.CampaignId
				,ISNULL(c.Name, N''No Campaign'') as [CampaignName]
				,c.[Short_Description__c] as [Campaign_Short_Desc]
				,o.SubExpo__c as SubExpo
				,isnull(s.SubShowName__c,''_None'')  as SubExpoName
				,isnull(b.[ExpectedRevenue__c], o.[ExpectedRevenue]) as [ExpectedRevenue]
				,c.Status as CampaignStatus
   FROM       dbo.Opportunity o (nolock)   
                       left JOIN  dbo.[User] u (nolock) ON u.Id = o.OwnerId
                       INNER JOIN  dbo.Account a (nolock) ON a.Id = o.AccountId 
                       INNER JOIN  dbo.Event__c e (nolock) ON o.Event__c = e.Id 
					   left join  [dbo].[Campaign] c (nolock) on c.Id = o.CampaignId
					   left join [dbo].[PackageForecast__c] b (nolock) on o.Id=b.[Opportunity__c]
					   left join SubExpo__c s on o.SubExpo__c=s.Id
  where 	 1=1
		 AND (o.Product__c IN ('''+replace(@pProduct,',',''',''')+''')) 
		 AND (isnull(s.SubShowName__c,''_None'') IN ('''+replace(@pSubExpo,',',''',''')+''')) 
		 AND (o.StageName IN ('''+replace(@pStage,',',''',''')+''')) 
		 AND (ISNULL(c.[Short_Description__c], N''No Campaign'') IN ('''+replace(@pCampaignShort,',',''',''')+'''))
         AND (e.[Event_Code__c] IN ('''+replace(@pEventCode,',',''',''')+''')) AND (u.Name IN ('''+replace(@pAccountExecutive,',',''',''')+'''))
    '
   if @pAccountExecutive ='None'
   begin
	 set @SQL= replace(@SQL,'AND (u.Name IN (''None''))','')
   end
   if @pSubExpo ='None'
   begin
	 set @SQL= replace(@SQL,'AND (isnull(s.SubShowName__c,''_None'') IN (''None''))','')
   end
    if @pProduct ='None'
   begin
	 set @SQL= replace(@SQL,'AND (o.Product__c IN (''None''))','')
   end
   if @pStage ='None'
   begin
	 set @SQL= replace(@SQL,'AND (o.StageName IN (''None''))','')
   end
   if @pCampaignShort ='None'
   begin
	 set @SQL= replace(@SQL,'AND (ISNULL(c.[Short_Description__c], N''No Campaign'') IN (''None''))','')
   end
   if @pEventCode ='None'
	begin
		set @SQL= replace(@SQL,'AND (e.[Event_Code__c] IN (''None'')) ','')
		--set @SQL= replace(@SQL,'AND 	 (dbo.Event__c.[Event_Code__c] IN (''None''))','')
	end


	--print @SQL
	
	EXEC (@SQL)

END


GO


