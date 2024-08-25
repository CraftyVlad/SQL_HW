USE master;
DROP DATABASE task;

CREATE DATABASE task;
USE task;

DROP TABLE IF EXISTS Curators;
DROP TABLE IF EXISTS Faculties;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS GroupsCurators;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Lectures;
DROP TABLE IF EXISTS GroupsLectures;

CREATE TABLE Curators
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(MAX) NOT NULL CHECK (LEN([Name]) > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0)
);

CREATE TABLE Faculties
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    [Name] NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN([Name]) > 0)
);

CREATE TABLE Departments
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    [Name] NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN([Name]) > 0),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Groups
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(10) NOT NULL UNIQUE CHECK (LEN([Name]) > 0),
    [Year] INT NOT NULL CHECK ([Year] BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Subjects
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100) NOT NULL UNIQUE CHECK (LEN([Name]) > 0)
);

CREATE TABLE Teachers
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(MAX) NOT NULL CHECK (LEN([Name]) > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (LEN(Surname) > 0),
    Salary MONEY NOT NULL CHECK (Salary > 0)
);

CREATE TABLE Lectures
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LEN(LectureRoom) > 0),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

INSERT INTO Curators
    ([Name], Surname)
VALUES
    ('Alice', 'Smith'),
    ('Bob', 'Johnson'),
    ('Carol', 'Williams');

INSERT INTO Faculties
    (Financing, [Name])
VALUES
    (100000, 'Science'),
    (120000, 'Engineering'),
    (50000, 'Computer Science');

INSERT INTO Departments
    (Financing, [Name], FacultyId)
VALUES
    (50000, 'Computer Science', 3),
    (600000, 'Mathematics', 2),
    (55000, 'Physics', 2);

INSERT INTO Groups
    ([Name], [Year], DepartmentId)
VALUES
    ('P101', 1, 1),
    ('P102', 2, 1),
    ('P103', 3, 2),
    ('P104', 4, 2),
    ('P105', 5, 1),
    ('P106', 5, 2),
    ('P107', 3, 3);

INSERT INTO GroupsCurators
    (CuratorId, GroupId)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (3, 5),
    (2, 6),
    (1, 7);

INSERT INTO Subjects
    ([Name])
VALUES
    ('Database Theory'),
    ('Linear Algebra'),
    ('Quantum Mechanics');

INSERT INTO Teachers
    ([Name], Surname, Salary)
VALUES
    ('John', 'Doe', 5000),
    ('Samantha', 'Adams', 6000),
    ('Michael', 'Brown', 5500);

INSERT INTO Lectures
    (LectureRoom, SubjectId, TeacherId)
VALUES
    ('A101', 1, 1),
    ('A102', 2, 2),
    ('A103', 3, 3),
    ('A104', 1, 2),
    ('B103', 2, 1),
    ('C101', 3, 3),
    ('B103', 1, 2);

INSERT INTO GroupsLectures
    (GroupId, LectureId)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7);

-- 1
SELECT
    T.[Name],
    T.Surname,
    G.[Name] AS GroupName
FROM
    Teachers T, Groups G;

-- 2
SELECT F.[Name]
FROM Faculties F
    JOIN Departments D ON F.Id = D.FacultyId
WHERE D.Financing > F.Financing;

-- 3
SELECT C.Surname, G.[Name] AS GroupName
FROM Curators C
    JOIN GroupsCurators GC ON C.Id = GC.CuratorId
    JOIN Groups G ON GC.GroupId = G.Id;

-- 4
SELECT T.[Name], T.Surname
FROM Teachers T
    JOIN Lectures L ON T.Id = L.TeacherId
    JOIN GroupsLectures GL ON L.Id = GL.LectureId
    JOIN Groups G ON GL.GroupId = G.Id
WHERE G.[Name] = 'P107';

-- 5
SELECT T.Surname, F.[Name] AS FacultyName
FROM Teachers T
    JOIN Lectures L ON T.Id = L.TeacherId
    JOIN GroupsLectures GL ON L.Id = GL.LectureId
    JOIN Groups G ON GL.GroupId = G.Id
    JOIN Departments D ON G.DepartmentId = D.Id
    JOIN Faculties F ON D.FacultyId = F.Id;

-- 6
SELECT D.[Name] AS DepartmentName, G.[Name] AS GroupName
FROM Departments D
    JOIN Groups G ON D.Id = G.DepartmentId;

-- 7
SELECT S.[Name] AS SubjectName
FROM Subjects S
    JOIN Lectures L ON S.Id = L.SubjectId
    JOIN Teachers T ON L.TeacherId = T.Id
WHERE T.[Name] = 'Samantha' AND T.Surname = 'Adams';

-- 8
SELECT D.[Name]
FROM Departments D
    JOIN Groups G ON D.Id = G.DepartmentId
    JOIN GroupsLectures GL ON G.Id = GL.GroupId
    JOIN Lectures L ON GL.LectureId = L.Id
    JOIN Subjects S ON L.SubjectId = S.Id
WHERE S.[Name] = 'Database Theory';

-- 9
SELECT G.[Name]
FROM Groups G
    JOIN Departments D ON G.DepartmentId = D.Id
    JOIN Faculties F ON D.FacultyId = F.Id
WHERE F.[Name] = 'Computer Science';

-- 10
SELECT G.[Name] AS GroupName, F.[Name] AS FacultyName
FROM Groups G
    JOIN Departments D ON G.DepartmentId = D.Id
    JOIN Faculties F ON D.FacultyId = F.Id
WHERE G.[Year] = 5;

-- 11
SELECT T.[Name], T.Surname, S.[Name] AS SubjectName, G.[Name] AS GroupName
FROM Teachers T
    JOIN Lectures L ON T.Id = L.TeacherId
    JOIN Subjects S ON L.SubjectId = S.Id
    JOIN GroupsLectures GL ON L.Id = GL.LectureId
    JOIN Groups G ON GL.GroupId = G.Id
WHERE L.LectureRoom = 'B103';
