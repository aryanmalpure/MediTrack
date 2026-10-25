package com.clinical.records.repository;

import com.clinical.records.entity.Encounter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EncounterRepository extends JpaRepository<Encounter, Long> {

    List<Encounter> findByPatientPatientIdOrderByEncounterDateDesc(Long patientId);

    long countByPatientPatientId(Long patientId);

    long countByClinicianClinicianId(Long clinicianId);
}
