/* Simplified ERP tables used only for the public portfolio example. */
CREATE TABLE dbo.ERP_PurchaseOrderHeader (
    PurchaseOrderNo VARCHAR(30) PRIMARY KEY,
    OrderDate       CHAR(8) NOT NULL,
    EdiStatus       VARCHAR(20) NOT NULL DEFAULT 'READY',
    EdiSentAt       DATETIME2 NULL
);
GO

CREATE TABLE dbo.ERP_PurchaseOrderLine (
    PurchaseOrderNo VARCHAR(30) NOT NULL,
    LineNo          INT NOT NULL,
    ProductCode     VARCHAR(50) NOT NULL,
    Quantity        DECIMAL(18,3) NOT NULL,
    UnitPrice       DECIMAL(18,2) NOT NULL,
    DeliveryDate    CHAR(8) NOT NULL,
    CONSTRAINT PK_ERP_PurchaseOrderLine PRIMARY KEY (PurchaseOrderNo, LineNo),
    CONSTRAINT FK_ERP_PurchaseOrderLine_Header FOREIGN KEY (PurchaseOrderNo)
        REFERENCES dbo.ERP_PurchaseOrderHeader(PurchaseOrderNo)
);
GO

CREATE TABLE dbo.ERP_ProductMaster (
    ProductCode     VARCHAR(50) PRIMARY KEY,
    ProductName     NVARCHAR(200) NOT NULL,
    ReplacementCode VARCHAR(50) NULL,
    Active          CHAR(1) NOT NULL,
    UpdatedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
