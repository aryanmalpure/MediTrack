# MediTrack – Patient Health Records
## Document 1: Project Overview & Technology Stack

---

## 1. Executive Summary

**MediTrack** is an academic, relational Database Management System (DBMS) web application developed to store, organize, and retrieve clinical encounters, patient demographic profiles, known allergies, and medical histories. Designed for an undergraduate DBMS curriculum, MediTrack demonstrates core and advanced relational database concepts through a clean, reliable, and functional full-stack architecture.

---

## 2. Problem Statement & Motivation

In traditional and paper-based healthcare environments, medical records suffer from several operational and database challenges:
1. **Fragmented Patient History**: Consultations, allergy details, and chronic conditions are often scattered across different physical logbooks or disconnected systems.
2. **Accidental Record Deletion (Orphaned Records)**: Deleting a patient record without referential integrity checks leaves consultation histories and diagnosis notes orphaned, compromising medical history tracking.
3. **Absence of Audit Logging**: Critical clinical diagnosis changes are often overwritten without logging who altered the diagnosis or when the change occurred.
4. **Slow Retrieval Under Scale**: Sequential table scans for patient names or chronological consultations result in severe latency without proper B-Tree single and composite indexing.

### The MediTrack Solution
MediTrack addresses these challenges by implementing an **InnoDB-backed MySQL relational database** with strict foreign keys (`ON DELETE RESTRICT`), automated event triggers for audit logging, B-Tree composite indexing for chronological lookups, and a 3-tier Java Spring Boot architecture connected to a lightweight, responsive browser interface.

---

## 3. Core Project Objectives

The project accomplishes four primary technical objectives:
1. **Academic Demonstration of DBMS Syllabi**: Practical implementation of DDL constraints, DCL user privileges, TCL transactions, BCNF normalization, stored procedures, functions, explicit cursors, triggers, views, and query execution plans (`EXPLAIN`).
2. **Referential Integrity Enforcement**: Implementing `ON DELETE RESTRICT` foreign key rules so patient records cannot be deleted if active consultations, medical history, or allergies exist.
3. **Data Security & Separation of Concerns**: Utilizing database-level user privileges to segregate application runtime access (`meditrack_app`) from read-only analytical reporting (`meditrack_reporter`).
4. **Clean Engineering Standards**: A layered architecture (Entity &rarr; Repository &rarr; Service &rarr; Controller) ensuring business rules and database constraints are validated at both the application and database tiers.

---

## 4. User Personas & Responsibilities

| User Role | Responsibilities within MediTrack | Interacting System Layer |
|---|---|---|
| **Attending Clinician (Doctor)** | Conducts consultations, documents symptoms, records diagnoses, prescribes treatment notes, and examines the full patient clinical dossier (allergies, chronic illnesses, prior visits). | Frontend Encounters & Dossier Views |
| **Front-Desk Healthcare Staff** | Registers newly admitted patients, updates contact info and addresses, searches patient directories, and filters recent admissions. | Frontend Patients & Dashboard Tabs |
| **Database Administrator (DBA)** | Maintains database constraints, executes schema scripts, defines views, configures user permissions (`GRANT`/`REVOKE`), and tunes query performance with `EXPLAIN`. | MySQL Server CLI / MySQL Workbench |
| **Clinical Auditor / Analyst** | Reads non-sensitive, aggregated health statistics through protected database views (`vw_patient_summary`, `vw_patient_encounter_history`) and reviews data change logs in `Encounter_Audit`. | MySQL Reporter Role (`meditrack_reporter`) |

---

## 5. Scope & Current Limitations

### In Scope (Fully Implemented & Verified):
- **Dashboard**: Real-time total patient count, total clinical encounter count, and list of the top 5 most recently registered patients loaded from live database queries.
- **Patient Management**: Full CRUD operations:
  - Register new patient with validation (`name`, `date_of_birth`, `gender`, `phone`, `email`, `blood_group`, `address`).
  - Search patients by name substring or exact patient ID.
  - Update demographic and contact info.
  - Safe deletion: Patient #5 (**Lucas Gray**) with 0 linked clinical records deletes cleanly; Patient #1 (**John Doe**) with active encounters/allergies is safely rejected by database referential integrity.
