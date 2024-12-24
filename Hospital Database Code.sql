-- Create the database
CREATE DATABASE HospitalDB;
USE HospitalDB;

-- Create tables
CREATE TABLE Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    ExperienceYears INT NOT NULL
);

CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    ContactNumber VARCHAR(15)
);

CREATE TABLE Medications (
    MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255)
);

CREATE TABLE Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME NOT NULL,
    Reason VARCHAR(255),
    CONSTRAINT FK_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT FK_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
);

CREATE TABLE Prescriptions (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT,
    MedicationID INT,
    Dosage VARCHAR(50),
    Duration VARCHAR(50),
    CONSTRAINT FK_Appointment FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE,
    CONSTRAINT FK_Medication FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID) ON DELETE CASCADE
);

-- Sample queries

-- Find busiest doctors and departments
SELECT 
    d.Name AS DoctorName, 
    d.Department, 
    COUNT(a.AppointmentID) AS TotalAppointments
FROM 
    Doctors d
LEFT JOIN 
    Appointments a ON d.DoctorID = a.DoctorID
GROUP BY 
    d.DoctorID, d.Name, d.Department
ORDER BY 
    TotalAppointments DESC;

-- Patient visit history
SELECT 
    p.PatientID, 
    p.Name AS PatientName, 
    a.AppointmentDate, 
    d.Name AS DoctorName, 
    a.Reason
FROM 
    Patients p
LEFT JOIN 
    Appointments a ON p.PatientID = a.PatientID
LEFT JOIN 
    Doctors d ON a.DoctorID = d.DoctorID
ORDER BY 
    p.PatientID, a.AppointmentDate DESC;

-- Detect appointment scheduling conflicts
SELECT 
    a1.AppointmentID AS Appointment1, 
    a2.AppointmentID AS Appointment2, 
    a1.DoctorID, 
    a1.AppointmentDate
FROM 
    Appointments a1
JOIN 
    Appointments a2 
    ON a1.DoctorID = a2.DoctorID AND a1.AppointmentDate = a2.AppointmentDate AND a1.AppointmentID < a2.AppointmentID;

-- Analyze medication usage
SELECT 
    m.Name AS MedicationName, 
    COUNT(p.PrescriptionID) AS TotalPrescriptions
FROM 
    Medications m
LEFT JOIN 
    Prescriptions p ON m.MedicationID = p.MedicationID
GROUP BY 
    m.MedicationID, m.Name
ORDER BY 
    TotalPrescriptions DESC;

-- Patient demographics analysis
SELECT 
    Gender, 
    COUNT(PatientID) AS TotalPatients
FROM 
    Patients
GROUP BY 
    Gender;

-- Transaction management example
BEGIN;
-- Insert a new doctor
INSERT INTO Doctors (Name, Department, ExperienceYears) VALUES ('Dr. Smith', 'Cardiology', 10);
-- Insert a new patient
INSERT INTO Patients (Name, DOB, Gender, ContactNumber) VALUES ('John Doe', '1990-01-01', 'Male', '1234567890');
COMMIT;
