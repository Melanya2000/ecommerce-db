
USE [E-Commerce];
GO

----ORDER ITEMS 

-- Reduces stock when order items are added and creates low-stock alerts.
-- This is the ONLY place where an order reduces stock.
CREATE OR ALTER TRIGGER trg_OrderItems_UpdateInventory
ON OrderItems
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Sum per product first: one INSERT can have the same product in several rows,
    -- and UPDATE ... FROM would use only one of them
    DECLARE @Changed TABLE (ProductID INT PRIMARY KEY, Qty INT);

    INSERT INTO @Changed (ProductID, Qty)
    SELECT ProductID, SUM(Quantity)
    FROM INSERTED
    GROUP BY ProductID;

    -- Negative stock is blocked by CK_Products_Stock:
    -- the UPDATE fails and the whole order is rolled back
    UPDATE p
    SET StockQuantity = p.StockQuantity - c.Qty,
        LastModifiedDate = GETDATE()
    FROM Products p
    INNER JOIN @Changed c ON p.ProductID = c.ProductID;

    -- Low stock alert, including products that just ran out (0)
    INSERT INTO LowStockAlerts (ProductID, CurrentStock, AlertDate)
    SELECT
        p.ProductID,
        p.StockQuantity,
        GETDATE()
    FROM Products p
    INNER JOIN @Changed c ON p.ProductID = c.ProductID
    WHERE p.StockQuantity <= p.ReorderLevel;
END
GO

-- Keeps Orders.TotalAmount equal to the sum of its items, with the order discount.
-- This is the ONLY place where the order total is calculated.
CREATE OR ALTER TRIGGER trg_OrderItems_UpdateTotal
ON OrderItems
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Get affected OrderIDs from both INSERTED and DELETED
    DECLARE @AffectedOrders TABLE (OrderID INT PRIMARY KEY);

    INSERT INTO @AffectedOrders (OrderID)
    SELECT OrderID FROM INSERTED
    UNION
    SELECT OrderID FROM DELETED;

    -- Recalculate only the affected orders, not the whole OrderItems table
    UPDATE o
    SET TotalAmount = dbo.fn_CalculateDiscountedPrice(COALESCE(totals.Total, 0), o.DiscountPercent),
        LastModifiedDate = GETDATE()
    FROM Orders o
    INNER JOIN @AffectedOrders ao ON o.OrderID = ao.OrderID
    LEFT JOIN (
        SELECT OrderID, SUM(Subtotal) AS Total
        FROM OrderItems
        WHERE OrderID IN (SELECT OrderID FROM @AffectedOrders)
        GROUP BY OrderID
    ) totals ON o.OrderID = totals.OrderID;
END
GO

----PRODUCTS 

-- Audit trail: price, stock and activation changes
CREATE OR ALTER TRIGGER trg_Products_Audit
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ProductAudit (ProductID, Action, OldPrice, NewPrice, OldStock, NewStock)
    SELECT
        i.ProductID,
        CASE
            WHEN d.IsActive = 1 AND i.IsActive = 0 THEN 'DEACTIVATE'
            WHEN d.IsActive = 0 AND i.IsActive = 1 THEN 'ACTIVATE'
            ELSE 'UPDATE'
        END,
        d.Price,
        i.Price,
        d.StockQuantity,
        i.StockQuantity
    FROM INSERTED i
    INNER JOIN DELETED d ON i.ProductID = d.ProductID
    WHERE i.Price <> d.Price
       OR i.StockQuantity <> d.StockQuantity
       OR i.IsActive <> d.IsActive;
END
GO

-- Soft delete: products are referenced by old orders, so a real DELETE
-- would either fail (foreign key) or break the order history.
-- DELETE FROM Products only hides the product and removes it from active carts.
CREATE OR ALTER TRIGGER trg_Products_DeleteProtection
ON Products
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET IsActive = 0,
        LastModifiedDate = GETDATE()
    FROM Products p
    INNER JOIN DELETED d ON d.ProductID = p.ProductID
    WHERE p.IsActive = 1;

    DELETE sc
    FROM ShoppingCart sc
    INNER JOIN DELETED d ON d.ProductID = sc.ProductID;
END
GO
