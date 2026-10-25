-- =============================================================================
-- MediTrack – Patient Health Records
-- DBMS Practical Concepts & Advanced SQL Demonstrations
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- 1. BASIC CRUD OPERATIONS (Insert, Select, Update, Delete)
-- =============================================================================

-- 1.1 INSERT: Register a new patient
INSERT INTO Patients (name, date_of_birth, gender, phone, address, blood_group)
VALUES ('David Miller', '1988-12-04', 'Male', '9898989898', '14 Oak Street, Uptown', 'O+');

-- 1.2 SELECT: Retrieve all patients sorted by name
SELECT patient_id, name, date_of_birth, gender, phone, blood_group 
FROM Patients 
ORDER BY name ASC;

-- 1.3 UPDATE: Modify phone number and address of a patient
UPDATE Patients 
SET phone = '9998887776', address = '250 Highlands Way, Uptown' 
WHERE patient_id = 6;

-- 1.4 DELETE: Delete a patient record with no linked encounters/allergies
DELETE FROM Patients 
WHERE patient_id = 6;


-- =============================================================================
-- 2. JOINS (INNER JOIN and LEFT JOIN)
-- =============================================================================

-- 2.1 INNER JOIN: Get encounter details with matching patient and clinician details
SELECT 
    e.encounter_id,
    p.name AS patient_name,
    p.blood_group,
    c.name AS clinician_name,
    c.specialization,
    e.encounter_date,
    e.diagnosis,
    e.treatment_notes
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id
INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
ORDER BY e.encounter_date DESC;

-- 2.2 LEFT JOIN: List all patients and any encounters they have had.
-- Patients with 0 encounters will show NULL for encounter fields (e.g. Lucas Gray).
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.phone,
    e.encounter_id,
    e.encounter_date,
    e.diagnosis
FROM Patients p
LEFT JOIN Encounters e ON p.patient_id = e.patient_id
ORDER BY p.patient_id ASC;


-- =============================================================================
-- 3. GROUP BY AND AGGREGATE FUNCTIONS
-- =============================================================================

-- 3.1 Count the number of clinical encounters handled by each clinician
SELECT 
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization,
    COUNT(e.encounter_id) AS total_encounters_handled
FROM Clinicians c
LEFT JOIN Encounters e ON c.clinician_id = e.clinician_id
GROUP BY c.clinician_id, c.name, c.specialization
ORDER BY total_encounters_handled DESC;

-- 3.2 Distribution of registered patients by Blood Group
SELECT 
    blood_group,
    COUNT(*) AS patient_count
FROM Patients
GROUP BY blood_group
ORDER BY patient_count DESC;

-- 3.3 Find patients who have had more than 1 clinical encounter (HAVING clause)
SELECT 
    p.patient_id,
    p.name,
    COUNT(e.encounter_id) AS encounter_count
FROM Patients p
INNER JOIN Encounters e ON p.patient_id = e.patient_id
GROUP BY p.patient_id, p.name
HAVING COUNT(e.encounter_id) > 1;


-- =============================================================================
-- 4. SUBQUERIES
-- =============================================================================

-- 4.1 Subquery with NOT IN: Find patients who have never had any clinical encounter
SELECT patient_id, name, phone, blood_group
FROM Patients
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id 
    FROM Encounters
);

-- 4.2 Subquery in WHERE: Find all encounters attended by clinicians in Cardiology
SELECT encounter_id, patient_id, encounter_date, diagnosis
FROM Encounters
WHERE clinician_id IN (
    SELECT clinician_id 
    FROM Clinicians 
    WHERE specialization = 'Cardiology'
);


-- =============================================================================
-- 5. DATABASE VIEW
-- =============================================================================

-- View combining Patient, Clinician, and Encounter details for simplified reporting
CREATE OR REPLACE VIEW view_patient_encounters AS
SELECT 
    e.encounter_id,
    p.patient_id,
    p.name AS patient_name,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS patient_age,
    p.gender,
    p.blood_group,
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization AS clinician_specialization,
    e.encounter_date,
    e.symptoms,
    e.diagnosis,
    e.treatment_notes
