# MediTrack – Relational Database Design & Normalization Specification

This document provides the formal mathematical and relational database specifications for **MediTrack – Patient Health Records**, including entity definitions, functional dependencies, candidate key analysis, and Boyce-Codd Normal Form (BCNF) justification.

---

## 1. Relational Schema Specifications

Database Name: `clinical_patient_db`  
Storage Engine: `InnoDB`  
Default Character Set: `utf8mb4`  

### 1.1 Relation: `Patients`
$$\text{Patients}(\underline{\text{patient\_id}}, \text{name}, \text{date\_of\_birth}, \text{gender}, \text{phone}, \text{email}, \text{address}, \text{blood\_group}, \text{created\_at})$$

- **Primary Key**: $\{\text{patient\_id}\}$
- **Alternate (Candidate) Key**: $\{\text{email}\}$ (Unique non-null identifier)
- **Foreign Keys**: None
- **Domain Constraints**:
  - `gender` $\in \{\text{'Male'}, \text{'Female'}, \text{'Other'}\}$
  - `date_of_birth` $\le \text{CURRENT\_DATE}$

### 1.2 Relation: `Clinicians`
$$\text{Clinicians}(\underline{\text{clinician\_id}}, \text{name}, \text{specialization}, \text{phone}, \text{email})$$

- **Primary Key**: $\{\text{clinician\_id}\}$
- **Alternate Key**: $\{\text{email}\}$
- **Foreign Keys**: None

### 1.3 Relation: `Encounters`
$$\text{Encounters}(\underline{\text{encounter\_id}}, \text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}, \text{diagnosis}, \text{symptoms}, \text{treatment\_notes})$$

- **Primary Key**: $\{\text{encounter\_id}\}$
- **Candidate Keys**: $\{\text{encounter\_id}\}$, $\{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}\}$
- **Foreign Keys**:
  - $\text{patient\_id} \rightarrow \text{Patients}(\text{patient\_id})$
  - $\text{clinician\_id} \rightarrow \text{Clinicians}(\text{clinician\_id})$

### 1.4 Relation: `Allergies`
$$\text{Allergies}(\underline{\text{allergy\_id}}, \text{patient\_id}, \text{allergen}, \text{reaction}, \text{severity})$$

- **Primary Key**: $\{\text{allergy\_id}\}$
- **Candidate Keys**: $\{\text{allergy\_id}\}$, $\{\text{patient\_id}, \text{allergen}\}$
- **Foreign Keys**: $\text{patient\_id} \rightarrow \text{Patients}(\text{patient\_id})$
- **Domain Constraint**: `severity` $\in \{\text{'Mild'}, \text{'Moderate'}, \text{'Severe'}\}$

### 1.5 Relation: `Medical_History`
$$\text{Medical\_History}(\underline{\text{history\_id}}, \text{patient\_id}, \text{condition\_name}, \text{diagnosis\_date}, \text{status}, \text{notes})$$

- **Primary Key**: $\{\text{history\_id}\}$
- **Candidate Keys**: $\{\text{history\_id}\}$, $\{\text{patient\_id}, \text{condition\_name}, \text{diagnosis\_date}\}$
- **Foreign Keys**: $\text{patient\_id} \rightarrow \text{Patients}(\text{patient\_id})$

### 1.6 Relation: `Medications`
$$\text{Medications}(\underline{\text{medication\_id}}, \text{patient\_id}, \text{medication\_name}, \text{dosage}, \text{start\_date}, \text{end\_date}, \text{instructions})$$

- **Primary Key**: $\{\text{medication\_id}\}$
- **Foreign Keys**: $\text{patient\_id} \rightarrow \text{Patients}(\text{patient\_id})$
- **Domain Constraint**: $\text{end\_date} \text{ IS NULL OR } \text{end\_date} \ge \text{start\_date}$

### 1.7 Relation: `Encounter_Audit`
$$\text{Encounter\_Audit}(\underline{\text{audit\_id}}, \text{encounter\_id}, \text{patient\_id}, \text{action\_type}, \text{old\_diagnosis}, \text{new\_diagnosis}, \text{old\_treatment\_notes}, \text{new\_treatment\_notes}, \text{changed\_at}, \text{changed\_by})$$

- **Primary Key**: $\{\text{audit\_id}\}$
- **Foreign Keys**: None (Independent immutable audit stream)

---

## 2. Functional Dependency (FD) Analysis

### Relation `Patients`:
- $FD_1: \{\text{patient\_id}\} \rightarrow \{\text{name}, \text{date\_of\_birth}, \text{gender}, \text{phone}, \text{email}, \text{address}, \text{blood\_group}, \text{created\_at}\}$
- $FD_2: \{\text{email}\} \rightarrow \{\text{patient\_id}, \text{name}, \text{date\_of\_birth}, \text{gender}, \text{phone}, \text{address}, \text{blood\_group}, \text{created\_at}\}$
- *Candidate Keys*: $\{\text{patient\_id}\}$, $\{\text{email}\}$.

### Relation `Clinicians`:
- $FD_1: \{\text{clinician\_id}\} \rightarrow \{\text{name}, \text{specialization}, \text{phone}, \text{email}\}$
- $FD_2: \{\text{email}\} \rightarrow \{\text{clinician\_id}, \text{name}, \text{specialization}, \text{phone}\}$
- *Candidate Keys*: $\{\text{clinician\_id}\}$, $\{\text{email}\}$.

### Relation `Encounters`:
- $FD_1: \{\text{encounter\_id}\} \rightarrow \{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}, \text{diagnosis}, \text{symptoms}, \text{treatment\_notes}\}$
- $FD_2: \{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}\} \rightarrow \{\text{encounter\_id}, \text{diagnosis}, \text{symptoms}, \text{treatment\_notes}\}$
- *Candidate Keys*: $\{\text{encounter\_id}\}$, $\{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}\}$.

