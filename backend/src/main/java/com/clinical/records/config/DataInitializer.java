package com.clinical.records.config;

import com.clinical.records.entity.*;
import com.clinical.records.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Automatically seeds initial fictional sample records if the database is empty.
 * Populates complete relational data matching the MediTrack schema.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    private final PatientRepository patientRepository;
    private final ClinicianRepository clinicianRepository;
    private final EncounterRepository encounterRepository;
    private final AllergyRepository allergyRepository;
    private final MedicalHistoryRepository medicalHistoryRepository;
    private final MedicationRepository medicationRepository;

    public DataInitializer(PatientRepository patientRepository,
                           ClinicianRepository clinicianRepository,
                           EncounterRepository encounterRepository,
                           AllergyRepository allergyRepository,
                           MedicalHistoryRepository medicalHistoryRepository,
                           MedicationRepository medicationRepository) {
        this.patientRepository = patientRepository;
        this.clinicianRepository = clinicianRepository;
        this.encounterRepository = encounterRepository;
        this.allergyRepository = allergyRepository;
        this.medicalHistoryRepository = medicalHistoryRepository;
        this.medicationRepository = medicationRepository;
    }

    @Override
    public void run(String... args) {
        if (patientRepository.count() > 0) {
            return;
        }

        // 1. Seed Clinicians
        Clinician c1 = clinicianRepository.save(new Clinician("Dr. Sarah Jenkins", "Cardiology", "9811122233", "sjenkins@meditrack.org"));
        Clinician c2 = clinicianRepository.save(new Clinician("Dr. Robert Chen", "General Medicine", "9822233344", "rchen@meditrack.org"));
        Clinician c3 = clinicianRepository.save(new Clinician("Dr. Anita Sharma", "Pediatrics", "9833344455", "asharma@meditrack.org"));
        Clinician c4 = clinicianRepository.save(new Clinician("Dr. David Miller", "Dermatology", "9844455566", "dmiller@meditrack.org"));

        // 2. Seed Patients
        Patient p1 = new Patient("John Doe", LocalDate.of(1985, 4, 12), "Male", "9876543210", "12 Elm Street, Springfield", "O+");
        p1.setEmail("john.doe@email.com");
        p1 = patientRepository.save(p1);

        Patient p2 = new Patient("Emily Watson", LocalDate.of(1992, 9, 23), "Female", "9812345678", "45 Maple Avenue, Riverdale", "A+");
        p2.setEmail("emily.watson@email.com");
        p2 = patientRepository.save(p2);

        Patient p3 = new Patient("Rajesh Kumar", LocalDate.of(1978, 11, 5), "Male", "9723456789", "88 Park Road, Metro City", "B+");
        p3.setEmail("rajesh.kumar@email.com");
        p3 = patientRepository.save(p3);

        Patient p4 = new Patient("Maria Garcia", LocalDate.of(2001, 2, 18), "Female", "9634567890", "102 Lakeview Blvd, Greenfield", "AB-");
        p4.setEmail("maria.garcia@email.com");
        p4 = patientRepository.save(p4);

        // Patient 5 has no encounters or allergies, useful for testing safe deletion
        Patient p5 = new Patient("Lucas Gray", LocalDate.of(1995, 7, 30), "Male", "9545678901", "77 Sunset Strip, Hilltown", "O-");
        p5.setEmail("lucas.gray@email.com");
        p5 = patientRepository.save(p5);

        // 3. Seed Allergies
        allergyRepository.save(new Allergy(p1, "Penicillin", "Skin hives and urticaria", "Moderate"));
        allergyRepository.save(new Allergy(p2, "Peanuts", "Anaphylactic facial swelling and bronchospasm", "Severe"));
        allergyRepository.save(new Allergy(p3, "Sulfa Drugs", "Mild maculopapular rash", "Mild"));
        allergyRepository.save(new Allergy(p4, "Latex", "Contact erythema and itching", "Mild"));

        // 4. Seed Medical History
        medicalHistoryRepository.save(new MedicalHistory(p1, "Mild Hyperlipidemia", LocalDate.of(2021, 6, 10), "Active", "Under dietary control and lifestyle management."));
        medicalHistoryRepository.save(new MedicalHistory(p1, "Essential Hypertension", LocalDate.of(2024, 1, 15), "Active", "Stage 1 hypertension diagnosed during routine review."));
        medicalHistoryRepository.save(new MedicalHistory(p2, "Childhood Asthma", LocalDate.of(2000, 5, 14), "Resolved", "No acute exacerbations since age 12."));
        medicalHistoryRepository.save(new MedicalHistory(p3, "Type 2 Diabetes Mellitus", LocalDate.of(2024, 3, 5), "Chronic", "HbA1c 7.8% on initial diagnosis."));
        medicalHistoryRepository.save(new MedicalHistory(p4, "Seasonal Allergic Rhinitis", LocalDate.of(2018, 9, 20), "Chronic", "Triggered during pollen seasons."));

        // 5. Seed Encounters
        encounterRepository.save(new Encounter(p1, c1, LocalDateTime.of(2024, 1, 15, 10, 30),
                "Chest discomfort on exertion, mild shortness of breath",
                "Essential Hypertension",
                "Prescribed Amlodipine 5mg once daily. Advised low-sodium diet and follow-up in 4 weeks."));

        encounterRepository.save(new Encounter(p1, c1, LocalDateTime.of(2024, 2, 18, 11, 15),
                "Follow-up visit. Blood pressure stable at 128/82 mmHg",
                "Hypertension - Controlled",
                "Continue current medication regimen. Re-check in 3 months."));

        encounterRepository.save(new Encounter(p2, c2, LocalDateTime.of(2024, 2, 1, 9, 0),
                "High fever, sore throat, fatigue for 3 days",
                "Acute Viral Pharyngitis",
                "Supportive care: warm saline gargles, Paracetamol 500mg SOS, adequate hydration."));

        encounterRepository.save(new Encounter(p2, c4, LocalDateTime.of(2024, 3, 10, 14, 45),
                "Erythematous itchy rash on forearms",
                "Contact Dermatitis",
                "Topical hydrocortisone cream 1% applied twice daily for 7 days. Avoid scented soaps."));

        encounterRepository.save(new Encounter(p3, c2, LocalDateTime.of(2024, 3, 5, 16, 0),
                "Excessive thirst, frequent urination, unexplained weight loss",
                "Type 2 Diabetes Mellitus",
                "Started on Metformin 500mg BD. Referred to nutritionist for diabetic diet counseling."));

        encounterRepository.save(new Encounter(p4, c3, LocalDateTime.of(2024, 3, 12, 10, 0),
                "Wheezing during physical activity, seasonal allergic rhinitis",
                "Mild Intermittent Asthma",
                "Prescribed Salbutamol inhaler 100mcg as needed before exercise."));

        // 6. Seed Medications
        medicationRepository.save(new Medication(p1, "Amlodipine", "5mg", LocalDate.of(2024, 1, 15), LocalDate.of(2024, 7, 15), "Take one tablet every morning after breakfast."));
        medicationRepository.save(new Medication(p1, "Atorvastatin", "10mg", LocalDate.of(2024, 1, 15), null, "Take one tablet at bedtime."));
        medicationRepository.save(new Medication(p2, "Paracetamol", "500mg", LocalDate.of(2024, 2, 1), LocalDate.of(2024, 2, 6), "Take one tablet every 6 hours as needed for fever."));
        medicationRepository.save(new Medication(p2, "Hydrocortisone 1% Cream", "Thin film", LocalDate.of(2024, 3, 10), LocalDate.of(2024, 3, 17), "Apply twice daily to affected forearm areas."));
        medicationRepository.save(new Medication(p3, "Metformin", "500mg", LocalDate.of(2024, 3, 5), null, "Take one tablet twice daily with main meals."));
        medicationRepository.save(new Medication(p4, "Salbutamol Inhaler", "100mcg/puff", LocalDate.of(2024, 3, 12), LocalDate.of(2025, 3, 12), "Inhale 1-2 puffs 15 minutes before vigorous exercise."));
    }
}
