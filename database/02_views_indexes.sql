-- =============================================================================
-- MediTrack – Patient Health Records
-- File 02: Indexing & Database Views
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- 1. INDEX DEFINITIONS
-- =============================================================================

-- 1.1 Index on Patient Name:
-- Speeds up substring and prefix searches filtering by patient name in the UI.
CREATE INDEX idx_patients_name ON Patients(name);

-- 1.2 Index on Encounter Date:
-- Accelerates date-range queries, timeline analytics, and monthly aggregation reports.
CREATE INDEX idx_encounters_date ON Encounters(encounter_date);

-- 1.3 Index on Encounter patient_id:
-- Optimizes foreign key joins and filters retrieving encounters for a specific patient.
CREATE INDEX idx_encounters_patient_id ON Encounters(patient_id);

-- 1.4 Composite Index on patient_id and encounter_date:
-- Enables index-only scans for retrieving a patient's consultations sorted chronologically.
CREATE INDEX idx_encounters_patient_date ON Encounters(patient_id, encounter_date DESC);

-- 1.5 Index on Clinician Foreign Key in Encounters:
-- Supports workload reporting by clinician_id without full table scans.
CREATE INDEX idx_encounters_clinician_id ON Encounters(clinician_id);

-- 1.6 Index on Medications patient_id:
-- Speeds up retrieval of active prescriptions during patient consultation reviews.
CREATE INDEX idx_medications_patient_id ON Medications(patient_id);


-- =============================================================================
-- 2. DATABASE VIEWS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- View 1: vw_patient_summary
-- Provides an aggregated clinical profile for each patient, including computed
-- age, total encounters count, total known allergies count, and active condition count.
-- Limits exposure of sensitive contact addresses to unauthorized analysts.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_patient_summary AS
SELECT 
    p.patient_id,
    p.name AS patient_name,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    p.gender,
    p.blood_group,
    p.phone,
    p.email,
    p.created_at AS registration_date,
    (SELECT COUNT(*) FROM Encounters e WHERE e.patient_id = p.patient_id) AS total_encounters,
    (SELECT COUNT(*) FROM Allergies a WHERE a.patient_id = p.patient_id) AS total_allergies,
    (SELECT COUNT(*) FROM Medical_History mh WHERE mh.patient_id = p.patient_id AND mh.status = 'Active') AS active_conditions_count,
    (SELECT COUNT(*) FROM Medications m WHERE m.patient_id = p.patient_id AND (m.end_date IS NULL OR m.end_date >= CURRENT_DATE)) AS active_prescriptions_count
FROM Patients p;


-- -----------------------------------------------------------------------------
-- View 2: vw_patient_encounter_history
-- Exposes chronological clinical consultation histories joining patient names
-- and clinician credentials while abstracting internal table foreign keys.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_patient_encounter_history AS
SELECT 
    e.encounter_id,
    p.patient_id,
    p.name AS patient_name,
    p.gender,
    p.blood_group,
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization,
    e.encounter_date,
    e.diagnosis,
    e.symptoms,
    e.treatment_notes
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id
INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id;
