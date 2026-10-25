package com.clinical.records.repository;

import com.clinical.records.entity.Clinician;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClinicianRepository extends JpaRepository<Clinician, Long> {
    List<Clinician> findAllByOrderByNameAsc();
}
