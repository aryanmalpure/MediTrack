package com.clinical.records.repository;

import com.clinical.records.entity.Medication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MedicationRepository extends JpaRepository<Medication, Long> {
    List<Medication> findAllByOrderByMedicationNameAsc();
    List<Medication> findByPatientPatientId(Long patientId);
    long countByPatientPatientId(Long patientId);
}
