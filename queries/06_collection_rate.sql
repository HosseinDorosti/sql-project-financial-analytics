SELECT
    p.ProjectName,
    SUM(i.Amount) AS TotalInvoiced,
    SUM(pay.Amount) AS TotalCollected,
    CASE
        WHEN SUM(i.Amount) = 0 THEN 0
        ELSE ROUND(SUM(pay.Amount) * 100.0 / SUM(i.Amount), 2)
    END AS CollectionRatePercent
FROM fin.DimProject p
LEFT JOIN fin.FactInvoice i
    ON p.ProjectID = i.ProjectID
LEFT JOIN fin.FactPayment pay
    ON i.InvoiceID = pay.InvoiceID
GROUP BY
    p.ProjectName
ORDER BY
    CollectionRatePercent DESC;
