package com.clinical.records.service;

import com.clinical.records.dto.EncounterRequest;
import com.clinical.records.entity.Clinician;
import com.clinical.records.entity.Encounter;
import com.clinical.records.entity.Patient;
import com.clinical.records.exception.ResourceNotFoundException;
import com.clinical.records.repository.ClinicianRepository;
import com.clinical.records.repository.EncounterRepository;
import com.clinical.records.repository.PatientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EncounterService {

    private final EncounterRepository encounterRepository;
    private final PatientRepository patientRepository;
    private final ClinicianRepository clinicianRepository;

    public EncounterService(EncounterRepository encounterRepository,
                            PatientRepository patientRepository,
                            ClinicianRepository clinicianRepository) {
        this.encounterRepository = encounterRepository;
        this.patientRepository = patientRepository;
        this.clinicianRepository = clinicianRepository;
    }

    @Transactional
    public Encounter recordEncounter(EncounterRequest request) {
        Patient patient = patientRepository.findById(request.getPatientId())
                .orElseThrow(() -> new ResourceNotFoundException("Cannot record encounter: Patient not found with ID: " + request.getPatientId()));

        Clinician clinician = clinicianRepository.findById(request.getClinicianId())
                .orElseThrow(() -> new ResourceNotFoundException("Cannot record encounter: Clinician not found with ID: " + request.getClinicianId()));

        LocalDateTime encounterDate = request.getEncounterDate() != null 
                ? request.getEncounterDate() 
                : LocalDateTime.now();

        Encounter encounter = new Encounter(
                patient,
                clinician,
                encounterDate,
                request.getSymptoms(),
                request.getDiagnosis(),
                request.getTreatmentNotes()
        );

        return encounterRepository.save(encounter);
    }

    public List<Encounter> getPatientEncounters(Long patientId) {
        if (!patientRepository.existsById(patientId)) {
            throw new ResourceNotFoundException("Patient not found with ID: " + patientId);
        }
        return encounterRepository.findByPatientPatientIdOrderByEncounterDateDesc(patientId);
    }

    public List<Encounter> getAllEncounters() {
        return encounterRepository.findAll();
    }

    public long getTotalEncountersCount() {
        return encounterRepository.count();
    }
}
