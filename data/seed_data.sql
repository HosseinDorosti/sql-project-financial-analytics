USE ProjectFinancialOps;
GO

/* =========================
   Seed Dimensions
   ========================= */

-- Expense Categories
INSERT INTO fin.DimExpenseCategory (CategoryName)
SELECT v.CategoryName
FROM (VALUES
 ('Materials'),
 ('Labor'),
 ('Subcontractor'),
 ('Permits & Fees'),
 ('Tools & Equipment'),
 ('Transportation'),
 ('Office & Admin')
) v(CategoryName)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.DimExpenseCategory c WHERE c.CategoryName = v.CategoryName
);

-- Clients
INSERT INTO fin.DimClient (ClientName, Email, Phone, City, ProvinceState, Country)
SELECT v.ClientName, v.Email, v.Phone, v.City, v.ProvinceState, v.Country
FROM (VALUES
 ('North Shore Homes', 'billing@northshorehomes.ca', '604-555-0101', 'North Vancouver', 'BC', 'Canada'),
 ('BlueWave Retail',   'ap@bluewaveretail.com',     '778-555-0112', 'Vancouver',       'BC', 'Canada'),
 ('Maple Clinics',     'finance@mapleclinics.ca',   '604-555-0125', 'Burnaby',         'BC', 'Canada')
) v(ClientName, Email, Phone, City, ProvinceState, Country)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.DimClient c WHERE c.ClientName = v.ClientName
);

-- Vendors
INSERT INTO fin.DimVendor (VendorName, Category)
SELECT v.VendorName, v.Category
FROM (VALUES
 ('Pacific Lumber',         'Materials'),
 ('WestCo Electrical',      'Subcontractor'),
 ('Metro Plumbing Supply',  'Materials'),
 ('City Permit Office',     'Permits & Fees'),
 ('ToolTime Rentals',       'Tools & Equipment')
) v(VendorName, Category)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.DimVendor x WHERE x.VendorName = v.VendorName
);

-- Projects
DECLARE @Client_NSH INT = (SELECT TOP 1 ClientID FROM fin.DimClient WHERE ClientName='North Shore Homes');
DECLARE @Client_BWR INT = (SELECT TOP 1 ClientID FROM fin.DimClient WHERE ClientName='BlueWave Retail');
DECLARE @Client_MCL INT = (SELECT TOP 1 ClientID FROM fin.DimClient WHERE ClientName='Maple Clinics');

INSERT INTO fin.DimProject (ClientID, ProjectName, ProjectType, Status, StartDate, EndDate, ContractValue)
SELECT v.ClientID, v.ProjectName, v.ProjectType, v.Status, v.StartDate, v.EndDate, v.ContractValue
FROM (VALUES
 (@Client_NSH, 'Kitchen Renovation - Lonsdale', 'Renovation', 'Active', '2025-11-15', NULL, 65000.00),
 (@Client_BWR, 'Retail Refresh - Downtown',    'Fit-out',    'Active', '2025-10-01', NULL, 42000.00),
 (@Client_MCL, 'Clinic Expansion - Burnaby',   'Expansion',  'Active', '2025-09-10', NULL, 98000.00)
) v(ClientID, ProjectName, ProjectType, Status, StartDate, EndDate, ContractValue)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.DimProject p WHERE p.ProjectName = v.ProjectName
);

/* =========================
   Seed Facts: Invoices
   ========================= */

DECLARE @P1 INT = (SELECT TOP 1 ProjectID FROM fin.DimProject WHERE ProjectName='Kitchen Renovation - Lonsdale');
DECLARE @P2 INT = (SELECT TOP 1 ProjectID FROM fin.DimProject WHERE ProjectName='Retail Refresh - Downtown');
DECLARE @P3 INT = (SELECT TOP 1 ProjectID FROM fin.DimProject WHERE ProjectName='Clinic Expansion - Burnaby');

