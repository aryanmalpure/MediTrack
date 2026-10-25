package com.clinical.records.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public class EncounterRequest {

    @NotNull(message = "Patient ID is required")
    private Long patientId;

    @NotNull(message = "Clinician ID is required")
    private Long clinicianId;

    @NotNull(message = "Encounter date is required")
    private LocalDateTime encounterDate;

    private String symptoms;

    @NotBlank(message = "Diagnosis is required")
    private String diagnosis;

    private String treatmentNotes;

    public EncounterRequest() {
    }

    public EncounterRequest(Long patientId, Long clinicianId, LocalDateTime encounterDate, String symptoms, String diagnosis, String treatmentNotes) {
        this.patientId = patientId;
        this.clinicianId = clinicianId;
        this.encounterDate = encounterDate;
        this.symptoms = symptoms;
        this.diagnosis = diagnosis;
        this.treatmentNotes = treatmentNotes;
    }

    public Long getPatientId() {
        return patientId;
    }

    public void setPatientId(Long patientId) {
        this.patientId = patientId;
    }

    public Long getClinicianId() {
        return clinicianId;
    }

    public void setClinicianId(Long clinicianId) {
        this.clinicianId = clinicianId;
    }

    public LocalDateTime getEncounterDate() {
        return encounterDate;
    }

    public void setEncounterDate(LocalDateTime encounterDate) {
        this.encounterDate = encounterDate;
    }

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getTreatmentNotes() {
        return treatmentNotes;
    }

    public void setTreatmentNotes(String treatmentNotes) {
        this.treatmentNotes = treatmentNotes;
    }
}
