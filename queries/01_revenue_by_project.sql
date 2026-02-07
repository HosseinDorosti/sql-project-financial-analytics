SELECT
    p.ProjectID,
    p.ProjectName,
    SUM(i.Amount) AS TotalInvoiced
FROM fin.DimProject p
LEFT JOIN fin.FactInvoice i
    ON p.ProjectID = i.ProjectID
GROUP BY
    p.ProjectID,
    p.ProjectName
ORDER BY
    TotalInvoiced DESC;
