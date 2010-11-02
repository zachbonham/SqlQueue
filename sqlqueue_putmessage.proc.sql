/****** Object:  StoredProcedure [dbo].[PutMessage]    Script Date: 12/22/2009 16:58:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PutMessage]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[PutMessage]
GO

CREATE PROCEDURE [dbo].[PutMessage]
    @QueueID		BIGINT,
    @MessageID		UNIQUEIDENTIFIER,
    @Body			VARBINARY(MAX),
    @TimeToLive		INT = 604800,
    @Debug			INT = 0
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

INSERT INTO [DBO].[QUEUETABLE]
(
	[QueueID]
	, [Status]
	, [MessageID]
	, [TimeToLive]
	, [Body]
	, [Inserted]
	, [Expires]
)
VALUES
(
	
	@QueueID
	, 'U'
	, @MessageID
	, @TimeToLive
	, @Body
	, @Inserted
	, @Expires
)
	
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


