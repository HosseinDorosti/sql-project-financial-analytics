WITH Payments AS (
    SELECT
        d.YearMonth,
        SUM(p.Amount) AS PaymentsIn
    FROM fin.FactPayment p
    JOIN fin.DimDate d
        ON p.PaymentDateKey = d.DateKey
    GROUP BY d.YearMonth
),
Expenses AS (
    SELECT
        d.YearMonth,
        SUM(e.Amount) AS ExpensesOut
    FROM fin.FactExpense e
    JOIN fin.DimDate d
        ON e.ExpenseDateKey = d.DateKey
    GROUP BY d.YearMonth
)
SELECT
    COALESCE(p.YearMonth, e.YearMonth) AS YearMonth,
    COALESCE(p.PaymentsIn, 0) AS PaymentsIn,
    COALESCE(e.ExpensesOut, 0) AS ExpensesOut,
    COALESCE(p.PaymentsIn, 0) - COALESCE(e.ExpensesOut, 0) AS NetCashFlow
FROM Payments p
FULL OUTER JOIN Expenses e
    ON p.YearMonth = e.YearMonth
ORDER BY YearMonth;
