USE [MessageQueues]
GO

/****** Object:  StoredProcedure [dbo].[PutMessage]    Script Date: 12/22/2009 16:58:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PutMessage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PutMessage]
GO

USE [MessageQueues]
GO

/****** Object:  StoredProcedure [dbo].[PutMessage]    Script Date: 12/22/2009 16:58:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PutMessage]
	@Schema			nvarchar(256),
	@Queue			nvarchar(50),
    @MessageID		uniqueidentifier,
    @TimeToLive		int = 604800,
    @Body			varbinary(max),
	@Debug			int = 0
AS
BEGIN
    
    SET NOCOUNT ON

	DECLARE
        @Error              int,
        @Return             int,
        @Inserted			datetime,
        @Expires			datetime,
		@Msg                nvarchar(1000),
		@SqlInsert			nvarchar(1000),
		@SqlParams			nvarchar(1000)

    -- init
    SET @Error    = 0
    SET @Return   = 0
    SET @Inserted = GETUTCDATE()
    
    -- this messages expires in @TimeToLive in seconds
    --
    SET @Expires = DATEADD(second, @TimeToLive, @Inserted);
    


-- validate schema and queue exist before we get here
--
	SET @SqlInsert = N'
		INSERT INTO [' + @Schema + '].[' + @Queue + ']
		([Status],
		 [MessageId],
		 [TimeToLive],
		 [Body],
		 [Inserted],
		 [Expires]
		 )
		VALUES
		(''U'',
		 @N_MessageId,
		 @N_TimeToLive,
		 @N_Body,
		 @N_Inserted,
		 @N_Expires
		 )'

	SET @SqlParams = N'
		@N_MessageId uniqueidentifier,
		@N_TimeToLive int,
		@N_Body varbinary(max), 
		@N_Inserted datetime,
		@N_Expires datetime'
	
	IF @Debug = 0
		BEGIN
			EXEC sp_executesql @SqlInsert, @SqlParams, 
					@N_MessageId = @MessageId,
					@N_TimeToLive = @TimeToLive,
					@N_Body = @Body,
					@N_Inserted = @Inserted,
					@N_Expires = @Expires
					
		END
	ELSE
		BEGIN
			PRINT @SqlInsert
		END

	 -- Check for errors and abort if found
	SELECT @Error = @@ERROR
	IF @Error <> 0 BEGIN
		SELECT @Msg = 'Error... dbo.PutMessage: Error inserting message.'
		GOTO lbl_abort
	END

	--  Done, exit procedure
	GOTO lbl_end

lbl_abort:
    SET @Return = ISNULL(@Return,100)
    SET @Msg = ISNULL(@Msg,'Error... dbo.PutMessage: aborted!')
    RAISERROR(@Msg,16,-1)

lbl_end:
    SET NOCOUNT OFF
    SET ROWCOUNT 0
    RETURN @Return

END 









GO


