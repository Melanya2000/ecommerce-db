

USE [E-Commerce];
GO

-------Users

CREATE OR ALTER PROCEDURE sp_RegisterUser
    @Email VARCHAR(100),
    @PasswordHash VARCHAR(255),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @PhoneNumber NVARCHAR(20) = NULL,
    @DateOfBirth DATE = NULL,
    @UserID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate email doesn't exist
        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
        BEGIN
            RAISERROR('Email already registered', 16, 1);
            RETURN -1;
        END
        INSERT INTO Users (Email, PasswordHash, FirstName, LastName, PhoneNumber, DateOfBirth)
        VALUES (@Email, @PasswordHash, @FirstName, @LastName, @PhoneNumber, @DateOfBirth);

        SET @UserID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        RETURN 0; -- Success

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN -1; -- Error
    END CATCH
END
GO

-- The password itself is checked in the application (bcrypt); the database only returns the hash
CREATE OR ALTER PROCEDURE sp_LoginUser
    @Email VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, PasswordHash FROM Users WHERE Email = @Email AND IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE sp_GetUserProfile
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        FirstName,
        LastName,
        Email,
        PhoneNumber,
        DateOfBirth
    FROM Users
    WHERE UserID = @UserID;
END
GO

------ PRODUCTS AND INVENTORY 

CREATE OR ALTER PROCEDURE sp_UpdateProduct
@ProductID INT,
@Name NVARCHAR(100),
@Price DECIMAL(10,2),
@Stock INT
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
BEGIN
    RAISERROR(N'Product not found.', 16, 1);
    RETURN;
END
IF @Price <= 0
BEGIN
    RAISERROR(N'The price of the product must be greater than 0.', 16, 1);
    RETURN;
END
IF @Stock < 0
BEGIN
    RAISERROR(N'The stock quantity cannot be negative.', 16, 1);
    RETURN;
END
UPDATE Products
 SET Name = @Name,
     Price = @Price,
     StockQuantity = @Stock,
     LastModifiedDate = GETDATE()
    WHERE ProductID = @ProductID;
    PRINT N'Product details were successfully updated';
END TRY
BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_UpdateInventory
    @ProductID INT,
    @Quantity INT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStock INT;
    DECLARE @NewStock INT;
    DECLARE @ReorderLevel INT;

    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            RAISERROR(N'Ապրանքը չի գտնվել:', 16, 1);
            RETURN;
        END

      
        SELECT @CurrentStock = StockQuantity, @ReorderLevel = ReorderLevel
        FROM Products
        WHERE ProductID = @ProductID;

      
        SET @NewStock = @CurrentStock + @Quantity;

     
        IF @NewStock < 0
        BEGIN
            RAISERROR(N'The stock quantity cannot become negative.', 16, 1);
            RETURN;
        END

       BEGIN TRANSACTION;

        UPDATE Products
        SET StockQuantity = @NewStock,
            LastModifiedDate = GETDATE()
        WHERE ProductID = @ProductID;

        IF @NewStock <= @ReorderLevel
        BEGIN
            INSERT INTO LowStockAlerts (ProductID, CurrentStock, AlertDate)
            VALUES (@ProductID, @NewStock, GETDATE());
        END

        COMMIT TRANSACTION;
        PRINT N'The repository was successfully updated.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

---- CART AND ORDERS 

