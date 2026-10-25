package com.clinical.records.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "Encounters",
    indexes = {
        @Index(name = "idx_encounters_patient_date", columnList = "patient_id, encounter_date")
    }
)
public class Encounter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "encounter_id")
    private Long encounterId;

    @NotNull(message = "Patient reference is required")
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @NotNull(message = "Clinician reference is required")
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "clinician_id", nullable = false)
    private Clinician clinician;

    @NotNull(message = "Encounter date is required")
    @Column(name = "encounter_date", nullable = false)
    private LocalDateTime encounterDate;

    @Column(name = "symptoms", columnDefinition = "TEXT")
    private String symptoms;

    @NotBlank(message = "Diagnosis is required")
    @Column(name = "diagnosis", nullable = false, length = 255)
    private String diagnosis;

    @Column(name = "treatment_notes", columnDefinition = "TEXT")
    private String treatmentNotes;

    public Encounter() {
    }

    public Encounter(Patient patient, Clinician clinician, LocalDateTime encounterDate, String symptoms, String diagnosis, String treatmentNotes) {
        this.patient = patient;
        this.clinician = clinician;
        this.encounterDate = encounterDate;
        this.symptoms = symptoms;
        this.diagnosis = diagnosis;
        this.treatmentNotes = treatmentNotes;
    }

    public Long getEncounterId() {
        return encounterId;
    }

    public void setEncounterId(Long encounterId) {
        this.encounterId = encounterId;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public Clinician getClinician() {
        return clinician;
    }

    public void setClinician(Clinician clinician) {
        this.clinician = clinician;
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
