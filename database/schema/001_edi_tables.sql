/* Public demo schema - SQL Server */
CREATE TABLE dbo.EDI_IntegrationLog (
    LogId           BIGINT IDENTITY(1,1) PRIMARY KEY,
    InterfaceName   NVARCHAR(100) NOT NULL,
    Direction       VARCHAR(10) NOT NULL,
    FileName        NVARCHAR(260) NULL,
    FileHash        VARCHAR(64) NULL,
    RecordCount     INT NULL,
    Status          VARCHAR(20) NOT NULL,
    Message         NVARCHAR(2000) NULL,
    StartedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FinishedAt      DATETIME2 NULL
);
GO

CREATE TABLE dbo.EDI_FileHistory (
    FileHash        VARCHAR(64) PRIMARY KEY,
    FileName        NVARCHAR(260) NOT NULL,
    Direction       VARCHAR(10) NOT NULL,
    ProcessedAt     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Status          VARCHAR(20) NOT NULL
);
GO

CREATE TABLE dbo.EDI_OutboundPurchaseOrder (
    EdiId               BIGINT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderNo     VARCHAR(30) NOT NULL,
    LineNo              INT NOT NULL,
    OrderDate           CHAR(8) NOT NULL,
    ProductCode         VARCHAR(50) NOT NULL,
    Quantity            DECIMAL(18,3) NOT NULL,
    UnitPrice           DECIMAL(18,2) NOT NULL,
    DeliveryDate        CHAR(8) NOT NULL,
    SendStatus          VARCHAR(20) NOT NULL DEFAULT 'READY',
    SendFileName        NVARCHAR(260) NULL,
    SentAt              DATETIME2 NULL
);
GO

CREATE TABLE dbo.EDI_InboundProductMaster (
    StageId             BIGINT IDENTITY(1,1) PRIMARY KEY,
    FileHash            VARCHAR(64) NOT NULL,
    ProductCode         VARCHAR(50) NOT NULL,
    ProductName         NVARCHAR(200) NOT NULL,
    ReplacementCode     VARCHAR(50) NULL,
    Active              CHAR(1) NOT NULL,
    ValidationStatus    VARCHAR(20) NOT NULL DEFAULT 'READY',
    ValidationMessage   NVARCHAR(1000) NULL,
    CreatedAt           DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