CREATE OR ALTER PROCEDURE sp_AddToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Quantity <= 0
            RAISERROR('Quantity must be greater than 0', 16, 1);

        DECLARE @Stock INT, @IsActive BIT, @InCart INT;
        SELECT @Stock = StockQuantity, @IsActive = IsActive
        FROM Products WHERE ProductID = @ProductID;

        IF @IsActive IS NULL
            RAISERROR('Product not found', 16, 1);

        IF @IsActive = 0
            RAISERROR('Product is not available', 16, 1);

        SELECT @InCart = COALESCE(SUM(Quantity), 0)
        FROM ShoppingCart
        WHERE UserID = @UserID AND ProductID = @ProductID;

        IF @Stock < @InCart + @Quantity
            RAISERROR('Insufficient stock. Available: %d', 16, 1, @Stock);

        IF @InCart > 0
        BEGIN
          
            UPDATE ShoppingCart
            SET Quantity = Quantity + @Quantity
            WHERE UserID = @UserID AND ProductID = @ProductID;
        END
        ELSE
        BEGIN
            
            INSERT INTO ShoppingCart (UserID, ProductID, Quantity)
            VALUES (@UserID, @ProductID, @Quantity);
        END

        COMMIT TRANSACTION;
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Cart -> order. Stock and TotalAmount are NOT changed here:
--   trg_OrderItems_UpdateInventory reduces stock,
--   trg_OrderItems_UpdateTotal calculates the order total.
-- (Doing it in both places reduced the stock twice.)
CREATE OR ALTER PROCEDURE sp_ProcessOrder
    @UserID INT,
    @ShippingAddressID INT,
    @OrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

       
        IF NOT EXISTS (SELECT 1 FROM ShoppingCart WHERE UserID = @UserID)
        BEGIN
            RAISERROR (N'The cart is empty.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Addresses WHERE AddressID = @ShippingAddressID AND UserID = @UserID)
        BEGIN
            RAISERROR (N'The delivery address does not belong to this user.', 16, 1);
            RETURN;
        END

        --    UPDLOCK, HOLDLOCK: the product rows stay locked until COMMIT,
        --    so two customers can't both pass this check and buy the last cake
        IF EXISTS (
            SELECT 1
            FROM ShoppingCart sc
            JOIN Products p WITH (UPDLOCK, HOLDLOCK) ON sc.ProductID = p.ProductID
            WHERE sc.UserID = @UserID
              AND (sc.Quantity > p.StockQuantity OR p.IsActive = 0)
        )
        BEGIN
            RAISERROR (N'The quantity in stock is not sufficient for the items you have selected.', 16, 1);
            RETURN;
        END

        -- 4. Create order header
        INSERT INTO Orders (UserID, ShippingAddressID, Status)
        VALUES (@UserID, @ShippingAddressID, 'Processing');

        SET @OrderID = SCOPE_IDENTITY();

        -- 5. Move cart items to order items (price is copied at the moment of the order)
        INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
        SELECT @OrderID, sc.ProductID, sc.Quantity, p.Price
        FROM ShoppingCart sc
        JOIN Products p ON p.ProductID = sc.ProductID
        WHERE sc.UserID = @UserID;

        -- 6. Clear cart
        DELETE FROM ShoppingCart WHERE UserID = @UserID;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_ApplyDiscount
@OrderID INT,
@CouponCode VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @ItemsTotal DECIMAL(10,2);
    DECLARE @DiscountPercent INT;
    DECLARE @NewTotalAmount DECIMAL(10,2);
BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
BEGIN
	RAISERROR(N'Order not found',16,1);
	RETURN;
END
IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID AND Status NOT IN ('Pending', 'Processing'))
BEGIN
	RAISERROR(N'The discount can be applied only to an order with a status of "Pending" or "Processing."',16,1);
	RETURN;
END
-- One coupon per order: otherwise the same discount could be applied again and again
IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID AND CouponCode IS NOT NULL)
BEGIN
	RAISERROR(N'A coupon has already been applied to this order.',16,1);
	RETURN;
END
SELECT @DiscountPercent = DiscountPercentage
FROM Coupons
WHERE CouponCode = @CouponCode
  AND IsActive = 1
  AND ExpiryDate >= CAST(GETDATE() AS DATE);
IF @DiscountPercent IS NULL
BEGIN
RAISERROR(N'The coupon was not found, is not active, or has expired.',16,1);
RETURN;
END
BEGIN TRANSACTION
-- The discount is stored on the order, so trg_OrderItems_UpdateTotal keeps it
-- when order items change later
SELECT @ItemsTotal = COALESCE(SUM(Subtotal), 0)
FROM OrderItems
WHERE OrderID = @OrderID;

