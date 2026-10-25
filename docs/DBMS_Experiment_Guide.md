# MediTrack – Complete DBMS Practical & Lab Examination Guide

An experiment-by-experiment laboratory manual demonstrating all core Database Management System (DBMS) concepts using **MySQL 8.0+** and the **MediTrack – Patient Health Records** schema.

---

## Quick Reference: Execution Sequence

To execute the entire database system in sequence on MySQL:

```sql
source database/01_schema_constraints.sql;
source database/02_views_indexes.sql;
source database/11_sample_data.sql;
source database/03_dcl_permissions.sql;
source database/04_transactions.sql;
source database/05_complex_queries.sql;
source database/06_mysql_procedural_sql.sql;
source database/07_procedures_functions.sql;
source database/08_cursors_processing.sql;
source database/09_triggers_audit.sql;
source database/10_query_optimization.sql;
```

---

## Experiment 1: Data Definition Language (DDL) & Integrity Constraints

- **Objective**: Create normalized relational tables and enforce domain, entity, and referential integrity using Primary Keys, Foreign Keys, Unique Keys, and Check constraints.
- **Source Script**: `database/01_schema_constraints.sql`
- **Key Concepts Demonstrated**:
  - `PRIMARY KEY (AUTO_INCREMENT)`
  - `FOREIGN KEY ... REFERENCES ... ON DELETE RESTRICT ON UPDATE CASCADE`
  - `CHECK (gender IN ('Male', 'Female', 'Other'))`
  - `CHECK (date_of_birth <= CURRENT_DATE)`
  - `CHECK (end_date IS NULL OR end_date >= start_date)`
  - `UNIQUE (email)`

### Verification Query:
```sql
USE clinical_patient_db;
SHOW TABLES;
DESCRIBE Patients;
DESCRIBE Encounters;
```

### Expected Output:
Tables `Patients`, `Clinicians`, `Encounters`, `Allergies`, `Medical_History`, `Medications`, and `Encounter_Audit` created under the `InnoDB` storage engine.

---

## Experiment 2: B-Tree Indexing & Security Views

- **Objective**: Improve query search performance and restrict direct base-table data exposure using indexes and views.
- **Source Script**: `database/02_views_indexes.sql`
- **Key Concepts Demonstrated**:
  - Secondary B-Tree indexes: `idx_patients_name`, `idx_encounters_date`, `idx_encounters_clinician_id`.
  - Composite Index: `idx_encounters_patient_date ON Encounters(patient_id, encounter_date DESC)`.
  - Analytical View: `vw_patient_summary` (computed age and aggregate consultation stats).
  - Reporting View: `vw_patient_encounter_history` (relational consultation histories).

### Verification Query:
```sql
SHOW INDEX FROM Encounters;
SELECT * FROM vw_patient_summary LIMIT 3;
SELECT * FROM vw_patient_encounter_history LIMIT 3;
```

---

## Experiment 3: Data Control Language (DCL) – Permissions & Privileges

- **Objective**: Implement the Principle of Least Privilege by configuring distinct database users for transactional operations and read-only reporting.
- **Source Script**: `database/03_dcl_permissions.sql`
- **Key Concepts Demonstrated**:
  - User creation: `CREATE USER 'meditrack_app'@'localhost'` and `'meditrack_reporter'@'localhost'`.
  - Granting CRUD privileges on operational tables to `meditrack_app`.
  - Restricting `meditrack_reporter` to read-only `SELECT` access strictly on views.
  - Revocation of accidental privileges using `REVOKE`.
  - Verification using `SHOW GRANTS FOR ...`.

### Verification Statements:
```sql
SHOW GRANTS FOR 'meditrack_app'@'localhost';
SHOW GRANTS FOR 'meditrack_reporter'@'localhost';
```

---

## Experiment 4: Transaction Control Language (TCL) – ACID Properties & Savepoints

- **Objective**: Demonstrate atomicity and consistency during multi-table writes using transactions, savepoints, partial rollbacks, and commits.
- **Source Script**: `database/04_transactions.sql`
- **Key Concepts Demonstrated**:
  - `START TRANSACTION`: Initiates atomic unit of work.
  - Multi-table write: Recording an encounter and prescribing corresponding medication.
  - `SAVEPOINT sv_after_encounter_created`: Marks intermediate state.
  - `ROLLBACK TO SAVEPOINT sv_after_encounter_created`: Cancels invalid medication write while retaining the encounter.
  - `COMMIT`: Persists valid state.
  - `ROLLBACK`: Reverses all operations when an unrecoverable failure occurs.

---

## Experiment 5: Complex SQL Queries & Analytics

- **Objective**: Formulate queries demonstrating set operations, multi-table joins, subqueries, aggregations, and window functions.
- **Source Script**: `database/05_complex_queries.sql`
- **Queries Covered**:
  1. `INNER JOIN` (Patient details with Encounters).
  2. `LEFT JOIN` (Identifying patients with zero consultations).
  3. Multiple Joins (Patients + Clinicians + Encounters).
  4. Correlated Subquery (Patients with above-average consultation counts).
  5. `UNION` (Aggregating severe allergy patients and chronic condition patients).
  6. `GROUP BY` and `HAVING` (Clinicians handling multiple consultations).
  7. Aggregate Functions (`COUNT`, `MIN`, `MAX`, `AVG`).
  8. Window Functions (`ROW_NUMBER()` for encounter sequence, `DENSE_RANK()` for clinician ranking).
  9. Parameterized Patient Complete History.
  10. Filter for patients with neither allergies nor history entries.
  11. Most recent encounter per patient using CTE & `ROW_NUMBER()`.
  12. Temporal Monthly Encounter Distribution (`DATE_FORMAT`).

