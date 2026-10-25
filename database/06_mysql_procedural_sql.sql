-- =============================================================================
-- MediTrack – Patient Health Records
-- File 06: MySQL Procedural SQL (Control Flow, Loops, Handlers & Signals)
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

DROP PROCEDURE IF EXISTS sp_analyze_patient_clinical_risk;
DROP PROCEDURE IF EXISTS sp_demonstrate_loop_and_control_flow;

DELIMITER //

-- =============================================================================
-- PROCEDURE 1: sp_analyze_patient_clinical_risk
-- Demonstrates:
--  - Parameters (IN, OUT)
--  - Local variable DECLARE and SET
--  - SELECT ... INTO
--  - IF / ELSEIF / ELSE
--  - CASE statement
--  - Exception handling with DECLARE ... HANDLER FOR SQLEXCEPTION
--  - SIGNAL SQLSTATE '45000' with descriptive error messages
-- =============================================================================
CREATE PROCEDURE sp_analyze_patient_clinical_risk(
    IN p_patient_id INT,
    OUT p_risk_tier VARCHAR(20),
    OUT p_evaluation_summary TEXT
)
proc_label: BEGIN
    -- Local variable declarations
    DECLARE v_patient_exists INT DEFAULT 0;
    DECLARE v_age INT DEFAULT 0;
    DECLARE v_encounter_count INT DEFAULT 0;
    DECLARE v_severe_allergy_count INT DEFAULT 0;
    DECLARE v_chronic_conditions_count INT DEFAULT 0;
    DECLARE v_score INT DEFAULT 0;

    -- Generic SQLEXCEPTION handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_risk_tier = 'ERROR';
        SET p_evaluation_summary = 'An unexpected database error occurred during clinical risk evaluation.';
        RESIGNAL;
    END;

    -- Validate patient existence
    SELECT COUNT(*) INTO v_patient_exists 
    FROM Patients 
    WHERE patient_id = p_patient_id;

    IF v_patient_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Risk Evaluation Failed: Patient ID does not exist in the system.';
    END IF;

    -- Compute patient age using SELECT ... INTO
    SELECT TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())
    INTO v_age
    FROM Patients
    WHERE patient_id = p_patient_id;

    -- Compute encounter frequency
    SELECT COUNT(*) 
    INTO v_encounter_count
    FROM Encounters
    WHERE patient_id = p_patient_id;

    -- Compute severe allergies count
    SELECT COUNT(*) 
    INTO v_severe_allergy_count
    FROM Allergies
    WHERE patient_id = p_patient_id AND severity = 'Severe';

    -- Compute chronic medical history count
    SELECT COUNT(*) 
    INTO v_chronic_conditions_count
    FROM Medical_History
    WHERE patient_id = p_patient_id AND status = 'Chronic';

    -- Conditional business rules (IF / ELSEIF / ELSE)
    IF v_age > 65 THEN
        SET v_score = v_score + 3;
    ELSEIF v_age BETWEEN 50 AND 65 THEN
        SET v_score = v_score + 2;
    ELSE
        SET v_score = v_score + 1;
    END IF;

    IF v_severe_allergy_count > 0 THEN
        SET v_score = v_score + (v_severe_allergy_count * 3);
    END IF;

    IF v_chronic_conditions_count > 0 THEN
        SET v_score = v_score + (v_chronic_conditions_count * 2);
    END IF;

    -- Multi-branch evaluation using CASE
    SET p_risk_tier = CASE 
        WHEN v_score >= 8 THEN 'HIGH_RISK'
        WHEN v_score BETWEEN 5 AND 7 THEN 'MODERATE_RISK'
        ELSE 'LOW_RISK'
    END;

    -- Format comprehensive summary string
    SET p_evaluation_summary = CONCAT(
        'Evaluation complete for Patient ID #', p_patient_id, 
        '. Age: ', v_age, 
        ', Consultations: ', v_encounter_count, 
        ', Severe Allergies: ', v_severe_allergy_count, 
        ', Chronic Conditions: ', v_chronic_conditions_count, 
        ', Calculated Risk Score: ', v_score, 
        ', Assigned Tier: ', p_risk_tier
    );

END //


-- =============================================================================
-- PROCEDURE 2: sp_demonstrate_loop_and_control_flow
-- Demonstrates:
--  - WHILE loop
--  - REPEAT ... UNTIL loop
--  - LOOP with LEAVE and ITERATE
-- =============================================================================
CREATE PROCEDURE sp_demonstrate_loop_and_control_flow(
    IN p_max_iterations INT,
    OUT p_odd_sum INT,
    OUT p_even_sum INT
)
BEGIN
    DECLARE v_counter INT DEFAULT 1;
    DECLARE v_even_counter INT DEFAULT 2;

    SET p_odd_sum = 0;
    SET p_even_sum = 0;

    -- 1. LOOP demonstration with LEAVE (exit) and ITERATE (continue)
    odd_loop: LOOP
        IF v_counter > p_max_iterations THEN
            LEAVE odd_loop;
        END IF;

        IF v_counter % 2 = 0 THEN
            SET v_counter = v_counter + 1;
            ITERATE odd_loop;
        END IF;

        SET p_odd_sum = p_odd_sum + v_counter;
        SET v_counter = v_counter + 1;
    END LOOP odd_loop;

    -- 2. WHILE loop demonstration
    WHILE v_even_counter <= p_max_iterations DO
        SET p_even_sum = p_even_sum + v_even_counter;
        SET v_even_counter = v_even_counter + 2;
    END WHILE;

END //

DELIMITER ;

-- =============================================================================
-- VERIFICATION & EXECUTION EXAMPLES (Run after loading 11_sample_data.sql)
-- =============================================================================

-- Test Procedure 1 with valid patient (Patient ID = 1):
-- CALL sp_analyze_patient_clinical_risk(1, @tier, @summary);
-- SELECT @tier AS Risk_Tier, @summary AS Risk_Summary;

-- Test Procedure 1 with non-existent patient (Patient ID = 9999) demonstrating SIGNAL error:
-- CALL sp_analyze_patient_clinical_risk(9999, @tier, @summary);

-- Test Procedure 2 demonstrating Loop, LEAVE, ITERATE, and WHILE:
-- CALL sp_demonstrate_loop_and_control_flow(10, @odd_sum, @even_sum);
-- SELECT @odd_sum AS Sum_Of_Odds_1_to_10, @even_sum AS Sum_Of_Evens_1_to_10;
