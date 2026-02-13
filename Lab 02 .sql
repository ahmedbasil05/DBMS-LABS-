CREATE TABLE `Students` (
  `student_id` int PRIMARY KEY,
  `name` varchar(50),
  `dob` date,
  `email` varchar(50),
  `program` varchar(50)
);

CREATE TABLE `Instructor` (
  `instructor_id` int PRIMARY KEY,
  `name` varchar(50)
);

CREATE TABLE `Courses` (
  `course_id` int PRIMARY KEY,
  `course_name` varchar(50)
);

CREATE TABLE `Enrollments` (
  `student_id` int,
  `course_id` int,
  `instructor_id` int,
  `session` varchar(4),
  `departments` varchar(50),
  PRIMARY KEY (`student_id`, `instructor_id`, `course_id`)
);

ALTER TABLE `Enrollments` ADD FOREIGN KEY (`student_id`) REFERENCES `Students` (`student_id`);

ALTER TABLE `Enrollments` ADD FOREIGN KEY (`course_id`) REFERENCES `Courses` (`course_id`);

ALTER TABLE `Enrollments` ADD FOREIGN KEY (`instructor_id`) REFERENCES `Instructor` (`instructor_id`);
