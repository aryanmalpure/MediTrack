package com.clinical.records.repository;

import com.clinical.records.entity.MedicalHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MedicalHistoryRepository extends JpaRepository<MedicalHistory, Long> {
    List<MedicalHistory> findByPatientPatientId(Long patientId);
    long countByPatientPatientId(Long patientId);
}
