package com.clinical.records;

import com.clinical.records.dto.EncounterRequest;
import com.clinical.records.dto.PatientDetailsDTO;
import com.clinical.records.entity.Clinician;
import com.clinical.records.entity.Encounter;
import com.clinical.records.entity.Patient;
import com.clinical.records.exception.DatabaseConstraintException;
import com.clinical.records.service.ClinicianService;
import com.clinical.records.service.EncounterService;
import com.clinical.records.service.PatientService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class ClinicalPatientRecordsApplicationTests {

    @Autowired
    private PatientService patientService;

    @Autowired
    private ClinicianService clinicianService;

    @Autowired
    private EncounterService encounterService;

    @Test
    @DisplayName("Test 1: Patient Registration (CRUD - Create)")
    void testPatientRegistration() {
        Patient newPatient = new Patient(
                "Alice Wonder",
                LocalDate.of(1996, 8, 14),
                "Female",
                "9988776655",
                "340 River View, Metrotown",
                "B+"
        );

        Patient registered = patientService.createPatient(newPatient);

        assertNotNull(registered.getPatientId(), "Patient ID should be generated");
        assertEquals("Alice Wonder", registered.getName());
        assertEquals("B+", registered.getBloodGroup());
    }

    @Test
    @DisplayName("Test 2: Encounter Creation (Link Patient & Clinician)")
    void testEncounterCreation() {
        Patient patient = patientService.createPatient(
                new Patient("Bob Martin", LocalDate.of(1982, 3, 10), "Male", "9123456789", "89 Pine St", "O+")
        );
        Clinician clinician = clinicianService.createClinician(
                new Clinician("Dr. Gregory House", "Diagnostics")
        );

        EncounterRequest request = new EncounterRequest(
                patient.getPatientId(),
                clinician.getClinicianId(),
                LocalDateTime.now(),
                "Chronic leg pain and fatigue",
                "Peripheral Neuropathy",
                "Rest, vitamin supplements, and MRI scan advised."
        );

        Encounter created = encounterService.recordEncounter(request);

        assertNotNull(created.getEncounterId(), "Encounter ID should be generated");
        assertEquals("Peripheral Neuropathy", created.getDiagnosis());
        assertEquals(patient.getPatientId(), created.getPatient().getPatientId());
        assertEquals(clinician.getClinicianId(), created.getClinician().getClinicianId());
    }

    @Test
    @DisplayName("Test 3: Patient History Retrieval (Chronological Order)")
    void testPatientHistoryRetrieval() {
        Patient patient = patientService.createPatient(
                new Patient("Clara Oswald", LocalDate.of(1990, 11, 23), "Female", "9012345678", "221 Baker St", "A-")
        );
        Clinician clinician = clinicianService.createClinician(
                new Clinician("Dr. John Watson", "General Medicine")
        );

        LocalDateTime date1 = LocalDateTime.now().minusDays(5);
        LocalDateTime date2 = LocalDateTime.now().minusDays(1);

        encounterService.recordEncounter(new EncounterRequest(
                patient.getPatientId(), clinician.getClinicianId(), date1, "Mild cough", "Bronchitis", "Cough syrup"
        ));
        encounterService.recordEncounter(new EncounterRequest(
                patient.getPatientId(), clinician.getClinicianId(), date2, "Follow-up", "Recovered", "No medication needed"
        ));

        PatientDetailsDTO details = patientService.getPatientDetails(patient.getPatientId());

        assertNotNull(details.getPatient());
        List<Encounter> history = details.getEncounters();
        assertEquals(2, history.size(), "Should have exactly 2 encounters");
        assertTrue(history.get(0).getEncounterDate().isAfter(history.get(1).getEncounterDate()) ||
                   history.get(0).getEncounterDate().isEqual(history.get(1).getEncounterDate()),
                "Encounters should be in reverse chronological order");
    }

    @Test
    @DisplayName("Test 4: Referential Integrity - Prevent Deletion When Encounters Exist")
    void testReferentialIntegrityOnPatientDelete() {
        Patient patient = patientService.createPatient(
                new Patient("Daniel Craig", LocalDate.of(1968, 3, 2), "Male", "9870001111", "007 Secret St", "AB+")
        );
        Clinician clinician = clinicianService.createClinician(
                new Clinician("Dr. M", "Internal Medicine")
        );

        encounterService.recordEncounter(new EncounterRequest(
                patient.getPatientId(), clinician.getClinicianId(), LocalDateTime.now(), "Physical checkup", "Normal", "Healthy"
        ));

        assertThrows(DatabaseConstraintException.class, () -> {
            patientService.deletePatient(patient.getPatientId());
        }, "Should throw DatabaseConstraintException due to foreign key integrity");
    }

    @Test
    @DisplayName("Test 5: Successful Patient Deletion When No Encounters Exist")
    void testSuccessfulPatientDeleteWhenNoEncounters() {
        Patient patient = patientService.createPatient(
                new Patient("Lonely Patient", LocalDate.of(1999, 1, 1), "Other", "9111122223", "None", "O+")
        );

        Long id = patient.getPatientId();
        assertDoesNotThrow(() -> patientService.deletePatient(id));
        assertFalse(patientService.getAllPatients().stream().anyMatch(p -> p.getPatientId().equals(id)));
    }
}
