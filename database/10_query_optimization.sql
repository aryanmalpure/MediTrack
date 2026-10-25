-- =============================================================================
-- MediTrack – Patient Health Records
-- File 10: Query Optimization & EXPLAIN Execution Plan Analysis
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- EXPERIMENT 1: PATIENT SEARCH OPTIMIZATION
-- Query: Search for patients by name or name prefix.
-- =============================================================================

-- Scenario A: Execution plan analyzing patient name search using index 'idx_patients_name':
EXPLAIN 
SELECT patient_id, name, date_of_birth, gender, phone, email 
FROM Patients 
WHERE name LIKE 'Emily%';

-- Explanation of Output:
-- 1. 'type': 'range' (Index range scan over B-Tree index idx_patients_name).
-- 2. 'key': 'idx_patients_name' confirms index usage instead of reading all rows.
-- 3. 'rows': Significantly reduced from total table rows to only matching range.
-- 4. 'Extra': 'Using index condition'.


-- =============================================================================
-- EXPERIMENT 2: PATIENT ENCOUNTER TIMELINE OPTIMIZATION
-- Query: Retrieve chronological consultations for a patient in a date range.
-- =============================================================================

-- Scenario A: Evaluating composite index 'idx_encounters_patient_date' on (patient_id, encounter_date)
EXPLAIN 
SELECT encounter_id, patient_id, encounter_date, diagnosis 
FROM Encounters 
WHERE patient_id = 1 AND encounter_date >= '2024-01-01'
ORDER BY encounter_date DESC;

-- Explanation of Execution Plan:
-- 1. 'key': Uses composite index 'idx_encounters_patient_date'.
-- 2. 'type': 'range' / 'ref'.
-- 3. 'Extra': Does NOT require 'Using filesort' because the composite index
--             stores rows pre-sorted by encounter_date DESC!


-- =============================================================================
-- EXPERIMENT 3: JOIN OPTIMIZATION & FOREIGN KEY INDEX USAGE
-- Query: Joining Encounters with Clinicians and Patients.
-- =============================================================================

EXPLAIN 
SELECT 
    e.encounter_id,
    p.name AS patient_name,
    c.name AS clinician_name,
    c.specialization,
    e.encounter_date,
    e.diagnosis
FROM Encounters e
INNER JOIN Patients p ON e.patient_id = p.patient_id
INNER JOIN Clinicians c ON e.clinician_id = c.clinician_id
WHERE e.clinician_id = 1;

-- Explanation of Output:
-- 1. Encounters table access utilizes 'idx_encounters_clinician_id' (type: ref).
-- 2. Patients lookup utilizes PRIMARY KEY on Patients (type: eq_ref - optimal 1-row lookup).
-- 3. Clinicians lookup utilizes PRIMARY KEY on Clinicians (type: eq_ref - optimal 1-row lookup).
-- 4. Result: Zero full-table scans ('type: ALL').


-- =============================================================================
-- EXPERIMENT 4: DEMONSTRATING INDEX EFFECTIVENESS VS UNINDEXED TEXT SEARCH
-- Query: Substring wildcard search (%term%) which cannot use standard B-Tree index.
-- =============================================================================

EXPLAIN 
SELECT encounter_id, patient_id, diagnosis, symptoms 
FROM Encounters 
WHERE symptoms LIKE '%fever%';

-- Explanation:
-- 1. 'type': 'ALL' (Full table scan).
-- 2. Reason: Leading wildcard '%' prevents B-Tree prefix traversal.
-- 3. Academic Learning: B-Tree indexes only optimize prefix matches ('term%') or exact matches ('term').
--    Full-text indexes (FULLTEXT) or dedicated search engines are required for arbitrary substring searches.
