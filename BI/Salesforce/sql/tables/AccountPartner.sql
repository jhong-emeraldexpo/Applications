USE [SFDC]
GO

/****** Object:  Table [dbo].[AccountPartner]    Script Date: 3/6/2018 5:19:48 PM ******/
DROP TABLE [dbo].[AccountPartner]
GO

/****** Object:  Table [dbo].[AccountPartner]    Script Date: 3/6/2018 5:19:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccountPartner](
	[AccountFromId] [nchar](18) NOT NULL,
	[AccountToId] [nchar](18) NULL,
	[CreatedById] [nchar](18) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Id] [nchar](18) NOT NULL,
	[IsDeleted] [varchar](5) NOT NULL,
	[IsPrimary] [varchar](5) NOT NULL,
	[LastModifiedById] [nchar](18) NULL,
	[LastModifiedDate] [datetime2](7) NOT NULL,
	[OpportunityId] [nchar](18) NULL,
	[ReversePartnerId] [nchar](18) NULL,
	[Role] [nvarchar](40) NULL,
	[SystemModstamp] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_AccountPartner_Id] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

