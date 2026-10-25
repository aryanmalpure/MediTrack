-- =============================================================================
-- MediTrack – Patient Health Records
-- Sample Data Population Script
-- =============================================================================

USE clinical_patient_db;

-- -----------------------------------------------------------------------------
-- Sample Clinicians
-- -----------------------------------------------------------------------------
INSERT INTO Clinicians (name, specialization) VALUES
('Dr. Sarah Jenkins', 'Cardiology'),
('Dr. Robert Chen', 'General Medicine'),
('Dr. Anita Sharma', 'Pediatrics'),
('Dr. David Miller', 'Dermatology');

-- -----------------------------------------------------------------------------
-- Sample Patients
-- Patient 1 to 4 have clinical encounters.
-- Patient 5 (Lucas Gray) has NO encounters or allergies (useful for testing deletion).
-- -----------------------------------------------------------------------------
INSERT INTO Patients (name, date_of_birth, gender, phone, address, blood_group) VALUES
('John Doe', '1985-04-12', 'Male', '9876543210', '12 Elm Street, Springfield', 'O+'),
('Emily Watson', '1992-09-23', 'Female', '9812345678', '45 Maple Avenue, Riverdale', 'A+'),
('Rajesh Kumar', '1978-11-05', 'Male', '9723456789', '88 Park Road, Metro City', 'B+'),
('Maria Garcia', '2001-02-18', 'Female', '9634567890', '102 Lakeview Blvd, Greenfield', 'AB-'),
('Lucas Gray', '1995-07-30', 'Male', '9545678901', '77 Sunset Strip, Hilltown', 'O-');

-- -----------------------------------------------------------------------------
-- Sample Encounters
-- -----------------------------------------------------------------------------
INSERT INTO Encounters (patient_id, clinician_id, encounter_date, symptoms, diagnosis, treatment_notes) VALUES
(1, 1, '2024-01-15 10:30:00', 'Chest discomfort on exertion, mild shortness of breath', 'Essential Hypertension', 'Prescribed Amlodipine 5mg once daily. Advised low-sodium diet and follow-up in 4 weeks.'),
(1, 1, '2024-02-18 11:15:00', 'Follow-up visit. Blood pressure stable at 128/82 mmHg', 'Hypertension - Controlled', 'Continue current medication regimen. Re-check in 3 months.'),
(2, 2, '2024-02-01 09:00:00', 'High fever, sore throat, fatigue for 3 days', 'Acute Viral Pharyngitis', 'Supportive care: warm saline gargles, Paracetamol 500mg SOS, adequate hydration.'),
(2, 4, '2024-03-10 14:45:00', 'Erythematous itchy rash on forearms', 'Contact Dermatitis', 'Topical hydrocortisone cream 1% applied twice daily for 7 days. Avoid scented soaps.'),
(3, 2, '2024-03-05 16:00:00', 'Excessive thirst, frequent urination, unexplained weight loss', 'Type 2 Diabetes Mellitus', 'Started on Metformin 500mg BD. Referred to nutritionist for diabetic diet counseling.'),
(4, 3, '2024-03-12 10:00:00', 'Wheezing during physical activity, seasonal allergic rhinitis', 'Mild Intermittent Asthma', 'Prescribed Salbutamol inhaler 100mcg as needed before exercise.');

-- -----------------------------------------------------------------------------
-- Sample Allergies
-- -----------------------------------------------------------------------------
INSERT INTO Allergies (patient_id, allergen, reaction, severity) VALUES
(1, 'Penicillin', 'Skin hives and urticaria', 'Moderate'),
(2, 'Peanuts', 'Anaphylactic facial swelling', 'Severe'),
(3, 'Sulfa Drugs', 'Mild maculopapular rash', 'Mild'),
(4, 'Latex', 'Contact erythema and itching', 'Mild');

-- -----------------------------------------------------------------------------
-- Sample Medical History
-- -----------------------------------------------------------------------------
INSERT INTO Medical_History (patient_id, condition_name, diagnosis_date, status) VALUES
(1, 'Mild Hyperlipidemia', '2021-06-10', 'Active'),
(1, 'Hypertension', '2024-01-15', 'Active'),
(2, 'Childhood Asthma', '2000-05-14', 'Resolved'),
(3, 'Type 2 Diabetes', '2024-03-05', 'Active'),
(4, 'Seasonal Allergic Rhinitis', '2018-09-20', 'Chronic');

-- -----------------------------------------------------------------------------
-- Sample Master Medications
-- -----------------------------------------------------------------------------
INSERT INTO Medications (medication_name, dosage_form) VALUES
('Amlodipine', 'Tablet'),
('Metformin', 'Tablet'),
('Paracetamol', 'Tablet'),
('Hydrocortisone 1%', 'Topical Cream'),
('Salbutamol Inhaler', 'Inhaler'),
('Amoxicillin', 'Capsule'),
('Cetirizine', 'Tablet'),
('Atorvastatin', 'Tablet');
