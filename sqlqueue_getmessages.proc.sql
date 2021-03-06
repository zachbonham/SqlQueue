IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetMessages]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetMessages]
GO

CREATE PROCEDURE [dbo].[GetMessages] 
	@QueueID		bigint,
	@Count			int = 1,
	@TimeToReceive	int = 120,
	@TimeToLive		int = 604800,
	@Debug			int = 0
	
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE
        @Error            int,
        @Return          int,
        @Msg              nvarchar(1000),
        @GUID             nvarchar(36),
        @TimeNow          nvarchar(25),
        @SqlCreateBatch		nvarchar(1000),
        @SqlSelect        nvarchar(1000)

    -- init
    SET @Error    = 0
    SET @Return   = 0

    SELECT @GUID     = CONVERT(nvarchar(36),NEWID())
	SELECT @TimeNow  = CONVERT(varchar(25),GETUTCDATE(),21) 
	
	IF @TimeToReceive = 0 OR @TimeToReceive > 120
		BEGIN
			SET @TimeToReceive = 30
		END
	
	IF @TimeToLive = 0 OR @TimeToLive > 604800
		BEGIN
			SET @TimeToLive = 604800
		END

    SET ROWCOUNT @Count
	-- Mark our subset of rows with a unique GUID

	BEGIN TRANSACTION
	
	UPDATE TOP (@Count) [dbo].[QueueTable] WITH (ROWLOCK, READPAST)
		SET ReceiveID = @GUID,
			Status = 'I',
			Received = @TimeNow,
			DequeCount = DequeCount + 1,
			TimeToReceive = @TimeToReceive
	FROM [dbo].[QueueTable] WITH (UPDLOCK, ROWLOCK, READPAST)
        WHERE (Status = 'I' AND DateDiff(second, Received, GetUTCDate()) > @TimeToReceive) 
            OR Status = 'U'
	
    -- Check for errors and abort if found
    SELECT @Error = @@ERROR
        IF @Error <> 0 BEGIN
			ROLLBACK
            SELECT @Msg = 'Error... [GetMessages]: Error creating batch, GUID: ' + @GUID
            GOTO lbl_abort
        END

	SELECT
          Id
		, ReceiveID
		, MessageID
		, DequeCount
		, Status
		, TimeToLive
		, TimeToReceive
		, Inserted
		, Received
		,Expires
		, Body
	FROM [dbo].[QUEUETABLE]
		WHERE Status = 'I'
			AND ReceiveID = @GUID
	ORDER BY [Id] ASC
	

    -- Check for errors and abort if found
    SELECT @Error = @@ERROR
        IF @Error <> 0 BEGIN
			ROLLBACK TRAN
            SELECT @Msg = 'Error... [GetMessages]: Error selecting batch. GUID: ' + @GUID
            GOTO lbl_abort
        END

	COMMIT
    
    --  Done, exit procedure
    GOTO lbl_end

lbl_abort:
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRAN
	END

    SET @Return = ISNULL(@Return,100)
    SET @Msg = ISNULL(@Msg,'Error... [GetMessages]: aborted!')
    RAISERROR(@Msg,16,-1)

lbl_end:
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRAN
	END

    SET NOCOUNT OFF
    SET ROWCOUNT 0

    RETURN @Return

END 


