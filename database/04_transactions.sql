-- =============================================================================
-- MediTrack – Patient Health Records
-- File 04: TCL (Transaction Control Language) – ACID Transactions & Savepoints
-- Database Name: clinical_patient_db
-- Storage Engine: InnoDB
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- SCENARIO 1: ATOMIC CONSULTATION & PRESCRIPTION TRANSACTION (COMMIT)
-- Objective: Ensure both an encounter record and its associated prescription
--            are committed together. If both succeed, COMMIT makes them permanent.
-- =============================================================================

START TRANSACTION;

-- Step 1: Insert new clinical consultation for Patient 1
INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
VALUES (
    1, 
    2, 
    NOW(), 
    'Recurrent tension headaches with elevated morning blood pressure', 
    'Moderate Hypertension - Followup', 
    'Adjusted antihypertensive therapy. Prescribed Telmisartan 40mg.'
);

-- Capture the auto-generated encounter ID
SET @latest_encounter_id = LAST_INSERT_ID();

-- Step 2: Prescribe the corresponding medication
INSERT INTO Medications (patient_id, medication_name, dosage, start_date, end_date, instructions)
VALUES (
    1, 
    'Telmisartan', 
    '40mg', 
    CURRENT_DATE, 
    DATE_ADD(CURRENT_DATE, INTERVAL 60 DAY), 
    'Take one tablet daily in the morning after breakfast.'
);

-- Verify pending changes within current transaction context:
SELECT * FROM Encounters WHERE encounter_id = @latest_encounter_id;
SELECT * FROM Medications WHERE patient_id = 1 AND medication_name = 'Telmisartan';

-- Permanent persistence:
COMMIT;


-- =============================================================================
-- SCENARIO 2: PARTIAL ERROR RECOVERY WITH SAVEPOINT (SAVEPOINT & ROLLBACK TO)
-- Objective: Demonstrate a transaction where Step 1 (Encounter) is recorded,
--            a SAVEPOINT is created, Step 2 (invalid prescription) fails,
--            the transaction rolls back to the SAVEPOINT, records a valid alternative,
--            and commits without losing the encounter.
-- =============================================================================

START TRANSACTION;

-- Step 1: Record initial consultation
INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
VALUES (
    2, 
    1, 
    NOW(), 
    'Mild palpitations following caffeine intake', 
    'Sinus Tachycardia - Transient', 
    'Advised reduction of caffeinated beverages. Trial of low-dose beta blocker.'
);

SET @enc_id_sp = LAST_INSERT_ID();

-- Establish a transaction savepoint:
SAVEPOINT sv_after_encounter_created;

-- Step 2: Attempt an invalid medication insert (violating chk_medication_dates: end_date < start_date)
-- Note: In a live procedural context or client script, an error handler catches this failure.
-- We demonstrate rolling back the invalid attempt to the savepoint:
ROLLBACK TO SAVEPOINT sv_after_encounter_created;

-- Step 3: Record valid medication with appropriate date range
INSERT INTO Medications (patient_id, medication_name, dosage, start_date, end_date, instructions)
VALUES (
    2, 
    'Metoprolol Tartrate', 
    '25mg', 
    CURRENT_DATE, 
    DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY), 
    'Take half tablet twice daily as required.'
);

-- Commit the verified valid state:
COMMIT;


-- =============================================================================
-- SCENARIO 3: COMPLETE FAILURE REVERSAL (FULL ROLLBACK)
-- Objective: Demonstrate that an entire transaction containing multiple writes
--            is completely rolled back upon detecting an unrecoverable business failure.
-- =============================================================================

START TRANSACTION;

-- Step 1: Create consultation
INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes)
VALUES (
    3, 
    3, 
    NOW(), 
    'Suspected adverse drug interaction', 
    'Adverse Reaction Pending Investigation', 
    'Pending lab test confirmation before final sign-off.'
);

SET @aborted_enc_id = LAST_INSERT_ID();

-- Step 2: Laboratory check reveals misidentified patient ID or duplicate entry
-- Entire transaction is canceled to preserve referential consistency:
ROLLBACK;

-- Verification: The aborted encounter ID must NOT exist in the database:
SELECT COUNT(*) AS should_be_zero FROM Encounters WHERE encounter_id = @aborted_enc_id;
