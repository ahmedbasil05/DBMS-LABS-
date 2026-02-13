DROP DATABASE IF EXISTS medixcare_db;
CREATE DATABASE medixcare_db;
USE medixcare_db;
CREATE TABLE Patients (
 PatientID INT PRIMARY KEY,
 FirstName VARCHAR(50),
 LastName VARCHAR(50),
 DOB DATE,
 Phone VARCHAR(20)
);
CREATE TABLE Doctors (
 DoctorID INT PRIMARY KEY,
 FullName VARCHAR(100),
 Specialization VARCHAR(100)
);
CREATE TABLE Appointments (
 ApptID INT PRIMARY KEY,
 PatientID INT,
 DoctorID INT,
 ApptDate DATE,
 Status VARCHAR(20),
 FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
 FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
CREATE TABLE Treatments (
 TreatmentID INT PRIMARY KEY,
 ApptID INT,
 Description VARCHAR(200),
 Cost DECIMAL(10,2),
 FOREIGN KEY (ApptID) REFERENCES Appointments(ApptID)
);
CREATE TABLE Billing (
 BillID INT PRIMARY KEY,
 ApptID INT,
 TotalAmount DECIMAL(10,2),
 PaymentStatus VARCHAR(20),
 FOREIGN KEY (ApptID) REFERENCES Appointments(ApptID)
);
-- --Required for cost-change and delete logging.
CREATE TABLE AuditLogs (
 log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 action_type VARCHAR(50),
 table_name VARCHAR(50),
 record_id BIGINT,
 old_value VARCHAR(255),
 new_value VARCHAR(255),
 change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Used in the “status = completed” trigger.
CREATE TABLE Notifications (
 notification_id BIGINT PRIMARY KEY,
 appointment_id BIGINT,
 message VARCHAR(255),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Used in the “doctor not available” validation trigger.
CREATE TABLE DoctorAvailability (
 doctor_id BIGINT,
 available_date DATE,
 is_available TINYINT(1) DEFAULT 1,
 PRIMARY KEY (doctor_id, available_date)
);
-- Used in the “inactive patient archiving” scheduled event.
CREATE TABLE PatientsArchive (
patient_id BIGINT PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 dob DATE,
 phone VARCHAR(20),
 archived_on DATETIME
);
INSERT INTO Patients VALUES
(1,'Ali','Khan','1998-04-12','0300123456'),
(2,'Sara','Malik','2000-10-05','0300654321');
INSERT INTO Doctors VALUES
(10,'Dr. Hamid Ali','Cardiology'),
(20,'Dr. Ayesha Siddiq','Dermatology');
-- Insert sample values
INSERT INTO DoctorAvailability (doctor_id, available_date,
is_available) VALUES
(1, '2025-03-20', 1),
(1, '2025-03-21', 1),
(1, '2025-03-22', 0), -- unavailable day
(2, '2025-03-20', 1),
(2, '2025-03-21', 0), -- unavailable day
(3, '2025-03-20', 1),
(3, '2025-03-21', 1);
-- Insert a very old patient:
INSERT INTO Patients (patient_id, first_name, last_name, dob, phone)
VALUES (999, 'Old', 'Patient', '1980-01-01', '0300-0000000');
-- Add an old appointment:
INSERT INTO Appointments (appointment_id, patient_id, doctor_id,
appointment_date, status)
VALUES (9991, 999, 1, '2021-01-10', 'Completed');