-- Helper to convert date to DateKey
DECLARE @d1 INT = CONVERT(INT, FORMAT(CAST('2025-11-20' AS DATE), 'yyyyMMdd'));
DECLARE @d2 INT = CONVERT(INT, FORMAT(CAST('2025-12-05' AS DATE), 'yyyyMMdd'));
DECLARE @d3 INT = CONVERT(INT, FORMAT(CAST('2026-01-10' AS DATE), 'yyyyMMdd'));
DECLARE @d4 INT = CONVERT(INT, FORMAT(CAST('2026-01-25' AS DATE), 'yyyyMMdd'));
DECLARE @d5 INT = CONVERT(INT, FORMAT(CAST('2026-02-01' AS DATE), 'yyyyMMdd'));

DECLARE @due30_1 INT = CONVERT(INT, FORMAT(DATEADD(DAY, 30, CAST('2025-11-20' AS DATE)), 'yyyyMMdd'));
DECLARE @due30_2 INT = CONVERT(INT, FORMAT(DATEADD(DAY, 30, CAST('2025-12-05' AS DATE)), 'yyyyMMdd'));
DECLARE @due30_3 INT = CONVERT(INT, FORMAT(DATEADD(DAY, 30, CAST('2026-01-10' AS DATE)), 'yyyyMMdd'));
DECLARE @due30_4 INT = CONVERT(INT, FORMAT(DATEADD(DAY, 30, CAST('2026-01-25' AS DATE)), 'yyyyMMdd'));
DECLARE @due30_5 INT = CONVERT(INT, FORMAT(DATEADD(DAY, 30, CAST('2026-02-01' AS DATE)), 'yyyyMMdd'));

INSERT INTO fin.FactInvoice (ProjectID, InvoiceNumber, IssueDateKey, DueDateKey, Amount, Status, Notes)
SELECT v.ProjectID, v.InvoiceNumber, v.IssueDateKey, v.DueDateKey, v.Amount, v.Status, v.Notes
FROM (VALUES
 (@P1, 'INV-1001', @d1, @due30_1, 12000.00, 'Issued', 'Initial deposit'),
 (@P1, 'INV-1002', @d2, @due30_2, 18000.00, 'Issued', 'Milestone 1'),
 (@P2, 'INV-2001', @d2, @due30_2,  9000.00, 'Paid',   'Phase 1'),
 (@P3, 'INV-3001', @d3, @due30_3, 25000.00, 'Issued', 'Structural work'),
 (@P3, 'INV-3002', @d4, @due30_4, 22000.00, 'Issued', 'Electrical & finishes'),
 (@P2, 'INV-2002', @d5, @due30_5, 11000.00, 'Issued', 'Phase 2')
) v(ProjectID, InvoiceNumber, IssueDateKey, DueDateKey, Amount, Status, Notes)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.FactInvoice i
    WHERE i.ProjectID = v.ProjectID AND i.InvoiceNumber = v.InvoiceNumber
);

/* =========================
   Seed Facts: Payments
   ========================= */

DECLARE @inv2001 INT = (SELECT TOP 1 InvoiceID FROM fin.FactInvoice WHERE InvoiceNumber='INV-2001');
DECLARE @pay1Date INT = CONVERT(INT, FORMAT(CAST('2025-12-20' AS DATE), 'yyyyMMdd'));

INSERT INTO fin.FactPayment (InvoiceID, PaymentDateKey, Amount, PaymentMethod, Reference)
SELECT v.InvoiceID, v.PaymentDateKey, v.Amount, v.PaymentMethod, v.Reference
FROM (VALUES
 (@inv2001, @pay1Date, 9000.00, 'E-Transfer', 'ETR-7781')
) v(InvoiceID, PaymentDateKey, Amount, PaymentMethod, Reference)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.FactPayment p
    WHERE p.InvoiceID = v.InvoiceID AND p.PaymentDateKey = v.PaymentDateKey AND p.Amount = v.Amount
);

