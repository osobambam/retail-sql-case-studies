/* Retail mid-size operation schema for Microsoft SQL Server */
IF DB_ID(N'RetailMidSize') IS NULL
    CREATE DATABASE RetailMidSize;
GO
USE RetailMidSize;
GO
IF OBJECT_ID(N'dbo.Order_Items', N'U') IS NOT NULL DROP TABLE dbo.Order_Items;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID(N'dbo.Promotions', N'U') IS NOT NULL DROP TABLE dbo.Promotions;
IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL DROP TABLE dbo.Customers;
GO
CREATE TABLE dbo.Customers (
    customer_id INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    acquisition_channel VARCHAR(50) NOT NULL CHECK (acquisition_channel IN ('Organic','Paid','Referral')),
    acquisition_date DATE NOT NULL,
    city VARCHAR(100) NOT NULL,
    customer_tier VARCHAR(20) NOT NULL CHECK (customer_tier IN ('Bronze','Silver','Gold'))
);
CREATE TABLE dbo.Promotions (
    promo_id INT NOT NULL PRIMARY KEY,
    promo_name VARCHAR(100) NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL CHECK (discount_pct >= 0 AND discount_pct <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    promo_type VARCHAR(50) NOT NULL CHECK (promo_type IN ('Seasonal','Flash','Loyalty')),
    CONSTRAINT CK_Promotions_DateRange CHECK (end_date >= start_date)
);
CREATE TABLE dbo.Products (
    product_id INT NOT NULL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL,
    full_price DECIMAL(10,2) NOT NULL CHECK (full_price >= 0),
    cogs DECIMAL(10,2) NOT NULL CHECK (cogs >= 0),
    margin_pct AS (CONVERT(DECIMAL(10,2), ((full_price - cogs) / NULLIF(full_price, 0)) * 100)) PERSISTED
);
CREATE TABLE dbo.Orders (
    order_id INT NOT NULL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    promo_id INT NULL,
    gross_revenue DECIMAL(10,2) NOT NULL CHECK (gross_revenue >= 0),
    net_revenue DECIMAL(10,2) NOT NULL CHECK (net_revenue >= 0),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id),
    CONSTRAINT FK_Orders_Promotions FOREIGN KEY (promo_id) REFERENCES dbo.Promotions(promo_id)
);
CREATE TABLE dbo.Order_Items (
    item_id INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);
GO
CREATE INDEX IX_Orders_CustomerId ON dbo.Orders(customer_id);
CREATE INDEX IX_Orders_OrderDate ON dbo.Orders(order_date);
CREATE INDEX IX_OrderItems_OrderId ON dbo.Order_Items(order_id);
CREATE INDEX IX_OrderItems_ProductId ON dbo.Order_Items(product_id);
CREATE INDEX IX_Products_Category ON dbo.Products(category);
GO