---

## Experiment 6: MySQL Procedural SQL (Control Flow & Exception Handling)

- **Objective**: Write stored procedural programs demonstrating variables, branches, loops, and error handlers.
- **Source Script**: `database/06_mysql_procedural_sql.sql`
- **Key Concepts Demonstrated**:
  - Local variables: `DECLARE v_score INT DEFAULT 0;`
  - Values assignment: `SET` and `SELECT ... INTO`
  - Branching: `IF ... ELSEIF ... ELSE` and `CASE ... WHEN`
  - Loops: `LOOP` with `LEAVE` and `ITERATE`; `WHILE` loop
  - Exception handler: `DECLARE EXIT HANDLER FOR SQLEXCEPTION`
  - Custom error raising: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...'`

### Verification Execution:
```sql
CALL sp_analyze_patient_clinical_risk(1, @tier, @summary);
SELECT @tier, @summary;
```

---

## Experiment 7: Stored Procedures & User-Defined Functions

- **Objective**: Encapsulate reusable database logic into stored procedures with IN/OUT parameters and deterministic scalar functions.
- **Source Script**: `database/07_procedures_functions.sql`
- **Routines Implemented**:
  1. `sp_register_encounter`: Validates patient and clinician foreign keys, checks date validity, and returns generated encounter ID.
  2. `sp_get_patient_history`: Returns consultation history for a given patient.
  3. `sp_update_medication`: Validates and updates drug dosage with date integrity checks.
  4. `fn_patient_encounter_count`: Scalar function returning total encounters for a patient ID.

### Verification Execution:
```sql
CALL sp_register_encounter(1, 2, NOW(), 'Sore throat', 'Pharyngitis', 'Rest', @new_id);
SELECT @new_id;
SELECT patient_id, name, fn_patient_encounter_count(patient_id) FROM Patients;
```

---

## Experiment 8: Cursors & Row-by-Row Processing

- **Objective**: Implement explicit server-side cursors to sequentially fetch and process tuples with duplicate protection.
- **Source Script**: `database/08_cursors_processing.sql`
- **Key Concepts Demonstrated**:
  - Explicit cursor declaration: `DECLARE cur_patient_encounters CURSOR FOR ...`
  - State control: `DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;`
  - Cursor lifecycle: `OPEN`, `FETCH`, and `CLOSE`.
  - Duplicate Prevention: `sp_safe_register_encounter_with_duplicate_check` inspects a 30-minute window before allowing encounter creation.

### Verification Execution:
```sql
CALL sp_generate_patient_encounter_brief(1, @brief);
SELECT @brief;
```

---

## Experiment 9: Database Triggers & Audit Trail

- **Objective**: Automatically record insert, update, and delete events into an audit log without modifying application code.
- **Source Script**: `database/09_triggers_audit.sql`
- **Key Concepts Demonstrated**:
  - `AFTER INSERT ON Encounters` (`trg_after_encounter_insert`)
  - `AFTER UPDATE ON Encounters` (`trg_after_encounter_update` - records previous and updated diagnoses)
  - `AFTER DELETE ON Encounters` (`trg_after_encounter_delete`)
  - `OLD` and `NEW` pseudo-row record access.
  - Timestamping and user tracking with `CURRENT_USER()`.

### Verification Execution:
```sql
SELECT * FROM Encounter_Audit ORDER BY audit_id DESC LIMIT 5;
```

---

## Experiment 10: Query Optimization & EXPLAIN Execution Plans

- **Objective**: Analyze query cost, access types, key usage, and row filtration using MySQL `EXPLAIN`.
- **Source Script**: `database/10_query_optimization.sql`
- **Concepts Evaluated**:
  - **Full Table Scan (`type: ALL`)**: Occurs when no index is present or leading wildcards (`%term%`) are used.
  - **Index Range Scan (`type: range`)**: Occurs on indexed column prefix searches (`WHERE name LIKE 'John%'`) or date boundaries.
  - **Equi-Join Optimization (`type: ref` / `eq_ref`)**: Optimal single-row lookups across foreign keys.
  - Eliminating filesorts using pre-sorted composite indexes (`idx_encounters_patient_date`).

### Verification Statement:
```sql
EXPLAIN SELECT * FROM Encounters WHERE patient_id = 1 AND encounter_date >= '2024-01-01' ORDER BY encounter_date DESC;
```

---

## Viva / Oral Exam Questions & Model Answers

1. **Why is BCNF strictly stronger than 3NF?**
   - *Answer*: 3NF permits a dependency $X \rightarrow A$ if $A$ is a prime attribute (part of a candidate key), even if $X$ is not a superkey. BCNF eliminates this loophole by strictly requiring every determinant $X$ to be a superkey.
2. **What is the difference between `CHAR_LENGTH` and `LENGTH` in MySQL?**
   - *Answer*: `LENGTH` measures bytes, while `CHAR_LENGTH` measures characters. In `utf8mb4`, multi-byte characters consume up to 4 bytes each, making `CHAR_LENGTH` the correct choice for string validation.
3. **What is the advantage of a Composite Index?**
   - *Answer*: A composite index on `(patient_id, encounter_date)` allows MySQL to filter by `patient_id` and read rows already sorted by `encounter_date`, avoiding an expensive in-memory or disk `Using filesort`.
4. **Why are Triggers executed on the server side?**
   - *Answer*: Server-side triggers ensure business rules and audit logs are guaranteed regardless of whether the modification originates from the Spring Boot application, MySQL Workbench, or a batch CLI script.
