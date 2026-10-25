# MediTrack – Patient Health Records
## Document 5: DBMS Concepts Mapping & Implementation Evidence

This document maps all fifteen semester-long DBMS syllabus concepts to their exact implementations, source files, and test results within MediTrack.

---

## 1. Comprehensive Concepts Verification Matrix

| # | DBMS Syllabus Concept | Status in MediTrack | Relevant File / Object | Live Test Status |
|---|---|---|---|---|
| 1 | **ER / Relational Modeling** | **Implemented & Verified** | [`docs/ER_Diagram.svg`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/ER_Diagram.svg), `01_schema_constraints.sql` | Verified in MySQL 9.6 |
| 2 | **Normalization (BCNF)** | **Implemented & Verified** | [`docs/Database_Design.md`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/Database_Design.md) | Verified mathematically |
| 3 | **DDL & Integrity Constraints** | **Implemented & Verified** | [`database/01_schema_constraints.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/01_schema_constraints.sql) | 7 tables created with PK, FK, CHECK, UNIQUE |
| 4 | **B-Tree & Composite Indexes** | **Implemented & Verified** | [`database/02_views_indexes.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/02_views_indexes.sql) | Indexes verified with `SHOW INDEX` |
| 5 | **Database Views** | **Implemented & Verified** | [`database/02_views_indexes.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/02_views_indexes.sql) | `vw_patient_summary`, `vw_patient_encounter_history` |
| 6 | **DCL (GRANT & REVOKE)** | **Implemented & Verified** | [`database/03_dcl_permissions.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/03_dcl_permissions.sql) | `meditrack_app`, `meditrack_reporter` verified |
| 7 | **TCL (ACID Transactions)** | **Implemented & Verified** | [`database/04_transactions.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/04_transactions.sql) | `COMMIT`, `SAVEPOINT`, `ROLLBACK TO` verified |
| 8 | **Complex Queries (12 Queries)**| **Implemented & Verified** | [`database/05_complex_queries.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/05_complex_queries.sql) | All 12 executed cleanly in MySQL |
| 9 | **MySQL Procedural SQL** | **Implemented & Verified** | [`database/06_mysql_procedural_sql.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/06_mysql_procedural_sql.sql) | `sp_analyze_patient_clinical_risk`, loops |
| 10 | **Stored Procedures** | **Implemented & Verified** | [`database/07_procedures_functions.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/07_procedures_functions.sql) | `sp_register_encounter`, `sp_get_patient_history` |
| 11 | **User-Defined Functions** | **Implemented & Verified** | [`database/07_procedures_functions.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/07_procedures_functions.sql) | `fn_patient_encounter_count` |
| 12 | **Explicit Cursors** | **Implemented & Verified** | [`database/08_cursors_processing.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/08_cursors_processing.sql) | `cur_patient_encounters` with `NOT FOUND` handler |
| 13 | **Duplicate Prevention** | **Implemented & Verified** | [`database/08_cursors_processing.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/08_cursors_processing.sql) | `sp_safe_register_encounter_with_duplicate_check` |
| 14 | **Audit Triggers** | **Implemented & Verified** | [`database/09_triggers_audit.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/09_triggers_audit.sql) | `trg_after_encounter_insert/update/delete` |
| 15 | **Query Optimization (EXPLAIN)**| **Implemented & Verified** | [`database/10_query_optimization.sql`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/database/10_query_optimization.sql) | Range scans vs table scans evaluated |

---

## 2. In-Depth Concept Explanations & Viva Code Snippets

### Concept 1: Database Design and ER/EER Modeling
- **Object**: ER Diagram and relational mapping.
- **Why useful**: Models entities, attributes, primary/foreign keys, and 1:N relationships between patients, clinicians, consultations, allergies, medical histories, and medications.
- **Viva Snippet**:
  ```sql
  -- Cardinality: 1 Patient to N Encounters (Foreign Key with ON DELETE RESTRICT)
  CONSTRAINT fk_encounters_patient FOREIGN KEY (patient_id) 
      REFERENCES Patients(patient_id) ON DELETE RESTRICT ON UPDATE CASCADE
  ```

