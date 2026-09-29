CREATE OR ALTER PROCEDURE dbo.usp_edi_write_log
    @InterfaceName NVARCHAR(100),
    @Direction VARCHAR(10),
    @FileName NVARCHAR(260) = NULL,
    @FileHash VARCHAR(64) = NULL,
    @RecordCount INT = NULL,
    @Status VARCHAR(20),
    @Message NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.EDI_IntegrationLog
        (InterfaceName, Direction, FileName, FileHash, RecordCount, Status, Message, StartedAt, FinishedAt)
    VALUES
        (@InterfaceName, @Direction, @FileName, @FileHash, @RecordCount, @Status, @Message,
         SYSUTCDATETIME(), CASE WHEN @Status IN ('SUCCESS','FAILED') THEN SYSUTCDATETIME() END);
END;
GO
