# MediTrack – Patient Health Records
## Document 8: Viva Preparation Guide, Project Elevator Pitch & 30 Core Questions

---

## 1. Two-Minute Project Introduction (Elevator Pitch)

> *"Good morning / afternoon professors. My DBMS project is titled **MediTrack – Patient Health Records**. It is a relational database-driven web application designed to manage clinical consultations, patient demographic profiles, allergies, chronic medical histories, and prescribed pharmacotherapy.*
>
> *The primary objective of MediTrack is to demonstrate core and advanced Database Management System concepts on an industry-standard **MySQL 9.6 / 8.0** engine backed by a **Java Spring Boot** REST backend and a clean, responsive frontend. Rather than focusing on unnecessary commercial features like payment gateways or third-party templates, MediTrack emphasizes formal database principles: an **InnoDB** schema normalized up to **Boyce-Codd Normal Form (BCNF)**, strict **Referential Integrity** using foreign keys with `ON DELETE RESTRICT` to prevent orphaned consultation notes, **B-Tree composite indexing** for high-speed chronological timeline queries, **Database Views** for secure analytical role segregation, **ACID transactions** with savepoints, **Stored Procedures and Deterministic Functions**, **Explicit Cursors** for row-by-row batch processing, and automated **Database Triggers** that capture diagnosis modifications into a tamper-proof audit table.*
>
> *All database operations are verified against live SQL queries and Spring Boot unit tests. Thank you, and I am ready to demonstrate the system and answer your questions."*

---

## 2. Five-Minute Technical Workflow Explanation

> *"To explain how MediTrack functions from end to end: the architecture follows a classic 3-Tier model consisting of a Presentation Tier, an Application Tier, and a Database Persistence Tier.*
>
> *When the Spring Boot application boots on port 8080, HikariCP establishes a connection pool to MySQL on port 3306. Our `DataInitializer` component checks if the database contains records; if empty, it populates initial relational data representing doctors, patients, chronic illnesses, and consultations.*
>
> *In the browser, when a user accesses the **Dashboard**, the frontend issues asynchronous `fetch` calls to `/api/dashboard/stats` and `/recent-patients`. The backend executes optimized `COUNT(*)` and `findTop5ByOrderByPatientIdDesc()` queries, populating real-time metrics dynamically.*
>
> *When registering a new patient, the form data is sent as a JSON payload to `POST /api/patients`. The backend validates the inputs using Jakarta Validation annotations, and Hibernate issues an `INSERT` to MySQL. At the database level, our `BEFORE INSERT` trigger `trg_patients_validate_dob_insert` verifies that the date of birth cannot be in the future, signaling error state `45000` if violated.*
>
> *A key DBMS highlight is our **Referential Integrity Guard**. If a staff member attempts to delete **Patient #1 (John Doe)**, the application executes a foreign key pre-check across Encounters, Allergies, History, and Medications. Because active records exist, the operation is blocked with a 409 Conflict exception. Conversely, deleting **Patient #5 (Lucas Gray)**—who has zero linked clinical encounters—succeeds cleanly, illustrating referential consistency.*
>
> *When recording a clinical consultation in the **Encounters** tab, the doctor selects a patient and attending clinician. The encounter is persisted via `POST /api/encounters`. Instantly upon database insertion, our MySQL trigger `trg_after_encounter_insert` executes inside the engine and writes an immutable audit record into `Encounter_Audit`.*
>
> *Finally, clicking **View Details** on any patient coordinates four relational queries across Patients, Allergies, Medical_History, and Encounters, assembling a comprehensive clinical dossier for clinical decision-making. Through this architecture, every action in the UI directly exercises relational database constraints."*

---

## 3. Top 30 Likely Viva Questions & Model Answers

### Category A: Database Design & ER Modeling

#### Q1: What is the cardinality between Patients and Encounters in MediTrack?
**Answer**: It is a **One-to-Many (1:N)** relationship. One patient can have zero, one, or multiple clinical encounters over time, but each encounter record belongs to exactly one registered patient.

#### Q2: What is the difference between an Entity and an Attribute in your project?
**Answer**: An **Entity** is a real-world object about which data is collected (e.g. `Patients`, `Clinicians`, `Encounters`). An **Attribute** is a property or characteristic describing that entity (e.g. `date_of_birth`, `gender`, `blood_group` describe a `Patient`).

#### Q3: Why is `encounter_id` used as a surrogate key instead of a composite natural key?
**Answer**: A surrogate key (`INT AUTO_INCREMENT`) is compact, immutable, and faster to join. A natural key would require a composite of `(patient_id, clinician_id, encounter_date)`, which consumes more index storage and creates wider foreign key references in child tables.

---

### Category B: Normalization & BCNF

#### Q4: What normal form does your database satisfy, and why?
**Answer**: MediTrack satisfies **Boyce-Codd Normal Form (BCNF)**. In every table, all attributes are atomic (1NF), there are no partial key dependencies (2NF), no transitive dependencies (3NF), and for every non-trivial functional dependency $X \rightarrow Y$, the determinant $X$ is a candidate key (superkey).