FROM Encounters e
JOIN Patients p ON e.patient_id = p.patient_id
JOIN Clinicians c ON e.clinician_id = c.clinician_id;

-- Querying the View:
SELECT * FROM view_patient_encounters WHERE patient_id = 1;


-- =============================================================================
-- 6. STORED PROCEDURE
-- =============================================================================

-- Stored procedure to retrieve chronological encounter history for a given patient
DROP PROCEDURE IF EXISTS GetPatientEncounterHistory;

DELIMITER //

CREATE PROCEDURE GetPatientEncounterHistory(IN p_patient_id INT)
BEGIN
    SELECT 
        e.encounter_id,
        e.encounter_date,
        c.name AS clinician_name,
        c.specialization,
        e.symptoms,
        e.diagnosis,
        e.treatment_notes
    FROM Encounters e
    INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
    WHERE e.patient_id = p_patient_id
    ORDER BY e.encounter_date DESC;
END //

DELIMITER ;

-- Test Procedure execution:
-- CALL GetPatientEncounterHistory(1);


-- =============================================================================
-- 7. DATABASE TRIGGER (Audit Trail)
-- =============================================================================

-- Trigger that fires AFTER an UPDATE on the Encounters table, recording changes into Encounter_Audit
DROP TRIGGER IF EXISTS trg_after_encounter_update;

DELIMITER //

CREATE TRIGGER trg_after_encounter_update
AFTER UPDATE ON Encounters
FOR EACH ROW
BEGIN
    INSERT INTO Encounter_Audit (
        encounter_id, 
        patient_id, 
        action_type, 
        old_diagnosis, 
        new_diagnosis, 
        old_treatment_notes,
        new_treatment_notes
    )
    VALUES (
        OLD.encounter_id, 
        OLD.patient_id, 
        'UPDATE', 
        OLD.diagnosis, 
        NEW.diagnosis, 
        OLD.treatment_notes,
        NEW.treatment_notes
    );
END //

DELIMITER ;

-- Test the Trigger:
-- UPDATE Encounters SET diagnosis = 'Stage 1 Hypertension' WHERE encounter_id = 1;
-- SELECT * FROM Encounter_Audit;


-- =============================================================================
-- 8. COMPOSITE INDEX
-- =============================================================================

-- Note: Created in schema.sql, explicitly shown here for syllabus demonstration.
-- A composite index optimizes searches filtering by patient_id and sorting by encounter_date.
-- CREATE INDEX idx_encounters_patient_date ON Encounters (patient_id, encounter_date);


-- =============================================================================
-- 9. TRANSACTION EXAMPLE (COMMIT & ROLLBACK)
-- =============================================================================

-- Scenario A: Successful Encounter Record (COMMIT)
START TRANSACTION;

INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
VALUES (1, 2, NOW(), 'Mild seasonal sneezing', 'Allergic Rhinitis', 'Prescribed Cetirizine 10mg OD');

-- Verify record before committing:
SELECT * FROM Encounters WHERE patient_id = 1 ORDER BY encounter_id DESC LIMIT 1;

COMMIT;

-- Scenario B: Simulated Error and Reversal (ROLLBACK)
START TRANSACTION;

INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
VALUES (2, 3, NOW(), 'Fever test', 'Temporary Diagnosis', 'Notes to rollback');

-- An issue or validation error occurs; discard changes:
ROLLBACK;


-- =============================================================================
-- 10. QUERY OPTIMIZATION WITH EXPLAIN
-- =============================================================================

-- Demonstrating EXPLAIN on the Encounters table utilizing composite index idx_encounters_patient_date
EXPLAIN 
SELECT encounter_id, encounter_date, diagnosis 
FROM Encounters 
WHERE patient_id = 1 AND encounter_date >= '2024-01-01'
ORDER BY encounter_date DESC;
