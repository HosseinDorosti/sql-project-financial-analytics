SELECT
    p.ProjectName,
    i.InvoiceNumber,
    d1.[Date] AS IssueDate,
    d2.[Date] AS DueDate,
    i.Amount,
    DATEDIFF(DAY, d2.[Date], CAST(GETDATE() AS DATE)) AS DaysOverdue
FROM fin.FactInvoice i
JOIN fin.DimProject p
    ON i.ProjectID = p.ProjectID
JOIN fin.DimDate d1
    ON i.IssueDateKey = d1.DateKey
JOIN fin.DimDate d2
    ON i.DueDateKey = d2.DateKey
WHERE
    i.Status <> 'Paid'
    AND d2.[Date] < CAST(GETDATE() AS DATE)
ORDER BY
    DaysOverdue DESC;
