USE [MessageQueues]
GO

/****** Object:  StoredProcedure [dbo].[CreateQueue]    Script Date: 12/22/2009 16:58:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CreateQueue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].CreateQueue
GO

USE [MessageQueues]
GO

/****** Object:  StoredProcedure [dbo].[CreateQueue]    Script Date: 12/22/2009 16:58:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].CreateQueue
	@Schema			nvarchar(256),
	@Queue			nvarchar(50),
	@Debug			int = 0
AS
BEGIN
    
    SET NOCOUNT ON

	DECLARE
        @Error              int,
        @Return             int,
		@Msg                nvarchar(1000),
		@Sql				nvarchar(1000),
		@SqlParams			nvarchar(1000)

    -- init
    SET @Error    = 0
    SET @Return   = 0
    


-- validate schema and queue exist before we get here
--
	SET @Sql = N'
		CREATE TABLE [' + @Schema + '].[' + @Queue + ']
		(
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
		) ON [PRIMARY]'
	
	IF @Debug = 0
		BEGIN
			EXEC sp_executesql @Sql
		END
	ELSE
		BEGIN
			PRINT @Sql
		END

	 -- Check for errors and abort if found
	SELECT @Error = @@ERROR
	IF @Error <> 0 BEGIN
		SELECT @Msg = 'Error... dbo.CreateQueue: Error creating queue.'
		GOTO lbl_abort
	END

	--  Done, exit procedure
	GOTO lbl_end

lbl_abort:
    SET @Return = ISNULL(@Return,100)
    SET @Msg = ISNULL(@Msg,'Error... dbo.CreateQueue: aborted!')
    RAISERROR(@Msg,16,-1)

lbl_end:
    SET NOCOUNT OFF
    SET ROWCOUNT 0
    RETURN @Return

END 









GO


