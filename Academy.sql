CREATE DATABASE Academy;

USE Academy;
GO

DROP TABLE IF EXISTS Groups
CREATE TABLE Groups
(
    Id INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(10) NOT NULL UNIQUE,
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    [Year] INT NOT NULL CHECK (Year BETWEEN 1 AND 5)
);
GO

DROP TABLE IF EXISTS Departments
CREATE TABLE Departments
(
    Id INT IDENTITY PRIMARY KEY,
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    [Name] NVARCHAR(100) NOT NULL UNIQUE
);
GO

DROP TABLE IF EXISTS Faculties
CREATE TABLE Faculties
(
    Id INT IDENTITY PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL UNIQUE
);
GO

DROP TABLE IF EXISTS Teachers
CREATE TABLE Teachers
(
    Id INT IDENTITY PRIMARY KEY,
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    [Name] NVARCHAR(MAX) NOT NULL,
    Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL
);
GO

INSERT INTO Groups
    ([Name], Rating, [Year])
VALUES
    ('Group1', 4, 1),
    ('Group2', 5, 2),
    ('Group3', 3, 3),
    ('Group4', 2, 4),
    ('Group5', 4, 5);

INSERT INTO Departments
    (Financing, [Name])
VALUES
    (150000.00, 'Department of Computer Sciences'),
    (120000.00, 'Department of Mathematics'),
    (100000.00, 'Department of Physics'),
    (80000.00, 'Departments of Chemisty');

INSERT INTO Faculties
    ([Name])
VALUES
    ('Faculty of Computer Sciences'),
    ('Faculty of Mathematics'),
    ('Faculty of Science');

INSERT INTO Teachers
    (EmploymentDate, [Name], Premium, Salary, Surname)
VALUES
    ('2023-01-15', 'John', 500, 25000, 'Doe'),
    ('2020-09-01', 'John', 700, 30000, 'Joe'),
    ('2023-03-10', 'John', 300, 22000, 'Boe'),
    ('2019-05-20', 'John', 600, 28000, 'Foe');

SELECT *
FROM Groups

SELECT *
FROM Departments

SELECT *
FROM Faculties

SELECT *
FROM Teachers
