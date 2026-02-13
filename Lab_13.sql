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

-- Task 01
DELIMITER $$
CREATE TRIGGER ValidateTreatmentCost
BEFORE INSERT ON Treatments
FOR EACH ROW
BEGIN
 IF NEW.cost < 0 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Treatment cost cannot be negative.';
 END IF;
END $$
DELIMITER ;

-- Task 02
DELIMITER $$
CREATE TRIGGER LogAppointmentInsert
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
 INSERT INTO AuditLogs(action_type, table_name, record_id,
new_value)
 VALUES ('INSERT', 'Appointments', NEW.appointment_id, NEW.status);
END $$
DELIMITER ;

-- Task 03
DELIMITER $$
CREATE TRIGGER PreventCompletedUpdate
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
 IF OLD.status = 'Completed' THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Cannot modify a completed
appointment.';
 END IF;
END $$
DELIMITER ;

-- Task 04
DELIMITER $$
CREATE TRIGGER LogStatusUpdate
AFTER UPDATE ON Appointments
FOR EACH ROW
BEGIN
 IF OLD.status <> NEW.status THEN
 INSERT INTO AuditLogs(action_type, table_name, record_id,
old_value, new_value)
 VALUES ('UPDATE', 'Appointments', NEW.appointment_id,
OLD.status, NEW.status);
 END IF;
END $$
DELIMITER ;

-- Task 05
DELIMITER $$
CREATE TRIGGER BlockDoctorDelete
BEFORE DELETE ON Doctors
FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Doctors cannot be deleted due to
dependency.';
END $$
DELIMITER ;

-- Task 06
DELIMITER $$
CREATE TRIGGER LogTreatmentDelete
AFTER DELETE ON Treatments
FOR EACH ROW
BEGIN
 INSERT INTO AuditLogs(action_type, table_name, record_id,
old_value)
 VALUES ('DELETE', 'Treatments', OLD.treatment_id,
OLD.description);
END $$
DELIMITER ;


-- Task 07
DELIMITER $$
CREATE TRIGGER SetDefaultStatus
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
 IF NEW.status IS NULL THEN
 SET NEW.status = 'Pending';
 END IF;
END $$
DELIMITER ;

-- Task 08
CREATE EVENT IF NOT EXISTS CleanCancelledAppointments
ON SCHEDULE EVERY 1 DAY
DO
 DELETE FROM Appointments
 WHERE status = 'Cancelled'
 AND appointment_date < CURDATE() - INTERVAL 30 DAY;


-- Task 09
CREATE TABLE IF NOT EXISTS DailyRevenue (
 report_date DATE PRIMARY KEY,
 total_revenue DECIMAL(10,2)
);
CREATE EVENT IF NOT EXISTS DailyRevenueReport
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO DailyRevenue(report_date, total_revenue)
 SELECT CURDATE(), SUM(cost) FROM Treatments;

-- Task 10
SET GLOBAL event_scheduler = OFF;
SET GLOBAL event_scheduler = ON;

-- Chalenge Tasks

-- Task 1
DELIMITER $$

CREATE TRIGGER AutoBillingAfterTreatment
AFTER INSERT ON Treatments
FOR EACH ROW
BEGIN
    -- Insert automatic billing entry
    INSERT INTO Billing (BillID, ApptID, TotalAmount, PaymentStatus)
    VALUES (
        NEW.TreatmentID,      -- Use TreatmentID as BillID (or you can auto-increment if needed)
        NEW.ApptID,           -- Appointment associated with the treatment
        NEW.Cost,             -- Billing amount equal to treatment cost
        'Pending'             -- Default payment status
    );
END $$

DELIMITER ;

-- Task 2
DELIMITER $$

CREATE TRIGGER LogTreatmentCostChange
BEFORE UPDATE ON Treatments
FOR EACH ROW
BEGIN
    -- Only log when cost is changed
    IF OLD.Cost <> NEW.Cost THEN
        INSERT INTO AuditLogs(action_type, table_name, record_id, old_value, new_value)
        VALUES (
            'COST UPDATE',
            'Treatments',
            OLD.TreatmentID,
            CONCAT('Old Cost: ', OLD.Cost),
            CONCAT('New Cost: ', NEW.Cost)
        );
    END IF;
END $$

DELIMITER ;

-- Task 3
DELIMITER $$

CREATE EVENT IF NOT EXISTS ArchiveInactivePatients
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    -- Insert into archive first
    INSERT INTO PatientsArchive (patient_id, first_name, last_name, dob, phone, archived_on)
    SELECT P.PatientID, P.FirstName, P.LastName, P.DOB, P.Phone, NOW()
    FROM Patients P
    LEFT JOIN Appointments A ON P.PatientID = A.PatientID
    WHERE (A.ApptDate IS NULL OR A.ApptDate < CURDATE() - INTERVAL 2 YEAR);

    -- Then delete from Patients
    DELETE FROM Patients
    WHERE PatientID IN (
        SELECT P.PatientID
        FROM Patients P
        LEFT JOIN Appointments A ON P.PatientID = A.PatientID
        WHERE (A.ApptDate IS NULL OR A.ApptDate < CURDATE() - INTERVAL 2 YEAR)
    );
END $$

DELIMITER ;


-- Task 4
DELIMITER $$

CREATE TRIGGER EnforceDoctorAvailability
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    DECLARE available_status INT;

    -- Check availability from DoctorAvailability table
    SELECT is_available
    INTO available_status
    FROM DoctorAvailability
    WHERE doctor_id = NEW.DoctorID
      AND available_date = NEW.ApptDate
    LIMIT 1;

    -- Case 1: No availability record found
    IF available_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No availability record for this doctor on this date.';
    END IF;

    -- Case 2: Doctor is marked unavailable
    IF available_status = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Doctor is unavailable on the selected date.';
    END IF;

END $$

DELIMITER ;

-- Task 5
DELIMITER $$

CREATE TRIGGER NotifyOnCompletion
AFTER UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Only trigger when status changes to 'Completed'
    IF OLD.Status <> 'Completed' AND NEW.Status = 'Completed' THEN
        INSERT INTO Notifications (notification_id, appointment_id, message)
        VALUES (
            NEW.ApptID,                        -- Use ApptID as notification ID (you may auto-increment if needed)
            NEW.ApptID,                        -- Appointment reference
            CONCAT('Appointment ', NEW.ApptID, ' has been marked as Completed.')
        );
    END IF;
END $$

DELIMITER ;


