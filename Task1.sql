DROP TABLE IF EXISTS Faculties
CREATE TABLE Faculties
(
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Dean NVARCHAR(100) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS Departments
CREATE TABLE Departments
(
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    [Name] NVARCHAR(100) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS Teachers
CREATE TABLE Teachers
(
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    IsAssistant BIT NOT NULL DEFAULT 0,
    IsProfessor BIT NOT NULL DEFAULT 0,
    [Name] NVARCHAR(100) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS Groups
CREATE TABLE Groups
(
    Id INT IDENTITY PRIMARY KEY NOT NULL,
    [Name] NVARCHAR(10) NOT NULL UNIQUE,
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    [Year] INT NOT NULL CHECK ([Year] BETWEEN 1 AND 5)
);

INSERT INTO Faculties
    (Dean, Name)
VALUES
    ('Dr. Alice Smith', 'Faculty of Science'),
    ('Dr. Bob Johnson', 'Faculty of Arts'),
    ('Dr. Carol Williams', 'Faculty of Engineering'),
    ('Dr. David Brown', 'Faculty of Medicine');

INSERT INTO Departments
    (Financing, Name)
VALUES
    (150000, 'Software Development'),
    (120000, 'Mathematics'),
    (100000, 'Physics'),
    (90000, 'Chemistry'),
    (110000, 'Biology');

INSERT INTO Teachers
    (EmploymentDate, IsAssistant, IsProfessor, Name, Position, Premium, Salary, Surname)
VALUES
    ('2010-09-01', 1, 0, 'John', 'Lecturer', 2000, 30000, 'Doe'),
    ('2015-03-15', 0, 1, 'Jane', 'Professor', 5000, 60000, 'Smith'),
    ('2018-01-10', 1, 0, 'Emily', 'Assistant', 500, 25000, 'Johnson'),
    ('1992-05-20', 0, 1, 'Michael', 'Associate Professor', 4000, 55000, 'Williams'),
    ('2012-11-11', 0, 0, 'Sarah', 'Senior Lecturer', 3000, 45000, 'Brown');

INSERT INTO Groups
    (Name, Rating, Year)
VALUES
    ('CS', 5, 1),
    ('MATH', 4, 2),
    ('PHY', 3, 3),
    ('CHEM', 4, 4),
    ('BIO', 5, 5);

-- 1
SELECT Financing, [Name]
FROM Departments;

-- 2
SELECT [Name] AS "Group Name", Rating AS "Group Rating"
FROM Groups;

-- 3
SELECT Surname,
    (Premium / Salary) * 100 AS BonusPercentage,
    (Salary / (Salary + Premium)) * 100 AS SalaryPercentage
FROM Teachers;

-- 4
SELECT 'The dean of faculty ' + Name + ' is ' + Dean + '.' AS FacultyInfo
FROM Faculties;

-- 5
SELECT Surname
FROM Teachers
WHERE Position = 'Professor' AND Salary > 1050;

-- 6
SELECT Name
FROM Departments
WHERE Financing < 11000 OR Financing > 25000;

-- 7
SELECT Name
FROM Faculties
WHERE Name != 'Computer Science';

-- 8
SELECT Surname, Position
FROM Teachers
WHERE Position != 'Professor';

-- 9
SELECT Surname, Position, Salary, Premium
FROM Teachers
WHERE Position = 'Assistant' AND Premium BETWEEN 160 AND 550;

-- 10
SELECT Surname, Salary
FROM Teachers
WHERE IsAssistant = 1;

-- 11

SELECT Surname, Position
FROM Teachers
WHERE EmploymentDate < '2000-01-01';

-- 12
SELECT Name AS "Name of Department"
FROM Departments
WHERE Name < 'Software Development'
ORDER BY Name;

-- 13
SELECT Surname
FROM Teachers
WHERE Position = 'Assistant' AND (Salary + Premium) <= 1200;

-- 14
SELECT Name
FROM Groups
WHERE Year = 5 AND Rating BETWEEN 2 AND 4;

-- 15
SELECT Surname
FROM Teachers
WHERE Position = 'Assistant' AND (Salary < 550 OR Premium < 200);
