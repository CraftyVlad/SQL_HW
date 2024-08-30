USE master;
DROP DATABASE _LibraryDB;

CREATE DATABASE _LibraryDB;
GO

USE _LibraryDB;
GO

CREATE TABLE Authors
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Country NVARCHAR(50) NOT NULL
);

CREATE TABLE Books
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(50) NOT NULL,

    AuthorId INT,
    FOREIGN KEY (AuthorId) REFERENCES Authors(Id)
);

CREATE TABLE Borrowers
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    BorrowDate DATE NOT NULL,
    ReturnDate DATE NULL,

    BorrowedBookId INT,
    FOREIGN KEY (BorrowedBookId) REFERENCES Books(Id)
);

INSERT INTO Authors
    (Name, Country)
VALUES
    ('George Orwell', 'United Kingdom'),
    ('Haruki Murakami', 'Japan'),
    ('Gabriel Garcia Marquez', 'Colombia');
GO

INSERT INTO Books
    (Title, Genre, AuthorId)
VALUES
    ('1984', 'Dystopian', 1),
    ('Norwegian Wood', 'Romance', 2),
    ('One Hundred Years of Solitude', 'Magical Realism', 3),
    ('Animal Farm', 'Political Satire', 1);
GO

INSERT INTO Borrowers
    (Name, BorrowDate, ReturnDate, BorrowedBookId)
VALUES
    ('Alice Johnson', '2024-08-01', '2024-08-15', 1),
    ('Bob Williams', '2024-08-03', NULL, 2),
    ('Charlie Brown', '2024-08-10', '2024-08-20', 3),
    ('Diana Prince', '2024-08-12', NULL, 4);
GO

-- 1
CREATE PROCEDURE AddNewAuthor
    @Name NVARCHAR(100),
    @Country NVARCHAR(50)
AS
BEGIN
    INSERT INTO Authors
        (Name, Country)
    VALUES
        (@Name, @Country);
    SELECT *
    FROM Authors
END;

EXEC AddNewAuthor 'NewAuthorName', 'USA'
GO

-- 2
CREATE PROCEDURE UpdateBooks
    @NewID INT,
    @NewTitle NVARCHAR(100),
    @NewGenre NVARCHAR(50)
AS
BEGIN
    UPDATE Books
SET Title = @NewTitle, Genre = @NewGenre WHERE Id = @NewID;
END;

EXEC UpdateBooks 2, 'NewBookTitle', 'NewBookGenre'
GO

-- 3

CREATE PROCEDURE DeleteBorrower
    @BorrowerID INT
AS
BEGIN
    DELETE FROM Borrowers
    WHERE Id = @BorrowerID
    SELECT *
    FROM Borrowers
END;

EXEC DeleteBorrower 1
GO

-- 4
CREATE PROCEDURE GetBooksByAuthor
    @AuthorName NVARCHAR(100)
AS
BEGIN
    SELECT Authors.Name, Books.Id AS BookID, Books.Title, Books.Genre
    FROM Books
        JOIN Authors ON Books.AuthorId = Authors.Id
    WHERE Authors.Name = @AuthorName;
END;

EXEC GetBooksByAuthor 'George Orwell'
GO

-- 5
CREATE PROCEDURE UpdateReturnDate
    @BorrowerId INT,
    @NewReturnDate DATE
AS
BEGIN
    UPDATE Borrowers
    SET ReturnDate = @NewReturnDate
    WHERE Id = @BorrowerId;
    SELECT *
    FROM Borrowers
    WHERE Id = @BorrowerId;
END;

EXEC UpdateReturnDate 2, '2024-09-01'
GO

-- 6
CREATE FUNCTION GetAuthorFullName (@AuthorId INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FullName NVARCHAR(100)
    SELECT @FullName = Name + ', ' + Country
    FROM Authors
    WHERE Id = @AuthorId;
    RETURN @FullName;
END;
GO

SELECT dbo.GetAuthorFullName(3) AS FullName
GO

-- 7
CREATE FUNCTION GetBooksByGenre (@Genre NVARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*)
    FROM Books
    WHERE Genre = @Genre;
    RETURN @Count
END;
GO

SELECT dbo.GetBooksByGenre('Romance') AS TotalBooksByGenre
GO

-- 8
CREATE FUNCTION BookExists
    (@Title NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;
    SELECT @Exists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM Books
    WHERE Title = @Title;
    RETURN @Exists;
END;
GO

SELECT dbo.BookExists('1984') AS [Exists];
GO

-- 9
CREATE FUNCTION GetBorrowerAge
    (@BorrowerId INT, @DateOfBirth DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SELECT @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE());
    IF (MONTH(GETDATE()) < MONTH(@DateOfBirth))
        OR (MONTH(GETDATE()) = MONTH(@DateOfBirth) AND DAY(GETDATE()) < DAY(@DateOfBirth))
    BEGIN
        SET @Age = @Age - 1;
    END
    RETURN @Age;
END;
GO

SELECT dbo.GetBorrowerAge(1, '2001-07-01') AS BorrowerAge;
GO

-- 10
CREATE FUNCTION CountBooksByAuthor
    (@AuthorId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*)
    FROM Books
    WHERE AuthorId = @AuthorId;
    RETURN @Count;
END;
GO

SELECT dbo.CountBooksByAuthor(1) AS BookCount;
GO
