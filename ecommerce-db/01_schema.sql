
IF DB_ID(N'E-Commerce') IS NULL
    CREATE DATABASE [E-Commerce];
GO

USE [E-Commerce];
GO

/* ---------- Users ---------- */

CREATE TABLE Users (
    UserID          INT             IDENTITY(1,1) PRIMARY KEY,
    Email           VARCHAR(100)    NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)    NOT NULL,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    PhoneNumber     NVARCHAR(20)    NULL,
    DateOfBirth     DATE            NULL,
    LastLoginDate   DATETIME        NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CK_Users_Email CHECK (Email LIKE '%_@__%.__%'),
    CONSTRAINT CK_Users_DOB   CHECK (DateOfBirth < CONVERT(DATE, GETDATE())),
    CONSTRAINT CK_Users_Phone CHECK (PhoneNumber IS NULL OR LEN(PhoneNumber) >= 10)
);
GO

CREATE TABLE Addresses (
    AddressID   INT             IDENTITY(1,1) PRIMARY KEY,
    UserID      INT             NOT NULL FOREIGN KEY REFERENCES Users (UserID),
    Street      NVARCHAR(100)   NOT NULL,
    City        NVARCHAR(50)    NOT NULL,
    Country     NVARCHAR(50)    NOT NULL,
    PostalCode  VARCHAR(10)     NOT NULL      -- text, so leading zeros are kept (0010)
);
GO

/* ---------- Catalog ---------- */

CREATE TABLE Categories (
    CategoryID      INT             IDENTITY(1,1) PRIMARY KEY,
    CategoryName    NVARCHAR(50)    NOT NULL UNIQUE,
    Description     NVARCHAR(150)   NULL
);
GO

CREATE TABLE Products (
    ProductID           INT             IDENTITY(1,1) PRIMARY KEY,
    Name                NVARCHAR(100)   NOT NULL,
    CategoryID          INT             NOT NULL FOREIGN KEY REFERENCES Categories (CategoryID),
    Description         NVARCHAR(MAX)   NULL,
    SKU                 NVARCHAR(50)    NOT NULL UNIQUE,
    Price               DECIMAL(10,2)   NOT NULL,
    Cost                DECIMAL(10,2)   NOT NULL,
    StockQuantity       INT             NOT NULL DEFAULT 0,
    ReorderLevel        INT             NOT NULL DEFAULT 10,
    IsActive            BIT             NOT NULL DEFAULT 1,
    CreatedDate         DATETIME        NOT NULL DEFAULT GETDATE(),
    LastModifiedDate    DATETIME        NULL,
    CONSTRAINT CK_Products_Price  CHECK (Price > 0),
    CONSTRAINT CK_Products_Cost   CHECK (Cost >= 0),
    CONSTRAINT CK_Products_Margin CHECK (Price > Cost),
    CONSTRAINT CK_Products_Stock  CHECK (StockQuantity >= 0)
);
GO

/* ---------- Orders ---------- */

CREATE TABLE Coupons (
    CouponCode          VARCHAR(20) PRIMARY KEY,
    DiscountPercentage  INT         NOT NULL CHECK (DiscountPercentage BETWEEN 1 AND 100),
    ExpiryDate          DATE        NOT NULL,
    IsActive            BIT         NOT NULL DEFAULT 1
);
GO

CREATE TABLE Orders (
    OrderID             INT             IDENTITY(1,1) PRIMARY KEY,
    UserID              INT             NOT NULL FOREIGN KEY REFERENCES Users (UserID),
    OrderDate           DATETIME        NOT NULL DEFAULT GETDATE(),
    Status              NVARCHAR(20)    NOT NULL DEFAULT 'Pending',
    TotalAmount         DECIMAL(10,2)   NOT NULL DEFAULT 0,   -- calculated by trg_OrderItems_UpdateTotal
    ShippingAddressID   INT             NOT NULL FOREIGN KEY REFERENCES Addresses (AddressID),
    CouponCode          VARCHAR(20)     NULL FOREIGN KEY REFERENCES Coupons (CouponCode),
    DiscountPercent     DECIMAL(5,2)    NOT NULL DEFAULT 0,   -- set by sp_ApplyDiscount
    LastModifiedDate    DATETIME        NULL,
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT CK_Orders_Total  CHECK (TotalAmount >= 0)
);
GO

