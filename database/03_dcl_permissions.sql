-- =============================================================================
-- MediTrack – Patient Health Records
-- File 03: DCL (Data Control Language) – Users, Roles, GRANT & REVOKE
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- =============================================================================
-- 1. USER CREATION (DBA EXECUTION)
-- NOTE: Execute these commands logged in as MySQL root or administrative user.
-- Passwords shown below are demonstrations and should be replaced with strong
-- environment-specific credentials in production deployments.
-- =============================================================================

-- Application User: Used by the Spring Boot backend service for normal operations
CREATE USER IF NOT EXISTS 'meditrack_app'@'localhost' IDENTIFIED BY 'AppPassword123!';

-- Reporting User: Restricted read-only user for clinical analysts & external reporting
CREATE USER IF NOT EXISTS 'meditrack_reporter'@'localhost' IDENTIFIED BY 'ReportPassword123!';


-- =============================================================================
-- 2. GRANTING PRIVILEGES (PRINCIPLE OF LEAST PRIVILEGE)
-- =============================================================================

-- 2.1 Application User Privileges:
-- Needs CRUD access to operational data tables, view querying, and stored procedure execution.
-- Intentionally does NOT receive administrative privileges (e.g. DROP DATABASE, GRANT OPTION).
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Patients TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Clinicians TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Encounters TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Allergies TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Medical_History TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Medications TO 'meditrack_app'@'localhost';
GRANT SELECT, INSERT ON clinical_patient_db.Encounter_Audit TO 'meditrack_app'@'localhost';
GRANT SELECT ON clinical_patient_db.vw_patient_summary TO 'meditrack_app'@'localhost';
GRANT SELECT ON clinical_patient_db.vw_patient_encounter_history TO 'meditrack_app'@'localhost';

-- 2.2 Reporting User Privileges:
-- Only permitted to read approved non-sensitive VIEWS.
-- Has NO direct access to raw base tables or audit trails.
GRANT SELECT ON clinical_patient_db.vw_patient_summary TO 'meditrack_reporter'@'localhost';
GRANT SELECT ON clinical_patient_db.vw_patient_encounter_history TO 'meditrack_reporter'@'localhost';


-- =============================================================================
-- 3. REVOKING PRIVILEGES DEMONSTRATION
-- =============================================================================

-- Step 1: Temporarily grant DELETE on Patients to reporting user to demonstrate revocation:
GRANT DELETE ON clinical_patient_db.Patients TO 'meditrack_reporter'@'localhost';

-- Step 2: Revoke DELETE privilege to enforce read-only role integrity:
REVOKE DELETE ON clinical_patient_db.Patients FROM 'meditrack_reporter'@'localhost';

-- Step 3: Refresh system privilege tables:
FLUSH PRIVILEGES;


-- =============================================================================
-- 4. VERIFICATION & AUDIT OF ASSIGNED PRIVILEGES
-- =============================================================================

-- Display grants for application user:
SHOW GRANTS FOR 'meditrack_app'@'localhost';

-- Display grants for reporting user:
SHOW GRANTS FOR 'meditrack_reporter'@'localhost';
