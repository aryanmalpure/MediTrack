# MediTrack – Patient Health Records
## Document 6: REST API Documentation & Request-Response Specifications

All backend endpoints use the standard base path `/api` and return a unified wrapper format:
```json
{
  "success": true,
  "message": "Status description",
  "data": { ... }
}
```

---

## 1. Complete Endpoints Master Table

| HTTP Method | Endpoint URL | Purpose | Request Parameters / Body | Expected Success Response | Database Operation Performed |
|---|---|---|---|---|---|
| `GET` | `/api/dashboard/stats` | Retrieves metrics for dashboard overview | None | `200 OK` + `{totalPatients: 5, totalEncounters: 6}` | `COUNT(*)` on `Patients` and `Encounters` |
| `GET` | `/api/dashboard/recent-patients` | Fetches top 5 most recently added patients | None | `200 OK` + Array of 5 `Patient` objects | `SELECT * FROM Patients ORDER BY patient_id DESC LIMIT 5` |
| `GET` | `/api/patients` | Retrieves all registered patients or filters by search | Optional query param: `?search=query` | `200 OK` + Array of `Patient` objects | `SELECT * FROM Patients ORDER BY patient_id DESC` or JPQL substring search on `name` / `patient_id` |
| `GET` | `/api/patients/{id}` | Fetches basic demographic profile of a single patient | Path variable: `id` (Long) | `200 OK` + Single `Patient` object (or `404 Not Found`) | `SELECT * FROM Patients WHERE patient_id = :id` |
| `GET` | `/api/patients/{id}/details` | Retrieves full clinical dossier (patient, allergies, history, encounters) | Path variable: `id` (Long) | `200 OK` + `PatientDetailsDTO` | 4 coordinated queries on `Patients`, `Allergies`, `Medical_History`, `Encounters` |
| `POST` | `/api/patients` | Registers a new patient | JSON Body: `Patient` object (name, DOB, gender, phone, email, address, bloodGroup) | `201 Created` + Created `Patient` with generated `patientId` | `INSERT INTO Patients (...) VALUES (...)` (Triggers `trg_patients_validate_dob_insert`) |
| `PUT` | `/api/patients/{id}` | Updates existing patient demographics | Path: `id`, Body: `Patient` object | `200 OK` + Updated `Patient` object | `UPDATE Patients SET ... WHERE patient_id = :id` |
| `DELETE` | `/api/patients/{id}` | Deletes a patient (blocked if clinical links exist) | Path variable: `id` (Long) | `200 OK` + Success message (or `409 Conflict`) | `COUNT(*)` on dependent tables, then `DELETE FROM Patients WHERE patient_id = :id` |
| `GET` | `/api/clinicians` | Lists all clinicians | None | `200 OK` + Array of `Clinician` objects | `SELECT * FROM Clinicians ORDER BY name ASC` |
| `POST` | `/api/clinicians` | Adds a new clinician | JSON Body: `{name: string, specialty: string}` | `201 Created` + Created `Clinician` with generated `clinicianId` | `INSERT INTO Clinicians (name, specialization) VALUES (...)` |
| `GET` | `/api/encounters` | Lists all clinical encounters | None | `200 OK` + Array of `Encounter` objects | `SELECT * FROM Encounters` |
| `POST` | `/api/encounters` | Records a clinical encounter | JSON Body: `EncounterRequest` (`patientId`, `clinicianId`, `encounterDate`, `diagnosis`, `symptoms`, `treatmentNotes`) | `201 Created` + Created `Encounter` object | `INSERT INTO Encounters (...)` (Triggers `trg_after_encounter_insert`) |
| `GET` | `/api/encounters/patient/{patientId}` | Retrieves chronological consultation timeline for a patient | Path variable: `patientId` (Long) | `200 OK` + Array of `Encounter` objects | `SELECT * FROM Encounters WHERE patient_id = :id ORDER BY encounter_date DESC` |

---

## 2. Request & Response Payload Examples

### 2.1 Register New Patient
- **Endpoint**: `POST /api/patients`
- **Request Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "name": "Sarah Connor",
    "dateOfBirth": "1984-05-12",
    "gender": "Female",
    "phone": "9811223344",
    "email": "sarah.connor@email.com",
    "bloodGroup": "A+",
    "address": "404 Skynet Ave, Los Angeles"
  }
  ```
- **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Patient registered successfully",
    "data": {
      "patientId": 6,
      "name": "Sarah Connor",
      "dateOfBirth": "1984-05-12",
      "gender": "Female",
      "phone": "9811223344",
      "email": "sarah.connor@email.com",
      "address": "404 Skynet Ave, Los Angeles",
      "bloodGroup": "A+",
      "createdAt": "2026-10-25T15:50:00"
    }
  }
  ```

