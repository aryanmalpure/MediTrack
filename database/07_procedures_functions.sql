-- =============================================================================
-- MediTrack – Patient Health Records
-- File 07: Stored Procedures & Stored Functions
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

DROP PROCEDURE IF EXISTS sp_register_encounter;
DROP PROCEDURE IF EXISTS sp_get_patient_history;
DROP PROCEDURE IF EXISTS sp_update_medication;
DROP FUNCTION IF EXISTS fn_patient_encounter_count;

DELIMITER //

-- =============================================================================
-- 1. STORED PROCEDURE: sp_register_encounter
-- Validates:
--  - Patient existence
--  - Clinician existence
--  - Diagnosis not blank
--  - Encounter date not in the future
-- Inserts record and outputs newly generated encounter_id
-- =============================================================================
CREATE PROCEDURE sp_register_encounter(
    IN p_patient_id INT,
    IN p_clinician_id INT,
    IN p_encounter_date DATETIME,
    IN p_symptoms TEXT,
    IN p_diagnosis VARCHAR(255),
    IN p_treatment_notes TEXT,
    OUT p_new_encounter_id INT
)
BEGIN
    DECLARE v_patient_exists INT DEFAULT 0;
    DECLARE v_clinician_exists INT DEFAULT 0;
    DECLARE v_final_date DATETIME;

    -- Validate Patient
    SELECT COUNT(*) INTO v_patient_exists FROM Patients WHERE patient_id = p_patient_id;
    IF v_patient_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Encounter Registration Rejected: Specified Patient ID does not exist.';
    END IF;

    -- Validate Clinician
    SELECT COUNT(*) INTO v_clinician_exists FROM Clinicians WHERE clinician_id = p_clinician_id;
    IF v_clinician_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Encounter Registration Rejected: Specified Clinician ID does not exist.';
    END IF;

    -- Validate Diagnosis non-empty
    IF p_diagnosis IS NULL OR CHAR_LENGTH(TRIM(p_diagnosis)) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Encounter Registration Rejected: Diagnosis cannot be empty.';
    END IF;

    -- Set date defaults or validate not in future
    IF p_encounter_date IS NULL THEN
        SET v_final_date = NOW();
    ELSE
        IF p_encounter_date > NOW() THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Encounter Registration Rejected: Encounter date cannot be set in the future.';
        END IF;
        SET v_final_date = p_encounter_date;
    END IF;

    -- Insert encounter
    INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
    VALUES (p_patient_id, p_clinician_id, v_final_date, p_symptoms, TRIM(p_diagnosis), p_treatment_notes);

    SET p_new_encounter_id = LAST_INSERT_ID();

END //


-- =============================================================================
-- 2. STORED PROCEDURE: sp_get_patient_history
-- Retrieves full chronological clinical encounter history for a verified patient.
-- =============================================================================
CREATE PROCEDURE sp_get_patient_history(
    IN p_patient_id INT
)
BEGIN
    DECLARE v_patient_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_patient_exists FROM Patients WHERE patient_id = p_patient_id;
    IF v_patient_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'History Lookup Failed: Patient ID does not exist.';
    END IF;

    SELECT 
        e.encounter_id,
        e.encounter_date,
        c.name AS attending_clinician,
        c.specialization,
        e.symptoms,
        e.diagnosis,
        e.treatment_notes
    FROM Encounters e
    INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
    WHERE e.patient_id = p_patient_id
    ORDER BY e.encounter_date DESC;

END //


-- =============================================================================
-- 3. STORED PROCEDURE: sp_update_medication
-- Updates medication dosage, end date, and instructions with domain validation.
-- =============================================================================
CREATE PROCEDURE sp_update_medication(
    IN p_medication_id INT,
    IN p_dosage VARCHAR(50),
    IN p_end_date DATE,
    IN p_instructions TEXT
)
BEGIN
    DECLARE v_med_exists INT DEFAULT 0;
    DECLARE v_start_date DATE;

    SELECT COUNT(*), MAX(start_date) INTO v_med_exists, v_start_date 
    FROM Medications 
    WHERE medication_id = p_medication_id;

    IF v_med_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medication Update Failed: Medication ID not found.';
    END IF;

    IF p_end_date IS NOT NULL AND p_end_date < v_start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medication Update Failed: End date cannot precede original start date.';
    END IF;

    UPDATE Medications
    SET dosage = IFNULL(p_dosage, dosage),
        end_date = p_end_date,
        instructions = IFNULL(p_instructions, instructions)
    WHERE medication_id = p_medication_id;

END //


-- =============================================================================
-- 4. STORED FUNCTION: fn_patient_encounter_count
-- Returns the total number of clinical consultations recorded for a given patient.
-- Deterministic read-only function for use in SQL queries and projections.
-- =============================================================================
CREATE FUNCTION fn_patient_encounter_count(
    p_patient_id INT
) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM Encounters
    WHERE patient_id = p_patient_id;

    RETURN v_count;
END //

DELIMITER ;


-- =============================================================================
-- VERIFICATION & TEST CALLS (Run after loading 11_sample_data.sql)
-- =============================================================================

-- 1. Test sp_register_encounter (Valid Case):
-- CALL sp_register_encounter(
--     1, 
--     2, 
--     NOW(), 
--     'Mild seasonal allergy and nasal congestion', 
--     'Allergic Rhinitis - Seasonal', 
--     'Cetirizine 10mg OD for 10 days', 
--     @created_enc_id
-- );
-- SELECT @created_enc_id AS Newly_Registered_Encounter_ID;

-- 2. Test sp_register_encounter (Invalid Case - Non-existent patient):
-- CALL sp_register_encounter(9999, 1, NOW(), 'Symptoms', 'Diagnosis', 'Notes', @fail_id);
-- Returns: ERROR 1644 (45000): Encounter Registration Rejected: Specified Patient ID does not exist.

-- 3. Test sp_get_patient_history:
-- CALL sp_get_patient_history(1);

-- 4. Test Stored Function fn_patient_encounter_count in standard SELECT:
-- SELECT 
--     patient_id, 
--     name, 
--     fn_patient_encounter_count(patient_id) AS total_encounters_via_function
-- FROM Patients;
