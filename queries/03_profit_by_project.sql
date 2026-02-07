SELECT
    p.ProjectID,
    p.ProjectName,
    COALESCE(SUM(i.Amount), 0) AS TotalInvoiced,
    COALESCE(SUM(e.Amount), 0) AS TotalExpenses,
    COALESCE(SUM(i.Amount), 0) - COALESCE(SUM(e.Amount), 0) AS GrossProfit
FROM fin.DimProject p
LEFT JOIN fin.FactInvoice i
    ON p.ProjectID = i.ProjectID
LEFT JOIN fin.FactExpense e
    ON p.ProjectID = e.ProjectID
GROUP BY
    p.ProjectID,
    p.ProjectName
ORDER BY
    GrossProfit DESC;
