package com.clinical.records.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

@Entity
@Table(name = "Medical_History")
public class MedicalHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "history_id")
    private Long historyId;

    @NotNull(message = "Patient reference is required")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    @JsonIgnore
    private Patient patient;

    @NotBlank(message = "Condition name is required")
    @Column(name = "condition_name", nullable = false, length = 150)
    private String conditionName;

    @Column(name = "diagnosis_date")
    private LocalDate diagnosisDate;

    @NotBlank(message = "Status is required")
    @Column(name = "status", nullable = false, length = 50)
    private String status;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    public MedicalHistory() {
    }

    public MedicalHistory(Patient patient, String conditionName, LocalDate diagnosisDate, String status) {
        this.patient = patient;
        this.conditionName = conditionName;
        this.diagnosisDate = diagnosisDate;
        this.status = status;
    }

    public MedicalHistory(Patient patient, String conditionName, LocalDate diagnosisDate, String status, String notes) {
        this.patient = patient;
        this.conditionName = conditionName;
        this.diagnosisDate = diagnosisDate;
        this.status = status;
        this.notes = notes;
    }

    public Long getHistoryId() {
        return historyId;
    }

    public void setHistoryId(Long historyId) {
        this.historyId = historyId;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public String getConditionName() {
        return conditionName;
    }

    public void setConditionName(String conditionName) {
        this.conditionName = conditionName;
    }

    public LocalDate getDiagnosisDate() {
        return diagnosisDate;
    }

    public void setDiagnosisDate(LocalDate diagnosisDate) {
        this.diagnosisDate = diagnosisDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
