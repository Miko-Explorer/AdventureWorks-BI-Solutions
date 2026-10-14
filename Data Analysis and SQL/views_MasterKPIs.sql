-- ============================================================================================
-- Master KPIs:
CREATE VIEW view_MasterKPIs AS SELECT
	DD.CalendarYear AS Year, 
	DD.EnglishMonthName AS Month, 
	DD.MonthNumberOfYear AS Month_Number,
	DST.SalesTerritoryRegion AS Region,
	DST.SalesTerritoryCountry AS Country,
	DPC.EnglishProductCategoryName AS Category,
	SUM(FIS.SalesAmount) AS Total_Online_Revenue, 
	SUM(FIS.TotalProductCost) AS Total_Cost,
	SUM(FIS.OrderQuantity) AS Total_Online_Units_Ordered, 
	COUNT(DISTINCT FIS.SalesOrderNumber) AS Total_Online_Orders, 
	COUNT(DISTINCT FIS.CustomerKey) AS Total_Online_Customers
FROM dbo.FactInternetSales AS FIS
INNER JOIN dbo.DimDate AS DD on DD.DateKey = FIS.OrderDateKey
INNER JOIN dbo.DimSalesTerritory AS DST ON DST.SalesTerritoryKey = FIS.SalesTerritoryKey
INNER JOIN dbo.DimProduct AS DP ON DP.ProductKey = FIS.ProductKey 
INNER JOIN dbo.DimProductSubcategory AS DPSC ON DPSC.ProductSubcategoryKey = DP.ProductSubcategoryKey 
INNER JOIN dbo.DimProductCategory AS DPC ON DPC.ProductCategoryKey = DPSC.ProductCategoryKey 
GROUP BY 
	DD.CalendarYear, 
	DD.EnglishMonthName, 
	DD.MonthNumberOfYear,
	DST.SalesTerritoryRegion,
	DST.SalesTerritoryCountry,
	DPC.EnglishProductCategoryName;
GO