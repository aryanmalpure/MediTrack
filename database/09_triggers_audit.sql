-- =============================================================================
-- MediTrack – Patient Health Records
-- File 09: Database Triggers & Audit Logging
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- -----------------------------------------------------------------------------
-- Ensure Encounter_Audit Table Exists with Complete Tracking Fields
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

DROP TRIGGER IF EXISTS trg_after_encounter_insert;
DROP TRIGGER IF EXISTS trg_after_encounter_update;
DROP TRIGGER IF EXISTS trg_after_encounter_delete;

DELIMITER //

-- =============================================================================
-- 1. TRIGGER: trg_after_encounter_insert
-- Fires AFTER an INSERT operation on Encounters table.
-- Logs the newly registered encounter into the audit trail.
-- =============================================================================
CREATE TRIGGER trg_after_encounter_insert
AFTER INSERT ON Encounters
FOR EACH ROW
BEGIN
    INSERT INTO Encounter_Audit (
        encounter_id,
        patient_id,
        action_type,
        old_diagnosis,
        new_diagnosis,
        old_treatment_notes,
        new_treatment_notes,
        changed_at,
        changed_by
    )
    VALUES (
        NEW.encounter_id,
        NEW.patient_id,
        'INSERT',
        NULL,
        NEW.diagnosis,
        NULL,
        NEW.treatment_notes,
        NOW(),
        CURRENT_USER()
    );
END //


-- =============================================================================
-- 2. TRIGGER: trg_after_encounter_update
-- Fires AFTER an UPDATE operation on Encounters table.
-- Captures previous vs modified diagnosis and treatment notes.
-- =============================================================================
CREATE TRIGGER trg_after_encounter_update
AFTER UPDATE ON Encounters
FOR EACH ROW
BEGIN
    -- Only write audit log if clinically significant data was changed
    IF (OLD.diagnosis <> NEW.diagnosis OR 
        IFNULL(OLD.treatment_notes, '') <> IFNULL(NEW.treatment_notes, '')) THEN
        
        INSERT INTO Encounter_Audit (
            encounter_id,
            patient_id,
            action_type,
            old_diagnosis,
            new_diagnosis,
            old_treatment_notes,
            new_treatment_notes,
            changed_at,
            changed_by
        )
        VALUES (
            NEW.encounter_id,
            NEW.patient_id,
            'UPDATE',
            OLD.diagnosis,
            NEW.diagnosis,
            OLD.treatment_notes,
            NEW.treatment_notes,
            NOW(),
            CURRENT_USER()
        );
    END IF;
END //


-- =============================================================================
-- 3. TRIGGER: trg_after_encounter_delete
-- Fires AFTER a DELETE operation on Encounters table (if deletion is executed).
-- Preserves audit history of deleted consultation records.
-- =============================================================================
CREATE TRIGGER trg_after_encounter_delete
AFTER DELETE ON Encounters
FOR EACH ROW
BEGIN
    INSERT INTO Encounter_Audit (
        encounter_id,
        patient_id,
        action_type,
        old_diagnosis,
        new_diagnosis,
        old_treatment_notes,
        new_treatment_notes,
        changed_at,
        changed_by
    )
    VALUES (
        OLD.encounter_id,
        OLD.patient_id,
        'DELETE',
        OLD.diagnosis,
        NULL,
        OLD.treatment_notes,
        NULL,
        NOW(),
        CURRENT_USER()
    );
END //

DELIMITER ;


-- =============================================================================
-- VERIFICATION OF TRIGGER BEHAVIOR (Optional Test Steps)
-- =============================================================================

-- Step A: Insert a test encounter (Trigger 1 fires)
-- INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
-- VALUES (1, 1, NOW(), 'Trigger test symptoms', 'Initial Test Diagnosis', 'Initial notes');

-- SET @test_enc_id = LAST_INSERT_ID();

-- Step B: Update the encounter (Trigger 2 fires)
-- UPDATE Encounters 
-- SET diagnosis = 'Updated Confirmed Diagnosis',
--     treatment_notes = 'Revised treatment notes'
-- WHERE encounter_id = @test_enc_id;

-- Step C: Delete the test encounter (Trigger 3 fires)
-- DELETE FROM Encounters 
-- WHERE encounter_id = @test_enc_id;

-- Step D: Query the Audit Log to inspect captured audit lifecycle:
-- SELECT 
--     audit_id,
--     encounter_id,
--     patient_id,
--     action_type,
--     old_diagnosis,
--     new_diagnosis,
--     changed_at,
--     changed_by
-- FROM Encounter_Audit
-- WHERE encounter_id = @test_enc_id
-- ORDER BY audit_id ASC;
