
CREATE DATABASE Lab_Enrollment;
USE Lab_Enrollment;

-- 1) Departments
CREATE TABLE Departments (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50),
    Building VARCHAR(50),
    Phone VARCHAR(20)
);

-- 2) Students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

-- 3) Courses
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100),
    CreditHours INT,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

-- 4) Semesters
CREATE TABLE Semesters (
    SemesterID INT PRIMARY KEY,
    Season VARCHAR(20),
    Sem_Year INT,
    StartDate DATE
);

-- 5) Enrollments
CREATE TABLE Enrollments (
    EnrollID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    SemesterID INT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID)
);

-- Departments
INSERT INTO Departments (DeptID, DeptName, Building, Phone) VALUES
(1, 'CP', 'Ground Floor', '111-1000'),
(2, 'IT', 'First Floor', '111-2000'),
(3,'CS', 'Main Block', '111-3000');

-- Students
INSERT INTO Students (StudentID, StudentName, Email, DeptID) VALUES
(07, 'Ahmed', 'ahmed@uni.edu', 1),
(51, 'Qureshi', 'qureshi@uni.edu', 2),
(99,'Basil','basil@uni.edu',3);

-- Courses
INSERT INTO Courses (CourseID, CourseName, CreditHours, DeptID) VALUES
(01, 'Database Management System', 3, 1),
(02, 'Web Development', 3, 2),
(03,'App Develpoment',2,3);

-- Semesters
INSERT INTO Semesters (SemesterID, Season, Sem_Year, StartDate) VALUES
(1, 'Fall', 2024, '2024-08-01'),
(2, 'Spring', 2025, '2025-01-10');

-- Enrollments
INSERT INTO Enrollments (EnrollID, StudentID, CourseID, SemesterID) VALUES
(1, 99, 03, 1),
(2, 51, 02, 1),
(3, 07, 01, 2);

-- QUERIES
-- 1) Show Students and Courses
SELECT * FROM Students;
SELECT * FROM Courses;

-- 2) Courses offered by CS (filtering)
SELECT * FROM Courses
WHERE DeptID = 3;

-- 3) Students with their Department names
SELECT s.StudentName, d.DeptName
FROM Students s
JOIN Departments d ON s.DeptID = d.DeptID;

-- 4) All enrollment with sudents and courses
SELECT s.StudentName, c.CourseName
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID;

-- 5) Student enrolled in Database
SELECT s.StudentName
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
WHERE e.CourseID = 01;

-- 6) Count students in each Courses
SELECT CourseID, COUNT(*) AS TotalEnrolled
FROM Enrollments
GROUP BY CourseID;

-- 7) Courses taken in Fall semester
SELECT c.CourseName
FROM Enrollments e
JOIN Courses c ON e.CourseID = c.CourseID
WHERE e.SemesterID = 1;

-- INDEXES 
CREATE INDEX idx_student_dept ON Students(DeptID);
CREATE INDEX idx_course_dept ON Courses(DeptID);
CREATE INDEX idx_enroll_student ON Enrollments(StudentID);
CREATE INDEX idx_enroll_course ON Enrollments(CourseID);
CREATE INDEX idx_enroll_semester ON Enrollments(SemesterID);

EXPLAIN SELECT s.StudentName, d.DeptName
FROM Students s
JOIN Departments d ON s.DeptID = d.DeptID;


-- VIEWS 
-- Student Enrollment Overview
CREATE VIEW V_StudentEnrollment AS
SELECT s.StudentName AS Student, c.CourseName AS Course, sem.Season AS Semester
FROM Enrollments e
JOIN Students s ON e.StudentID = s.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Semesters sem ON e.SemesterID = sem.SemesterID;

-- Department wise Courses
CREATE VIEW V_DepartmentCourses AS
SELECT d.DeptName, c.CourseName
FROM Departments d
JOIN Courses c ON d.DeptID = c.DeptID;

SELECT * FROM V_DepartmentCourses;

EXPLAIN ANALYZE
SELECT s.StudentName, d.DeptName
FROM Students s
JOIN Departments d ON s.DeptID = d.DeptID;








