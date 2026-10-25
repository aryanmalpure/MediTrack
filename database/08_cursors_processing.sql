-- =============================================================================
-- MediTrack – Patient Health Records
-- File 08: Cursors & Batch Processing with Duplicate Prevention
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

DROP PROCEDURE IF EXISTS sp_generate_patient_encounter_brief;
DROP PROCEDURE IF EXISTS sp_safe_register_encounter_with_duplicate_check;

DELIMITER //

-- =============================================================================
-- PROCEDURE 1: sp_generate_patient_encounter_brief (CURSOR DEMONSTRATION)
-- Objective:
--  - Demonstrates an explicit MySQL CURSOR.
--  - Implements DECLARE CONTINUE HANDLER FOR NOT FOUND.
--  - Iterates through individual encounter records one by one.
--  - Formulates an aggregated clinical consultation brief for a given patient.
-- =============================================================================
CREATE PROCEDURE sp_generate_patient_encounter_brief(
    IN p_patient_id INT,
    OUT p_brief_text TEXT
)
BEGIN
    -- Variable declarations for cursor fields
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_encounter_id INT;
    DECLARE v_date DATETIME;
    DECLARE v_clinician_name VARCHAR(100);
    DECLARE v_diagnosis VARCHAR(255);
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_patient_name VARCHAR(100);

    -- Cursor Declaration: Restricted by parameterized patient_id
    DECLARE cur_patient_encounters CURSOR FOR
        SELECT 
            e.encounter_id, 
            e.encounter_date, 
            c.name, 
            e.diagnosis
        FROM Encounters e
        INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
        WHERE e.patient_id = p_patient_id
        ORDER BY e.encounter_date DESC;

    -- Cursor handler for exhausting rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Verify patient name
    SELECT name INTO v_patient_name FROM Patients WHERE patient_id = p_patient_id;

    IF v_patient_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Brief Generation Failed: Invalid Patient ID.';
    END IF;

    SET p_brief_text = CONCAT('=== CLINICAL HISTORY SUMMARY FOR: ', UPPER(v_patient_name), ' (ID #', p_patient_id, ') ===\n');

    -- Open the Cursor
    OPEN cur_patient_encounters;

    -- Fetch and process rows
    read_loop: LOOP
        FETCH cur_patient_encounters INTO v_encounter_id, v_date, v_clinician_name, v_diagnosis;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_counter = v_counter + 1;
        SET p_brief_text = CONCAT(
            p_brief_text, 
            '\n[Visit #', v_counter, ' | Encounter #', v_encounter_id, '] Date: ', 
            DATE_FORMAT(v_date, '%Y-%m-%d %H:%i'), 
            ' | Attending: ', v_clinician_name, 
            ' | Diagnosis: ', v_diagnosis
        );
    END LOOP read_loop;

    -- Close the Cursor to release server resources
    CLOSE cur_patient_encounters;

    IF v_counter = 0 THEN
        SET p_brief_text = CONCAT(p_brief_text, '\n(No clinical consultation records found for this patient)');
    ELSE
        SET p_brief_text = CONCAT(p_brief_text, '\n\nTotal Consultations Processed by Cursor: ', v_counter);
    END IF;

END //


-- =============================================================================
-- PROCEDURE 2: sp_safe_register_encounter_with_duplicate_check
-- Objective:
--  - Demonstrates Duplicate Prevention and Validation.
--  - Prevents registering duplicate encounters for the same patient with the
--    same clinician on the exact same calendar day and time window (1 hour).
-- =============================================================================
CREATE PROCEDURE sp_safe_register_encounter_with_duplicate_check(
    IN p_patient_id INT,
    IN p_clinician_id INT,
    IN p_encounter_date DATETIME,
    IN p_symptoms TEXT,
    IN p_diagnosis VARCHAR(255),
    IN p_treatment_notes TEXT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_duplicate_count INT DEFAULT 0;
    DECLARE v_check_date DATETIME;

    SET v_check_date = IFNULL(p_encounter_date, NOW());

    -- Duplicate detection: Check if an encounter exists within +/- 30 minutes
    SELECT COUNT(*) INTO v_duplicate_count
    FROM Encounters
    WHERE patient_id = p_patient_id
      AND clinician_id = p_clinician_id
      AND encounter_date BETWEEN DATE_SUB(v_check_date, INTERVAL 30 MINUTE) 
                             AND DATE_ADD(v_check_date, INTERVAL 30 MINUTE);

    IF v_duplicate_count > 0 THEN
        SET p_status_message = 'DUPLICATE_REJECTED: An encounter for this patient with this clinician already exists in this time window.';
    ELSE
        INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
        VALUES (p_patient_id, p_clinician_id, v_check_date, p_symptoms, p_diagnosis, p_treatment_notes);

        SET p_status_message = CONCAT('SUCCESS: Encounter registered with ID #', LAST_INSERT_ID());
    END IF;

END //

DELIMITER ;


-- =============================================================================
-- VERIFICATION & TEST CALLS (Run after loading 11_sample_data.sql)
-- =============================================================================

-- 1. Execute Cursor procedure for Patient 1:
-- CALL sp_generate_patient_encounter_brief(1, @report);
-- SELECT @report AS Generated_Cursor_Report;

-- 2. Test Duplicate Prevention:
-- CALL sp_safe_register_encounter_with_duplicate_check(
--     1, 1, '2026-10-25 10:00:00', 'Checkup', 'Routine Hypertension Check', 'Normal', @res1
-- );
-- SELECT @res1 AS First_Attempt;

-- Attempting identical encounter in same 30 min window:
-- CALL sp_safe_register_encounter_with_duplicate_check(
--     1, 1, '2026-10-25 10:10:00', 'Checkup', 'Routine Hypertension Check', 'Normal', @res2
-- );
-- SELECT @res2 AS Duplicate_Attempt_Result;