#### Q5: Can you give an example of an insertion or update anomaly you prevented through normalization?
**Answer**: If clinician specializations were stored inside the `Encounters` table, every time Dr. Sarah Jenkins changed her specialty or phone number, multiple encounter records would need updating (update anomaly). If a new clinician joined who had not yet conducted any encounters, they could not be recorded without inserting NULL patient data (insertion anomaly). Separating `Clinicians` into its own table eliminates both anomalies.

#### Q6: What is a Functional Dependency? Give one from your project.
**Answer**: A functional dependency $X \rightarrow Y$ means the value of attribute $X$ uniquely determines the value of attribute $Y$. In the `Patients` table:
$$\text{patient\_id} \rightarrow \{\text{name, date\_of\_birth, gender, phone, email, address, blood\_group}\}$$

---

### Category C: Constraints & Referential Integrity

#### Q7: What foreign key constraint rule did you use, and why?
**Answer**: We used `ON DELETE RESTRICT ON UPDATE CASCADE`. `ON DELETE RESTRICT` prevents accidental deletion of a parent row (e.g. a patient or doctor) if dependent child rows (e.g. consultation encounters or prescriptions) exist, preventing orphaned records.

#### Q8: Why did your original CHECK constraint on `date_of_birth` fail in MySQL?
**Answer**: MySQL prohibits non-deterministic functions (such as `CURDATE()`, `CURRENT_DATE()`, or `NOW()`) inside `CHECK` constraints, throwing `ERROR 3814`. Check constraints must be deterministic. We resolved this by implementing MySQL `BEFORE INSERT` and `BEFORE UPDATE` triggers that evaluate `NEW.date_of_birth > CURDATE()` dynamically.

#### Q9: What deterministic CHECK constraints are implemented in your schema?
**Answer**: 
1. `chk_patient_gender`: `CHECK (gender IN ('Male', 'Female', 'Other'))`
2. `chk_allergy_severity`: `CHECK (severity IN ('Mild', 'Moderate', 'Severe'))`
3. `chk_history_status`: `CHECK (status IN ('Active', 'Resolved', 'Chronic'))`
4. `chk_medication_dates`: `CHECK (end_date IS NULL OR end_date >= start_date)`
5. `chk_encounter_diagnosis`: `CHECK (CHAR_LENGTH(TRIM(diagnosis)) > 0)`

---

### Category D: Indexes & Views

#### Q10: What is a composite index and why did you create one on Encounters?
**Answer**: A composite index indexes multiple columns together. We created `idx_encounters_patient_date` on `(patient_id, encounter_date DESC)`. This allows MySQL to retrieve a specific patient's consultations pre-sorted chronologically using an **index range scan** without requiring an in-memory or on-disk `Using filesort`.

#### Q11: What is the underlying data structure of your MySQL indexes?
**Answer**: **B+ Tree** (B-Tree). It maintains sorted data with balanced search paths, providing $O(\log N)$ time complexity for exact matches and efficient sequential traversal for range scans.

#### Q12: What is the difference between a table and a view?
**Answer**: A table physically stores data on disk. A view is a virtual table defined by an underlying SQL query; it does not store data itself (unless materialized). In MediTrack, `vw_patient_summary` aggregates clinical visit counts while masking private contact addresses.

---

### Category E: DCL & TCL

