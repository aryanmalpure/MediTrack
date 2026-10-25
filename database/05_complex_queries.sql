-- =============================================================================
-- MediTrack – Patient Health Records
-- File 05: Complex SQL Queries (12 Mandatory Syllabus Demonstrations)
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- QUERY 1: INNER JOIN BETWEEN PATIENTS AND ENCOUNTERS
-- Retrieves consultation encounters along with matching patient demographic details.
-- =============================================================================
SELECT 
    e.encounter_id,
    p.patient_id,
    p.name AS patient_name,
    p.gender,
    p.blood_group,
    e.encounter_date,
    e.diagnosis,
    e.treatment_notes
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id
ORDER BY e.encounter_date DESC;


-- =============================================================================
-- QUERY 2: LEFT JOIN TO SHOW PATIENTS WITH NO ENCOUNTERS
-- Identifies registered patients who have never had any clinical consultations.
-- Patients with zero encounters show NULL for encounter attributes.
-- =============================================================================
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.phone,
    p.email,
    p.created_at AS registration_date,
    e.encounter_id,
    e.encounter_date,
    IFNULL(e.diagnosis, 'NO ENCOUNTERS RECORDED') AS consultation_status
FROM Patients p
LEFT JOIN Encounters e ON p.patient_id = e.patient_id
WHERE e.encounter_id IS NULL
ORDER BY p.patient_id ASC;


-- =============================================================================
-- QUERY 3: MULTIPLE JOINS INVOLVING PATIENTS, CLINICIANS, AND ENCOUNTERS
-- Full relational consultation report showing patient, attending physician, and encounter.
-- =============================================================================
SELECT 
    e.encounter_id,
    p.patient_id,
    p.name AS patient_name,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS patient_age,
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization,
    e.encounter_date,
    e.diagnosis,
    e.treatment_notes
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id
INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
ORDER BY e.encounter_date DESC;


-- =============================================================================
-- QUERY 4: SUBQUERY TO FIND PATIENTS WITH ABOVE-AVERAGE ENCOUNTER COUNTS
-- Identifies high-utilization patients who have more consultations than the
-- average encounters per patient across the entire health network.
-- =============================================================================
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.gender,
    COUNT(e.encounter_id) AS total_patient_encounters
FROM Patients p
INNER JOIN Encounters e ON p.patient_id = e.patient_id
GROUP BY p.patient_id, p.name, p.gender
HAVING COUNT(e.encounter_id) > (
    -- Subquery: Calculates overall average encounters per registered patient
    SELECT COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT patient_id), 0)
    FROM Encounters
)
ORDER BY total_patient_encounters DESC;


-- =============================================================================
-- QUERY 5: UNION TO COMBINE CLINICALLY MONITORED PATIENT GROUPS
-- Combines patients with Severe Allergies with patients suffering from Chronic
-- Medical Conditions into a single high-priority clinical cohort.
-- =============================================================================
SELECT 
    p.patient_id,
    p.name AS patient_name,
    'Severe Allergy Risk' AS clinical_category,
    a.allergen AS detail_description,
    a.severity AS severity_level
FROM Patients p
INNER JOIN Allergies a ON p.patient_id = a.patient_id
WHERE a.severity = 'Severe'

UNION

SELECT 
    p.patient_id,
    p.name AS patient_name,
    'Chronic Medical Condition' AS clinical_category,
    mh.condition_name AS detail_description,
    mh.status AS severity_level
FROM Patients p
INNER JOIN Medical_History mh ON p.patient_id = mh.patient_id
WHERE mh.status = 'Chronic'
ORDER BY patient_id ASC;


-- =============================================================================
-- QUERY 6: GROUP BY AND HAVING TO IDENTIFY CLINICIANS WITH MULTIPLE ENCOUNTERS
-- Filters clinicians who have conducted more than 1 clinical consultation.
-- =============================================================================
SELECT 
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization,
    COUNT(e.encounter_id) AS total_encounters_handled
FROM Clinicians c
INNER JOIN Encounters e ON c.clinician_id = e.clinician_id
GROUP BY c.clinician_id, c.name, c.specialization
HAVING COUNT(e.encounter_id) > 1
ORDER BY total_encounters_handled DESC;


