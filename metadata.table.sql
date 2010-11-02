SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [crm].[Metadata](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[QueueName] varchar(256) NOT NULL,
	[IsEnabled] bit NOT NULL,
	[PropertName] varchar(256) NOT NULL,
	[PropertyValue] varchar(1024),
	[Inserted] [datetime] NOT NULL,
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

