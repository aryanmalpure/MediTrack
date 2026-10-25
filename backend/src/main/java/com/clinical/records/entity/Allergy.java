package com.clinical.records.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Entity
@Table(name = "Allergies")
public class Allergy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "allergy_id")
    private Long allergyId;

    @NotNull(message = "Patient reference is required")
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    @JsonIgnore
    private Patient patient;

    @NotBlank(message = "Allergen name is required")
    @Column(name = "allergen", nullable = false, length = 100)
    private String allergen;

    @Column(name = "reaction", length = 150)
    private String reaction;

    @NotBlank(message = "Severity is required")
    @Column(name = "severity", nullable = false, length = 20)
    private String severity;

    public Allergy() {
    }

    public Allergy(Patient patient, String allergen, String reaction, String severity) {
        this.patient = patient;
        this.allergen = allergen;
        this.reaction = reaction;
        this.severity = severity;
    }

    public Long getAllergyId() {
        return allergyId;
    }

    public void setAllergyId(Long allergyId) {
        this.allergyId = allergyId;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public String getAllergen() {
        return allergen;
    }

    public void setAllergen(String allergen) {
        this.allergen = allergen;
    }

    public String getReaction() {
        return reaction;
    }

    public void setReaction(String reaction) {
        this.reaction = reaction;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }
}
