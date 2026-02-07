-- 1) Create database
IF DB_ID('ProjectFinancialOps') IS NULL
BEGIN
    CREATE DATABASE ProjectFinancialOps;
END
GO

USE ProjectFinancialOps;
GO

-- 2) Create a dedicated schema (keeps things tidy)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'fin')
BEGIN
    EXEC('CREATE SCHEMA fin');
END
GO

/* =========================
   Dimension Tables
   ========================= */

CREATE TABLE fin.DimDate (
    DateKey        INT         NOT NULL PRIMARY KEY,      -- yyyymmdd (e.g., 20260207)
    [Date]         DATE        NOT NULL UNIQUE,
    [Year]         SMALLINT    NOT NULL,
    [Quarter]      TINYINT     NOT NULL,
    [Month]        TINYINT     NOT NULL,
    MonthName      VARCHAR(15) NOT NULL,
    YearMonth      CHAR(7)     NOT NULL,                   -- 'YYYY-MM'
    [Day]          TINYINT     NOT NULL,
    DayOfWeek      TINYINT     NOT NULL,                   -- 1-7 (Mon-Sun or Sun-Sat; we’ll be consistent later)
    DayName        VARCHAR(10) NOT NULL,
    IsWeekend      BIT         NOT NULL
);

CREATE TABLE fin.DimClient (
    ClientID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClientName     NVARCHAR(150) NOT NULL,
    Email          NVARCHAR(200) NULL,
    Phone          NVARCHAR(50)  NULL,
    City           NVARCHAR(100) NULL,
    ProvinceState  NVARCHAR(100) NULL,
    Country        NVARCHAR(100) NULL,
    IsActive       BIT           NOT NULL DEFAULT(1),
    CreatedAt      DATETIME2     NOT NULL DEFAULT(SYSDATETIME())
);

CREATE TABLE fin.DimProject (
    ProjectID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClientID       INT           NOT NULL,
    ProjectName    NVARCHAR(200) NOT NULL,
    ProjectType    NVARCHAR(100) NULL,
    Status         NVARCHAR(50)  NOT NULL DEFAULT('Active'),  -- Active/On Hold/Closed
    StartDate      DATE          NULL,
    EndDate        DATE          NULL,
    ContractValue  DECIMAL(18,2) NULL,                        -- optional if you have it
    CreatedAt      DATETIME2     NOT NULL DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_DimProject_Client FOREIGN KEY (ClientID) REFERENCES fin.DimClient(ClientID)
);

CREATE TABLE fin.DimVendor (
    VendorID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    VendorName     NVARCHAR(200) NOT NULL,
    Category       NVARCHAR(100) NULL,      -- materials, subcontractor, etc.
    IsActive       BIT           NOT NULL DEFAULT(1),
    CreatedAt      DATETIME2     NOT NULL DEFAULT(SYSDATETIME())
);

CREATE TABLE fin.DimExpenseCategory (
    ExpenseCategoryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CategoryName      NVARCHAR(100) NOT NULL UNIQUE           -- Materials, Labor, Permits, Tools, etc.
);

/* =========================
   Fact Tables
   ========================= */

CREATE TABLE fin.FactInvoice (
    InvoiceID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectID      INT           NOT NULL,
    InvoiceNumber  NVARCHAR(50)  NOT NULL,
    IssueDateKey   INT           NOT NULL,
    DueDateKey     INT           NULL,
    Amount         DECIMAL(18,2) NOT NULL,
    Status         NVARCHAR(30)  NOT NULL DEFAULT('Issued'), -- Issued/Paid/Overdue/Void
    Notes          NVARCHAR(500) NULL,
    CONSTRAINT UQ_Invoice_Project_Number UNIQUE (ProjectID, InvoiceNumber),
    CONSTRAINT FK_Invoice_Project FOREIGN KEY (ProjectID) REFERENCES fin.DimProject(ProjectID),
    CONSTRAINT FK_Invoice_IssueDate FOREIGN KEY (IssueDateKey) REFERENCES fin.DimDate(DateKey),
    CONSTRAINT FK_Invoice_DueDate FOREIGN KEY (DueDateKey) REFERENCES fin.DimDate(DateKey)
);

CREATE TABLE fin.FactPayment (
    PaymentID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InvoiceID      INT           NOT NULL,
    PaymentDateKey INT           NOT NULL,
    Amount         DECIMAL(18,2) NOT NULL,
    PaymentMethod  NVARCHAR(50)  NULL,     -- E-Transfer, Credit Card, etc.
    Reference      NVARCHAR(100) NULL,
    CONSTRAINT FK_Payment_Invoice FOREIGN KEY (InvoiceID) REFERENCES fin.FactInvoice(InvoiceID),
    CONSTRAINT FK_Payment_Date FOREIGN KEY (PaymentDateKey) REFERENCES fin.DimDate(DateKey)
);

CREATE TABLE fin.FactExpense (
    ExpenseID          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectID          INT           NOT NULL,
    VendorID           INT           NULL,
    ExpenseCategoryID  INT           NOT NULL,
    ExpenseDateKey     INT           NOT NULL,
    Amount             DECIMAL(18,2) NOT NULL,
    Description        NVARCHAR(300) NULL,
    IsBillable         BIT           NOT NULL DEFAULT(0),
    CONSTRAINT FK_Expense_Project FOREIGN KEY (ProjectID) REFERENCES fin.DimProject(ProjectID),
    CONSTRAINT FK_Expense_Vendor FOREIGN KEY (VendorID) REFERENCES fin.DimVendor(VendorID),
    CONSTRAINT FK_Expense_Category FOREIGN KEY (ExpenseCategoryID) REFERENCES fin.DimExpenseCategory(ExpenseCategoryID),
    CONSTRAINT FK_Expense_Date FOREIGN KEY (ExpenseDateKey) REFERENCES fin.DimDate(DateKey)
);

USE ProjectFinancialOps;
GO

-- Populate fin.DimDate for a useful range (2019-01-01 to 2031-12-31)
DECLARE @StartDate DATE = '2019-01-01';
DECLARE @EndDate   DATE = '2031-12-31';

;WITH d AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM d
    WHERE [Date] < @EndDate
)
INSERT INTO fin.DimDate (DateKey, [Date], [Year], [Quarter], [Month], MonthName, YearMonth, [Day], DayOfWeek, DayName, IsWeekend)
SELECT
    CONVERT(INT, FORMAT([Date], 'yyyyMMdd'))                  AS DateKey,
    [Date],
    YEAR([Date])                                              AS [Year],
    DATEPART(QUARTER, [Date])                                 AS [Quarter],
    MONTH([Date])                                             AS [Month],
    DATENAME(MONTH, [Date])                                   AS MonthName,
    CONCAT(YEAR([Date]), '-', RIGHT('0' + CAST(MONTH([Date]) AS VARCHAR(2)), 2)) AS YearMonth,
    DAY([Date])                                               AS [Day],
    DATEPART(WEEKDAY, [Date])                                 AS DayOfWeek,
    DATENAME(WEEKDAY, [Date])                                 AS DayName,
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend
FROM d
OPTION (MAXRECURSION 0);
GO

-- Quick check
SELECT TOP 5 * FROM fin.DimDate ORDER BY [Date];
SELECT TOP 5 * FROM fin.DimDate ORDER BY [Date] DESC;
