

USE [E-Commerce];
GO



-- Price after a percentage discount
CREATE OR ALTER FUNCTION fn_CalculateDiscountedPrice
(
    @OriginalPrice DECIMAL(10,2),
    @DiscountPercent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @DiscountedPrice DECIMAL(10,2);

    -- Validate inputs
    IF @DiscountPercent < 0 OR @DiscountPercent > 100
        RETURN @OriginalPrice;

    -- Calculate discounted price
    SET @DiscountedPrice = @OriginalPrice * (1 - @DiscountPercent / 100);
    RETURN @DiscountedPrice;
END
GO

-- Purchase history of one customer for a date range
CREATE OR ALTER FUNCTION fn_GetCustomerPurchases
(
    @UserID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        p.Name AS ProductName,
        oi.Quantity,
        oi.UnitPrice,
        oi.Subtotal,
        o.Status
    FROM Orders o
    INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
    INNER JOIN Products p ON oi.ProductID = p.ProductID
    WHERE o.UserID = @UserID
      -- OrderDate has a time part: "< next day" keeps the whole last day
      AND o.OrderDate >= @StartDate
      AND o.OrderDate < DATEADD(day, 1, @EndDate)
);
GO

-----VIEWS 

-- One row per order with customer and item totals
CREATE OR ALTER VIEW vw_SalesReport AS
SELECT
    o.OrderID,
    o.OrderDate,
    u.FirstName + N' ' + u.LastName AS CustomerName,
    u.Email,
    COUNT(oi.OrderItemID) AS TotalItems,
    SUM(oi.Quantity) AS TotalQuantity,
    o.TotalAmount,
    o.Status,
    DATEDIFF(day, o.OrderDate, GETDATE()) AS DaysSinceOrder
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.OrderDate, u.FirstName, u.LastName,
         u.Email, o.TotalAmount, o.Status;
GO

-- Product performance: sales, rating, stock status.
-- Reviews and sales are grouped separately first: joining both tables
-- to Products at once would multiply the rows and inflate the totals.
CREATE OR ALTER VIEW vw_ProductAnalytics AS
WITH ReviewStats AS (
    SELECT ProductID,
           COUNT(*) AS ReviewCount,
           CAST(AVG(Rating * 1.0) AS DECIMAL(3,2)) AS AvgRating   -- * 1.0: 4.5, not 4
    FROM Reviews
    GROUP BY ProductID
),
SalesStats AS (
    SELECT oi.ProductID,
           SUM(oi.Quantity) AS TotalUnitsSold,
           SUM(oi.Subtotal) AS TotalRevenue
    FROM OrderItems oi
    INNER JOIN Orders o ON o.OrderID = oi.OrderID
    WHERE o.Status <> 'Cancelled'
    GROUP BY oi.ProductID
)
SELECT
    p.ProductID,
    p.Name AS ProductName,
    c.CategoryName,
    p.Price,
    p.StockQuantity,
    COALESCE(rs.ReviewCount, 0) AS ReviewCount,
    rs.AvgRating,                                   -- NULL = no reviews yet
    COALESCE(ss.TotalUnitsSold, 0) AS TotalUnitsSold,
    COALESCE(ss.TotalRevenue, 0) AS TotalRevenue,
    CASE
        WHEN p.StockQuantity = 0 THEN 'Out of Stock'
        WHEN p.StockQuantity <= p.ReorderLevel THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN ReviewStats rs ON rs.ProductID = p.ProductID
LEFT JOIN SalesStats ss ON ss.ProductID = p.ProductID
WHERE p.IsActive = 1;
GO

-- Active products that need to be reordered
CREATE OR ALTER VIEW vw_LowStockProducts AS
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.SKU,
    c.CategoryName,
    p.StockQuantity,
    p.ReorderLevel,
    p.ReorderLevel * 2 - p.StockQuantity AS SuggestedOrderQty   
FROM Products p
INNER JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.IsActive = 1
  AND p.StockQuantity <= p.ReorderLevel;
GO

-- One row per user: number of orders, money spent, last purchase
CREATE OR ALTER VIEW vw_CustomerActivity AS
SELECT
    u.UserID,
    u.FirstName + N' ' + u.LastName AS CustomerName,
    u.Email,
    COUNT(o.OrderID) AS TotalOrders,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpent,
    MAX(o.OrderDate) AS LastPurchase,
    CASE
        WHEN COUNT(o.OrderID) = 0 THEN 'No orders yet'
        WHEN MAX(o.OrderDate) >= DATEADD(day, -30, GETDATE()) THEN 'Active'
        ELSE 'Inactive'
    END AS ActivityStatus
FROM Users u
LEFT JOIN Orders o ON o.UserID = u.UserID AND o.Status <> 'Cancelled'
GROUP BY u.UserID, u.FirstName, u.LastName, u.Email;
GO
