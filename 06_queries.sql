
USE [E-Commerce];
GO

-- 1. List all active products with their category, most expensive first.
SELECT p.Name, c.CategoryName, p.Price, p.StockQuantity
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.IsActive = 1
ORDER BY p.Price DESC;


-- 2. For each category show the number of products and the average, min and max price.
SELECT c.CategoryName,
       COUNT(*) AS ProductCount,
       AVG(p.Price) AS AvgPrice,
       MIN(p.Price) AS MinPrice,
       MAX(p.Price) AS MaxPrice
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY AvgPrice DESC;


-- 3. Show only the categories where the average product price is above 20 000.
SELECT c.CategoryName, AVG(p.Price) AS AvgPrice
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
HAVING AVG(p.Price) > 20000;


-- 4. Split products into price groups (Cheap < 5 000, Medium < 30 000, Premium)
--    and count the products in each group.
SELECT PriceGroup, COUNT(*) AS ProductCount
FROM (
    SELECT CASE
               WHEN Price < 5000 THEN 'Cheap'
               WHEN Price < 30000 THEN 'Medium'
               ELSE 'Premium'
           END AS PriceGroup
    FROM Products
) t
GROUP BY PriceGroup;


-- 5. Find customers who have never placed an order.
SELECT u.UserID, u.FirstName, u.LastName, u.Email
FROM Users u
LEFT JOIN Orders o ON o.UserID = u.UserID
WHERE o.OrderID IS NULL;


-- 6. Find products that were never sold.
SELECT p.ProductID, p.Name, p.Price
FROM Products p
WHERE NOT EXISTS (
    SELECT 1
    FROM OrderItems oi
    WHERE oi.ProductID = p.ProductID
);


-- 7. Top 5 customers by money spent.
SELECT TOP (5)
       u.FirstName + N' ' + u.LastName AS Customer,
       COUNT(o.OrderID) AS Orders,
       SUM(o.TotalAmount) AS TotalSpent
FROM Users u
JOIN Orders o ON o.UserID = u.UserID
WHERE o.Status <> 'Cancelled'
GROUP BY u.FirstName, u.LastName
ORDER BY TotalSpent DESC;


-- 8. Show orders whose amount is above the average order amount.
SELECT OrderID, UserID, OrderDate, TotalAmount
FROM Orders
WHERE Status <> 'Cancelled'
  AND TotalAmount > (SELECT AVG(TotalAmount) FROM Orders WHERE Status <> 'Cancelled')
ORDER BY TotalAmount DESC;


-- 9. Revenue and number of orders for each month.
SELECT YEAR(OrderDate) AS OrderYear,
       MONTH(OrderDate) AS OrderMonth,
       COUNT(*) AS Orders,
       SUM(TotalAmount) AS Revenue
FROM Orders
WHERE Status <> 'Cancelled'
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;


-- 10. Profit of each category: revenue - cost of sold products.
SELECT c.CategoryName,
       SUM(oi.Subtotal) AS Revenue,
       SUM(oi.Quantity * p.Cost) AS TotalCost,
       SUM(oi.Subtotal) - SUM(oi.Quantity * p.Cost) AS Profit
FROM OrderItems oi
JOIN Orders o ON o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE o.Status <> 'Cancelled'
GROUP BY c.CategoryName
ORDER BY Profit DESC;


-- 11. Customers who bought from at least 3 different categories.
SELECT u.FirstName, u.LastName, COUNT(DISTINCT p.CategoryID) AS Categories
FROM Users u
JOIN Orders o ON o.UserID = u.UserID
JOIN OrderItems oi ON oi.OrderID = o.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
WHERE o.Status <> 'Cancelled'
GROUP BY u.UserID, u.FirstName, u.LastName
HAVING COUNT(DISTINCT p.CategoryID) >= 3;


-- 12. For each coupon: how many orders used it and how much money customers saved.
SELECT o.CouponCode,
       COUNT(*) AS Orders,
       SUM(oi.ItemsTotal - o.TotalAmount) AS Saved
FROM Orders o
-- items are summed per order first, so every order is one row
JOIN (SELECT OrderID, SUM(Subtotal) AS ItemsTotal FROM OrderItems GROUP BY OrderID) oi
    ON oi.OrderID = o.OrderID
WHERE o.CouponCode IS NOT NULL
GROUP BY o.CouponCode;


-- 13. The most expensive product in each category.
WITH Ranked AS (
    SELECT c.CategoryName, p.Name, p.Price,
           ROW_NUMBER() OVER (PARTITION BY p.CategoryID ORDER BY p.Price DESC) AS rn
    FROM Products p
    JOIN Categories c ON c.CategoryID = p.CategoryID
)
SELECT CategoryName, Name, Price
FROM Ranked
WHERE rn = 1;


-- 14. Rank products by units sold (the same number of units = the same rank).
SELECT p.Name,
       SUM(oi.Quantity) AS UnitsSold,
       DENSE_RANK() OVER (ORDER BY SUM(oi.Quantity) DESC) AS SalesRank
FROM OrderItems oi
JOIN Orders o ON o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
WHERE o.Status <> 'Cancelled'
GROUP BY p.Name;


-- 15. For every order show the customer's previous order date
--     and how many days passed between the two orders.
SELECT UserID,
       OrderID,
       OrderDate,
       LAG(OrderDate) OVER (PARTITION BY UserID ORDER BY OrderDate) AS PreviousOrder,
       DATEDIFF(day,
                LAG(OrderDate) OVER (PARTITION BY UserID ORDER BY OrderDate),
                OrderDate) AS DaysBetween
FROM Orders
WHERE Status <> 'Cancelled'
ORDER BY UserID, OrderDate;


-- 16. Monthly revenue with a running total.
WITH Monthly AS (
    SELECT YEAR(OrderDate) AS OrderYear,
           MONTH(OrderDate) AS OrderMonth,
           SUM(TotalAmount) AS Revenue
    FROM Orders
    WHERE Status <> 'Cancelled'
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT OrderYear, OrderMonth, Revenue,
       SUM(Revenue) OVER (ORDER BY OrderYear, OrderMonth) AS RunningTotal
FROM Monthly
ORDER BY OrderYear, OrderMonth;


-- 17. Share of each category in the total revenue (%).
SELECT c.CategoryName,
       SUM(oi.Subtotal) AS Revenue,
       CAST(SUM(oi.Subtotal) * 100.0 / SUM(SUM(oi.Subtotal)) OVER () AS DECIMAL(5,2)) AS SharePct
FROM OrderItems oi
JOIN Orders o ON o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE o.Status <> 'Cancelled'
GROUP BY c.CategoryName
ORDER BY SharePct DESC;


-- 18. Products with an average rating of 4 or higher and at least 2 reviews.
SELECT p.Name,
       COUNT(r.ReviewID) AS Reviews,
       CAST(AVG(r.Rating * 1.0) AS DECIMAL(3,2)) AS AvgRating
FROM Products p
JOIN Reviews r ON r.ProductID = p.ProductID
GROUP BY p.Name
HAVING COUNT(r.ReviewID) >= 2 AND AVG(r.Rating * 1.0) >= 4
ORDER BY AvgRating DESC;
