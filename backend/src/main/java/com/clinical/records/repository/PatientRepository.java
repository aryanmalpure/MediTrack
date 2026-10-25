package com.clinical.records.repository;

import com.clinical.records.entity.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {

    List<Patient> findAllByOrderByPatientIdDesc();

    List<Patient> findTop5ByOrderByPatientIdDesc();

    @Query("SELECT p FROM Patient p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%')) OR CAST(p.patientId AS string) = :query")
    List<Patient> searchPatients(@Param("query") String query);
}
