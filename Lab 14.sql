-- Guided Tasks

-- Task 01 - Creating the Hospital Database
CREATE DATABASE hospital_db;
USE hospital_db;

-- Task 02 - Creating Core Tables
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    disease VARCHAR(100),
    admission_date DATE
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    amount DECIMAL(10,2),
    bill_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Task 03 - Inserting Sample Data
INSERT INTO patients (name, disease, admission_date) VALUES
('Ali Khan', 'Diabetes', '2024-03-01'),
('Sara Ahmed', 'Asthma', '2024-03-05');

INSERT INTO doctors (name, specialization) VALUES
('Dr. Aslam', 'Cardiology'),
('Dr. Fatima', 'Pulmonology');

INSERT INTO appointments (patient_id, doctor_id, appointment_date) VALUES
(1, 1, '2024-03-10'),
(2, 2, '2024-03-12');

INSERT INTO billing (patient_id, amount, bill_date) VALUES
(1, 15000, '2024-03-11'),
(2, 12000, '2024-03-13');

-- Task 04 - Verifying Database Content
SHOW TABLES;

SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM appointments;
SELECT * FROM billing;

-- Task 05 - Creating Full Database Backup (CMD)
-- mysqldump -u root -p hospital_db > hospital_db_full_backup.sql

-- Task 06 - Inspecting Backup File
-- notepad hospital_db_full_backup.sql

-- Task 07 - Simulating Partial Data Loss
DELETE FROM appointments;
DELETE FROM billing;

-- Task 08 - Restoring database
-- mysql -u root -p hospital_db < hospital_db_full_backup.sql

-- Task 09 - Verifying successful recovery
SELECT * FROM appointments;
SELECT * FROM billing;

-- Task 10 - Checking Binary Logging
SHOW VARIABLES LIKE 'log_bin';
SHOW BINARY LOGS;

-- Task 11 - Point-in-Time Recovery
-- Uses full backup + binary logs
  -- Restores database to exact time
  -- Critical for hospitals & finance systems
  
-- Challenge Tasks

-- Task 01
CREATE DATABASE hospital_partial_db;
USE hospital_partial_db;
SHOW TABLES;
SELECT * FROM patients;
SELECT * FROM doctors;

-- Task 02
USE hospital_db;

INSERT INTO appointments (patient_id, doctor_id, appointment_date)
VALUES (1, 1, '2024-03-20');

INSERT INTO billing (patient_id, amount, bill_date)
VALUES (1, 18000, '2024-03-21');

SELECT * FROM appointments;
SELECT * FROM billing;

-- Task 03
-- Step 1: Restore full backup
-- Restore the last full backup taken before 3:15 PM.
-- Step 2: Use Binary Logs
-- Binary logs store all changes with timestamps
-- Apply logs only up to 3:14 PM

-- Task 04 and Task 05
-- In report as they are theoratical






  











