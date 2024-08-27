USE master;
DROP DATABASE MyStoreDB;

CREATE DATABASE MyStoreDB;
GO

USE MyStoreDB;
GO

DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Manufacturer;
DROP TABLE IF EXISTS Product;

CREATE TABLE Category
(
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Manufacturer
(
    ManufacturerID INT PRIMARY KEY IDENTITY(1,1),
    ManufacturerName NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Product
(
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    CategoryID INT,
    ManufacturerID INT,
    StockLevel INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturer(ManufacturerID)
);
GO

INSERT INTO Category
    (CategoryName)
VALUES
    ('Electronics'),
    ('Clothing'),
    ('Groceries'),
    ('Books'),
    ('Toys');
GO

INSERT INTO Manufacturer
    (ManufacturerName)
VALUES
    ('Sony'),
    ('Samsung'),
    ('LG'),
    ('Apple'),
    ('Microsoft');
GO

INSERT INTO Product
    (ProductName, Price, CategoryID, ManufacturerID, StockLevel)
VALUES
    ('TV', 499.99, 1, 1, 50),
    ('Smartphone', 999.99, 1, 2, 30),
    ('Laptop', 899.99, 1, 3, 20),
    ('Jeans', 49.99, 2, 4, 100),
    ('T-Shirt', 19.99, 2, 5, 200),
    ('Apple', 1.99, 3, NULL, 300),
    ('Banana', 0.99, 3, NULL, 400),
    ('Novel', 14.99, 4, NULL, 150),
    ('Toy Car', 9.99, 5, NULL, 250),
    ('Doll', 19.99, 5, NULL, 150);
GO

INSERT INTO Product
    (ProductName, Price, CategoryID, ManufacturerID, StockLevel)
VALUES
    ('Headphones', 199.99, 1, 1, 75),
    ('Camera', 299.99, 1, 2, 40),
    ('Tablet', 399.99, 1, 3, 35),
    ('Dress', 79.99, 2, 4, 90),
    ('Sneakers', 59.99, 2, 5, 120),
    ('Orange', 2.49, 3, NULL, 350),
    ('Grapes', 3.49, 3, NULL, 380),
    ('Cookbook', 24.99, 4, NULL, 140),
    ('Puzzle', 12.99, 5, NULL, 220),
    ('Building Blocks', 29.99, 5, NULL, 180);
GO

-- 1
DECLARE @CategoryID INT;
SET @CategoryID = 1;

SELECT ProductID, ProductName, Price, StockLevel
FROM Product
WHERE CategoryID = @CategoryID;
GO

-- 2
SELECT ProductID, ProductName, Price,
    CASE
        WHEN Price > 100 THEN 'Expensive'
        ELSE 'Cheap'
    END AS PriceStatus
FROM Product;
GO

-- 3
DECLARE @Counter INT = 1;
DECLARE @MaxCount INT = 5;
DECLARE @ProductNamePrefix NVARCHAR(50) = 'NewProduct';

WHILE @Counter <= @MaxCount
BEGIN
    INSERT INTO Product
        (ProductName, Price, CategoryID, ManufacturerID, StockLevel)
    VALUES
        (@ProductNamePrefix + CONVERT(NVARCHAR(10), @Counter), 10.00 * @Counter, 1, 1, 50);

    SET @Counter = @Counter + 1;
END;
GO

-- 4
CREATE VIEW ProductDetails
AS
    SELECT
        p.ProductID,
        p.ProductName,
        p.Price,
        c.CategoryName,
        m.ManufacturerName,
        p.StockLevel
    FROM
        Product p
        JOIN
        Category c ON p.CategoryID = c.CategoryID
        JOIN
        Manufacturer m ON p.ManufacturerID = m.ManufacturerID;
GO

SELECT *
FROM ProductDetails;
GO

-- 5
CREATE VIEW ProductPriceUpdate
AS
    SELECT ProductID, ProductName, Price
    FROM Product;
GO

UPDATE ProductPriceUpdate
SET Price = Price * 1.10
WHERE ProductID = 1;
GO

-- 6
DECLARE @ProductTable TABLE (
    ProductID INT,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2)
);

INSERT INTO @ProductTable
    (ProductID, ProductName, Price)
SELECT ProductID, ProductName, Price
FROM Product
WHERE CategoryID = 1;

SELECT *
FROM @ProductTable;
GO

-- 7
CREATE TABLE #LowStockProducts
(
    ProductID INT,
    ProductName NVARCHAR(100),
    StockLevel INT
);

INSERT INTO #LowStockProducts
    (ProductID, ProductName, StockLevel)
SELECT ProductID, ProductName, StockLevel
FROM Product
WHERE StockLevel < 100;

SELECT *
FROM #LowStockProducts;

DROP TABLE #LowStockProducts;
GO

-- 8
CREATE VIEW ProductPriceCategory
AS
    SELECT
        ProductID,
        ProductName,
        Price,
        CASE 
        WHEN Price > 100 THEN 'Expensive'
        ELSE 'Cheap'
    END AS PriceCategory
    FROM Product;
GO

SELECT *
FROM ProductPriceCategory;
GO

-- 9
DECLARE @Counter INT = 1;
DECLARE @MaxCount INT = 3;
DECLARE @ErrorMessage NVARCHAR(100);
DECLARE @ProductNamePrefix NVARCHAR(50) = 'NewNewProduct';

WHILE @Counter <= @MaxCount
BEGIN
    BEGIN TRY
        INSERT INTO Product
        (ProductName, Price, CategoryID, ManufacturerID, StockLevel)
    VALUES
        (@ProductNamePrefix + CONVERT(NVARCHAR(10), @Counter), 15.00 * @Counter, 1, 1, 100);

        SET @Counter = @Counter + 1;
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error occurred: ' + @ErrorMessage;
        BREAK;
    END CATCH
END;
GO
