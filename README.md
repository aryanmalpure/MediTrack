# MediTrack
### *Patient Health Records*

An academic Database Management System (DBMS) course implementation built using **MySQL**, **Java with Spring Boot**, and **vanilla HTML/CSS/JavaScript**.

---

## 1. Project Overview

**MediTrack** is a relational database-driven health records management platform designed to store, manage, and audit clinical encounters, patient demographic records, medical histories, allergies, and prescribed medications. The project demonstrates core and advanced relational database concepts:

- **Formal Relational Modeling**: Boyce-Codd Normal Form (BCNF) schema design with candidate keys and functional dependency proofs.
- **Relational Integrity**: Primary Key, Foreign Key (`ON DELETE RESTRICT`), `CHECK`, `UNIQUE`, `NOT NULL`, and `DEFAULT` constraints.
- **Advanced Querying**: Multi-table `INNER JOIN` and `LEFT JOIN`, aggregate grouping with `HAVING`, correlated subqueries, set operations (`UNION`), and MySQL 8.0 window functions (`ROW_NUMBER()`, `DENSE_RANK()`).
- **Programmability**: Stored procedures with `IN`/`OUT` parameters, user-defined scalar functions, conditional branches (`IF`/`ELSEIF`), loops, `CASE` expressions, and custom error signaling (`SIGNAL SQLSTATE '45000'`).
- **Cursor Processing**: Explicit MySQL cursors with `CONTINUE HANDLER FOR NOT FOUND` for sequential row inspection and duplicate record prevention.
- **Audit & Triggers**: Automated event-driven audit logging with `AFTER INSERT`, `AFTER UPDATE`, and `AFTER DELETE` database triggers on encounters.
- **Transaction Control (TCL)**: ACID transactions demonstrating `START TRANSACTION`, `SAVEPOINT`, `ROLLBACK TO`, and `COMMIT`.
- **Database Security & DCL**: Least-privilege role segregation between application users and reporting analysts (`GRANT` / `REVOKE`).
- **Query Optimization**: B-Tree single and composite indexing analyzed with `EXPLAIN` execution plans.

---

## 2. Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript (ES6)
  - Student-styled, lightweight, responsive interface with clean typography, dark-blue headings, and minimal CSS without third-party frameworks.
- **Backend**: Java 17+ (tested and verified on Java 21 & Java 25), Spring Boot 3.3.5
  - Layered Architecture: Controller &rarr; Service &rarr; Repository &rarr; Entity.
- **Database**: MySQL Server 8.0+ / 9.x (InnoDB Storage Engine)
- **Database Connectivity**: Spring Data JPA / Hibernate & MySQL Connector/J
- **Build & Dependency Tool**: Apache Maven

---

## 3. Directory Structure

```text
DBMS MiniProject/
├── database/
│   ├── 01_schema_constraints.sql       # DDL: Tables, PKs, FKs, CHECK, UNIQUE, NOT NULL, DEFAULT
│   ├── 02_views_indexes.sql             # B-Tree single/composite indexes & views (summary, encounter history)
│   ├── 03_dcl_permissions.sql           # DCL: meditrack_app & meditrack_reporter, GRANT/REVOKE least privilege
│   ├── 04_transactions.sql              # TCL: START TRANSACTION, SAVEPOINT, ROLLBACK TO, COMMIT
│   ├── 05_complex_queries.sql           # 12 syllabus queries (multi-joins, subqueries, UNION, window functions)
│   ├── 06_mysql_procedural_sql.sql      # Procedural SQL: variables, IF/ELSEIF, loops, SIGNAL 45000
│   ├── 07_procedures_functions.sql      # Stored procedures (IN/OUT), scalar function (encounter count)
│   ├── 08_cursors_processing.sql        # Explicit cursor with NOT FOUND handler & duplicate detection
│   ├── 09_triggers_audit.sql            # AFTER INSERT, AFTER UPDATE, AFTER DELETE audit triggers
│   ├── 10_query_optimization.sql        # EXPLAIN execution plans (range scans vs table scans)
│   ├── 11_sample_data.sql               # Seed data for all 6 core tables + audit records
│   ├── schema.sql                       # Legacy consolidated schema
│   ├── sample_data.sql                  # Legacy sample seed data
│   └── advanced_queries.sql             # Legacy queries
├── docs/
│   ├── Database_Design.md               # Formal relational schema, FDs, and mathematical BCNF proof
│   ├── ER_Diagram.md                    # Entity-Relationship diagram in Mermaid specification
│   ├── ER_Diagram.svg                   # Vector graphical ER diagram showing tables, keys, and cardinalities
│   └── DBMS_Experiment_Guide.md         # Comprehensive 10-experiment lab manual with queries & viva questions
├── backend/
│   ├── pom.xml                          # Maven build configuration
│   └── src/
│       ├── main/
│       │   ├── java/com/clinical/records/
│       │   │   ├── ClinicalPatientRecordsApplication.java
│       │   │   ├── config/DataInitializer.java    # Seeds fictional records on first boot
│       │   │   ├── controller/                    # REST API Controllers (Dashboard, Patient, Clinician, Encounter)
│       │   │   ├── dto/                           # Data Transfer Objects & API Response wrappers
│       │   │   ├── entity/                        # JPA Entities: Patient, Clinician, Encounter, Allergy, History, Medication
│       │   │   ├── exception/                     # Global exception handler & custom exceptions
│       │   │   ├── repository/                    # Spring Data JPA repositories
│       │   │   └── service/                       # Business logic & referential integrity checks
│       │   └── resources/
│       │       ├── application.properties         # MySQL connection configuration
│       │       └── static/                        # Frontend served by Spring Boot
│       │           ├── css/style.css
│       │           ├── js/app.js
│       │           └── index.html
│       └── test/
│           ├── java/com/clinical/records/ClinicalPatientRecordsApplicationTests.java
│           └── resources/application.properties   # H2 in-memory test configuration
├── frontend/                                      # Standalone frontend copy
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
└── README.md
```