-- =============================================================================
-- QUERY 7: AGGREGATE FUNCTIONS (COUNT, MIN, MAX, AVG)
-- Computes comprehensive statistical distribution of patient demographics.
-- =============================================================================
SELECT 
    COUNT(*) AS total_patients,
    MIN(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS youngest_patient_age,
    MAX(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS oldest_patient_age,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())), 1) AS average_patient_age
FROM Patients;


-- =============================================================================
-- QUERY 8: WINDOW FUNCTIONS (ROW_NUMBER & DENSE_RANK)
-- Ranks consultation encounters chronologically per patient using ROW_NUMBER(),
-- and ranks clinicians by workload using DENSE_RANK().
-- =============================================================================
-- 8.1 Consultation ranking per patient:
SELECT 
    e.encounter_id,
    e.patient_id,
    p.name AS patient_name,
    e.encounter_date,
    e.diagnosis,
    ROW_NUMBER() OVER (
        PARTITION BY e.patient_id 
        ORDER BY e.encounter_date DESC
    ) AS consultation_seq_recent_first
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id;

-- 8.2 Clinician workload ranking:
SELECT 
    c.clinician_id,
    c.name AS clinician_name,
    c.specialization,
    COUNT(e.encounter_id) AS encounter_count,
    DENSE_RANK() OVER (ORDER BY COUNT(e.encounter_id) DESC) AS clinician_workload_rank
FROM Clinicians c
LEFT JOIN Encounters e ON c.clinician_id = e.clinician_id
GROUP BY c.clinician_id, c.name, c.specialization;


-- =============================================================================
-- QUERY 9: RETRIEVE A PATIENT'S COMPLETE ENCOUNTER HISTORY
-- Chronological encounter history for a specific patient ID (e.g. patient_id = 1).
-- =============================================================================
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
WHERE e.patient_id = 1
ORDER BY e.encounter_date DESC;


-- =============================================================================
-- QUERY 10: PATIENTS WITH NO RECORDED ALLERGIES AND NO MEDICAL-HISTORY ENTRIES
-- Finds completely clean-slate patients who have no recorded allergies and no history.
-- =============================================================================
SELECT 
    p.patient_id,
    p.name AS patient_name,
    p.gender,
    p.phone
FROM Patients p
WHERE p.patient_id NOT IN (SELECT DISTINCT patient_id FROM Allergies)
  AND p.patient_id NOT IN (SELECT DISTINCT patient_id FROM Medical_History);


-- =============================================================================
-- QUERY 11: FIND THE MOST RECENT ENCOUNTER FOR EACH PATIENT
-- Uses a correlated subquery / window partition to pinpoint each patient's latest visit.
-- =============================================================================
WITH RankedEncounters AS (
    SELECT 
        e.encounter_id,
        e.patient_id,
        p.name AS patient_name,
        c.name AS clinician_name,
        e.encounter_date,
        e.diagnosis,
        ROW_NUMBER() OVER (PARTITION BY e.patient_id ORDER BY e.encounter_date DESC) as rn
    FROM Encounters e
    INNER JOIN Patients p ON e.patient_id = p.patient_id
    INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
)
SELECT 
    patient_id,
    patient_name,
    encounter_id AS latest_encounter_id,
    clinician_name,
    encounter_date AS latest_encounter_date,
    diagnosis AS latest_diagnosis
FROM RankedEncounters
WHERE rn = 1
ORDER BY latest_encounter_date DESC;


-- =============================================================================
-- QUERY 12: SUMMARIZE ENCOUNTERS BY MONTH
-- Groups consultations by year and month to examine seasonal health trends.
-- =============================================================================
SELECT 
    DATE_FORMAT(encounter_date, '%Y-%m') AS encounter_year_month,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT patient_id) AS unique_patients_served,
    COUNT(DISTINCT clinician_id) AS active_clinicians_count
FROM Encounters
GROUP BY DATE_FORMAT(encounter_date, '%Y-%m')
ORDER BY encounter_year_month DESC;
