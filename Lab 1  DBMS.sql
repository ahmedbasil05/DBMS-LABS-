-- TASK 01 : Installation

-- TASK 02 : Create a Database

CREATE DATABASE college;
USE college;

-- TASK 03 : Create a students table

CREATE TABLE students (
	student_id INT PRIMARY KEY,
    name VARCHAR(50),
    dob DATE,
    program VARCHAR(50)
);

-- TASK 04 : Create a courses and enrollments

CREATE TABLE courses (
	course_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(100),
    credit_hours INT 
);
CREATE TABLE enrollments (
    student_id INT,
    course_id VARCHAR(10),
    semester VARCHAR(10),
    PRIMARY KEY(student_id, course_id),
    FOREIGN KEY(student_id) REFERENCES students(student_id),
    FOREIGN KEY(course_id) REFERENCES courses(course_id)
);

-- TASK 05: Insert sample records

INSERT INTO students VALUES (1, 'Ali Khan', '2000-05-12', 'Computer Engineering');
INSERT INTO students VALUES (2, 'Sara Ahmed', '2001-09-23', 'Software Engineering');

INSERT INTO courses VALUES ('CS101', 'Databases' , 3);
INSERT INTO courses VALUES ('CS102', 'Programming' , 4);

INSERT INTO enrollments VALUES (1, 'CS101', 'FALL2023');
INSERT INTO enrollments VALUES (2, 'CS102', 'FALL2023');

-- TASK 06: Query all students

SELECT * FROM students;

-- TASK 07: Join tables to show enrollments

SELECT s.name, c.title, e.semester
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- TASK 08: View Structure in GUI

DESCRIBE students;

-- TASK 09: Alter Table - add column

ALTER TABLE students ADD email VARCHAR(100);

-- TASK 10: Drop a Column

ALTER TABLE students DROP COLUMN email;

-- Question 01:

ALTER TABLE students ADD email VARCHAR(100) UNIQUE;

-- Question 02:
CREATE TABLE departments (
dept_id VARCHAR(10) PRIMARY KEY,
dept_name VARCHAR(100)
);
ALTER TABLE students
ADD COLUMN dept_id VARCHAR(10),
ADD FOREIGN KEY (dept_id) REFERENCES departments(dept_id); SELECT s.student_id, d.dept_name
FROM students s
JOIN departments d ON s.dept_id = d.dept_id;

-- Question 03:  
 DELETE FROM courses WHERE course_id = "CS101";
 
 -- Question 04:  
UPDATE students
SET program = 'Civil Engineering' WHERE student_id = 1;
SELECT * FROM students;
 
 -- Question 05:
 SELECT program, COUNT(*) AS student_count FROM students
GROUP BY program;

 
   



