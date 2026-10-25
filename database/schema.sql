-- =============================================================================
-- MediTrack – Patient Health Records
-- Database Schema Definition Script
-- Database Name: clinical_patient_db
-- =============================================================================

CREATE DATABASE IF NOT EXISTS clinical_patient_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinical_patient_db;

-- -----------------------------------------------------------------------------
-- 1. Patients Table
-- Stores master demographic and contact details for registered patients.
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
    CONSTRAINT chk_legacy_patient_gender CHECK (gender IN ('Male', 'Female', 'Other'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 2. Clinicians Table
-- Stores medical staff information and their respective specializations.
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
-- 3. Encounters Table
-- Records clinical consultations between a patient and a clinician.
-- ON DELETE RESTRICT prevents deleting a patient or clinician if encounters exist.
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
        REFERENCES Clinicians(clinician_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 4. Allergies Table
-- Tracks identified allergies, adverse reactions, and severity per patient.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Allergies (
    allergy_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    allergen VARCHAR(100) NOT NULL,
    reaction VARCHAR(150),
    severity VARCHAR(20) NOT NULL,
    CONSTRAINT fk_allergies_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 5. Medical_History Table
-- Retains past diagnosed conditions and their current clinical status.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Medical_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    condition_name VARCHAR(150) NOT NULL,
    diagnosis_date DATE,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT fk_history_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 6. Medications Table
-- Master reference table for available medications and forms.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE,
    instructions TEXT,
    CONSTRAINT fk_medications_patient FOREIGN KEY (patient_id) 
        REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------------------------
-- 7. Encounter_Audit Table
-- Audit log used by triggers to track updates made to clinical encounter records.
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
    changed_by VARCHAR(100) DEFAULT (CURRENT_USER())
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
