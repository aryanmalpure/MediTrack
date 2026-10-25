# MediTrack – Entity-Relationship (ER) Diagram

This document illustrates the conceptual and logical schema for the **MediTrack – Patient Health Records** database system.

---

## 1. Visual EER Diagram (Mermaid)

```mermaid
erDiagram
    PATIENTS ||--o{ ENCOUNTERS : "has consultations"
    PATIENTS ||--o{ ALLERGIES : "experiences"
    PATIENTS ||--o{ MEDICAL_HISTORY : "maintains"
    PATIENTS ||--o{ MEDICATIONS : "prescribed"
    CLINICIANS ||--o{ ENCOUNTERS : "conducts"
    ENCOUNTERS ||--o{ ENCOUNTER_AUDIT : "tracked in"

    PATIENTS {
        int patient_id PK "Auto Increment"
        string name "NOT NULL"
        date date_of_birth "NOT NULL, <= CURRENT_DATE"
        string gender "NOT NULL, CHECK (Male/Female/Other)"
        string phone "Contact number"
        string email UK "Unique address"
        string address "Residential details"
        string blood_group "Blood type"
        timestamp created_at "Registration date"
    }

    CLINICIANS {
        int clinician_id PK "Auto Increment"
        string name "NOT NULL"
        string specialization "NOT NULL"
        string phone "Direct contact"
        string email UK "Unique medical address"
    }

    ENCOUNTERS {
        int encounter_id PK "Auto Increment"
        int patient_id FK "References Patients"
        int clinician_id FK "References Clinicians"
        datetime encounter_date "NOT NULL, Consultation time"
        string diagnosis "NOT NULL, Primary clinical finding"
        text symptoms "Reported complaints"
        text treatment_notes "Prescription & advice"
    }

    ALLERGIES {
        int allergy_id PK "Auto Increment"
        int patient_id FK "References Patients"
        string allergen "Substance name"
        string reaction "Manifested symptoms"
        string severity "CHECK (Mild/Moderate/Severe)"
    }

    MEDICAL_HISTORY {
        int history_id PK "Auto Increment"
        int patient_id FK "References Patients"
        string condition_name "Diagnosed ailment"
        date diagnosis_date "Initial diagnosis date"
        string status "Active / Resolved / Chronic"
        text notes "Clinical observations"
    }

    MEDICATIONS {
        int medication_id PK "Auto Increment"
        int patient_id FK "References Patients"
        string medication_name "Drug name"
        string dosage "e.g. 500mg, 10ml"
        date start_date "Commencement date"
        date end_date "CHECK (end_date >= start_date)"
        text instructions "Dosage schedule & directions"
    }

    ENCOUNTER_AUDIT {
        int audit_id PK "Auto Increment"
        int encounter_id "Referenced consultation ID"
        int patient_id "Associated patient"
        string action_type "INSERT / UPDATE / DELETE"
        string old_diagnosis "Pre-update state"
        string new_diagnosis "Post-update state"
        text old_treatment_notes "Pre-update advice"
        text new_treatment_notes "Post-update advice"
        timestamp changed_at "Timestamp of event"
        string changed_by "Database user performing change"
    }
```

---

## 2. Structural Relationship Cardinalities

| Entity A | Relationship | Entity B | Cardinality | Participation | Foreign Key in Child Entity |
|---|---|---|---|---|---|
| **Patients** | records | **Encounters** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Encounters.patient_id` |
| **Clinicians** | conducts | **Encounters** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Encounters.clinician_id` |
| **Patients** | experiences | **Allergies** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Allergies.patient_id` |
| **Patients** | has diagnosed | **Medical_History** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Medical_History.patient_id` |
| **Patients** | is prescribed | **Medications** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Medications.patient_id` |
| **Encounters** | triggers log | **Encounter_Audit** | 1 : N (One-to-Many) | Mandatory (1) to Optional (N) | `Encounter_Audit.encounter_id` |

---

## 3. Referential Integrity Rules

1. **`Encounters.patient_id` &rarr; `Patients.patient_id`**:
   - `ON DELETE RESTRICT`: Prevents deletion of any patient who has clinical consultation history.
   - `ON UPDATE CASCADE`: If patient ID changes, all related encounters cascade update.
2. **`Encounters.clinician_id` &rarr; `Clinicians.clinician_id`**:
   - `ON DELETE RESTRICT`: Clinicians with patient consultation records cannot be removed.
   - `ON UPDATE CASCADE`: Updates to clinician IDs reflect across consultations.
3. **`Allergies.patient_id` &rarr; `Patients.patient_id`**:
   - `ON DELETE RESTRICT`: Protects against orphaned allergy records.
4. **`Medical_History.patient_id` &rarr; `Patients.patient_id`**:
   - `ON DELETE RESTRICT`: Preserves chronic diagnosis integrity.
5. **`Medications.patient_id` &rarr; `Patients.patient_id`**:
   - `ON DELETE RESTRICT`: Active drug histories cannot be orphaned.
