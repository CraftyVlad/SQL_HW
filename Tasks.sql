USE master;
DROP DATABASE Store;

CREATE DATABASE Store;
USE Store;

DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;

CREATE TABLE Authors
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL CHECK([Name] != ''),
    Country NVARCHAR(100) NULL,
    DateOfBirth DATE NULL
);

CREATE TABLE Books
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL CHECK(Title != ''),
    PublicationYear INT NULL,
    Genre NVARCHAR(50) NULL,
    AuthorId INT NOT NULL,
    FOREIGN KEY (AuthorId) REFERENCES Authors(Id)
);

CREATE TABLE Customers
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL CHECK([Name] != ''),
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(20) NULL UNIQUE,
    [Address] NVARCHAR(200) NULL
);

CREATE TABLE Orders
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerId INT NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
    TotalAmount DECIMAL(10, 2) NOT NULL
);

CREATE TABLE OrderDetails
(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderId INT NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    BookId INT NOT NULL,
    FOREIGN KEY (BookId) REFERENCES Books(Id),
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

INSERT INTO Authors
    ([Name], Country, DateOfBirth)
VALUES
    ('J.K. Rowling', 'United Kingdom', '1965-07-31'),
    ('George R.R. Martin', 'United States', '1948-09-20'),
    ('J.R.R. Tolkien', 'United Kingdom', '1892-01-03'),
    ('Agatha Christie', 'United Kingdom', '1890-09-15');

INSERT INTO Books
    (Title, PublicationYear, Genre, AuthorId)
VALUES
    ('Harry Potter and the Philosopher''s Stone', 1997, 'Fantasy', 1),
    ('A Game of Thrones', 1996, 'Fantasy', 2),
    ('The Hobbit', 1937, 'Fantasy', 3),
    ('Murder on the Orient Express', 1934, 'Mystery', 4);

INSERT INTO Customers
    ([Name], Email, PhoneNumber, [Address])
VALUES
    ('John Doe', 'john.doe@example.com', '123-456-7890', '123 Elm Street'),
    ('Jane Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak Avenue'),
    ('Emily Johnson', 'emily.johnson@example.com', '234-567-8902', '789 Pine Road'),
    ('Michael Brown', 'michael.brown@example.com', '345-678-9012', '101 Maple Lane');

INSERT INTO Orders
    (OrderDate, CustomerId, TotalAmount)
VALUES
    ('2024-08-15', 1, 20),
    ('2024-08-16', 2, 40),
    ('2024-08-16', 3, 10),
    ('2024-08-17', 4, 30);

INSERT INTO OrderDetails
    (OrderId, BookId, Quantity, Price)
VALUES
    (1, 1, 1, 20),
    (2, 2, 1, 40),
    (3, 3, 1, 10),
    (4, 4, 2, 20);

-- 1
SELECT
    Books.Title AS BookTitle,
    Authors.[Name] AS AuthorName
FROM
    Books
    JOIN
    Authors ON Books.AuthorId = Authors.Id;

-- 2
SELECT
    Customers.Name AS CustomerName
FROM
    Customers
    JOIN
    Orders ON Customers.Id = Orders.CustomerId
    JOIN
    OrderDetails ON Orders.Id = OrderDetails.OrderId
    JOIN
    Books ON OrderDetails.BookId = Books.Id
WHERE 
    Books.Genre = 'Fantasy';

-- 3
SELECT
    Orders.OrderDate,
    Books.Title AS BookTitle,
    OrderDetails.Quantity
FROM
    Orders
    JOIN
    OrderDetails ON Orders.Id = OrderDetails.OrderId
    JOIN
    Books ON OrderDetails.BookId = Books.Id;

-- 4
SELECT
    Customers.Name AS CustomerName,
    SUM(Orders.TotalAmount) AS TotalSpent
FROM
    Customers
    JOIN
    Orders ON Customers.Id = Orders.CustomerId
GROUP BY 
    Customers.Name;

-- 5
SELECT
    Books.Title AS BookTitle,
    Authors.Country
FROM
    Books
    JOIN
    Authors ON Books.AuthorId = Authors.Id
WHERE 
    Authors.Country = 'United Kingdom';

-- 6
SELECT
    Authors.Name AS AuthorName,
    SUM(OrderDetails.Quantity) AS TotalBooksSold
FROM
    Books
    JOIN
    Authors ON Books.AuthorId = Authors.Id
    JOIN
    OrderDetails ON Books.Id = OrderDetails.BookId
GROUP BY 
    Authors.Name
ORDER BY 
    TotalBooksSold DESC;

-- 7
SELECT
    Customers.Name AS CustomerName,
    Orders.OrderDate,
    Books.Title AS BookTitle,
    OrderDetails.Price
FROM
    Customers
    JOIN
    Orders ON Customers.Id = Orders.CustomerId
    JOIN
    OrderDetails ON Orders.Id = OrderDetails.OrderId
    JOIN
    Books ON OrderDetails.BookId = Books.Id;

-- 8
SELECT
    Authors.Name AS AuthorName
FROM
    Authors
    LEFT JOIN
    Books ON Authors.Id = Books.AuthorId
    LEFT JOIN
    OrderDetails ON Books.Id = OrderDetails.BookId
WHERE 
    OrderDetails.Id IS NULL;

-- 9
SELECT
    Books.Title AS BookTitle,
    Authors.Name AS AuthorName,
    Orders.OrderDate
FROM
    Orders
    JOIN
    OrderDetails ON Orders.Id = OrderDetails.OrderId
    JOIN
    Books ON OrderDetails.BookId = Books.Id
    JOIN
    Authors ON Books.AuthorId = Authors.Id
WHERE 
    Orders.OrderDate = '2024-08-16';

-- 10
SELECT
    Orders.Id AS OrderId,
    SUM(OrderDetails.Quantity * OrderDetails.Price) AS TotalOrderAmount
FROM
    Orders
    JOIN
    OrderDetails ON Orders.Id = OrderDetails.OrderId
GROUP BY 
    Orders.Id
HAVING 
    COUNT(OrderDetails.BookId) > 1;
