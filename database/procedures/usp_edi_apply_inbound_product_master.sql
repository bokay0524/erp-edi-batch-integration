CREATE OR ALTER PROCEDURE dbo.usp_edi_stage_inbound_product_master
    @ProductCode VARCHAR(50),
    @ProductName NVARCHAR(200),
    @ReplacementCode VARCHAR(50) = NULL,
    @Active CHAR(1),
    @FileHash VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.EDI_InboundProductMaster
        (FileHash, ProductCode, ProductName, ReplacementCode, Active)
    VALUES
        (@FileHash, @ProductCode, @ProductName, NULLIF(@ReplacementCode,''), @Active);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_edi_apply_inbound_product_master
    @FileHash VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF EXISTS (SELECT 1 FROM dbo.EDI_FileHistory WHERE FileHash = @FileHash AND Status = 'SUCCESS')
        THROW 51000, 'The file has already been processed.', 1;

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE dbo.EDI_InboundProductMaster
           SET ValidationStatus = CASE
                WHEN ProductCode = '' THEN 'ERROR'
                WHEN Active NOT IN ('Y','N') THEN 'ERROR'
                ELSE 'VALID'
               END,
               ValidationMessage = CASE
                WHEN ProductCode = '' THEN N'ProductCode is required.'
                WHEN Active NOT IN ('Y','N') THEN N'Active must be Y or N.'
                ELSE NULL
               END
         WHERE FileHash = @FileHash;

        IF EXISTS (SELECT 1 FROM dbo.EDI_InboundProductMaster WHERE FileHash=@FileHash AND ValidationStatus='ERROR')
            THROW 51001, 'Inbound validation failed.', 1;

        MERGE dbo.ERP_ProductMaster AS target
        USING (
            SELECT ProductCode, ProductName, ReplacementCode, Active
            FROM dbo.EDI_InboundProductMaster
            WHERE FileHash=@FileHash AND ValidationStatus='VALID'
        ) AS source
        ON target.ProductCode = source.ProductCode
        WHEN MATCHED THEN UPDATE SET
            ProductName=source.ProductName,
            ReplacementCode=source.ReplacementCode,
            Active=source.Active,
            UpdatedAt=SYSUTCDATETIME()
        WHEN NOT MATCHED THEN INSERT(ProductCode,ProductName,ReplacementCode,Active)
            VALUES(source.ProductCode,source.ProductName,source.ReplacementCode,source.Active);

        INSERT dbo.EDI_FileHistory(FileHash, FileName, Direction, Status)
        VALUES(@FileHash, CONCAT('INBOUND-', LEFT(@FileHash,12)), 'INBOUND', 'SUCCESS');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
