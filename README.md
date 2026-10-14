# AdventureWorks BI Solutions

An end-to-end Business Intelligence solution built on the **AdventureWorksDW2025** data warehouse. The project combines SQL aggregation, exploratory data analysis (EDA) in Python, and interactive Power BI dashboards to support decision-making across **online sales, profitability, promotions, and customer segmentation**.

> **Academic Context**
> - **Names:** Enrico Miguel Veloso, Benedict Caliba, John Dennis Vergara
> - **Section:** 3DSA-2
> - **Course:** DSA4157 — Business Intelligence
> - **Department:** College of Science
> - **Institution:** University of Santo Tomas
> - **Date:** 9/13/2026

---

## Table of Contents

- [Overview](#overview)
- [Business Context](#business-context)
- [Repository Structure](#repository-structure)
- [Architecture](#architecture)
- [Database & Schema](#database--schema)
- [SQL Layer](#sql-layer)
- [Data Analysis Layer](#data-analysis-layer)
- [Power BI Layer](#power-bi-layer)
- [Project Documents](#project-documents)
- [Getting Started](#getting-started)
- [AI Use Declaration](#ai-use-declaration)

---

## Overview

The solution follows a classic BI pipeline:

```
AdventureWorksDW2025 (SQL Server)
        │
        ├── DATABASE & TABLES   →  .bak backup + 30 CSV extracts
        │
        ├── SQL LAYER           →  view_MasterKPIs (pre-aggregated KPI view)
        │
        ├── EDA (Python)        →  notebook profiling all tables
        │
        └── POWER BI LAYER      →  3 interactive dashboards (DAX measures)
```

The goal is to move AdventureWorks away from fragmented, unreliable reporting toward a consistent, self-service view of business health that executives, regional managers, sales directors, and inventory managers can act on.

---

## Business Context

Three dashboards were scoped, each driven by its own problem statement and KPI set.

### 1. Online Sales & Profitability

- **Problem:** AdventureWorks lacks a real-time view of online sales performance across regions and product categories, forcing managers to rely on broken or fragmented data.
- **Goal:** Provide executives a comprehensive, real-time view of online sales performance across regions and product categories, enabling decisions on inventory, marketing, regional expansion, and resource allocation.
- **Lagging KPIs:** Total Online Revenue, Total Cost of Goods Sold, Total Online Profit, Total Units Sold, Profit Margin %.
- **Leading KPIs:** Daily Sales Run Rate, Average Products Per Order, Average Order Value, Average Products Per Order, Regional Velocity, Orders per Customer.
- **Primary users:** CEO / Executive Teams, Regional Managers, Sales Directors, Inventory Managers.

### 2. Promotions & Profitability

- **Problem:** No consolidated view of sales promotions and their performance across online and reseller channels, making it hard to know which promotions to continue, adjust, or discontinue.
- **Goal:** Evaluate promotion effectiveness by comparing sales, profit, profit margin, and discount rate to decide whether promotions should be continued or reassessed.
- **Lagging KPIs:** Total Sales (Internet + Reseller), Total Profit, Overall Profit Margin.
- **Leading KPIs:** Average Discount Rate.
- **Primary users:** Sales Managers, Marketing Managers, Business Executives.
- **Special feature:** A **Promotion Selector** and a dynamically generated **Management Remark** that automatically labels each promotion (No Data / Underperforming / High Discount Risk / Profitable).

### 3. Customer Segmentation

- **Problem:** No prior knowledge of customer purchasing behavior; first-time buyers may not be impressed by the current product/price mix, slowing revenue growth and risking retention.
- **Goal:** Analyze customer demographics (career, age, yearly income, gender, family structure) to identify high-value and loyal customers and to plan promotions, discounts, and loyalty programs.
- **Lagging KPIs:** Average Revenue per Customer.
- **Leading KPIs:** Customer Retention Rate, Survey Engagement Rate.
- **Primary users:** Marketing Committee, Sales Committee, Customer Relations Officers.

---

## Repository Structure

```
AdventureWorks BI Solutions/
│
├── Data Analysis and SQL/
│   ├── AdventureWorks - Data Analysis.ipynb      # Python EDA notebook (source)
│   ├── AdventureWorks - Data Analysis.html       # Rendered HTML export of the notebook
│   └── views_MasterKPIs.sql                         # KPI aggregation view (SQL Server)
│
├── Database and Tables/
│   ├── AdventureWorksDW2025.bak                     # Full database backup (SQL Server)
│   └── AdventuerWorksDW2025 Tables/                 # 30 CSV extracts (one per table)
│       ├── DimAccount.csv
│       ├── DimCurrency.csv
│       ├── ...                                      # (16 dimension tables)
│       ├── FactInternetSales.csv
│       ├── FactResellerSales.csv
│       └── ...                                      # (fact tables + system tables)
│
├── Power BI Dashboard/
│   ├── Online Sales & Profitability Dashboard.pbix
│   ├── Promotions & Profitability Dashboard.pbix
│   ├── Customer Segmentation Dashboard.pbix
│   └── README - Dashboard Navigation.md             # Cross-dashboard navigation guide
│
└── Project Documents/
    ├── AdventureWorks - Business Case.pdf           # Problem statements, KPIs, stakeholders
    ├── AdventureWorks - Dashboard Details.pdf       # DAX measures, visuals, filters
    └── AdventureWorks - Schema Report (AI Generated).pdf  # Full schema inventory
```

> **Note:** The extracted-tables folder is spelled `AdventuerWorksDW2025 Tables` in the repository (typo preserved).

---

## Architecture

### Star Schema

AdventureWorksDW2025 is a **star-schema** data warehouse:

- **Dimension tables** (prefix `Dim`) describe business entities — date, product, customer, geography, promotion, reseller, employee, etc.
- **Fact tables** (prefix `Fact`) record measurable business events (sales, inventory movement, call-center activity) and reference dimensions through surrogate keys.

A typical fact row joins back to dimensions via surrogate keys — e.g. `FactInternetSales` uses `ProductKey`, `CustomerKey`, `OrderDateKey`, `PromotionKey`, `SalesTerritoryKey`, and `CurrencyKey`.

### Three-Layer Design

| Layer | Technology | Responsibility |
|-------|-----------|----------------|
| Storage | SQL Server / `.bak` | Persist the warehouse (31 user tables, 359 columns) |
| Modeling | SQL View + Python | Pre-aggregate KPIs and profile/validate data |
| Presentation | Power BI + DAX | Interactive dashboards, filters, drill-down |

The aggregated `view_MasterKPIs` exists specifically to keep dashboards responsive: it pre-groups the largest fact table (`FactInternetSales`) by Year, Month, Region, Country, and Category so visuals do not scan the raw fact table on every interaction.

---

## Database & Schema

Source: **AdventureWorksDW2025** (SQL Server, server `NORTHAMERICA\randolphwest`), restored from `AdventureWorksDW2025.bak`.

**Schema summary:** `dbo` — 31 user tables, 359 columns, 28 primary keys, 7 unique constraints, 44 foreign keys (45 column references), 0 check constraints, 0 default constraints.

### Dimension Tables

| Table | Purpose | Key columns |
|-------|---------|-------------|
| DimDate | Calendar/fiscal date helper (3,652 rows) | `DateKey` (natural key) |
| DimProduct | Product catalog | `ProductKey`, `ProductSubcategoryKey` |
| DimProductCategory | Top-level product category | `ProductCategoryKey` |
| DimProductSubcategory | Product subcategory | `ProductSubcategoryKey`, `ProductCategoryKey` |
| DimCustomer | Customer demographics | `CustomerKey`, `GeographyKey` |
| DimGeography | City/state/country | `GeographyKey`, `SalesTerritoryKey` |
| DimSalesTerritory | Region/country/group | `SalesTerritoryKey` |
| DimPromotion | Promotion definitions & discounts | `PromotionKey` |
| DimReseller | Reseller (B2B) accounts | `ResellerKey`, `GeographyKey` |
| DimEmployee | Employees / salespeople | `EmployeeKey` |
| DimCurrency | Currency reference | `CurrencyKey` |
| DimAccount | Chart of accounts | `AccountKey` |
| DimOrganization | Org hierarchy | `OrganizationKey` |
| DimDepartmentGroup | Department hierarchy | `DepartmentGroupKey` |
| DimSalesReason | Sales reason reference | `SalesReasonKey` |
| DimScenario | Finance scenarios | `ScenarioKey` |

### Fact Tables

| Table | Rows (approx.) | Purpose |
|-------|---------------|---------|
| FactInternetSales | 60,398 | Online (B2C) sales lines |
| FactResellerSales | 60,855 | Reseller (B2B) sales lines |
| FactProductInventory | 776,286 | Daily inventory movement |
| FactFinance | 39,409 | Financial transactions |
| FactCurrencyRate | 14,264 | Daily exchange rates |
| FactSurveyResponse | 2,727 | Customer survey responses |
| ProspectiveBuyer | 2,059 | Prospective customer profiles |
| FactAdditionalInternationalProductDescription | 1,911 | Localized product descriptions |
| FactSalesQuota | 163 | Salesperson quotas |
| FactCallCenter | 120 | Call-center metrics |
| FactInternetSalesReason | — | Bridge: order → sales reason |
| NewFactCurrencyRate | 50 | Supplementary currency rates |

Additional system tables: `DatabaseLog`, `AdventureWorksDWBuildVersion`, `sysdiagrams`.

> See `Project Documents/AdventureWorks - Schema Report (AI Generated).pdf` for the full per-column inventory (data types, lengths, precision/scale, nullability, identity) and the complete PK/FK/unique-constraint listings.

---

## SQL Layer

**File:** `Data Analysis and SQL/views_MasterKPIs.sql`

Defines the aggregated view `view_MasterKPIs`, the semantic source consumed by the Online Sales dashboard. It joins `FactInternetSales` to `DimDate`, `DimSalesTerritory`, `DimProduct`, `DimProductSubcategory`, and `DimProductCategory`, then groups by Year, Month, Region, Country, and Category.

Grain: one row per **Year × Month × Region × Country × Category**, exposing:

- `Total_Online_Revenue` — `SUM(FIS.SalesAmount)`
- `Total_Cost` — `SUM(FIS.TotalProductCost)`
- `Total_Online_Units_Ordered` — `SUM(FIS.OrderQuantity)`
- `Total_Online_Orders` — `COUNT(DISTINCT SalesOrderNumber)`
- `Total_Online_Customers` — `COUNT(DISTINCT CustomerKey)`

---

## Data Analysis Layer

**Files:** `Data Analysis and SQL/AdventureWorks - Data Analysis.ipynb` (source) and `.html` (rendered).

A basic EDA over all extracted tables, structured as:

1. **Import libraries** — pandas, numpy, matplotlib, seaborn.
2. **Load all tables** — dimensions and facts into dictionaries keyed by table name.
3. **Shape inspection** — rows × columns for every table.
4. **Data-type inspection** — dtype of every column.
5. **Null analysis** — missing-value counts per column.
6. **Descriptive statistics** — distributions of key sales measures.
7. **Value distributions** — histograms with written interpretations.

**Selected findings:**

- **FactInternetSales** — 60,398 complete rows; every row is a single-unit line item (`OrderQuantity = 1`); `UnitPriceDiscountPct` is `0` throughout, i.e. no online discounts; `SalesAmount` is heavily right-skewed (mean 486.09, std 928.49) with a long tail to 3,578.27.
- **FactResellerSales** — 60,855 rows; average order quantity 3.52 (max 44), confirming bulk B2B ordering; mean `SalesAmount` (1,322.00) is nearly triple the median (461.69), indicating thin, volume-driven margins.
- **FactProductInventory** — 776,286 rows; sparse movement with a **negative `UnitsBalance` minimum of −494**, flagging possible stockouts/backorders or data-integrity issues worth investigating.
- **FactCurrencyRate** — 14,264 rows; average and end-of-day rates behave similarly, with moderate (~0.19 std) variation around 1.0.
- **DimCustomer / DimProduct** — product pricing shows discrete tiers with a visible gap between $1,500–$2,000; customer income is recorded in fixed $10,000 brackets with bimodal peaks at $40k and $60k (middle-income core).

**Data quality:** Most keys are complete. Notable nulls include `CarrierTrackingNumber`/`CustomerPONumber` (100% null in `FactInternetSales`), optional address/name fields, `DimProduct` description/`EndDate` fields, and `DimensionKey` gaps in `NewFactCurrencyRate` (all 50 null).

---

## Power BI Layer

Three `.pbix` reports, published separately and linked through **web-URL navigation buttons** (see `Power BI Dashboard/README - Dashboard Navigation.md`). Access to each depends on the sharing permissions configured in Power BI.

### Dashboards

**Online Sales & Profitability**
- Global filters: Year (2010–2014), Month, Region, Country; visual-level Top 3 Countries and trend date-range.
- Visuals: Top Countries by Revenue (clustered bar), Global Online Sales by Region (clustered bar), Online Sales Trend Over Time (line), Total Units Sold by Category (column), Profitability by Category (stacked bar, revenue vs cost), Product Category Mix (donut).

**Promotions & Profitability**
- Filters: Promotion Selector (drives all visuals), visual-level filtering.
- Visuals: Profit by Promotion (clustered bar), Discount vs. Profitability (scatter, bubble size emphasizes the selected promotion), Promotion Performance Details (table), Management Remark (dynamic text).
- Selected-promotion logic returns 1 for the active promotion (dark-blue highlight, enlarged bubble) and 0 otherwise.

**Customer Segmentation**
- Filters: Generation, Marital Status, Country.
- Visuals: Total Revenue by Occupation by Gender (clustered bar), First-Time Customers Frequency over Time (line), Top 20 Frequent Customers (matrix), Average Yearly Income by Number of Children (clustered column).
- Generation derived via a DAX `SWITCH` on `DimCustomer[BirthDate]` year (Greatest, Silent, Baby Boom, Gen X, Millennial).

### Key DAX Measures

**Online Sales & Profitability**

```dax
Total Online Revenue (TOR)   = SUM(view_MasterKPIs[Total_Online_Revenue])
Total Cost of Goods Sold     = SUM(view_MasterKPIs[Total_Cost])
Total Online Profit (TOP)    = [TOR] - [TCOGS]
Regional Velocity (RV)       = DIVIDE(SUM(view_MasterKPIs[Total_Online_Revenue]), DISTINCTCOUNT(view_MasterKPIs[Region]), 0)
Profit Margin % (PM%)        = DIVIDE([TOP], [TOR], 0)
Orders per Customer (OPC)    = DIVIDE(SUM(view_MasterKPIs[Total_Online_Orders]), SUM(view_MasterKPIs[Total_Online_Customers]), 0)
Daily Sales Run Rate (DSRR)  = DIVIDE(SUM(view_MasterKPIs[Total_Online_Revenue]), 30, 0)
Average Products per Order   = DIVIDE(SUM(view_MasterKPIs[Total_Online_Units_Ordered]), SUM(view_MasterKPIs[Total_Online_Orders]))
Average Order Value (AOV)    = DIVIDE(SUM(view_MasterKPIs[Total_Online_Revenue]), SUM(view_MasterKPIs[Total_Online_Orders]), 0)
```

**Promotions & Profitability**

```dax
Total Sales All   = SUM(FactInternetSales[SalesAmount]) + SUM(FactResellerSales[SalesAmount])
Total Profit All  = (SUM(FactInternetSales[SalesAmount]) - SUM(FactInternetSales[TotalProductCost]))
                  + (SUM(FactResellerSales[SalesAmount]) - SUM(FactResellerSales[TotalProductCost]))
Profit Margin All = DIVIDE([Total Profit All], [Total Sales All])
Total Discount All= SUM(FactInternetSales[DiscountAmount]) + SUM(FactResellerSales[DiscountAmount])
Discount Rate All = DIVIDE(
                      SUMX(FactInternetSales, FactInternetSales[ExtendedAmount] * FactInternetSales[UnitPriceDiscountPct])
                    + SUMX(FactResellerSales,  FactResellerSales[ExtendedAmount]  * FactResellerSales[UnitPriceDiscountPct]),
                      SUM(FactInternetSales[ExtendedAmount]) + SUM(FactResellerSales[ExtendedAmount]), 0)
```

**Customer Segmentation**

```dax
Average Revenue per Customer = DIVIDE(SUM(FactInternetSales[SalesAmount]), DISTINCTCOUNT(DimCustomer[CustomerKey]))
Customer Retention Rate      = VAR CustomerRetention =
                                 COUNTROWS(FILTER(VALUES(FactInternetSales[CustomerKey]),
                                   CALCULATE(DISTINCTCOUNT(FactInternetSales[SalesOrderNumber])) > 1))
                               RETURN DIVIDE(CustomerRetention, DISTINCTCOUNT(FactInternetSales[CustomerKey]))
Survey Engagement Rate       = DIVIDE(DISTINCTCOUNT(FactSurveyResponse[CustomerKey]), DISTINCTCOUNT(DimCustomer[CustomerKey]))
```

### Business Formula Reference

- `Profit Margin % = [(Total Online Revenue − Total Cost) / Total Online Revenue] × 100`
- `Average Order Value = Total Online Revenue / Total Online Orders`
- `Average Products per Order = Total Units Sold / Total Online Orders`
- `Regional Velocity = Total Online Revenue / Total Number of Regions`
- `Daily Sales Run Rate = Total Online Revenue / 30`
- `Orders per Customer = Total Online Orders / Total Unique Online Customers`
- `Customer Retention Rate = (Customers with ≥ 2 orders / Number of Customers) × 100%`
- `Survey Engagement Rate = (Surveys Answered / Number of Customers) × 100%`

---

## Project Documents

| File | Contents |
|------|----------|
| `AdventureWorks - Business Case.pdf` | Problem statements, value hypotheses, key business questions, success measures, stakeholders, and data requirements for all three dashboards. |
| `AdventureWorks - Dashboard Details.pdf` | Dashboard titles, business goals, critical success factors, primary users, data sources, filters, KPI definitions, DAX measures, visual specs, and per-dashboard AI-use declarations. |
| `AdventureWorks - Schema Report (AI Generated).pdf` | Structural inventory: all 31 tables/359 columns, constraints, primary/foreign/unique keys, and an example star-schema join walkthrough. |

---

## Getting Started

### Prerequisites

- **SQL Server** (to restore the warehouse and create the view)
- **Python 3** with `pandas`, `numpy`, `matplotlib`, `seaborn`, and **Jupyter** (EDA)
- **Power BI Desktop** (to open/edit `.pbix` reports)

### Restore the database

1. Restore `Database and Tables/AdventureWorksDW2025.bak` in SQL Server Management Studio (or `RESTORE DATABASE`).
2. Run `Data Analysis and SQL/views_MasterKPIs.sql` against the restored database to create `view_MasterKPIs`.

### Run the EDA

1. Place the CSVs from `Database and Tables/AdventuerWorksDW2025 Tables/` in the same directory as the notebook (the notebook loads them by filename).
2. Open `Data Analysis and SQL/AdventureWorks - Data Analysis.ipynb` in Jupyter and run all cells.

### Open the dashboards

1. Open the `.pbix` files in `Power BI Dashboard/` with Power BI Desktop.
2. Repoint the data source to your restored `AdventureWorksDW2025` server.
3. To navigate between published reports, follow `Power BI Dashboard/README - Dashboard Navigation.md`.

---

## AI Use Declaration

Per the project's own declarations:

- **Qwen AI** — brainstorming, suggestions, and guidance for dashboard development (Online Sales & Profitability).
- **OpenCode (Desktop)** — analyzed the database and produced the README/schema report.
- **Claude** — converted the README into the PDF schema report.
- **OpenAI** — supplementary clarification of Power BI and DAX concepts, troubleshooting, and refinement (Promotions & Profitability).
