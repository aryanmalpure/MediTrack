-- =============================================================================
-- MediTrack – Patient Health Records
-- File 11: Comprehensive Fictional Sample Data Population
-- Database Name: clinical_patient_db
-- =============================================================================

USE clinical_patient_db;

-- Clear previous sample records in reverse foreign key order if needed
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Encounter_Audit;
TRUNCATE TABLE Medications;
TRUNCATE TABLE Medical_History;
TRUNCATE TABLE Allergies;
TRUNCATE TABLE Encounters;
TRUNCATE TABLE Clinicians;
TRUNCATE TABLE Patients;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- 1. Insert Sample Clinicians
-- -----------------------------------------------------------------------------
INSERT INTO Clinicians (clinician_id, name, specialization, phone, email) VALUES
(1, 'Dr. Sarah Jenkins', 'Cardiology', '9811122233', 'sjenkins@meditrack.org'),
(2, 'Dr. Robert Chen', 'General Medicine', '9822233344', 'rchen@meditrack.org'),
(3, 'Dr. Anita Sharma', 'Pediatrics', '9833344455', 'asharma@meditrack.org'),
(4, 'Dr. David Miller', 'Dermatology', '9844455566', 'dmiller@meditrack.org');

-- -----------------------------------------------------------------------------
-- 2. Insert Sample Patients
-- Patient 1 to 4 have clinical encounters, allergies, and history.
-- Patient 5 (Lucas Gray) has NO linked encounters (ideal for safe deletion testing).
-- -----------------------------------------------------------------------------
INSERT INTO Patients (patient_id, name, date_of_birth, gender, phone, email, address, blood_group, created_at) VALUES
(1, 'John Doe', '1985-04-12', 'Male', '9876543210', 'john.doe@email.com', '12 Elm Street, Springfield', 'O+', '2024-01-10 09:30:00'),
(2, 'Emily Watson', '1992-09-23', 'Female', '9812345678', 'emily.watson@email.com', '45 Maple Avenue, Riverdale', 'A+', '2024-01-15 11:15:00'),
(3, 'Rajesh Kumar', '1978-11-05', 'Male', '9723456789', 'rajesh.kumar@email.com', '88 Park Road, Metro City', 'B+', '2024-01-20 14:00:00'),
(4, 'Maria Garcia', '2001-02-18', 'Female', '9634567890', 'maria.garcia@email.com', '102 Lakeview Blvd, Greenfield', 'AB-', '2024-02-01 10:45:00'),
(5, 'Lucas Gray', '1995-07-30', 'Male', '9545678901', 'lucas.gray@email.com', '77 Sunset Strip, Hilltown', 'O-', '2024-02-10 16:20:00');

-- -----------------------------------------------------------------------------
-- 3. Insert Sample Allergies
-- -----------------------------------------------------------------------------
INSERT INTO Allergies (allergy_id, patient_id, allergen, reaction, severity) VALUES
(1, 1, 'Penicillin', 'Skin hives and urticaria', 'Moderate'),
(2, 2, 'Peanuts', 'Anaphylactic facial swelling and bronchospasm', 'Severe'),
(3, 3, 'Sulfa Drugs', 'Mild maculopapular rash', 'Mild'),
(4, 4, 'Latex', 'Contact erythema and itching', 'Mild');

-- -----------------------------------------------------------------------------
-- 4. Insert Sample Medical History
-- -----------------------------------------------------------------------------
INSERT INTO Medical_History (history_id, patient_id, condition_name, diagnosis_date, status, notes) VALUES
(1, 1, 'Mild Hyperlipidemia', '2021-06-10', 'Active', 'Under dietary control and lifestyle management.'),
(2, 1, 'Essential Hypertension', '2024-01-15', 'Active', 'Stage 1 hypertension diagnosed during routine review.'),
(3, 2, 'Childhood Asthma', '2000-05-14', 'Resolved', 'No acute exacerbations since age 12.'),
(4, 3, 'Type 2 Diabetes Mellitus', '2024-03-05', 'Chronic', 'HbA1c 7.8% on initial diagnosis. Started on oral hypoglycemics.'),
(5, 4, 'Seasonal Allergic Rhinitis', '2018-09-20', 'Chronic', 'Triggered during pollen seasons; managed symptomatic.');

-- -----------------------------------------------------------------------------
-- 5. Insert Sample Encounters
-- -----------------------------------------------------------------------------
INSERT INTO Encounters (encounter_id, patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes) VALUES
(1, 1, 1, '2024-01-15 10:30:00', 'Chest discomfort on exertion, mild shortness of breath', 'Essential Hypertension', 'Prescribed Amlodipine 5mg once daily. Advised low-sodium diet and follow-up in 4 weeks.'),
(2, 1, 1, '2024-02-18 11:15:00', 'Follow-up visit. Blood pressure stable at 128/82 mmHg', 'Hypertension - Controlled', 'Continue current medication regimen. Re-check in 3 months.'),
(3, 2, 2, '2024-02-01 09:00:00', 'High fever, sore throat, fatigue for 3 days', 'Acute Viral Pharyngitis', 'Supportive care: warm saline gargles, Paracetamol 500mg SOS, adequate hydration.'),
(4, 2, 4, '2024-03-10 14:45:00', 'Erythematous itchy rash on forearms', 'Contact Dermatitis', 'Topical hydrocortisone cream 1% applied twice daily for 7 days. Avoid scented soaps.'),
(5, 3, 2, '2024-03-05 16:00:00', 'Excessive thirst, frequent urination, unexplained weight loss', 'Type 2 Diabetes Mellitus', 'Started on Metformin 500mg BD. Referred to nutritionist for diabetic diet counseling.'),
(6, 4, 3, '2024-03-12 10:00:00', 'Wheezing during physical activity, seasonal allergic rhinitis', 'Mild Intermittent Asthma', 'Prescribed Salbutamol inhaler 100mcg as needed before exercise.');

-- -----------------------------------------------------------------------------
-- 6. Insert Sample Medications (Linked directly to Patients)
-- -----------------------------------------------------------------------------
INSERT INTO Medications (medication_id, patient_id, medication_name, dosage, start_date, end_date, instructions) VALUES
(1, 1, 'Amlodipine', '5mg', '2024-01-15', '2024-07-15', 'Take one tablet every morning after breakfast.'),
(2, 1, 'Atorvastatin', '10mg', '2024-01-15', NULL, 'Take one tablet at bedtime.'),
(3, 2, 'Paracetamol', '500mg', '2024-02-01', '2024-02-06', 'Take one tablet every 6 hours as needed for fever.'),
(4, 2, 'Hydrocortisone 1% Cream', 'Thin film', '2024-03-10', '2024-03-17', 'Apply twice daily to affected forearm areas.'),
(5, 3, 'Metformin', '500mg', '2024-03-05', NULL, 'Take one tablet twice daily with main meals.'),
(6, 4, 'Salbutamol Inhaler', '100mcg/puff', '2024-03-12', '2025-03-12', 'Inhale 1-2 puffs 15 minutes before vigorous exercise.');
