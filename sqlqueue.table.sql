
/****** Object:  Table [dbo].[MyQueue]    Script Date: 12/07/2009 07:49:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [crm].[MyQueue](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MessageId] [uniqueidentifier] NOT NULL,
	[ReceiveId] [uniqueidentifier] NULL,
	[Body] [varbinary](max) NULL,
	[DequeCount] [int] default 0,
	[Status] [char](10) NOT NULL,
	[TimeToLive] [int] NOT NULL,
	[TimeToReceive] [int] NULL,
	[Inserted] [datetime] NOT NULL,
	[Received] [datetime] NULL,
	[Expires] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO