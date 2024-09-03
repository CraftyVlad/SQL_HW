-- Я користувався RAISERROR для деяких завдань

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

INSERT INTO Books
    (Title, Genre, AuthorId)
VALUES
    ('1984', 'Dystopian', 1),
    ('Norwegian Wood', 'Romance', 2),
    ('One Hundred Years of Solitude', 'Magical Realism', 3),
    ('Animal Farm', 'Political Satire', 1);

INSERT INTO Borrowers
    (Name, BorrowDate, ReturnDate, BorrowedBookId)
VALUES
    ('Alice Johnson', '2024-08-01', '2024-08-15', 1),
    ('Bob Williams', '2024-08-03', NULL, 2),
    ('Charlie Brown', '2024-08-10', '2024-08-20', 3),
    ('Diana Prince', '2024-08-12', NULL, 4);

SELECT *
FROM Authors
SELECT *
FROM Books
SELECT *
FROM Borrowers

-- 1
CREATE TABLE AuthorLogs
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    AuthorId INT,
    Name NVARCHAR(100),
    Country NVARCHAR(50)
);
GO

CREATE TRIGGER NewAuthorLog
ON Authors
AFTER INSERT
AS
BEGIN
    INSERT INTO AuthorLogs
        (AuthorId, Name, Country)
    SELECT Id, Name, Country
    FROM inserted;
END;

INSERT INTO Authors
    (Name, Country)
VALUES
    ('J.K. Rowling', 'United Kingdom');

SELECT *
FROM AuthorLogs
GO

-- 2
CREATE TABLE BookChangeLogs
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    BookId INT,
    OldTitle NVARCHAR(100),
    OldGenre NVARCHAR(50),
    ChangeDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER LogBookChanges
ON Books
AFTER UPDATE
AS
BEGIN
    INSERT INTO BookChangeLogs
        (BookId, OldTitle, OldGenre)
    SELECT Id, Title, Genre
    FROM deleted;
END;

UPDATE Books
SET Title = '1984 Revised', Genre = 'Dystopian Fiction'
WHERE Id = 1;

SELECT *
FROM BookChangeLogs;
GO

-- 3
CREATE TRIGGER CheckAuthorExists
ON Books
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT *
    FROM inserted
    WHERE AuthorId IS NOT NULL
        AND AuthorId NOT IN (SELECT Id
        FROM Authors)
    )
    BEGIN
        RAISERROR ('Author does not exist.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Books
            (Title, Genre, AuthorId)
        SELECT Title, Genre, AuthorId
        FROM inserted;
    END
END;

INSERT INTO Books
    (Title, Genre, AuthorId)
VALUES
    ('Nonexistent Author Book', 'Fiction', 999);
GO

-- 4
CREATE TRIGGER PreventAuthorDeletion
ON Authors
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT *
    FROM deleted d
    WHERE d.Id IN (SELECT AuthorId
    FROM Books)
    )
    BEGIN
        RAISERROR ('Cannot delete author with associated books.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Authors
        WHERE Id IN (SELECT Id
        FROM deleted);
    END
END;

DELETE FROM Authors
WHERE Id = 1;
GO

-- 5
CREATE TRIGGER SetReturnDate
ON Borrowers
AFTER UPDATE
AS
BEGIN
    UPDATE Borrowers
    SET ReturnDate = DATEADD(DAY, 14, BorrowDate)
    WHERE ReturnDate IS NULL AND Id IN (SELECT Id
        FROM inserted);
END;

UPDATE Borrowers
SET ReturnDate = NULL
WHERE Id = 2;

SELECT *
FROM Borrowers
WHERE Id = 2;
GO

-- 6
CREATE TABLE BorrowerLogs
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    BorrowerId INT,
    Name NVARCHAR(100),
    BorrowedBookId INT,
    DeletionDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TRIGGER LogBorrowerDeletion
ON Borrowers
AFTER DELETE
AS
BEGIN
    INSERT INTO BorrowerLogs
        (BorrowerId, Name, BorrowedBookId)
    SELECT Id, Name, BorrowedBookId
    FROM deleted;
END;

DELETE FROM Borrowers
WHERE Id = 1;

SELECT *
FROM BorrowerLogs;
GO

-- 7
CREATE TRIGGER CheckGenreBeforeUpdate
ON Books
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT *
    FROM inserted
    WHERE Genre = 'Banned'
    )
    BEGIN
        RAISERROR ('Cannot update book genre to a banned genre.', 16, 1);
    END
    ELSE
    BEGIN
        UPDATE Books
        SET Title = i.Title, Genre = i.Genre, AuthorId = i.AuthorId
        FROM inserted i
        WHERE Books.Id = i.Id;
    END
END;

UPDATE Books
SET Genre = 'Banned'
WHERE Id = 2;
GO

-- 8
CREATE TRIGGER PreventDuplicateTitles
ON Books
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT i.Title
    FROM inserted i JOIN Books b ON i.Title = b.Title AND i.Id <> b.Id)
    BEGIN
        RAISERROR ('Title duplication detected. Update aborted.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE Books
    SET Title = i.Title, Genre = i.Genre, AuthorId = i.AuthorId
    FROM inserted i
    WHERE Books.Id = i.Id;
END;

UPDATE Books
SET Title = 'Animal Farm'
WHERE Id = 3;
GO

-- 9
CREATE TRIGGER PreventBookDeletionOnLoan
ON Books
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT *
    FROM deleted d
    WHERE d.Id IN (SELECT BorrowedBookId
    FROM Borrowers
    WHERE ReturnDate IS NULL)
    )
    BEGIN
        RAISERROR ('Cannot delete book that is currently on loan.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Books
        WHERE Id IN (SELECT Id
        FROM deleted);
    END
END;

DELETE FROM Books
WHERE Id = 2;
GO

-- 10
CREATE TRIGGER InsertOrUpdateBook
ON Books
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT *
    FROM inserted i
    WHERE i.AuthorId NOT IN (SELECT Id
    FROM Authors)
    )
    BEGIN
        RAISERROR ('Cannot insert or update book because the specified AuthorId does not exist.', 16, 1);
    END
    ELSE
    BEGIN
        IF EXISTS (
            SELECT *
        FROM inserted i
        WHERE i.Title IN (SELECT Title
        FROM Books)
        )
        BEGIN
            UPDATE Books
            SET Genre = i.Genre, AuthorId = i.AuthorId
            FROM inserted i
            WHERE Books.Title = i.Title;
        END
        ELSE
        BEGIN
            INSERT INTO Books
                (Title, Genre, AuthorId)
            SELECT Title, Genre, AuthorId
            FROM inserted;
        END
    END
END;

INSERT INTO Books
    (Title, Genre, AuthorId)
VALUES
    ('1984', 'Science Fiction', 1);

    SELECT *
FROM Books
WHERE Title = '1984';
