package com.clinical.records.service;

import com.clinical.records.entity.Clinician;
import com.clinical.records.exception.ResourceNotFoundException;
import com.clinical.records.repository.ClinicianRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ClinicianService {

    private final ClinicianRepository clinicianRepository;

    public ClinicianService(ClinicianRepository clinicianRepository) {
        this.clinicianRepository = clinicianRepository;
    }

    public List<Clinician> getAllClinicians() {
        return clinicianRepository.findAllByOrderByNameAsc();
    }

    public Clinician getClinicianById(Long id) {
        return clinicianRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Clinician not found with ID: " + id));
    }

    @Transactional
    public Clinician createClinician(Clinician clinician) {
        return clinicianRepository.save(clinician);
    }
}
