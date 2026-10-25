package com.clinical.records.service;

import com.clinical.records.dto.PatientDetailsDTO;
import com.clinical.records.entity.Allergy;
import com.clinical.records.entity.Encounter;
import com.clinical.records.entity.MedicalHistory;
import com.clinical.records.entity.Patient;
import com.clinical.records.exception.DatabaseConstraintException;
import com.clinical.records.exception.ResourceNotFoundException;
import com.clinical.records.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PatientService {

    private final PatientRepository patientRepository;
    private final EncounterRepository encounterRepository;
    private final AllergyRepository allergyRepository;
    private final MedicalHistoryRepository medicalHistoryRepository;
    private final MedicationRepository medicationRepository;

    public PatientService(PatientRepository patientRepository,
                          EncounterRepository encounterRepository,
                          AllergyRepository allergyRepository,
                          MedicalHistoryRepository medicalHistoryRepository,
                          MedicationRepository medicationRepository) {
        this.patientRepository = patientRepository;
        this.encounterRepository = encounterRepository;
        this.allergyRepository = allergyRepository;
        this.medicalHistoryRepository = medicalHistoryRepository;
        this.medicationRepository = medicationRepository;
    }

    public List<Patient> getAllPatients() {
        return patientRepository.findAllByOrderByPatientIdDesc();
    }

    public List<Patient> getRecentPatients() {
        return patientRepository.findTop5ByOrderByPatientIdDesc();
    }

    public List<Patient> searchPatients(String query) {
        if (query == null || query.trim().isEmpty()) {
            return getAllPatients();
        }
        return patientRepository.searchPatients(query.trim());
    }

    public Patient getPatientById(Long id) {
        return patientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Patient not found with ID: " + id));
    }

    public PatientDetailsDTO getPatientDetails(Long id) {
        Patient patient = getPatientById(id);
        List<Allergy> allergies = allergyRepository.findByPatientPatientId(id);
        List<MedicalHistory> history = medicalHistoryRepository.findByPatientPatientId(id);
        List<Encounter> encounters = encounterRepository.findByPatientPatientIdOrderByEncounterDateDesc(id);

        return new PatientDetailsDTO(patient, allergies, history, encounters);
    }

    @Transactional
    public Patient createPatient(Patient patient) {
        return patientRepository.save(patient);
    }

    @Transactional
    public Patient updatePatient(Long id, Patient updated) {
        Patient existing = getPatientById(id);
        existing.setName(updated.getName());
        existing.setDateOfBirth(updated.getDateOfBirth());
        existing.setGender(updated.getGender());
        existing.setPhone(updated.getPhone());
        existing.setEmail(updated.getEmail());
        existing.setAddress(updated.getAddress());
        existing.setBloodGroup(updated.getBloodGroup());
        return patientRepository.save(existing);
    }

    @Transactional
    public void deletePatient(Long id) {
        Patient patient = getPatientById(id);

        long encounterCount = encounterRepository.countByPatientPatientId(id);
        long allergyCount = allergyRepository.countByPatientPatientId(id);
        long historyCount = medicalHistoryRepository.countByPatientPatientId(id);
        long medicationCount = medicationRepository.countByPatientPatientId(id);

        if (encounterCount > 0 || allergyCount > 0 || historyCount > 0 || medicationCount > 0) {
            StringBuilder reason = new StringBuilder("Cannot delete patient ID " + id + " (" + patient.getName() + ") because active relationships exist: ");
            boolean first = true;
            if (encounterCount > 0) {
                reason.append(encounterCount).append(" clinical encounter(s)");
                first = false;
            }
            if (allergyCount > 0) {
                if (!first) reason.append(", ");
                reason.append(allergyCount).append(" allergy record(s)");
                first = false;
            }
            if (historyCount > 0) {
                if (!first) reason.append(", ");
                reason.append(historyCount).append(" medical history record(s)");
                first = false;
            }
            if (medicationCount > 0) {
                if (!first) reason.append(", ");
                reason.append(medicationCount).append(" medication record(s)");
            }
            reason.append(". Database referential integrity prevented deletion.");
            throw new DatabaseConstraintException(reason.toString());
        }

        patientRepository.delete(patient);
    }

    public long getTotalPatientsCount() {
        return patientRepository.count();
    }
}