/* =========================
   Seed Facts: Expenses
   ========================= */

DECLARE @Cat_Materials INT = (SELECT TOP 1 ExpenseCategoryID FROM fin.DimExpenseCategory WHERE CategoryName='Materials');
DECLARE @Cat_Labor     INT = (SELECT TOP 1 ExpenseCategoryID FROM fin.DimExpenseCategory WHERE CategoryName='Labor');
DECLARE @Cat_Permits   INT = (SELECT TOP 1 ExpenseCategoryID FROM fin.DimExpenseCategory WHERE CategoryName='Permits & Fees');
DECLARE @Cat_Tools     INT = (SELECT TOP 1 ExpenseCategoryID FROM fin.DimExpenseCategory WHERE CategoryName='Tools & Equipment');
DECLARE @Cat_Subcon    INT = (SELECT TOP 1 ExpenseCategoryID FROM fin.DimExpenseCategory WHERE CategoryName='Subcontractor');

DECLARE @V_Lumber  INT = (SELECT TOP 1 VendorID FROM fin.DimVendor WHERE VendorName='Pacific Lumber');
DECLARE @V_Elec    INT = (SELECT TOP 1 VendorID FROM fin.DimVendor WHERE VendorName='WestCo Electrical');
DECLARE @V_Plumb   INT = (SELECT TOP 1 VendorID FROM fin.DimVendor WHERE VendorName='Metro Plumbing Supply');
DECLARE @V_Permit  INT = (SELECT TOP 1 VendorID FROM fin.DimVendor WHERE VendorName='City Permit Office');
DECLARE @V_Rental  INT = (SELECT TOP 1 VendorID FROM fin.DimVendor WHERE VendorName='ToolTime Rentals');

-- Expense dates
DECLARE @e1 INT = CONVERT(INT, FORMAT(CAST('2025-11-18' AS DATE), 'yyyyMMdd'));
DECLARE @e2 INT = CONVERT(INT, FORMAT(CAST('2025-11-28' AS DATE), 'yyyyMMdd'));
DECLARE @e3 INT = CONVERT(INT, FORMAT(CAST('2025-12-12' AS DATE), 'yyyyMMdd'));
DECLARE @e4 INT = CONVERT(INT, FORMAT(CAST('2026-01-15' AS DATE), 'yyyyMMdd'));
DECLARE @e5 INT = CONVERT(INT, FORMAT(CAST('2026-01-28' AS DATE), 'yyyyMMdd'));

INSERT INTO fin.FactExpense (ProjectID, VendorID, ExpenseCategoryID, ExpenseDateKey, Amount, Description, IsBillable)
SELECT v.ProjectID, v.VendorID, v.ExpenseCategoryID, v.ExpenseDateKey, v.Amount, v.Description, v.IsBillable
FROM (VALUES
 (@P1, @V_Permit, @Cat_Permits,   @e1,  450.00, 'City permit', 0),
 (@P1, @V_Lumber, @Cat_Materials, @e2, 3200.00, 'Cabinet materials', 1),
 (@P2, @V_Rental, @Cat_Tools,     @e3,  600.00, 'Tool rental', 0),
 (@P3, @V_Elec,   @Cat_Subcon,    @e4, 7800.00, 'Electrical subcontractor', 1),
 (@P3, @V_Plumb,  @Cat_Materials, @e5, 2100.00, 'Plumbing supplies', 1)
) v(ProjectID, VendorID, ExpenseCategoryID, ExpenseDateKey, Amount, Description, IsBillable)
WHERE NOT EXISTS (
    SELECT 1 FROM fin.FactExpense e
    WHERE e.ProjectID = v.ProjectID
      AND e.ExpenseDateKey = v.ExpenseDateKey
      AND e.Amount = v.Amount
      AND ISNULL(e.Description,'') = ISNULL(v.Description,'')
);
GO