SET @NewTotalAmount = dbo.fn_CalculateDiscountedPrice(@ItemsTotal, @DiscountPercent);

UPDATE Orders
        SET CouponCode = @CouponCode,
            DiscountPercent = @DiscountPercent,
            TotalAmount = @NewTotalAmount,
            LastModifiedDate = GETDATE()
        WHERE OrderID = @OrderID;
COMMIT TRANSACTION;
        PRINT N'The discount was applied successfully. New amount: ' + CAST(@NewTotalAmount AS NVARCHAR(20));

    END TRY
    BEGIN CATCH
              IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE sp_CancelOrder
@OrderID INT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
IF NOT EXISTS( SELECT 1 FROM Orders WHERE OrderID = @OrderID)
BEGIN
RAISERROR (N'Order not found',16,1);
RETURN;
END
-- Without this check the same order could be cancelled twice and the stock restored twice
IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID AND Status NOT IN ('Pending', 'Processing'))
BEGIN
RAISERROR (N'This order cannot be cancelled.',16,1);
RETURN;
END
BEGIN TRANSACTION
UPDATE Orders
SET Status = 'Cancelled',
    LastModifiedDate = GETDATE()
WHERE OrderID = @OrderID;
-- Restore stock (grouped: the same product can be in two lines of one order)
UPDATE p
SET p.StockQuantity = p.StockQuantity + oi.Qty,
    p.LastModifiedDate = GETDATE()
FROM Products p
INNER JOIN (SELECT ProductID, SUM(Quantity) AS Qty
            FROM OrderItems
            WHERE OrderID = @OrderID
            GROUP BY ProductID) oi ON p.ProductID = oi.ProductID;
-- Paid orders get their money back
UPDATE Payments
SET Status = 'Refunded'
WHERE OrderID = @OrderID AND Status = 'Completed';
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION;
THROW;
END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_GetUserOrders
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.UserID,
        o.OrderID,
        o.OrderDate,
        o.Status,
        o.TotalAmount,
        o.ShippingAddressID,
        ISNULL(oi.ProductID, 0) AS ProductID, 
        p.Name AS ProductName,
        ISNULL(oi.Quantity, 0) AS Quantity,
        ISNULL(oi.UnitPrice, 0) AS UnitPrice
    FROM Orders o
    LEFT JOIN OrderItems oi ON oi.OrderID = o.OrderID
    LEFT JOIN Products p ON p.ProductID = oi.ProductID
    WHERE o.UserID = @UserID
    ORDER BY o.OrderDate DESC, o.OrderID;
END
GO

----REVIEWS 

CREATE OR ALTER PROCEDURE sp_AddReview
@UserID INT,
@ProductID INT,
@Rating INT,
@Comment NVARCHAR(500)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
IF @Rating < 1 OR @Rating > 5
        BEGIN
            RAISERROR(N'The rating must be in the range of 1 to 5.', 16, 1);
            RETURN;
        END
IF NOT EXISTS (
    SELECT 1
    FROM Orders o
    INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
    WHERE o.UserID = @UserID AND oi.ProductID = @ProductID
      AND o.Status <> 'Cancelled'
)
BEGIN
    RAISERROR(N'You cannot leave a review for this product because you have not purchased it yet.', 16, 1);
    RETURN;
END
IF EXISTS (SELECT 1 FROM Reviews WHERE UserID = @UserID AND ProductID = @ProductID)
BEGIN
    RAISERROR(N'You have already left a review for this product.', 16, 1);
    RETURN;
END
BEGIN TRANSACTION;
INSERT INTO Reviews (ProductID, UserID, Rating, Comment, ReviewDate)
VALUES (@ProductID, @UserID, @Rating, @Comment, GETDATE());
COMMIT TRANSACTION;
PRINT N'The opinion was successfully added.';
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
ROLLBACK TRANSACTION;
THROW;
END CATCH
END
GO