- **Clinician Management**: Registration of clinicians with medical specializations and real-time listing.
- **Clinical Encounters**: Recording new consultations linking selected patient ID and clinician ID with date/time, diagnosis, symptoms, and treatment notes. Chronological consultation timeline displayed in real-time.
- **Comprehensive Patient Dossier**: Integrated view showing patient demographic card, known allergies table, past medical history table, and past clinical encounters history.
- **Database Subsystem**: All 7 InnoDB tables, 4 date-validation triggers, 3 audit triggers, 2 views, composite indexes, 4 stored procedures/functions, and 12 complex SQL queries.

### Current Limitations & Out of Scope:
- **No User Authentication/Login**: In accordance with college project requirements, user authentication (OAuth2 / Spring Security) and payment gateways are omitted to focus on relational DBMS concepts.
- **Medications UI Form**: The `Medications` table, JPA entity, repository methods, and referential integrity deletion checks are fully implemented in the database and backend; however, prescriptions are recorded via the `treatmentNotes` text field in the Encounter UI rather than a dedicated multi-table prescription form.
- **Single-Tenant Deployment**: MediTrack is designed for single-facility or clinic use on a local area network or local machine.

---

## 6. Technology Stack Analysis

Every technology listed below is present and actively used in the MediTrack codebase:

```text
+---------------------------------------------------------------+
|                      BROWSER CLIENT                           |
|        HTML5  |  CSS3 (Custom Minimalist)  |  JavaScript ES6  |
+-------------------------------+-------------------------------+
                                | HTTP REST Calls (JSON)
                                v
+---------------------------------------------------------------+
|                   SPRING BOOT BACKEND (Java 21/25)            |
|  - Embedded Tomcat Web Server (Port 8080)                     |
|  - Spring Web (REST Controllers & Exception Handlers)         |
|  - Spring Data JPA & Hibernate 6.5.3 (ORM / Repositories)     |
|  - HikariCP Connection Pooling                                |
+-------------------------------+-------------------------------+
                                | JDBC Protocol (mysql-connector-j)
                                v
+---------------------------------------------------------------+
|                   MYSQL DATABASE SERVER 9.6.0                 |
|  - Database: clinical_patient_db (InnoDB Storage Engine)      |
|  - ACID Transactions, B-Tree Indexes, Views, Cursors, Triggers|
+---------------------------------------------------------------+
```

### Detailed Component Breakdown:

1. **Frontend**:
   - **HTML5**: Semantic document structure for tables, modals, input forms, and responsive containers (`index.html`).
   - **CSS3**: Lightweight, responsive custom stylesheet (`css/style.css`). Light background (`#f4f7f6`), dark-blue headers (`#0d3b66`), and clear contrast without bulky third-party libraries (no Bootstrap, Tailwind, or jQuery).
   - **Vanilla JavaScript (ES6)**: Pure asynchronous client-side scripting (`js/app.js`) utilizing the native `fetch()` API, `async/await`, DOM manipulation, and HTML sanitization.

2. **Backend Framework**:
   - **Java 17+ (Compiled & Verified on Java 25.0.1)**: Modern Java runtime.
   - **Spring Boot 3.3.5**: Production-ready enterprise backend framework handling request routing, JSON serialization via Jackson, dependency injection, and transaction boundaries.
   - **Embedded Apache Tomcat 10.1.31**: Embedded web servlet container listening on `http://localhost:8080`.

3. **Database & Persistence**:
   - **MySQL Server 8.0+ / 9.6.0**: Relational database engine utilizing **InnoDB** for full ACID compliance, foreign key constraint enforcement, and row-level locking.
   - **Spring Data JPA & Hibernate ORM 6.5.3**: Object-Relational Mapping framework translating Java entity objects into SQL queries and mapping MySQL result sets into POJOs.
   - **HikariCP**: High-performance JDBC connection pool managing database connections between Spring Boot and MySQL.
   - **MySQL Connector/J (com.mysql:mysql-connector-j)**: Official Type-4 JDBC driver executing SQL commands over TCP/IP port `3306`.
   - **H2 Database (In-Memory)**: Dedicated test database used exclusively by `mvn test` in `ClinicalPatientRecordsApplicationTests.java` to verify business logic and constraint handling in isolation without mutating production data.

4. **Build & Package Management**:
   - **Apache Maven 3.8+**: Build automation tool managing project dependencies (`pom.xml`), compiling 29 Java source files, executing unit tests, and packaging the standalone runnable JAR (`target/clinical-patient-records-1.0.0.jar`).
