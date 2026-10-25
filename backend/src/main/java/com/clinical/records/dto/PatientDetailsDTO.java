package com.clinical.records.dto;

import com.clinical.records.entity.Allergy;
import com.clinical.records.entity.Encounter;
import com.clinical.records.entity.MedicalHistory;
import com.clinical.records.entity.Patient;

import java.util.List;

public class PatientDetailsDTO {
    private Patient patient;
    private List<Allergy> allergies;
    private List<MedicalHistory> medicalHistory;
    private List<Encounter> encounters;

    public PatientDetailsDTO() {
    }

    public PatientDetailsDTO(Patient patient, List<Allergy> allergies, List<MedicalHistory> medicalHistory, List<Encounter> encounters) {
        this.patient = patient;
        this.allergies = allergies;
        this.medicalHistory = medicalHistory;
        this.encounters = encounters;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public List<Allergy> getAllergies() {
        return allergies;
    }

    public void setAllergies(List<Allergy> allergies) {
        this.allergies = allergies;
    }

    public List<MedicalHistory> getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(List<MedicalHistory> medicalHistory) {
        this.medicalHistory = medicalHistory;
    }

    public List<Encounter> getEncounters() {
        return encounters;
    }

    public void setEncounters(List<Encounter> encounters) {
        this.encounters = encounters;
    }
}
