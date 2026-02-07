SELECT
    p.ProjectID,
    p.ProjectName,
    SUM(e.Amount) AS TotalExpenses
FROM fin.DimProject p
LEFT JOIN fin.FactExpense e
    ON p.ProjectID = e.ProjectID
GROUP BY
    p.ProjectID,
    p.ProjectName
ORDER BY
    TotalExpenses DESC;