CREATE TABLE OrderItems (
    OrderItemID INT             IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT             NOT NULL FOREIGN KEY REFERENCES Orders (OrderID) ON DELETE CASCADE,
    ProductID   INT             NOT NULL FOREIGN KEY REFERENCES Products (ProductID),
    Quantity    INT             NOT NULL CHECK (Quantity > 0),
    UnitPrice   DECIMAL(10,2)   NOT NULL CHECK (UnitPrice > 0),   -- price at the moment of the order
    Subtotal    AS (Quantity * UnitPrice) PERSISTED
);
GO

CREATE TABLE Payments (
    PaymentID       INT             IDENTITY(1,1) PRIMARY KEY,
    OrderID         INT             NOT NULL FOREIGN KEY REFERENCES Orders (OrderID) ON DELETE CASCADE,
    Amount          DECIMAL(10,2)   NOT NULL CHECK (Amount > 0),
    PaymentMethod   VARCHAR(20)     NOT NULL CHECK (PaymentMethod IN ('Card', 'Cash', 'BankTransfer')),
    PaymentDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          VARCHAR(20)     NOT NULL CHECK (Status IN ('Pending', 'Completed', 'Refunded'))
);
GO

/* ---------- Customer activity ---------- */

CREATE TABLE Reviews (
    ReviewID    INT             IDENTITY(1,1) PRIMARY KEY,
    ProductID   INT             NOT NULL FOREIGN KEY REFERENCES Products (ProductID) ON DELETE CASCADE,
    UserID      INT             NOT NULL FOREIGN KEY REFERENCES Users (UserID) ON DELETE CASCADE,
    Rating      INT             NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment     NVARCHAR(500)   NULL,
    ReviewDate  DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Reviews_User_Product UNIQUE (UserID, ProductID)   -- one review per product per user
);
GO

CREATE TABLE ShoppingCart (
    CartID      INT         IDENTITY(1,1) PRIMARY KEY,
    UserID      INT         NOT NULL FOREIGN KEY REFERENCES Users (UserID) ON DELETE CASCADE,
    ProductID   INT         NOT NULL FOREIGN KEY REFERENCES Products (ProductID) ON DELETE CASCADE,
    Quantity    INT         NOT NULL CHECK (Quantity > 0),
    AddedDate   DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_ShoppingCart_User_Product UNIQUE (UserID, ProductID)
);
GO

CREATE TABLE Wishlist (
    WishlistID  INT         IDENTITY(1,1) PRIMARY KEY,
    UserID      INT         NOT NULL FOREIGN KEY REFERENCES Users (UserID) ON DELETE CASCADE,
    ProductID   INT         NOT NULL FOREIGN KEY REFERENCES Products (ProductID) ON DELETE CASCADE,
    AddedDate   DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Wishlist_User_Product UNIQUE (UserID, ProductID)
);
GO

/* ---------- Inventory and audit (filled by triggers) ---------- */

CREATE TABLE LowStockAlerts (
    AlertID         INT         IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT         NOT NULL FOREIGN KEY REFERENCES Products (ProductID),
    CurrentStock    INT         NOT NULL,
    AlertDate       DATETIME    NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE ProductAudit (
    AuditID         INT             IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT             NOT NULL,
    Action          VARCHAR(10)     NOT NULL,
    OldPrice        DECIMAL(10,2)   NULL,
    NewPrice        DECIMAL(10,2)   NULL,
    OldStock        INT             NULL,
    NewStock        INT             NULL,
    ModifiedBy      NVARCHAR(128)   NOT NULL DEFAULT SUSER_SNAME(),
    ModifiedDate    DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

/* ---------- Indexes ----------
   SQL Server does not create indexes for foreign keys automatically */

CREATE INDEX IX_Addresses_UserID   ON Addresses (UserID);
CREATE INDEX IX_Products_CategoryID ON Products (CategoryID);
CREATE INDEX IX_Orders_UserID      ON Orders (UserID, OrderDate);
CREATE INDEX IX_OrderItems_OrderID ON OrderItems (OrderID);
CREATE INDEX IX_OrderItems_ProductID ON OrderItems (ProductID);
CREATE INDEX IX_Reviews_ProductID  ON Reviews (ProductID);
CREATE INDEX IX_Payments_OrderID   ON Payments (OrderID);
GO
