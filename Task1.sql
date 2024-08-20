CREATE DATABASE _UniversityDB;
GO

USE _UniversityDB;
GO

DROP TABLE IF EXISTS Courses
CREATE TABLE Courses
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Credits INT NOT NULL,
    Instructor NVARCHAR(100)
);

DROP TABLE IF EXISTS Students
CREATE TABLE Students
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    EnrollmentDate DATE NOT NULL,
    Grade CHAR(2),

    CourseId INT,
    FOREIGN KEY (CourseId) REFERENCES Courses(Id)
);

INSERT INTO Courses
    (Name, Credits, Instructor)
VALUES
    ('Mathematics', 4, 'Dr. Alan Smith'),
    ('Physics', 3, 'Dr. Barbara White'),
    ('Literature', 2, 'Prof. Charles Green'),
    ('Computer Science', 5, 'Dr. Emily Jones'),
    ('Chemistry', 3, 'Dr. Frank Harris'),
    ('History', 2, 'Prof. George Martin'),
    ('Biology', 4, 'Dr. Helen Clark'),
    ('Philosophy', 3, 'Prof. Ian Turner');

INSERT INTO Students
    (Name, DateOfBirth, EnrollmentDate, Grade, CourseId)
VALUES
    ('Alice Johnson', '2000-05-14', '2024-08-16', 'A', 1),
    -- Mathematics
    ('Bob Williams', '1999-11-22', '2024-08-16', 'B', 1),
    -- Mathematics
    ('Charlie Brown', '2001-02-10', '2024-08-16', 'A', 2),
    -- Physics
    ('Diana Prince', '2000-07-09', '2024-08-16', 'B', 2),
    -- Physics
    ('Eva Adams', '1998-09-05', '2024-08-16', 'A', 3),
    -- Literature
    ('Frank Miller', '1997-04-12', '2024-08-16', 'B+', 4),
    -- Computer Science
    ('Grace Kelly', '2001-08-23', '2024-08-16', 'A', 4),
    -- Computer Science
    ('Henry Ford', '1999-12-15', '2024-08-16', 'B', 5),
    -- Chemistry
    ('Ivy Green', '2002-01-29', '2024-08-16', 'A', 6),
    -- Chemistry
    ('Jack Black', '2000-03-17', '2024-08-16', 'A-', 6),
    -- History
    ('Kara White', '2001-05-25', '2024-08-16', 'B+', 6),
    -- History
    ('Liam Brown', '1998-11-30', '2024-08-16', 'A', 7),
    -- Biology
    ('Mia Green', '1999-02-28', '2024-08-16', 'B', 7),
    -- Biology
    ('Noah Blue', '2002-06-06', '2024-08-16', 'A', 8),
    -- Philosophy
    ('Olivia Black', '2000-10-18', '2024-08-16', 'B+', 8);  -- Philosophy
GO

-- 1
SELECT
    c.Name AS CourseName,
    COUNT(s.Id) AS StudentCount
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
GROUP BY 
    c.Name;

-- 2
SELECT
    SUM(c.Credits) AS TotalCredits
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id;

-- 3
SELECT
    c.Name AS CourseName,
    AVG(CASE 
        WHEN s.Grade = 'A' THEN 4
        WHEN s.Grade = 'B+' THEN 3.5
        WHEN s.Grade = 'B' THEN 3
        WHEN s.Grade = 'A-' THEN 3.7
        ELSE 0 
    END) AS AverageGrade
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
GROUP BY 
    c.Name;

-- 4
SELECT
    c.Name AS CourseName,
    COUNT(s.Id) AS StudentCount
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
GROUP BY 
    c.Name
HAVING 
    COUNT(s.Id) > 2;

-- 5
SELECT
    c.Name AS CourseName,
    AVG(CASE 
        WHEN s.Grade = 'A' THEN 4
        WHEN s.Grade = 'B+' THEN 3.5
        WHEN s.Grade = 'B' THEN 3
        WHEN s.Grade = 'A-' THEN 3.7
        ELSE 0 
    END) AS AverageGrade
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
GROUP BY 
    c.Name
HAVING 
    AVG(CASE 
        WHEN s.Grade = 'A' THEN 4
        WHEN s.Grade = 'B+' THEN 3.5
        WHEN s.Grade = 'B' THEN 3
        WHEN s.Grade = 'A-' THEN 3.7
        ELSE 0 
    END) > 3.0;

-- 6
SELECT
    c.Name AS CourseName,
    COUNT(s.Id) AS StudentCount
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
GROUP BY 
    ROLLUP(c.Name);

-- 7
SELECT
    s.Name AS StudentName,
    c.Name AS CourseName,
    c.Credits
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
WHERE 
    c.Credits > (SELECT AVG(Credits)
FROM Courses);

-- 8
UPDATE 
    Students
SET 
    Grade = 'A'
FROM
    Students s
    JOIN
    Courses c ON s.CourseId = c.Id
WHERE 
    c.Credits > 3;

-- 9
DELETE 
    FROM Students
WHERE 
    CourseId IN (SELECT Id
FROM Courses
WHERE Instructor = 'Dr. Alan Smith');

-- 10
SELECT
    Name
FROM
    Students
WHERE 
    UPPER(Name) = Name;

-- 11
SELECT
    Name AS CourseName,
    ROUND(Credits, 0) AS RoundedCredits
FROM
    Courses;

-- 12
SELECT Name, FORMAT(EnrollmentDate, 'yyyy-MM-dd') AS EnrollmentDateFormatted
FROM Students;

-- 13
SELECT
    Name,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
FROM
    Students;
