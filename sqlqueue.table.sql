USE queues;

GO
CREATE TABLE [QueueTable]
(
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[QueueId] [BIGINT] NOT NULL,
	[MessageId] [UNIQUEIDENTIFIER] NOT NULL,
	[ReceiveId] [UNIQUEIDENTIFIER] NULL,
	[Body] [VARBINARY](MAX) NULL,
	[DequeCount] [INT] default 0,
	[Status] [CHAR](10) NOT NULL,
	[TimeToLive] [INT] NOT NULL,
	[TimeToReceive] [INT] NULL,
	[Inserted] [DATETIME] NOT NULL,
	[Received] [DATETIME] NULL,
	[Expires] [DATETIME] NOT NULL
) ON [PRIMARY]

GO
