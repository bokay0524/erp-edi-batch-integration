CREATE OR ALTER PROCEDURE dbo.usp_edi_prepare_outbound_purchase_order
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM dbo.EDI_OutboundPurchaseOrder WHERE SendStatus = 'READY';

        INSERT dbo.EDI_OutboundPurchaseOrder
            (PurchaseOrderNo, LineNo, OrderDate, ProductCode, Quantity, UnitPrice, DeliveryDate)
        SELECT h.PurchaseOrderNo, l.LineNo, h.OrderDate, l.ProductCode,
               l.Quantity, l.UnitPrice, l.DeliveryDate
        FROM dbo.ERP_PurchaseOrderHeader h
        JOIN dbo.ERP_PurchaseOrderLine l ON l.PurchaseOrderNo = h.PurchaseOrderNo
        WHERE h.EdiStatus = 'READY';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT
        PurchaseOrderNo AS PURCHASE_ORDER_NO,
        LineNo AS LINE_NO,
        OrderDate AS ORDER_DATE,
        ProductCode AS PRODUCT_CODE,
        Quantity AS QUANTITY,
        UnitPrice AS UNIT_PRICE,
        DeliveryDate AS DELIVERY_DATE
    FROM dbo.EDI_OutboundPurchaseOrder
    WHERE SendStatus = 'READY'
    ORDER BY PurchaseOrderNo, LineNo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_edi_complete_outbound_purchase_order
    @FileName NVARCHAR(260),
    @FileHash VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE dbo.EDI_OutboundPurchaseOrder
           SET SendStatus = 'SENT', SendFileName = @FileName, SentAt = SYSUTCDATETIME()
         WHERE SendStatus = 'READY';

        UPDATE h
           SET EdiStatus = 'SENT', EdiSentAt = SYSUTCDATETIME()
        FROM dbo.ERP_PurchaseOrderHeader h
        WHERE h.EdiStatus = 'READY'
          AND EXISTS (
              SELECT 1 FROM dbo.EDI_OutboundPurchaseOrder o
              WHERE o.PurchaseOrderNo = h.PurchaseOrderNo
                AND o.SendFileName = @FileName
          );

        INSERT dbo.EDI_FileHistory(FileHash, FileName, Direction, Status)
        VALUES(@FileHash, @FileName, 'OUTBOUND', 'SUCCESS');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
