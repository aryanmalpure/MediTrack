# MediTrack – Patient Health Records
## Document 7: Windows Setup, Execution & Testing Guide

This guide provides instructions to configure, run, and test MediTrack from scratch on a Windows workstation.

---

## 1. System Prerequisites

Ensure the following tools are installed on your Windows machine:
1. **MySQL Community Server 8.0+ or 9.x** (Configured on default port `3306`).
2. **Java Development Kit (JDK 17, 21, or 25)** (Verify in PowerShell: `java -version`).
3. **Apache Maven 3.8+** (Verify in PowerShell: `mvn -version`).
4. **Web Browser** (Google Chrome, Microsoft Edge, Mozilla Firefox).

---

## 2. Database Setup & Script Execution Order

### Step 2.1: Start MySQL Server
If MySQL is not running as a Windows background service, start it via PowerShell (run as Administrator) or the Windows Services panel:
```powershell
net start MySQL90    # Or 'net start MySQL80' depending on your service name
```

### Step 2.2: Log in to MySQL CLI
```bash
mysql -u root -p
# Enter your MySQL root password (e.g. 17May@2006)
```

### Step 2.3: Execute Scripts in Exact Dependency Order
Run the scripts sequentially using the `source` command with forward slashes:

```sql
-- Step 1: Create all 7 tables in parent-to-child order and date-validation triggers
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/01_schema_constraints.sql;

-- Step 2: Create B-Tree indexes and reporting views
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/02_views_indexes.sql;

-- Step 3: Populate comprehensive sample records
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/11_sample_data.sql;

-- Step 4: Configure least-privilege user accounts (meditrack_app & meditrack_reporter)
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/03_dcl_permissions.sql;

-- Step 5: Install procedural risk evaluation routines & loops
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/06_mysql_procedural_sql.sql;

-- Step 6: Install stored procedures and functions
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/07_procedures_functions.sql;

-- Step 7: Install cursor processing & duplicate detection procedures
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/08_cursors_processing.sql;

-- Step 8: Install automated audit triggers on Encounters
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/09_triggers_audit.sql;

-- Step 9 (Optional): Execute complex query suite & EXPLAIN optimization
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/05_complex_queries.sql;
source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/10_query_optimization.sql;
```

### Step 2.4: Verify Database State in MySQL
```sql
USE clinical_patient_db;
SHOW TABLES;
```
Expected Output:
```text
+-------------------------------+
| Tables_in_clinical_patient_db |
+-------------------------------+
| allergies                     |
| clinicians                    |
| encounter_audit               |
| encounters                    |
| medical_history               |
| medications                   |
| patients                      |
| view_patient_encounters       |
| vw_patient_encounter_history  |
| vw_patient_summary            |
+-------------------------------+
10 rows in set
```

---

## 3. Running the Backend & Frontend Application

### Step 3.1: Verify Database Password in Backend Configuration
Open `backend/src/main/resources/application.properties` and verify your MySQL password:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/clinical_patient_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=17May@2006
```

### Step 3.2: Launch the Spring Boot Server
Open PowerShell and navigate to the `backend` folder:
```powershell
cd "C:\Users\Aryan\OneDrive\Desktop\DBMS MiniProject\backend"
mvn spring-boot:run
```
*(Alternatively, run the packaged JAR directly):*
```powershell
java -jar target/clinical-patient-records-1.0.0.jar
```

Wait until the console outputs:
```text
Started ClinicalPatientRecordsApplication in ... seconds
Tomcat started on port 8080 (http)
```

### Step 3.3: Open the Web Application
Open your browser and navigate to:
```
http://localhost:8080/
```

---

## 4. Feature Testing & Verification Checklist

| Test Scenario | Action to Perform in UI | Expected System Behavior | Verification in MySQL |
|---|---|---|---|
| **1. Dashboard Counts** | Open `http://localhost:8080/` | Total Patients: **5**, Total Encounters: **6** | `SELECT COUNT(*) FROM Patients; SELECT COUNT(*) FROM Encounters;` |
| **2. Patient Search** | Type `emily` or `2` into search bar and click Search | Table filters to Emily Watson (ID #2) | `SELECT * FROM Patients WHERE name LIKE '%emily%';` |
| **3. Patient Registration** | Click `+ Register New Patient`, enter valid fields, click Save | Success banner appears, patient ID generated | `SELECT * FROM Patients ORDER BY patient_id DESC LIMIT 1;` |
| **4. Future DOB Rejection** | Attempt to add a patient with a DOB in year `2099` | Operation blocked by trigger `trg_patients_validate_dob_insert` with error message | Row is NOT inserted into MySQL |
| **5. Referential Integrity (Safe Deletion)** | Click Delete on **Lucas Gray (ID #5)** | Confirms deletion and record is deleted (0 active links) | `SELECT * FROM Patients WHERE patient_id = 5;` returns 0 rows |
| **6. Referential Integrity (Blocked Deletion)**| Click Delete on **John Doe (ID #1)** | System displays red alert banner: Deletion rejected due to active encounters & allergies | `SELECT * FROM Patients WHERE patient_id = 1;` row is safely preserved |
| **7. Add Clinician** | Open Clinicians tab, enter doctor name & specialty, click submit | New clinician appears in table & encounter dropdown | `SELECT * FROM Clinicians ORDER BY clinician_id DESC LIMIT 1;` |
| **8. Record Encounter** | Open Encounters tab, select patient & doctor, fill diagnosis, click submit | Encounter added to chronological list | `SELECT * FROM Encounters ORDER BY encounter_id DESC LIMIT 1;` |
| **9. Audit Trigger** | Record an encounter (Scenario 8) | Trigger `trg_after_encounter_insert` automatically logs event | `SELECT * FROM Encounter_Audit ORDER BY audit_id DESC LIMIT 1;` shows `action_type = 'INSERT'` |
| **10. Patient Dossier** | Click `View Details` on any patient | Displays demographic card, known allergies, chronic illnesses, and past visits | Verified across `Allergies`, `Medical_History`, `Encounters` tables |

---

## 5. Troubleshooting Common Issues

### Issue 1: `Port 8080 was already in use`
- **Cause**: Another background process or previous run of Tomcat is still holding port 8080.
- **Fix**: Open PowerShell as Administrator and terminate the process holding port 8080:
  ```powershell
  $processId = (Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue).OwningProcess
  if ($processId) { Stop-Process -Id $processId -Force }
  ```

### Issue 2: `Access denied for user 'root'@'localhost'`
- **Cause**: MySQL password mismatch in `backend/src/main/resources/application.properties`.
- **Fix**: Update `spring.datasource.password` to match your actual local MySQL root password.

### Issue 3: `ERROR 3814: An expression of a check constraint cannot contain a non-deterministic function`
- **Cause**: Running legacy DDL containing `CHECK (date_of_birth <= CURRENT_DATE)`.
- **Fix**: Use the corrected [`database/01_schema_constraints.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/01_schema_constraints.sql), which replaces non-deterministic CHECK constraints with `BEFORE INSERT`/`BEFORE UPDATE` triggers.