#### Q13: Explain the difference between DCL and DDL.
**Answer**: **DDL (Data Definition Language)** defines database structure (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`). **DCL (Data Control Language)** manages user permissions and security (`GRANT`, `REVOKE`).

#### Q14: How did you implement the Principle of Least Privilege?
**Answer**: We created two separate users in `03_dcl_permissions.sql`:
- `meditrack_app`: Has CRUD permissions on operational tables and execution rights on procedures.
- `meditrack_reporter`: Restricted strictly to `SELECT` permissions on database views (`vw_patient_summary`), blocking direct access to raw clinical tables or audit logs.

#### Q15: What is a SAVEPOINT in TCL and when is it useful?
**Answer**: A `SAVEPOINT` creates a checkpoint within a transaction. If a subsequent non-fatal statement fails, the application can execute `ROLLBACK TO SAVEPOINT` to undo only the failed step without canceling the entire transaction.

---

### Category F: Advanced SQL & Window Functions

#### Q16: What is the difference between `INNER JOIN` and `LEFT JOIN` in your project?
**Answer**: 
- `INNER JOIN` returns rows only when there is a match in both tables (e.g. querying encounters with patient details returns only patients who have visits).
- `LEFT JOIN` returns all rows from the left table regardless of whether matching records exist on the right (e.g. listing all patients alongside encounter data retains **Patient #5 Lucas Gray**, showing NULL for encounter fields).

#### Q17: What does the `HAVING` clause do that `WHERE` cannot?
**Answer**: `WHERE` filters individual rows before aggregation. `HAVING` filters aggregated groups after `GROUP BY`. In MediTrack, we use `HAVING COUNT(encounter_id) > 1` to identify clinicians who have handled multiple consultations.

#### Q18: What window functions are demonstrated in your project?
**Answer**: `ROW_NUMBER()` to sequence consultation visits chronologically per patient (`PARTITION BY patient_id ORDER BY encounter_date DESC`), and `DENSE_RANK()` to rank clinicians by consultation workload.

---

### Category G: Procedures, Functions, Cursors & Triggers

#### Q19: What is the difference between a Stored Procedure and a Stored Function?
**Answer**: A Stored Procedure is executed with `CALL`, can have `IN`, `OUT`, and `INOUT` parameters, and does not have to return a value. A Stored Function returns a single scalar value via `RETURNS` and can be called directly within a SQL `SELECT` expression (e.g. `SELECT name, fn_patient_encounter_count(patient_id) FROM Patients`).

#### Q20: What is an explicit Cursor and what handler did you use with it?
**Answer**: A cursor allows row-by-row iteration over an active query result set. We declared `cur_patient_encounters` and paired it with `DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;` so the loop terminates gracefully when all rows are fetched.

#### Q21: What is the difference between a `BEFORE` trigger and an `AFTER` trigger?
**Answer**: A `BEFORE` trigger executes before the data modification is committed to the table; it is ideal for validation and data sanitization (e.g. our `BEFORE INSERT` trigger checking `NEW.date_of_birth <= CURDATE()`). An `AFTER` trigger executes after the data change succeeds; it is ideal for audit logging (e.g. logging modified diagnosis into `Encounter_Audit`).

---

### Category H: Query Optimization & EXPLAIN

#### Q22: What does `EXPLAIN` show, and what `type` value indicates an index scan?
**Answer**: `EXPLAIN` displays the MySQL query optimizer's execution plan. An unindexed search shows `type: ALL` (full table scan). An indexed search shows `type: range` or `type: ref`, indicating that MySQL traversed the B-Tree index rather than scanning the entire table.

#### Q23: Why does a query with `WHERE name LIKE '%emily%'` fail to use a B-Tree index?
**Answer**: A leading wildcard (`%emily`) prevents the B-Tree from performing prefix-based binary tree traversal because the starting character is unknown. The engine must scan every row (`type: ALL`). If rewritten as `WHERE name LIKE 'emily%'`, the B-Tree index is utilized (`type: range`).

---

### Category I: Technology Stack & Implementation

#### Q24: Why was Spring Boot chosen over standard Java Servlets or PHP?
**Answer**: Spring Boot provides production-grade dependency injection, automated transaction management (`@Transactional`), integrated connection pooling (`HikariCP`), declarative ORM (`Spring Data JPA`), and consistent exception handling via `@RestControllerAdvice`.

#### Q25: What is the role of HikariCP in MediTrack?
**Answer**: HikariCP is a lightweight, high-performance JDBC connection pool. Instead of opening and closing an expensive TCP/IP socket connection to MySQL for every HTTP request, HikariCP maintains pre-established database connections, lowering latency.

#### Q26: Why does your project use Vanilla JavaScript instead of React or Angular?
**Answer**: Vanilla JS keeps the project lightweight, self-contained, and easy to run without requiring Node.js, `npm install`, or complex build pipelines. It demonstrates pure DOM manipulation and the native `fetch()` API.

---

### Category J: Architecture & Future Scope

#### Q27: How does your application prevent SQL Injection?
**Answer**: Spring Data JPA and Hibernate use **Parameterized PreparedStatements** under the hood. User inputs are bound as parameter placeholders (`?` or `:query`) rather than concatenated directly into SQL strings, preventing injection attacks.

#### Q28: How does your backend communicate that a patient cannot be deleted?
**Answer**: `PatientService` checks dependent counts; if positive, it throws `DatabaseConstraintException`. `GlobalExceptionHandler` catches this exception and returns an HTTP 409 Conflict status code with a descriptive JSON message, which the frontend renders as a red alert banner.

#### Q29: What was the most challenging database problem you encountered and resolved?
**Answer**: Resolving `ERROR 3814` and `ERROR 1824`. MySQL rejected `CHECK (date_of_birth <= CURRENT_DATE)` because `CURRENT_DATE` is non-deterministic. The failure prevented the `Patients` table from creating, causing all dependent foreign key tables to fail. We resolved this by refactoring non-deterministic validations into MySQL `BEFORE INSERT` and `BEFORE UPDATE` triggers.

#### Q30: What future improvements would you recommend for MediTrack?
**Answer**:
1. Implement role-based JWT authentication (doctor vs receptionist login).
2. Add a dedicated prescription UI form that writes directly to the `Medications` table.
3. Partition the `Encounter_Audit` and `Encounters` tables by year for long-term historical scalability.