### Relation `Allergies`:
- $FD_1: \{\text{allergy\_id}\} \rightarrow \{\text{patient\_id}, \text{allergen}, \text{reaction}, \text{severity}\}$
- $FD_2: \{\text{patient\_id}, \text{allergen}\} \rightarrow \{\text{allergy\_id}, \text{reaction}, \text{severity}\}$
- *Candidate Keys*: $\{\text{allergy\_id}\}$, $\{\text{patient\_id}, \text{allergen}\}$.

### Relation `Medical_History`:
- $FD_1: \{\text{history\_id}\} \rightarrow \{\text{patient\_id}, \text{condition\_name}, \text{diagnosis\_date}, \text{status}, \text{notes}\}$
- *Candidate Keys*: $\{\text{history\_id}\}$.

### Relation `Medications`:
- $FD_1: \{\text{medication\_id}\} \rightarrow \{\text{patient\_id}, \text{medication\_name}, \text{dosage}, \text{start\_date}, \text{end\_date}, \text{instructions}\}$
- *Candidate Keys*: $\{\text{medication\_id}\}$.

---

## 3. Step-by-Step Normalization Proof

### 3.1 First Normal Form (1NF)
A relation $R$ is in **1NF** if and only if all underlying domains contain only atomic (indivisible) values, and there are no repeating groups.
- All attributes (`name`, `date_of_birth`, `phone`, `dosage`, etc.) are scalar.
- Patient multiple phone numbers or multiple addresses are normalized.
- Consultations, allergies, histories, and medications are factored out into individual 1:N relations rather than CSV or array fields in `Patients`.
- **Verdict**: The schema strictly satisfies **1NF**.

### 3.2 Second Normal Form (2NF)
A relation $R$ is in **2NF** if and only if it is in 1NF and no non-prime attribute is partially functionally dependent on any candidate key of $R$.
- In relations with single-attribute candidate keys (`patient_id`, `clinician_id`, `history_id`, `medication_id`), partial dependencies are mathematically impossible.
- In `Encounters`, the composite candidate key is $\{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}\}$. Every non-prime attribute (`diagnosis`, `symptoms`, `treatment\_notes`) depends on the entire consultation instance, not on `patient_id` alone or `clinician_id` alone. Patient demographics (`name`, `dob`) reside strictly in `Patients`; clinician specialty resides strictly in `Clinicians`.
- In `Allergies`, severity and reaction describe the specific patient-allergen pair.
- **Verdict**: The schema strictly satisfies **2NF**.

### 3.3 Third Normal Form (3NF)
A relation $R$ is in **3NF** if and only if whenever a non-trivial functional dependency $X \rightarrow A$ holds in $R$, either:
1. $X$ is a superkey of $R$, OR
2. $A$ is a prime attribute (member of a candidate key) of $R$.

Checking dependencies:
- In `Patients`, `phone` does not determine `address`, nor does `blood_group` determine `gender`. There are no transitive dependencies $X \rightarrow Y \rightarrow Z$ where $Y$ is a non-key attribute.
- In `Encounters`, `clinician_id` does not determine `diagnosis`, nor does `diagnosis` determine `treatment_notes`.
- **Verdict**: The schema strictly satisfies **3NF**.

### 3.4 Boyce-Codd Normal Form (BCNF)
A relation $R$ is in **BCNF** if and only if for every non-trivial functional dependency $X \rightarrow Y$, the determinant $X$ is a **superkey** of $R$.

Let us verify every functional dependency in every relation:

1. **`Patients`**:
   - $FD_1: \{\text{patient\_id}\} \rightarrow \text{All attributes}$. Determinant $\{\text{patient\_id}\}$ is a superkey. $\checkmark$
   - $FD_2: \{\text{email}\} \rightarrow \text{All attributes}$. Determinant $\{\text{email}\}$ is a candidate key, hence a superkey. $\checkmark$
   - *Result: Patients is in BCNF.*

2. **`Clinicians`**:
   - $FD_1: \{\text{clinician\_id}\} \rightarrow \text{All attributes}$. Determinant is a superkey. $\checkmark$
   - $FD_2: \{\text{email}\} \rightarrow \text{All attributes}$. Determinant is a candidate key. $\checkmark$
   - *Result: Clinicians is in BCNF.*

3. **`Encounters`**:
   - $FD_1: \{\text{encounter\_id}\} \rightarrow \text{All attributes}$. Determinant is a superkey. $\checkmark$
   - $FD_2: \{\text{patient\_id}, \text{clinician\_id}, \text{encounter\_date}\} \rightarrow \text{All attributes}$. Determinant is a candidate key. $\checkmark$
   - *Result: Encounters is in BCNF.*

4. **`Allergies`**:
   - $FD_1: \{\text{allergy\_id}\} \rightarrow \text{All attributes}$. Determinant is a superkey. $\checkmark$
   - $FD_2: \{\text{patient\_id}, \text{allergen}\} \rightarrow \text{All attributes}$. Determinant is a candidate key. $\checkmark$
   - *Result: Allergies is in BCNF.*

5. **`Medical_History`**:
   - $FD_1: \{\text{history\_id}\} \rightarrow \text{All attributes}$. Determinant is a superkey. $\checkmark$
   - *Result: Medical_History is in BCNF.*

6. **`Medications`**:
   - $FD_1: \{\text{medication\_id}\} \rightarrow \text{All attributes}$. Determinant is a superkey. $\checkmark$
   - *Result: Medications is in BCNF.*

**Conclusion:** Every single determinant in the schema is a valid candidate key or superkey. Therefore, the MediTrack database design is mathematically proven to be in **Boyce-Codd Normal Form (BCNF)**.