### Concept 2: Normalization up to BCNF
- **Object**: Candidate keys and functional dependency proofs in [`docs/Database_Design.md`](file:///c:/Users/Aryan/OneDrive/Desktop/DBMS MiniProject/docs/Database_Design.md).
- **Why useful**: Eliminates update, insertion, and deletion anomalies. Ensures no duplicate clinician or patient demographic details are repeated inside encounter rows.
- **Viva Explanation**: Every non-trivial functional dependency $X \rightarrow Y$ in the schema has a determinant $X$ that is a candidate key (superkey). Hence, no partial or transitive dependencies exist.

### Concept 3: DDL and Database Constraints
- **Object**: `database/01_schema_constraints.sql`.
- **Why useful**: Guarantees domain integrity at the database engine level.
- **Viva Snippet**:
  ```sql
  CREATE TABLE Patients (
      patient_id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      date_of_birth DATE NOT NULL,
      gender VARCHAR(10) NOT NULL,
      phone VARCHAR(20) UNIQUE,
      email VARCHAR(100) UNIQUE,
      blood_group VARCHAR(10),
      CONSTRAINT chk_patient_gender CHECK (gender IN ('Male', 'Female', 'Other')),
      CONSTRAINT chk_patient_blood_group CHECK (blood_group IS NULL OR blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
  ) ENGINE=InnoDB;
  ```

### Concept 4: B-Tree and Composite Indexes
- **Object**: `database/02_views_indexes.sql`.
- **Why useful**: Speeds up chronological consultation timeline lookups by patient ID without filesort.
- **Viva Snippet**:
  ```sql
  -- Composite index on (patient_id, encounter_date DESC)
  CREATE INDEX idx_encounters_patient_date ON Encounters(patient_id, encounter_date DESC);
  ```

### Concept 5: Database Views
- **Object**: `vw_patient_summary` and `vw_patient_encounter_history` in `database/02_views_indexes.sql`.
- **Why useful**: Encapsulates multi-table joins and protects confidential patient addresses from reporting analysts.
- **Viva Snippet**:
  ```sql
  CREATE OR REPLACE VIEW vw_patient_summary AS
  SELECT 
      p.patient_id, p.name AS patient_name,
      TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
      (SELECT COUNT(*) FROM Encounters e WHERE e.patient_id = p.patient_id) AS total_encounters,
      (SELECT COUNT(*) FROM Allergies a WHERE a.patient_id = p.patient_id) AS total_allergies
  FROM Patients p;
  ```

### Concept 6: DCL (Data Control Language - GRANT & REVOKE)
- **Object**: `database/03_dcl_permissions.sql`.
- **Why useful**: Enforces principle of least privilege between operational application user (`meditrack_app`) and analytical reporting user (`meditrack_reporter`).
- **Viva Snippet**:
  ```sql
  -- Grant application full CRUD on Patients:
  GRANT SELECT, INSERT, UPDATE, DELETE ON clinical_patient_db.Patients TO 'meditrack_app'@'localhost';

  -- Grant reporting user read-only access to view ONLY:
  GRANT SELECT ON clinical_patient_db.vw_patient_summary TO 'meditrack_reporter'@'localhost';

  -- Revoke accidental DELETE grant:
  REVOKE DELETE ON clinical_patient_db.Patients FROM 'meditrack_reporter'@'localhost';
  ```

### Concept 7: TCL (Transaction Control Language - ACID)
- **Object**: `database/04_transactions.sql`.
- **Why useful**: Ensures atomic operations when recording a consultation and prescription together.
- **Viva Snippet**:
  ```sql
  START TRANSACTION;
  INSERT INTO Encounters (patient_id, clinician_id, diagnosis) VALUES (1, 2, 'Hypertension');
  SAVEPOINT sp_before_medication;
  -- If medication insertion fails:
  ROLLBACK TO SAVEPOINT sp_before_medication;
  -- Record alternative valid medication:
  INSERT INTO Medications (patient_id, medication_name, dosage, start_date) VALUES (1, 'Amlodipine', '5mg', CURDATE());
  COMMIT;
  ```

### Concept 8: Complex SQL Queries
- **Object**: `database/05_complex_queries.sql` (12 comprehensive syllabus queries).
- **Why useful**: Demonstrates `INNER JOIN`, `LEFT JOIN` for patients with zero encounters, `HAVING` clause, `UNION` for risk cohorts, and window functions (`ROW_NUMBER()`, `DENSE_RANK()`).
- **Viva Snippet**:
  ```sql
  -- Rank consultation encounters chronologically per patient using window function:
  SELECT 
      encounter_id, patient_id, encounter_date, diagnosis,
      ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY encounter_date DESC) AS consultation_seq
  FROM Encounters;
  ```

### Concept 9: MySQL Procedural SQL (Control Flow & Signals)
- **Object**: `database/06_mysql_procedural_sql.sql` (`sp_analyze_patient_clinical_risk`).
- **Why useful**: Implements server-side decision trees (`IF/ELSEIF/ELSE`, `CASE`), loops, and custom error signaling.
- **Viva Snippet**:
  ```sql
  IF v_patient_exists = 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Risk Evaluation Failed: Patient ID does not exist in the system.';
  END IF;
  ```

### Concept 10: Stored Procedures
- **Object**: `sp_register_encounter` and `sp_get_patient_history` in `database/07_procedures_functions.sql`.
- **Why useful**: Pre-compiled database routine with `IN` and `OUT` parameters reducing network round-trips.
- **Viva Snippet**:
  ```sql
  CALL sp_register_encounter(1, 2, NOW(), 'Symptoms', 'Diagnosis', 'Notes', @new_enc_id);
  SELECT @new_enc_id AS Generated_Encounter_ID;
  ```

### Concept 11: Stored Functions
- **Object**: `fn_patient_encounter_count` in `database/07_procedures_functions.sql`.
- **Why useful**: Deterministic scalar function callable directly inside `SELECT` projections.
- **Viva Snippet**:
  ```sql
  SELECT patient_id, name, fn_patient_encounter_count(patient_id) AS total_visits 
  FROM Patients;
  ```

### Concept 12: Explicit Cursors & Batch Processing
- **Object**: `sp_generate_patient_encounter_brief` in `database/08_cursors_processing.sql`.
- **Why useful**: Iterates sequentially over encounter result sets using `DECLARE CURSOR`, `FETCH`, and `CONTINUE HANDLER FOR NOT FOUND`.
- **Viva Snippet**:
  ```sql
  DECLARE cur CURSOR FOR SELECT encounter_id, encounter_date, diagnosis FROM Encounters WHERE patient_id = p_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  OPEN cur;
  read_loop: LOOP
      FETCH cur INTO v_enc_id, v_date, v_diag;
      IF v_done = 1 THEN LEAVE read_loop; END IF;
      -- process row
  END LOOP;
  CLOSE cur;
  ```

### Concept 13: Duplicate Prevention
- **Object**: `sp_safe_register_encounter_with_duplicate_check` in `database/08_cursors_processing.sql`.
- **Why useful**: Blocks doctors or staff from inadvertently inserting double consultation entries within a +/- 30-minute window for the same patient.
- **Viva Snippet**:
  ```sql
  SELECT COUNT(*) INTO v_dup 
  FROM Encounters 
  WHERE patient_id = p_pid AND clinician_id = p_cid 
    AND encounter_date BETWEEN DATE_SUB(p_date, INTERVAL 30 MINUTE) AND DATE_ADD(p_date, INTERVAL 30 MINUTE);
  IF v_dup > 0 THEN
      SET p_msg = 'DUPLICATE_REJECTED';
  END IF;
  ```

### Concept 14: Database Triggers & Audit Trail
- **Object**: `trg_after_encounter_insert`, `trg_after_encounter_update`, `trg_after_encounter_delete` in `database/09_triggers_audit.sql`.
- **Why useful**: Automatic, tamper-proof logging of diagnosis modifications into `Encounter_Audit` without relying on application code.
- **Viva Snippet**:
  ```sql
  CREATE TRIGGER trg_after_encounter_update
  AFTER UPDATE ON Encounters
  FOR EACH ROW
  BEGIN
      IF OLD.diagnosis <> NEW.diagnosis THEN
          INSERT INTO Encounter_Audit (encounter_id, patient_id, action_type, old_diagnosis, new_diagnosis, changed_at, changed_by)
          VALUES (NEW.encounter_id, NEW.patient_id, 'UPDATE', OLD.diagnosis, NEW.diagnosis, NOW(), CURRENT_USER());
      END IF;
  END;
  ```

### Concept 15: Query Optimization with EXPLAIN
- **Object**: `database/10_query_optimization.sql`.
- **Why useful**: Inspects query execution plans, verifying index usage (`type: range`, `key: idx_encounters_patient_date`) versus unindexed full table scans (`type: ALL`).
- **Viva Snippet**:
  ```sql
  EXPLAIN SELECT * FROM Encounters WHERE patient_id = 1 AND encounter_date >= '2024-01-01';
  -- Result: type: range, key: idx_encounters_patient_date, Extra: Using index condition
  ```
