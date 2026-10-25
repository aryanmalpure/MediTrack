-- =============================================================================
-- MediTrack – Patient Health Records
-- File 01: DDL & Database Constraints Definition
-- Database Name: clinical_patient_db
-- Storage Engine: InnoDB (Full ACID & Referential Integrity Support)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS clinical_patient_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinical_patient_db;

-- -----------------------------------------------------------------------------
-- 1. Patients Table (Parent Table)
-- Stores master demographic and contact details for registered patients.
-- Constraints:
--  - PRIMARY KEY: patient_id (AUTO_INCREMENT)
--  - UNIQUE: phone, email
--  - NOT NULL: name, date_of_birth, gender
--  - CHECK (chk_patient_gender): limits gender values to 'Male', 'Female', 'Other'
--  - CHECK (chk_patient_blood_group): limits blood group to standard ABO/Rh types
--  - Future-date validation for date_of_birth is enforced via BEFORE INSERT/UPDATE triggers
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    blood_group VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_patient_gender CHECK (gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT chk_patient_blood_group CHECK (blood_group IS NULL OR blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 2. Clinicians Table (Parent Table)
-- Stores healthcare providers and their medical specializations.
-- Constraints:
--  - PRIMARY KEY: clinician_id (AUTO_INCREMENT)
--  - UNIQUE: phone, email
--  - NOT NULL: name, specialization
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Clinicians (
    clinician_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 3. Encounters Table (Dependent Table)
-- Records consultations between a patient and a clinician.
-- Constraints:
--  - PRIMARY KEY: encounter_id (AUTO_INCREMENT)
--  - FOREIGN KEY: patient_id -> Patients(patient_id) (ON DELETE RESTRICT, ON UPDATE CASCADE)
--  - FOREIGN KEY: clinician_id -> Clinicians(clinician_id) (ON DELETE RESTRICT, ON UPDATE CASCADE)
--  - NOT NULL: patient_id, clinician_id, encounter_date, diagnosis
--  - CHECK: diagnosis must contain non-whitespace characters
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Encounters (
    encounter_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    clinician_id INT NOT NULL,
    encounter_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptoms TEXT,
    diagnosis VARCHAR(255) NOT NULL,
    treatment_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_encounters_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_encounters_clinician FOREIGN KEY (clinician_id) 
        REFERENCES Clinicians(clinician_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_encounter_diagnosis CHECK (CHAR_LENGTH(TRIM(diagnosis)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 4. Allergies Table (Dependent Table)
-- Tracks identified allergens, reactions, and severity levels per patient.
-- Constraints:
--  - PRIMARY KEY: allergy_id (AUTO_INCREMENT)
--  - FOREIGN KEY: patient_id -> Patients(patient_id) (ON DELETE RESTRICT, ON UPDATE CASCADE)
--  - CHECK (chk_allergy_severity): allows only 'Mild', 'Moderate', 'Severe'
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Allergies (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    allergen VARCHAR(100) NOT NULL,
    reaction VARCHAR(150),
    severity VARCHAR(20) NOT NULL,
    CONSTRAINT fk_allergies_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_allergy_severity CHECK (severity IN ('Mild', 'Moderate', 'Severe'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 5. Medical_History Table (Dependent Table)
-- Retains diagnosed past/chronic conditions and clinical status.
-- Constraints:
--  - PRIMARY KEY: history_id (AUTO_INCREMENT)
--  - FOREIGN KEY: patient_id -> Patients(patient_id) (ON DELETE RESTRICT, ON UPDATE CASCADE)
--  - CHECK (chk_history_status): allows 'Active', 'Resolved', 'Chronic'
--  - Future-date validation for diagnosis_date is enforced via BEFORE INSERT/UPDATE triggers
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Medical_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    condition_name VARCHAR(150) NOT NULL,
    diagnosis_date DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Active',
    notes TEXT,
    CONSTRAINT fk_history_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_history_status CHECK (status IN ('Active', 'Resolved', 'Chronic'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 6. Medications Table (Dependent Table)
-- Prescribed active and past pharmacotherapy regimens for patients.
-- Constraints:
--  - PRIMARY KEY: medication_id (AUTO_INCREMENT)
--  - FOREIGN KEY: patient_id -> Patients(patient_id) (ON DELETE RESTRICT, ON UPDATE CASCADE)
--  - CHECK (chk_medication_dates): end_date must be on or after start_date
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_medications_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_medication_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 7. Encounter_Audit Table (Audit Table)
-- Captures data audit log events generated by triggers for encounter modifications.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Encounter_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    encounter_id INT NOT NULL,
    patient_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    old_diagnosis VARCHAR(255),
    new_diagnosis VARCHAR(255),
    old_treatment_notes TEXT,
    new_treatment_notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) DEFAULT (CURRENT_USER()),
    CONSTRAINT chk_audit_action CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 8. Future-Date Validation Triggers (Deterministic validation replacing CURDATE in CHECK)
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_patients_validate_dob_insert;
DROP TRIGGER IF EXISTS trg_patients_validate_dob_update;
DROP TRIGGER IF EXISTS trg_med_history_validate_date_insert;
DROP TRIGGER IF EXISTS trg_med_history_validate_date_update;

DELIMITER //

-- Validates that patient date of birth is not in the future on INSERT
CREATE TRIGGER trg_patients_validate_dob_insert
BEFORE INSERT ON Patients
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Patient date of birth cannot be in the future.';
    END IF;
END //

-- Validates that patient date of birth is not in the future on UPDATE
CREATE TRIGGER trg_patients_validate_dob_update
BEFORE UPDATE ON Patients
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Patient date of birth cannot be in the future.';
    END IF;
END //

-- Validates that medical history diagnosis date is not in the future on INSERT
CREATE TRIGGER trg_med_history_validate_date_insert
BEFORE INSERT ON Medical_History
FOR EACH ROW
BEGIN
    IF NEW.diagnosis_date IS NOT NULL AND NEW.diagnosis_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Medical history diagnosis date cannot be in the future.';
    END IF;
END //

-- Validates that medical history diagnosis date is not in the future on UPDATE
CREATE TRIGGER trg_med_history_validate_date_update
BEFORE UPDATE ON Medical_History
FOR EACH ROW
BEGIN
    IF NEW.diagnosis_date IS NOT NULL AND NEW.diagnosis_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Medical history diagnosis date cannot be in the future.';
    END IF;
END //

DELIMITER ;
