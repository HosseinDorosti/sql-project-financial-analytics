📊 Project Financial & Operations Analytics

SQL Server + Power BI | End-to-End Analytics Portfolio Project

🔍 Overview

This project demonstrates an end-to-end financial and operational analytics solution, built using SQL Server for data modeling and Power BI for reporting and insights.

The dashboard is designed for executive-level decision-making, focusing on:

Revenue vs expenses

Cash flow timing

Accounts receivable risk (aging & overdue)

Project-level profitability and financial health

It mirrors real-world scenarios commonly found in construction, professional services, and project-based businesses.

🏗️ Architecture & Tools

Data Source

Microsoft SQL Server (Developer Edition)

Analytics & Visualization

Power BI Desktop

DAX measures

Star-schema modeling

Core Skills Demonstrated

Data modeling (facts & dimensions)

Financial KPIs and ratios

Time-based analysis

Accounts receivable aging logic

Executive dashboard design

Data validation & QA techniques

🧱 Data Model

The model follows a clean star schema design.

Fact Tables

fin FactInvoice – issued invoices by project

fin FactPayment – customer payments

fin FactExpense – project expenses

Dimension Tables

fin DimProject

fin DimClient

fin DimVendor

fin DimDate

fin DimExpenseCategory

Relationships are single-directional from dimensions to facts to avoid ambiguity and ensure predictable filtering behavior.

## 🧱 Data Model
![Data Model](screenshots/data-model.png)

📈 Key Metrics & KPIs

The dashboard calculates and visualizes:

KPI	Description
Total Invoiced	Total revenue billed
Total Payments	Cash collected
Total Expenses	Project costs
Gross Profit	Invoiced – Expenses
Outstanding Amount	Invoiced – Payments
Total Overdue Amount	Past-due receivables
Net Cash Flow	Payments – Expenses
Cash Coverage Ratio	Payments ÷ Invoiced
📊 Executive Dashboard

The Executive Overview page is designed for senior stakeholders.

Includes:

KPI cards (top-level financial health)

Revenue vs Expenses by Project

Cash In vs Cash Out (Monthly)

Accounts Receivable Aging (Overdue Balance)

## 📊 Executive Overview
![Executive Overview](screenshots/executive-overview.png)

⏱️ Accounts Receivable Aging Logic

Invoices are categorized into aging buckets based on Days Past Due:

0–30

31–60

61–90

90+

Only overdue balances are included in the aging chart to focus attention on collection risk.

This allows leaders to quickly identify:

Cash flow bottlenecks

At-risk projects

Collection priorities

🔢 Example DAX Measures
Net Cash Flow :=
[Total Payments] - [Total Expenses]

Cash Coverage Ratio :=
DIVIDE ( [Total Payments], [Total Invoiced] )

Outstanding Amount :=
[Total Invoiced] - [Paid Amount]


Measures are stored in a dedicated Measures table for clarity and maintainability.

🧪 Data Validation

A separate QA / Validation page was used during development to:

Cross-check invoice totals

Validate payment allocations

Confirm aging logic

This page can be hidden in production but demonstrates strong analytical discipline.

## 🧪 QA / Validation
![QA Validation](screenshots/qa-validation.png)

🎯 Business Value

This solution enables stakeholders to:

Monitor project profitability

Understand cash flow timing issues

Identify overdue receivables early

Make data-driven decisions with confidence

The design emphasizes clarity, accuracy, and executive usability.

🚀 Possible Enhancements

Forecasted cash flow

Budget vs actual analysis

Customer payment behavior scoring

Row-level security (RLS)

Power BI Service deployment

📌 Notes

This project uses sample data and is intended for demonstration and portfolio purposes only.

👤 Author

Hossein Dorosti
Business / Data Analyst
📍 Vancouver, Canada