---

## 4. Relational Schema & Entity Specifications

- Database Name: `clinical_patient_db`
- Storage Engine: **InnoDB**
- Character Set: `utf8mb4`

### 4.1 Tables Summary

1. **`Patients`**
   - `patient_id` (INT, PK, AUTO_INCREMENT)
   - `name` (VARCHAR(100), NOT NULL)
   - `date_of_birth` (DATE, NOT NULL)
   - `gender` (VARCHAR(10), NOT NULL, `CHECK (gender IN ('Male', 'Female', 'Other'))`)
   - `phone` (VARCHAR(20), UNIQUE)
   - `email` (VARCHAR(100), UNIQUE)
   - `address` (VARCHAR(255))
   - `blood_group` (VARCHAR(10), `CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))`)
   - `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

2. **`Clinicians`**
   - `clinician_id` (INT, PK, AUTO_INCREMENT)
   - `name` (VARCHAR(100), NOT NULL)
   - `specialization` (VARCHAR(100), NOT NULL)
   - `phone` (VARCHAR(20), UNIQUE)
   - `email` (VARCHAR(100), UNIQUE)
   - `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

3. **`Encounters`**
   - `encounter_id` (INT, PK, AUTO_INCREMENT)
   - `patient_id` (INT, FK &rarr; `Patients(patient_id)`, ON DELETE RESTRICT)
   - `clinician_id` (INT, FK &rarr; `Clinicians(clinician_id)`, ON DELETE RESTRICT)
   - `encounter_date` (DATETIME, NOT NULL, DEFAULT CURRENT_TIMESTAMP)
   - `symptoms` (TEXT)
   - `diagnosis` (VARCHAR(255), NOT NULL)
   - `treatment_notes` (TEXT)
   - `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

4. **`Allergies`**
   - `allergy_id` (INT, PK, AUTO_INCREMENT)
   - `patient_id` (INT, FK &rarr; `Patients(patient_id)`, ON DELETE RESTRICT)
   - `allergy_name` (VARCHAR(100), NOT NULL)
   - `reaction` (VARCHAR(150))
   - `severity` (VARCHAR(20), NOT NULL, `CHECK (severity IN ('Mild', 'Moderate', 'Severe'))`)

5. **`Medical_History`**
   - `history_id` (INT, PK, AUTO_INCREMENT)
   - `patient_id` (INT, FK &rarr; `Patients(patient_id)`, ON DELETE RESTRICT)
   - `condition_name` (VARCHAR(150), NOT NULL)
   - `diagnosis_date` (DATE)
   - `notes` (TEXT)
   - `status` (VARCHAR(50), NOT NULL, `CHECK (status IN ('Active', 'Resolved', 'Chronic'))`)

6. **`Medications`**
   - `medication_id` (INT, PK, AUTO_INCREMENT)
   - `patient_id` (INT, FK &rarr; `Patients(patient_id)`, ON DELETE RESTRICT)
   - `medication_name` (VARCHAR(100), NOT NULL)
   - `dosage` (VARCHAR(50), NOT NULL)
   - `start_date` (DATE, NOT NULL)
   - `end_date` (DATE)
   - `instructions` (TEXT)
   - `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
   - *Constraint*: `CHECK (end_date IS NULL OR end_date >= start_date)`

7. **`Encounter_Audit`** *(Automated Audit Log Table)*
   - `audit_id` (INT, PK, AUTO_INCREMENT)
   - `encounter_id` (INT, NOT NULL)
   - `patient_id` (INT, NOT NULL)
   - `action_type` (VARCHAR(20), NOT NULL, `CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE'))`)
   - `change_timestamp` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
   - `old_diagnosis` (VARCHAR(255))
   - `new_diagnosis` (VARCHAR(255))
   - `details` (TEXT)

---

## 5. Structured SQL Scripts Overview

All SQL scripts are in the `database/` directory and use valid **MySQL 8.0+ syntax exclusively**:

| File | DBMS Topic Covered | Key Highlights |
|---|---|---|
| `01_schema_constraints.sql` | DDL & Integrity Constraints | Tables, PKs, FKs (`ON DELETE RESTRICT`), CHECK, UNIQUE, NOT NULL, DEFAULT |
| `02_views_indexes.sql` | Views & B-Tree Indexes | Composite index `(patient_id, encounter_date)`, `vw_patient_summary`, `vw_patient_encounter_history` |
| `03_dcl_permissions.sql` | DCL Security & Roles | App user (`meditrack_app`) vs Reporter (`meditrack_reporter`), least-privilege `GRANT`/`REVOKE` |
| `04_transactions.sql` | TCL & ACID Properties | `START TRANSACTION`, `SAVEPOINT sp_before_medication`, `ROLLBACK TO`, `COMMIT`, `ROLLBACK` |
| `05_complex_queries.sql` | Advanced SQL Queries | 12 queries: multi-table joins, subqueries, UNION, GROUP BY/HAVING, window functions (`ROW_NUMBER()`, `DENSE_RANK()`) |
| `06_mysql_procedural_sql.sql` | Procedural SQL Blocks | Stored routine with variables, IF/ELSEIF/ELSE risk calculator, loops, `SIGNAL SQLSTATE '45000'` |
| `07_procedures_functions.sql` | Procedures & Functions | `sp_register_encounter` (IN/OUT), `sp_get_patient_history`, `sp_update_medication`, `fn_patient_encounter_count` |
| `08_cursors_processing.sql` | Explicit Cursors | `DECLARE cur CURSOR FOR...`, `CONTINUE HANDLER FOR NOT FOUND`, row-by-row iteration & duplicate detection |
| `09_triggers_audit.sql` | Triggers & Auditing | `trg_after_encounter_insert`, `trg_after_encounter_update`, `trg_after_encounter_delete` auditing to `Encounter_Audit` |
| `10_query_optimization.sql` | EXPLAIN Analysis | `EXPLAIN` query execution plans, index scans vs table scans, cost and row count comparisons |
| `11_sample_data.sql` | Sample Data Insertion | Relational seed data covering all tables and edge cases |

---

## 6. Setup and Running Instructions

### 6.1 Prerequisites
- **Java Development Kit (JDK)**: JDK 17, 21, or 25 installed (`java -version`).
- **Apache Maven**: Maven 3.8+ installed (`mvn -version`).
- **MySQL Server**: MySQL 8.0+ or 9.x running on port `3306`.
- **IntelliJ IDEA** or any standard terminal / browser.

### 6.2 Step 1: Database Setup
1. Launch MySQL Command Line Client:
   ```bash
   mysql -u root -p
   ```
2. Run the schema creation and constraints script:
   ```sql
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/01_schema_constraints.sql;
   ```
3. Run the views and indexes:
   ```sql
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/02_views_indexes.sql;
   ```
4. Load the enhanced sample data:
   ```sql
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/11_sample_data.sql;
   ```
5. *(Optional)* Load procedures, functions, cursors, and triggers:
   ```sql
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/07_procedures_functions.sql;
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/08_cursors_processing.sql;
   source C:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/09_triggers_audit.sql;
   ```

### 6.3 Step 2: Configure MySQL Credentials in Spring Boot
Open `backend/src/main/resources/application.properties` and verify your MySQL password:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/clinical_patient_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=17May@2006
```

### 6.4 Step 3: Run the Application
In your terminal:
```powershell
cd backend
mvn spring-boot:run
```

### 6.5 Step 4: Access the Web Application
Open your web browser and navigate to:
```
http://localhost:8080/
```

---

## 7. REST API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/dashboard/stats` | Total registered patients and clinical encounters count |
| `GET` | `/api/dashboard/recent-patients` | Top 5 most recently registered patients |
| `GET` | `/api/patients` | All patients (supports query filter: `?search=term`) |
| `GET` | `/api/patients/{id}` | Patient record by ID |
| `GET` | `/api/patients/{id}/details` | Full clinical dossier (demographics, encounters, allergies, medical history) |
| `POST` | `/api/patients` | Register a new patient |
| `PUT` | `/api/patients/{id}` | Update patient details |
| `DELETE` | `/api/patients/{id}` | Safe deletion (blocked if encounters, allergies, history, or medications exist) |
| `GET` | `/api/clinicians` | List all clinicians |
| `POST` | `/api/clinicians` | Add a new clinician |
| `GET` | `/api/encounters` | List all clinical encounters |
| `POST` | `/api/encounters` | Record a new encounter |
| `GET` | `/api/encounters/patient/{patientId}` | Chronological consultation history for a given patient |

---

## 8. Documentation Files

Comprehensive documentation is provided in the `docs/` directory:
- [Database_Design.md](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/Database_Design.md): Relational schema, functional dependency sets, candidate keys, and mathematical proofs for 1NF, 2NF, 3NF, and BCNF compliance.
- [ER_Diagram.md](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/ER_Diagram.md): Complete Entity-Relationship model written in Mermaid format.
- [ER_Diagram.svg](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/ER_Diagram.svg): Vector SVG graphic illustrating entities, attributes, primary/foreign keys, and cardinalities.
- [DBMS_Experiment_Guide.md](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/DBMS_Experiment_Guide.md): 10-experiment manual with step-by-step SQL scripts, expected tabular outputs, and viva voce question sets.
