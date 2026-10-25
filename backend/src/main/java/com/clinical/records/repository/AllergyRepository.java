package com.clinical.records.repository;

import com.clinical.records.entity.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AllergyRepository extends JpaRepository<Allergy, Long> {
    List<Allergy> findByPatientPatientId(Long patientId);
    long countByPatientPatientId(Long patientId);
}