---

### 2.2 Record Clinical Encounter
- **Endpoint**: `POST /api/encounters`
- **Request Body**:
  ```json
  {
    "patientId": 1,
    "clinicianId": 2,
    "encounterDate": "2026-10-25T14:30:00",
    "symptoms": "Low grade fever and productive cough",
    "diagnosis": "Acute Bronchitis",
    "treatmentNotes": "Prescribed Azithromycin 500mg daily for 5 days. Steam inhalation advised."
  }
  ```
- **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Clinical encounter recorded successfully",
    "data": {
      "encounterId": 7,
      "patient": {
        "patientId": 1,
        "name": "John Doe",
        "dateOfBirth": "1985-04-12",
        "gender": "Male"
      },
      "clinician": {
        "clinicianId": 2,
        "name": "Dr. Robert Chen",
        "specialization": "General Medicine"
      },
      "encounterDate": "2026-10-25T14:30:00",
      "symptoms": "Low grade fever and productive cough",
      "diagnosis": "Acute Bronchitis",
      "treatmentNotes": "Prescribed Azithromycin 500mg daily for 5 days. Steam inhalation advised."
    }
  }
  ```

---

### 2.3 Comprehensive Patient Dossier
- **Endpoint**: `GET /api/patients/1/details`
- **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Full patient clinical history retrieved successfully",
    "data": {
      "patient": {
        "patientId": 1,
        "name": "John Doe",
        "dateOfBirth": "1985-04-12",
        "gender": "Male",
        "phone": "9876543210",
        "bloodGroup": "O+",
        "address": "12 Elm Street, Springfield",
        "createdAt": "2024-01-10T09:30:00"
      },
      "allergies": [
        {
          "allergyId": 1,
          "allergen": "Penicillin",
          "reaction": "Skin hives and urticaria",
          "severity": "Moderate"
        }
      ],
      "medicalHistory": [
        {
          "historyId": 1,
          "conditionName": "Mild Hyperlipidemia",
          "diagnosisDate": "2021-06-10",
          "status": "Active"
        },
        {
          "historyId": 2,
          "conditionName": "Essential Hypertension",
          "diagnosisDate": "2024-01-15",
          "status": "Active"
        }
      ],
      "encounters": [
        {
          "encounterId": 2,
          "encounterDate": "2024-02-18T11:15:00",
          "clinician": { "clinicianId": 1, "name": "Dr. Sarah Jenkins", "specialization": "Cardiology" },
          "symptoms": "Follow-up visit. Blood pressure stable at 128/82 mmHg",
          "diagnosis": "Hypertension - Controlled",
          "treatmentNotes": "Continue current medication regimen. Re-check in 3 months."
        },
        {
          "encounterId": 1,
          "encounterDate": "2024-01-15T10:30:00",
          "clinician": { "clinicianId": 1, "name": "Dr. Sarah Jenkins", "specialization": "Cardiology" },
          "symptoms": "Chest discomfort on exertion, mild shortness of breath",
          "diagnosis": "Essential Hypertension",
          "treatmentNotes": "Prescribed Amlodipine 5mg once daily."
        }
      ]
    }
  }
  ```

---

## 3. Global Exception & Error Handling Matrix

Centralized error handling is managed by [`GlobalExceptionHandler.java`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/backend/src/main/java/com/clinical/records/exception/GlobalExceptionHandler.java):

| Exception Type | Trigger Condition | HTTP Status Code | Response Payload Structure |
|---|---|---|---|
| `ResourceNotFoundException` | Requesting an ID that does not exist in MySQL (e.g. `GET /api/patients/9999`) | `404 Not Found` | `{"success": false, "message": "Patient not found with ID: 9999", "data": null}` |
| `DatabaseConstraintException` | Attempting to delete a patient who has linked encounters, allergies, or history | `409 Conflict` | `{"success": false, "message": "Cannot delete patient ID 1... Database referential integrity prevented deletion.", "data": null}` |
| `MethodArgumentNotValidException` | Submitting a form with missing mandatory fields (e.g. blank name or blank diagnosis) | `400 Bad Request` | `{"success": false, "message": "Validation failed for one or more fields", "data": {"name": "Patient name is required"}}` |
| `DataIntegrityViolationException` | Submitting a duplicate unique phone/email or violating a MySQL database constraint | `409 Conflict` | `{"success": false, "message": "Database integrity violation: The operation cannot be completed...", "data": null}` |
| `Generic Exception` | Uncaught runtime error or unexpected server failure | `500 Internal Server Error`| `{"success": false, "message": "An internal server error occurred: ...", "data": null}` |
